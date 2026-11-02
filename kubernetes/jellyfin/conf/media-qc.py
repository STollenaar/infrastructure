#!/usr/bin/env python3
"""media-qc: checks imported movies for missing English and burned-in watermarks.

Flow
  1. Radarr calls POST /hooks/radarr when it imports or upgrades a movie (the
     webhook is registered by this service on startup, see ensure_webhook).
  2. The file is queued in Postgres (table `scans`). The queue is drained by one
     worker using SELECT ... FOR UPDATE SKIP LOCKED, woken by LISTEN/NOTIFY. Webhook
     items wait WEBHOOK_DELAY_MINUTES first, so Bazarr has time to add subtitles.
  3. Each file gets two checks:
       language  - ffprobe audio/subtitle tags plus subtitle files next to the movie.
       picture   - FRAME_COUNT frames sent to a vision model through LiteLLM, which
                   reports uploader watermarks, non-English burned-in subtitles and
                   camcorder rips.
  4. Anything flagged waits on the review page (GET /). Nothing is removed until a
     person presses Reject, which blocklists the release in Radarr, deletes the
     file and starts a new search.

POST /api/backfill queues every movie Radarr has a file for; the one-time
media-qc-backfill Job calls it. Already-queued files are skipped, so it is safe to
call again.
"""

from __future__ import annotations

import base64
import html
import json
import os
import re
import shutil
import subprocess
import sys
import threading
import time
import traceback
import urllib.error
import urllib.parse
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import psycopg
from psycopg.rows import dict_row
from psycopg.types.json import Jsonb


def env(name: str, default: str | None = None) -> str:
    value = os.environ.get(name, default)
    if value is None:
        sys.exit(f"missing required environment variable {name}")
    return value


DATABASE_URL = env("DATABASE_URL")
RADARR_URL = env("RADARR_URL").rstrip("/")
RADARR_KEY = env("RADARR_KEY")
LITELLM_URL = env("LITELLM_URL").rstrip("/")
LITELLM_KEY = env("LITELLM_KEY")
VISION_MODEL = env("VISION_MODEL", "gemma4-26b")
WEBHOOK_URL = env("WEBHOOK_URL")  # how Radarr reaches this service
WEBHOOK_TOKEN = env("WEBHOOK_TOKEN")
WEBHOOK_NAME = env("WEBHOOK_NAME", "media-qc")
WEBHOOK_DELAY_MINUTES = int(env("WEBHOOK_DELAY_MINUTES", "30"))
FRAME_COUNT = int(env("FRAME_COUNT", "10"))
FRAME_WIDTH = int(env("FRAME_WIDTH", "1280"))
MIN_CONFIDENCE = float(env("MIN_CONFIDENCE", "0.6"))
# Foreign-language films rarely have an English dub; English subtitles count as
# "an English option" for them when this is on.
ALLOW_SUBS_FOR_FOREIGN = env("ALLOW_SUBS_FOR_FOREIGN", "true").lower() == "true"
MAX_ATTEMPTS = int(env("MAX_ATTEMPTS", "3"))
LLM_TIMEOUT = int(env("LLM_TIMEOUT", "900"))  # a cold model swap alone can take minutes
DATA_DIR = env("DATA_DIR", "/data")
PORT = int(env("PORT", "8080"))

FRAMES_DIR = os.path.join(DATA_DIR, "frames")
EN = {"en", "eng", "english"}
UNKNOWN_LANG = {"", "und", "unk", "unknown", "mis", "zxx", "mul"}
SUB_EXTS = (".srt", ".ass", ".ssa", ".vtt", ".sub", ".idx", ".sup")


def log(msg: str) -> None:
    print(time.strftime("%Y-%m-%d %H:%M:%S"), msg, flush=True)


# --------------------------------------------------------------------------- db

SCHEMA = """
create table if not exists scans (
    id            bigserial primary key,
    movie_file_id integer not null unique,
    movie_id      integer not null,
    title         text,
    path          text,
    source        text not null,               -- webhook | backfill | rescan
    priority      smallint not null default 1, -- 0 = new downloads first
    status        text not null default 'pending', -- pending | running | done | error | gone
    run_after     timestamptz not null default now(),
    attempts      integer not null default 0,
    enqueued_at   timestamptz not null default now(),
    started_at    timestamptz,
    finished_at   timestamptz,
    verdict       text,                        -- ok | flagged
    reasons       jsonb not null default '[]',
    language      jsonb,
    vision        jsonb,
    error         text,
    review        text,                        -- null | kept | rejected
    review_note   text,
    reviewed_at   timestamptz
);
create index if not exists scans_queue_idx on scans (priority, run_after, id) where status = 'pending';
create table if not exists settings (key text primary key, value text not null);
"""


def db() -> psycopg.Connection:
    return psycopg.connect(DATABASE_URL, autocommit=True, row_factory=dict_row)


def wait_for_db() -> None:
    while True:
        try:
            with db() as conn:
                conn.execute(SCHEMA)
                # Single worker: anything still 'running' was cut off by a restart.
                conn.execute("update scans set status = 'pending', run_after = now() where status = 'running'")
            return
        except psycopg.OperationalError as e:
            log(f"waiting for postgres: {e}")
            time.sleep(5)


def enqueue(conn, movie_file_id: int, movie_id: int, title: str | None, source: str) -> bool:
    """Queue a file. Webhooks re-queue a known file; backfill never does."""
    if source == "webhook":
        row = conn.execute(
            """insert into scans (movie_file_id, movie_id, title, source, priority, run_after)
               values (%s, %s, %s, 'webhook', 0, now() + make_interval(mins => %s))
               on conflict (movie_file_id) do update
                 set status = 'pending', source = 'webhook', priority = 0, attempts = 0,
                     run_after = excluded.run_after, review = null, error = null
                 where scans.status <> 'running'
               returning id""",
            (movie_file_id, movie_id, title, WEBHOOK_DELAY_MINUTES),
        ).fetchone()
    else:
        row = conn.execute(
            """insert into scans (movie_file_id, movie_id, title, source, priority)
               values (%s, %s, %s, %s, 1)
               on conflict (movie_file_id) do nothing returning id""",
            (movie_file_id, movie_id, title, source),
        ).fetchone()
    conn.execute("notify media_qc")
    return row is not None


def paused(conn) -> bool:
    row = conn.execute("select value from settings where key = 'paused'").fetchone()
    return bool(row and row["value"] == "true")


# ----------------------------------------------------------------------- radarr

def http_json(method: str, url: str, headers: dict, body=None, timeout: int = 60):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method, headers={
        "Content-Type": "application/json", "Accept": "application/json", **headers})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        raw = resp.read()
    return json.loads(raw) if raw else None


def radarr(method: str, path: str, body=None, **params):
    url = f"{RADARR_URL}/api/v3/{path}"
    if params:
        url += "?" + urllib.parse.urlencode(params)
    return http_json(method, url, {"X-Api-Key": RADARR_KEY}, body)


def ensure_webhook() -> None:
    """Create or update the Radarr Connect entry that calls /hooks/radarr."""
    url = f"{WEBHOOK_URL}?token={WEBHOOK_TOKEN}"
    existing = next((n for n in radarr("GET", "notification") if n["name"] == WEBHOOK_NAME), None)
    if existing is None:
        schema = next(s for s in radarr("GET", "notification/schema") if s["implementation"] == "Webhook")
        hook = dict(schema, name=WEBHOOK_NAME)
    else:
        hook = existing
    hook.update(onDownload=True, onUpgrade=True)
    for field in hook["fields"]:
        if field["name"] == "url":
            field["value"] = url
        elif field["name"] == "method":
            field["value"] = 1  # POST
    if existing is None:
        radarr("POST", "notification", hook, forceSave="true")
        log("registered Radarr webhook")
    else:
        radarr("PUT", f"notification/{hook['id']}", hook, forceSave="true")
        log("Radarr webhook up to date")


def ensure_webhook_forever() -> None:
    while True:
        try:
            ensure_webhook()
            return
        except Exception as e:  # Radarr may still be starting
            log(f"could not register Radarr webhook, retrying: {e}")
            time.sleep(60)


def reject_release(scan: dict) -> str:
    """Blocklist the release behind this file, delete the file, search again."""
    notes = []
    history = radarr("GET", "history/movie", movieId=scan["movie_id"]) or []
    imported = next((h for h in history if h["eventType"] == "downloadFolderImported"
                     and str(h.get("data", {}).get("fileId")) == str(scan["movie_file_id"])), None)
    grab = None
    if imported and imported.get("downloadId"):
        grabs = [h for h in history if h["eventType"] == "grabbed" and h.get("downloadId") == imported["downloadId"]]
        grab = max(grabs, key=lambda h: h["date"], default=None)
    if grab:
        radarr("POST", f"history/failed/{grab['id']}")
        notes.append(f"blocklisted '{grab['sourceTitle']}'")
    else:
        notes.append("no grab found in Radarr history (manual import?), release not blocklisted")
    try:
        radarr("DELETE", f"moviefile/{scan['movie_file_id']}")
        notes.append("file deleted")
    except urllib.error.HTTPError as e:
        if e.code != 404:
            raise
        notes.append("file was already gone")
    radarr("POST", "command", {"name": "MoviesSearch", "movieIds": [scan["movie_id"]]})
    notes.append("search started")
    return "; ".join(notes)


# --------------------------------------------------------------- language check

def norm_lang(stream: dict) -> tuple[str | None, str]:
    tags = {k.lower(): str(v) for k, v in (stream.get("tags") or {}).items()}
    lang = tags.get("language", "").strip().lower()
    return (None if lang in UNKNOWN_LANG else lang), tags.get("title", "")


def is_english(lang: str | None, title: str) -> bool:
    return lang in EN or (lang is None and re.search(r"\benglish\b", title, re.I) is not None)


def external_subs(path: str) -> list[str]:
    folder, name = os.path.split(path)
    stem = os.path.splitext(name)[0]
    found = []
    try:
        for f in os.listdir(folder):
            if f.startswith(stem) and f.lower().endswith(SUB_EXTS) and f != name:
                found.append(f)
    except OSError:
        pass
    return found


def check_language(probe: dict, path: str, original_language: str | None) -> dict:
    audio, subs = [], []
    for s in probe.get("streams", []):
        lang, title = norm_lang(s)
        entry = {"lang": lang or "und", "title": title, "codec": s.get("codec_name"),
                 "english": is_english(lang, title)}
        if s.get("codec_type") == "audio":
            audio.append(entry)
        elif s.get("codec_type") == "subtitle":
            entry["forced"] = bool((s.get("disposition") or {}).get("forced"))
            subs.append(entry)

    ext = external_subs(path)
    stem = os.path.splitext(os.path.basename(path))[0]
    ext_en = [f for f in ext if set(f[len(stem):].lower().split(".")) & EN]
    has_en_audio = any(a["english"] for a in audio)
    untagged_audio = [a for a in audio if a["lang"] == "und" and not a["english"]]
    has_en_subs = any(s["english"] and not s["forced"] for s in subs) or bool(ext_en)
    foreign = bool(original_language) and original_language != "English"

    result = {"audio": audio, "subtitles": subs, "external_subtitles": ext,
              "original_language": original_language, "ok": True, "note": ""}
    langs = ", ".join(a["lang"] for a in audio) or "none"
    if not audio:
        result.update(ok=False, note="no audio track")
    elif has_en_audio:
        result["note"] = "English audio present"
    elif untagged_audio and original_language == "English":
        result["note"] = "audio is untagged; original language is English, so assumed English"
    elif foreign and has_en_subs and ALLOW_SUBS_FOR_FOREIGN:
        result["note"] = f"{original_language} film with English subtitles"
    else:
        sub_note = "has English subtitles" if has_en_subs else "no English subtitles"
        result.update(ok=False, note=f"no English audio (audio: {langs}; original language: "
                                     f"{original_language or 'unknown'}; {sub_note})")
    return result


# ---------------------------------------------------------------- picture check

VISION_SCHEMA = {
    "type": "object",
    "properties": {
        "watermark": {"type": "boolean"},
        "watermark_text": {"type": "string"},
        "watermark_frames": {"type": "array", "items": {"type": "integer"}},
        "burned_in_subtitles": {"type": "boolean"},
        "burned_in_subtitle_language": {"type": "string"},
        "camcorder": {"type": "boolean"},
        "confidence": {"type": "number"},
        "explanation": {"type": "string"},
    },
    "required": ["watermark", "watermark_text", "watermark_frames", "burned_in_subtitles",
                 "burned_in_subtitle_language", "camcorder", "confidence", "explanation"],
}

VISION_PROMPT = """You are checking frames sampled from a downloaded movie file for problems \
added by whoever uploaded it. The frames are numbered in the order shown.

Report:
- watermark: true if any frame has an overlay that is NOT part of the original film, such as \
a website or domain name (e.g. "www.something.com", "YTS", "1337x", "RARBG"), a torrent site, \
uploader or release-group name or logo, a Telegram/Discord handle, a "downloaded from" banner, \
or betting/casino/VPN advertising. Give the text you can read in watermark_text and the frame \
numbers in watermark_frames.
  Do NOT count: studio or distributor logos in opening or closing credits, the film's own \
titles and credits, signs, screens or other text that belongs to the scene, rating cards, or a \
TV channel logo from an original broadcast.
- burned_in_subtitles: true if dialogue subtitles are drawn into the picture itself; give their \
language in burned_in_subtitle_language (empty string if none).
- camcorder: true if the picture looks like a camera recording of a cinema screen (tilted or \
curved screen edges, audience heads, heavy blur or shake).
- confidence: 0 to 1, how sure you are about whatever you reported as true (or that the frames \
are clean, if nothing is true).
- explanation: one or two short sentences.

Mostly dark frames or credits are normal; judge from the frames that show the picture."""


def video_stream(probe: dict) -> dict | None:
    for s in probe.get("streams", []):
        if s.get("codec_type") == "video" and not (s.get("disposition") or {}).get("attached_pic"):
            return s
    return None


def extract_frames(scan_id: int, path: str, probe: dict) -> list[dict]:
    stream = video_stream(probe)
    duration = float((probe.get("format") or {}).get("duration") or 0)
    if stream is None or duration <= 0:
        return []
    out_dir = os.path.join(FRAMES_DIR, str(scan_id))
    shutil.rmtree(out_dir, ignore_errors=True)
    os.makedirs(out_dir, exist_ok=True)
    frames = []
    n = max(FRAME_COUNT, 2)
    for i in range(n):
        # 6%..94% skips cold opens/studio logos at the start and the end credits.
        t = duration * (0.06 + 0.88 * i / (n - 1))
        out = os.path.join(out_dir, f"{i + 1:02d}.jpg")
        cmd = ["ffmpeg", "-nostdin", "-v", "error", "-ss", f"{t:.2f}", "-i", path,
               "-map", f"0:{stream['index']}", "-frames:v", "1",
               "-vf", f"scale='min({FRAME_WIDTH},iw)':-2", "-q:v", "3", "-y", out]
        try:
            subprocess.run(cmd, check=True, timeout=180, capture_output=True)
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
            log(f"frame {i + 1} at {t:.0f}s failed: {getattr(e, 'stderr', b'')[-300:]!r}")
            continue
        if os.path.exists(out) and os.path.getsize(out) > 0:
            frames.append({"n": i + 1, "file": os.path.basename(out), "t": round(t)})
    return frames


def ask_vision(scan_id: int, frames: list[dict]) -> dict:
    content: list[dict] = [{"type": "text", "text": VISION_PROMPT}]
    for f in frames:
        with open(os.path.join(FRAMES_DIR, str(scan_id), f["file"]), "rb") as fh:
            b64 = base64.b64encode(fh.read()).decode()
        content.append({"type": "text", "text": f"Frame {f['n']} ({fmt_time(f['t'])}):"})
        content.append({"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{b64}"}})
    body = {
        "model": VISION_MODEL,
        "messages": [{"role": "user", "content": content}],
        "temperature": 0,
        "max_tokens": 1024,
        "response_format": {"type": "json_schema",
                            "json_schema": {"name": "frame_check", "strict": True, "schema": VISION_SCHEMA}},
    }
    resp = http_json("POST", f"{LITELLM_URL}/v1/chat/completions",
                     {"Authorization": f"Bearer {LITELLM_KEY}"}, body, timeout=LLM_TIMEOUT)
    text = resp["choices"][0]["message"]["content"] or ""
    # Tolerate a fenced block in case the backend ignores response_format.
    match = re.search(r"\{.*\}", text, re.S)
    if not match:
        raise ValueError(f"vision model returned no JSON: {text[:300]!r}")
    return json.loads(match.group(0))


def fmt_time(seconds: int) -> str:
    return f"{seconds // 3600}:{seconds % 3600 // 60:02d}:{seconds % 60:02d}"


# ----------------------------------------------------------------------- worker

class Gone(Exception):
    """The file was replaced or deleted before it was scanned."""


def ffprobe(path: str) -> dict:
    out = subprocess.run(["ffprobe", "-v", "error", "-print_format", "json", "-show_format", "-show_streams", path],
                         check=True, timeout=180, capture_output=True)
    return json.loads(out.stdout)


def scan(job: dict) -> dict:
    try:
        mf = radarr("GET", f"moviefile/{job['movie_file_id']}")
    except urllib.error.HTTPError as e:
        if e.code == 404:
            raise Gone()
        raise
    movie = radarr("GET", f"movie/{job['movie_id']}")
    path = mf["path"]
    title = f"{movie['title']} ({movie.get('year')})"
    if not os.path.exists(path):
        raise FileNotFoundError(f"{path} is not mounted in this pod")

    reasons: list[dict] = []
    language = vision = None
    try:
        probe = ffprobe(path)
    except subprocess.CalledProcessError as e:
        reasons.append({"kind": "unreadable", "detail": f"ffprobe failed: {e.stderr.decode(errors='replace')[-300:]}"})
        probe = None

    if probe is not None:
        language = check_language(probe, path, (movie.get("originalLanguage") or {}).get("name"))
        if not language["ok"]:
            reasons.append({"kind": "language", "detail": language["note"]})

        frames = extract_frames(job["id"], path, probe)
        if not frames:
            reasons.append({"kind": "unreadable", "detail": "no video frames could be decoded"})
        else:
            vision = ask_vision(job["id"], frames)
            vision["frames"] = frames
            confident = float(vision.get("confidence") or 0) >= MIN_CONFIDENCE
            if vision.get("watermark") and confident:
                reasons.append({"kind": "watermark", "detail": vision.get("watermark_text") or "watermark"})
            sub_lang = (vision.get("burned_in_subtitle_language") or "").strip()
            if vision.get("burned_in_subtitles") and confident and sub_lang.lower() not in EN | {""}:
                reasons.append({"kind": "burned-in subtitles", "detail": sub_lang})
            if vision.get("camcorder") and confident:
                reasons.append({"kind": "camcorder", "detail": vision.get("explanation", "")})

    if not reasons:
        shutil.rmtree(os.path.join(FRAMES_DIR, str(job["id"])), ignore_errors=True)
    return {"title": title, "path": path, "reasons": reasons, "language": language, "vision": vision,
            "verdict": "flagged" if reasons else "ok"}


def claim(conn) -> dict | None:
    with conn.transaction():
        job = conn.execute(
            """select id, movie_file_id, movie_id, attempts from scans
               where status = 'pending' and run_after <= now()
               order by priority, run_after, id
               for update skip locked limit 1""").fetchone()
        if job:
            conn.execute("update scans set status = 'running', started_at = now(), attempts = attempts + 1 "
                         "where id = %s", (job["id"],))
    return job


def worker() -> None:
    conn = db()
    conn.execute("listen media_qc")
    while True:
        try:
            job = None if paused(conn) else claim(conn)
            if job is None:
                # Woken early by NOTIFY; the timeout picks up delayed webhook items.
                for _ in conn.notifies(timeout=60, stop_after=1):
                    pass
                continue
            log(f"scanning file {job['movie_file_id']} (scan {job['id']})")
            try:
                r = scan(job)
            except Gone:
                conn.execute("update scans set status = 'gone', finished_at = now() where id = %s", (job["id"],))
                log(f"scan {job['id']}: file no longer in Radarr")
                continue
            except Exception as e:
                failed = job["attempts"] + 1 >= MAX_ATTEMPTS
                conn.execute(
                    """update scans set status = %s, error = %s, finished_at = now(),
                         run_after = now() + make_interval(mins => %s) where id = %s""",
                    ("error" if failed else "pending", f"{type(e).__name__}: {e}", 10 * (job["attempts"] + 1), job["id"]))
                log(f"scan {job['id']} failed ({'giving up' if failed else 'will retry'}): {e}")
                traceback.print_exc()
                continue
            conn.execute(
                """update scans set status = 'done', finished_at = now(), title = %s, path = %s, verdict = %s,
                     reasons = %s, language = %s, vision = %s, error = null where id = %s""",
                (r["title"], r["path"], r["verdict"], Jsonb(r["reasons"]), Jsonb(r["language"]),
                 Jsonb(r["vision"]), job["id"]))
            log(f"scan {job['id']} {r['title']}: {r['verdict']} {[x['kind'] for x in r['reasons']]}")
        except psycopg.OperationalError as e:
            log(f"lost postgres connection: {e}")
            time.sleep(5)
            conn = db()
            conn.execute("listen media_qc")


# ------------------------------------------------------------------------- http

PAGE_CSS = """
:root{--bg:#f7f7f5;--fg:#1d1d1b;--muted:#6b6b66;--card:#fff;--line:#e3e2dd;--bad:#b3261e;--ok:#2e7d32;--acc:#3557c6}
@media (prefers-color-scheme:dark){:root{--bg:#161615;--fg:#ecebe6;--muted:#9a9993;--card:#21211f;--line:#34332f;--bad:#f2867e;--ok:#81c784;--acc:#8fa8ff}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--fg);font:15px/1.45 system-ui,sans-serif}
main{max-width:1100px;margin:0 auto;padding:20px 16px 60px}h1{font-size:22px;margin:0 0 4px}h2{font-size:17px;margin:28px 0 10px}
.muted{color:var(--muted)}.stats{display:flex;gap:16px;flex-wrap:wrap;margin:10px 0}.stats b{font-size:18px}
.card{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:14px;margin:0 0 14px}
.reason{color:var(--bad);margin:4px 0}.frames{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:6px;margin:10px 0}
.frames img{width:100%;border-radius:4px;border:2px solid transparent}.frames img.hit{border-color:var(--bad)}
button{font:inherit;border:1px solid var(--line);background:var(--card);color:var(--fg);border-radius:6px;padding:5px 12px;cursor:pointer}
button.bad{background:var(--bad);border-color:var(--bad);color:#fff}form{display:inline}
table{width:100%;border-collapse:collapse;font-size:14px}td,th{text-align:left;padding:6px;border-bottom:1px solid var(--line);vertical-align:top}
.ok{color:var(--ok)}.flagged{color:var(--bad)}code{font-size:12px;word-break:break-all}
"""


def esc(v) -> str:
    return html.escape("" if v is None else str(v))


def render_page() -> str:
    with db() as conn:
        counts = {r["k"]: r["n"] for r in conn.execute(
            """select case when status = 'done' and verdict = 'flagged' and review is null then 'review'
                           else status end as k, count(*) as n from scans group by 1""")}
        is_paused = paused(conn)
        review = conn.execute("select * from scans where status = 'done' and verdict = 'flagged' and review is null "
                              "order by finished_at desc").fetchall()
        recent = conn.execute("select * from scans where status in ('done','error','running') "
                              "order by coalesce(finished_at, started_at) desc nulls last limit 60").fetchall()

    parts = [f"<!doctype html><html><head><meta charset=utf-8><meta name=viewport content='width=device-width,initial-scale=1'>"
             f"<title>Media QC</title><style>{PAGE_CSS}</style></head><body><main>",
             "<h1>Media QC</h1><div class=muted>Movies checked for missing English and uploader watermarks.</div>",
             "<div class=stats>"]
    for label, key in (("to review", "review"), ("queued", "pending"), ("scanning", "running"),
                       ("checked", "done"), ("errors", "error")):
        parts.append(f"<span><b>{counts.get(key, 0)}</b> <span class=muted>{label}</span></span>")
    action = "resume" if is_paused else "pause"
    parts.append(f"<form method=post action=/api/{action}><button>{'Resume' if is_paused else 'Pause'} queue</button></form>")
    if is_paused:
        parts.append("<span class=flagged>paused</span>")
    parts.append("</div>")

    parts.append("<h2>Needs review</h2>")
    if not review:
        parts.append("<p class=muted>Nothing flagged.</p>")
    for s in review:
        vision = s["vision"] or {}
        hits = set(vision.get("watermark_frames") or [])
        parts.append(f"<div class=card><b>{esc(s['title'])}</b><div><code>{esc(s['path'])}</code></div>")
        for r in s["reasons"]:
            parts.append(f"<div class=reason>{esc(r['kind'])}: {esc(r['detail'])}</div>")
        if vision.get("explanation"):
            parts.append(f"<div class=muted>Model: {esc(vision['explanation'])} "
                         f"(confidence {esc(vision.get('confidence'))})</div>")
        if s["language"]:
            parts.append(f"<div class=muted>Language: {esc(s['language'].get('note'))}</div>")
        frames = vision.get("frames") or []
        if frames:
            parts.append("<div class=frames>")
            for f in frames:
                cls = " class=hit" if f["n"] in hits else ""
                src = f"/frames/{s['id']}/{f['file']}"
                parts.append(f"<a href='{src}' target=_blank><img{cls} loading=lazy src='{src}' "
                             f"title='frame {f['n']} at {fmt_time(f['t'])}'></a>")
            parts.append("</div>")
        parts.append(
            f"<form method=post action=/scans/{s['id']}/keep><button>Keep</button></form> "
            f"<form method=post action=/scans/{s['id']}/rescan><button>Rescan</button></form> "
            f"<form method=post action=/scans/{s['id']}/reject onsubmit=\"return confirm('Blocklist this release, "
            f"delete the file and search for another?')\"><button class=bad>Reject &amp; re-download</button></form>"
            "</div>")

    parts.append("<h2>Recent</h2><table><tr><th>Movie</th><th>Result</th><th>When</th><th></th></tr>")
    for s in recent:
        if s["status"] == "error":
            result = f"<span class=flagged>error</span> <span class=muted>{esc(s['error'])}</span>"
        elif s["status"] == "running":
            result = "scanning..."
        elif s["verdict"] == "flagged":
            kinds = ", ".join(r["kind"] for r in s["reasons"])
            result = f"<span class=flagged>flagged</span> {esc(kinds)}" + (f" &middot; {esc(s['review'])}" if s["review"] else "")
            if s["review_note"]:
                result += f"<div class=muted>{esc(s['review_note'])}</div>"
        else:
            result = "<span class=ok>ok</span>"
        when = s["finished_at"] or s["started_at"]
        parts.append(f"<tr><td>{esc(s['title'] or s['movie_file_id'])}</td><td>{result}</td>"
                     f"<td class=muted>{esc(when.strftime('%Y-%m-%d %H:%M') if when else '')}</td>"
                     f"<td><form method=post action=/scans/{s['id']}/rescan><button>Rescan</button></form></td></tr>")
    parts.append("</table></main></body></html>")
    return "".join(parts)


class Handler(BaseHTTPRequestHandler):
    server_version = "media-qc"

    def log_message(self, fmt, *args):  # keep health checks out of the log
        if "/healthz" not in self.path:
            log(f"{self.address_string()} {fmt % args}")

    def send(self, code: int, body: bytes | str = b"", ctype: str = "text/plain; charset=utf-8", headers=None):
        data = body.encode() if isinstance(body, str) else body
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        for k, v in (headers or {}).items():
            self.send_header(k, v)
        self.end_headers()
        self.wfile.write(data)

    def back(self):
        self.send(303, "", headers={"Location": "/"})

    def do_GET(self):
        url = urllib.parse.urlparse(self.path)
        if url.path == "/healthz":
            return self.send(200, "ok")
        if url.path == "/":
            return self.send(200, render_page(), "text/html; charset=utf-8")
        m = re.fullmatch(r"/frames/(\d+)/(\d{2}\.jpg)", url.path)
        if m:
            p = os.path.join(FRAMES_DIR, m.group(1), m.group(2))
            if os.path.isfile(p):
                with open(p, "rb") as fh:
                    return self.send(200, fh.read(), "image/jpeg", {"Cache-Control": "max-age=86400"})
        self.send(404, "not found")

    def do_POST(self):
        url = urllib.parse.urlparse(self.path)
        length = int(self.headers.get("Content-Length") or 0)
        raw = self.rfile.read(length) if length else b""
        try:
            if url.path == "/hooks/radarr":
                return self.radarr_hook(url, raw)
            if url.path == "/api/backfill":
                return self.backfill()
            if url.path in ("/api/pause", "/api/resume"):
                with db() as conn:
                    conn.execute("insert into settings values ('paused', %s) on conflict (key) do update "
                                 "set value = excluded.value", ("true" if url.path.endswith("pause") else "false",))
                    conn.execute("notify media_qc")
                return self.back()
            m = re.fullmatch(r"/scans/(\d+)/(keep|reject|rescan)", url.path)
            if m:
                return self.review(int(m.group(1)), m.group(2))
            self.send(404, "not found")
        except Exception as e:
            traceback.print_exc()
            self.send(500, f"{type(e).__name__}: {e}")

    def radarr_hook(self, url, raw: bytes):
        token = urllib.parse.parse_qs(url.query).get("token", [""])[0]
        if token != WEBHOOK_TOKEN:
            return self.send(403, "bad token")
        event = json.loads(raw or b"{}")
        kind = event.get("eventType")
        if kind == "Download" and event.get("movieFile", {}).get("id"):
            movie = event.get("movie") or {}
            with db() as conn:
                enqueue(conn, event["movieFile"]["id"], movie["id"],
                        f"{movie.get('title')} ({movie.get('year')})", "webhook")
            log(f"queued {movie.get('title')} from Radarr webhook")
        return self.send(200, "ok")

    def backfill(self):
        added = 0
        movies = radarr("GET", "movie")
        with db() as conn:
            for m in movies:
                mf = m.get("movieFile")
                if m.get("hasFile") and mf:
                    added += enqueue(conn, mf["id"], m["id"], f"{m['title']} ({m.get('year')})", "backfill")
        log(f"backfill queued {added} of {len(movies)} movies")
        self.send(200, json.dumps({"queued": added, "movies": len(movies)}), "application/json")

    def review(self, scan_id: int, action: str):
        with db() as conn:
            s = conn.execute("select * from scans where id = %s", (scan_id,)).fetchone()
            if s is None:
                return self.send(404, "no such scan")
            if action == "keep":
                conn.execute("update scans set review = 'kept', reviewed_at = now() where id = %s", (scan_id,))
            elif action == "rescan":
                conn.execute("update scans set status = 'pending', priority = 0, run_after = now(), attempts = 0, "
                             "review = null, review_note = null, error = null, source = 'rescan' "
                             "where id = %s and status <> 'running'", (scan_id,))
                conn.execute("notify media_qc")
            else:
                note = reject_release(s)
                conn.execute("update scans set review = 'rejected', review_note = %s, reviewed_at = now() "
                             "where id = %s", (note, scan_id))
                shutil.rmtree(os.path.join(FRAMES_DIR, str(scan_id)), ignore_errors=True)
                log(f"rejected {s['title']}: {note}")
        self.back()


def main() -> None:
    os.makedirs(FRAMES_DIR, exist_ok=True)
    wait_for_db()
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    log(f"listening on :{PORT}")
    threading.Thread(target=ensure_webhook_forever, daemon=True).start()
    worker()


if __name__ == "__main__":
    main()
