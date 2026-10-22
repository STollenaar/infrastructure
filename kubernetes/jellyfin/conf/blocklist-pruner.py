#!/usr/bin/env python3
"""Time-based stall handling for Sonarr/Radarr, with an expiring blocklist.

decluttarr can't express either half of this (v2.2.0):
  - 'stalled for N days' - max_strikes counts job cycles, and the counters live in
    an in-memory dict that resets on restart or whenever the queue empties.
  - 'block for N days'   - RemoveStalled hardcodes blocklist = True, and *arr
    blocklist entries have no expiry field.

So this job owns stall removal end to end:

  Phase 1  find queue items whose torrent has sat in a stalled state with no
           activity for STALL_DAYS, remove them with blocklist=true, and record
           the blocklist ids that appeared as a result.
  Phase 2  delete recorded entries once they are BLOCK_DAYS old.

Attribution is the whole point of the state file. The *arrs stamp every
queue-delete-with-blocklist as "Manually marked as failed" no matter the cause, so
a blocklist record carries nothing that says why it exists. Phase 2 therefore only
ever touches ids this job wrote down in phase 1. Blocks created by anything else -
decluttarr's remove_bad_files / remove_failed_imports for invalid media formats, or
a manual click in the UI - are never recorded, so they are never pruned and stay
permanent, which is what we want for fake releases.

Torrents carrying the protected tag are skipped, matching decluttarr's
general.protected_tag behaviour.
"""

from __future__ import annotations

import http.cookiejar
import json
import os
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request

# qBittorrent states that mean "a download that is going nowhere". Deliberately
# excludes stalledUP/stoppedUP (those are finished and seeding, not stalled
# downloads) and metaDL (decluttarr's remove_metadata_missing owns that case).
STALLED_STATES = {"stalledDL"}

STALL_DAYS = float(os.environ.get("STALL_DAYS", "3"))
BLOCK_DAYS = float(os.environ.get("BLOCK_DAYS", "18"))
PROTECTED_TAG = os.environ.get("PROTECTED_TAG", "Don't Kill")
STATE_FILE = os.environ.get("STATE_FILE", "/state/blocklist-state.json")
DRY_RUN = os.environ.get("DRY_RUN", "false").lower() in ("1", "true", "yes")

QBIT_URL = os.environ.get("QBITTORRENT_URL", "http://qbittorrent:8080")
ARRS = [
    {
        "name": "sonarr",
        "url": os.environ.get("SONARR_URL", "http://sonarr:8989"),
        "key": os.environ.get("SONARR_KEY", ""),
        "unknown_param": "includeUnknownSeriesItems",
    },
    {
        "name": "radarr",
        "url": os.environ.get("RADARR_URL", "http://radarr:7878"),
        "key": os.environ.get("RADARR_KEY", ""),
        "unknown_param": "includeUnknownMovieItems",
    },
]

NOW = time.time()


def log(msg: str) -> None:
    print(msg, flush=True)


# --------------------------------------------------------------------------- arr


def arr_request(arr: dict, method: str, path: str, params: dict | None = None):
    url = arr["url"] + "/api/v3" + path
    if params:
        url += "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, method=method, headers={"X-Api-Key": arr["key"]})
    with urllib.request.urlopen(req, timeout=120) as resp:
        raw = resp.read()
    return json.loads(raw) if raw else None


def arr_paged(arr: dict, path: str, params: dict | None = None) -> list:
    """Fetch every record of a paged endpoint."""
    params = dict(params or {})
    params.update({"page": 1, "pageSize": 1000})
    records: list = []
    while True:
        page = arr_request(arr, "GET", path, params)
        if not page:
            break
        records.extend(page.get("records", []))
        if len(records) >= page.get("totalRecords", 0) or not page.get("records"):
            break
        params["page"] += 1
    return records


# ------------------------------------------------------------------- qbittorrent


def qbit_torrents() -> dict:
    """Return {lowercase hash: torrent}. Empty dict if qBittorrent is unreachable."""
    opener = urllib.request.build_opener(
        urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar())
    )
    creds = urllib.parse.urlencode(
        {
            "username": os.environ.get("QBITTORRENT_USERNAME", ""),
            "password": os.environ.get("QBITTORRENT_PASSWORD", ""),
        }
    ).encode()
    body = opener.open(QBIT_URL + "/api/v2/auth/login", creds, timeout=60).read()
    if body.strip() != b"Ok.":
        raise RuntimeError("qBittorrent login rejected: %r" % body[:80])
    torrents = json.load(
        opener.open(QBIT_URL + "/api/v2/torrents/info", timeout=120)
    )
    return {t["hash"].lower(): t for t in torrents}


# ------------------------------------------------------------------------- state


def load_state() -> dict:
    try:
        with open(STATE_FILE) as fh:
            state = json.load(fh)
    except (FileNotFoundError, json.JSONDecodeError):
        return {"blocked": {}}
    state.setdefault("blocked", {})
    return state


def save_state(state: dict) -> None:
    if DRY_RUN:
        return
    os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
    # Write-then-rename so a crash can't leave a truncated state file behind;
    # losing it would orphan every pending block as un-prunable.
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(STATE_FILE), suffix=".tmp")
    try:
        with os.fdopen(fd, "w") as fh:
            json.dump(state, fh, indent=1, sort_keys=True)
        os.replace(tmp, STATE_FILE)
    except BaseException:
        os.unlink(tmp)
        raise


def state_key(arr_name: str, blocklist_id) -> str:
    return "%s:%s" % (arr_name, blocklist_id)


# ----------------------------------------------------------------------- phase 1


def sweep_stalled(arr: dict, torrents: dict, state: dict) -> int:
    """Remove+blocklist queue items stalled beyond STALL_DAYS; record the new ids."""
    queue = arr_paged(arr, "/queue", {arr["unknown_param"]: "true"})
    if not queue:
        return 0

    removed = 0
    for item in queue:
        download_id = (item.get("downloadId") or "").lower()
        if not download_id:
            continue
        torrent = torrents.get(download_id)
        if torrent is None:
            continue  # not ours (usenet, other client, or already gone)
        if torrent.get("state") not in STALLED_STATES:
            continue

        tags = {t.strip() for t in (torrent.get("tags") or "").split(",")}
        if PROTECTED_TAG in tags:
            log("    skip (protected): %s" % torrent["name"][:70])
            continue

        last_activity = torrent.get("last_activity") or 0
        if last_activity <= 0:
            continue
        idle_days = (NOW - last_activity) / 86400.0
        if idle_days < STALL_DAYS:
            continue

        title = item.get("title") or torrent["name"]
        log("    stalled %.1fd -> remove+block: %s" % (idle_days, title[:70]))
        if DRY_RUN:
            removed += 1
            continue

        before = {r["id"] for r in arr_paged(arr, "/blocklist")}
        try:
            arr_request(
                arr,
                "DELETE",
                "/queue/%s" % item["id"],
                {"removeFromClient": "true", "blocklist": "true"},
            )
        except urllib.error.HTTPError as exc:
            log("      !! removal failed (HTTP %s), skipping" % exc.code)
            continue
        # The blocklist row can land a moment after the delete returns, so retry
        # briefly. Missing it is safe but unhelpful: the block would then be
        # untracked and stay permanent, like a bad-format one.
        new: list = []
        for attempt in range(4):
            if attempt:
                time.sleep(1)
            new = [r for r in arr_paged(arr, "/blocklist") if r["id"] not in before]
            if new:
                break
        if not new:
            # Removal worked but produced no blocklist row (already blocklisted,
            # for instance). Nothing to expire later, so nothing to record.
            log("      (no new blocklist entry to track)")
        for rec in new:
            state["blocked"][state_key(arr["name"], rec["id"])] = {
                "arr": arr["name"],
                "blocklistId": rec["id"],
                "sourceTitle": rec.get("sourceTitle"),
                "blockedAt": NOW,
                "reason": "stalled",
                "idleDaysAtRemoval": round(idle_days, 1),
            }
            log("      tracking blocklist id %s for %g days" % (rec["id"], BLOCK_DAYS))
        removed += 1

    return removed


# ----------------------------------------------------------------------- phase 2


def prune_expired(state: dict, live_ids: dict) -> tuple[int, int]:
    """Delete tracked blocklist entries older than BLOCK_DAYS. Returns (pruned, dropped)."""
    arrs_by_name = {a["name"]: a for a in ARRS}
    pruned = dropped = 0

    for key, rec in list(state["blocked"].items()):
        arr = arrs_by_name.get(rec.get("arr"))
        if arr is None:
            continue
        blocklist_id = rec.get("blocklistId")

        # Gone already (manual cleanup, *arr DB reset): stop tracking it.
        if blocklist_id not in live_ids.get(rec["arr"], set()):
            log("    no longer in %s blocklist, untracking: %s"
                % (rec["arr"], str(rec.get("sourceTitle"))[:60]))
            del state["blocked"][key]
            dropped += 1
            continue

        age_days = (NOW - float(rec.get("blockedAt") or NOW)) / 86400.0
        if age_days < BLOCK_DAYS:
            continue

        log("    block expired (%.1fd) -> unblocking: %s"
            % (age_days, str(rec.get("sourceTitle"))[:60]))
        if DRY_RUN:
            pruned += 1
            continue
        try:
            arr_request(arr, "DELETE", "/blocklist/%s" % blocklist_id)
        except urllib.error.HTTPError as exc:
            log("      !! unblock failed (HTTP %s), leaving tracked" % exc.code)
            continue
        del state["blocked"][key]
        pruned += 1

    return pruned, dropped


# -------------------------------------------------------------------------- main


def main() -> int:
    log("blocklist-pruner: stall>=%gd, block expires after %gd%s"
        % (STALL_DAYS, BLOCK_DAYS, "  [DRY RUN]" if DRY_RUN else ""))

    active = [a for a in ARRS if a["key"]]
    if not active:
        log("no *arr API keys in env, nothing to do")
        return 1

    state = load_state()
    log("tracking %d stall-caused block(s)" % len(state["blocked"]))

    try:
        torrents = qbit_torrents()
        log("qBittorrent: %d torrent(s)" % len(torrents))
    except Exception as exc:  # noqa: BLE001 - never remove blind
        log("!! qBittorrent unreachable (%s); skipping phase 1" % exc)
        torrents = None

    # Phase 1 - find and action stalled downloads.
    if torrents:
        for arr in active:
            log("  %s: checking queue for stalled downloads" % arr["name"])
            try:
                n = sweep_stalled(arr, torrents, state)
                log("  %s: removed %d stalled download(s)" % (arr["name"], n))
            except Exception as exc:  # noqa: BLE001
                log("  !! %s sweep failed: %s" % (arr["name"], exc))
        save_state(state)

    # Phase 2 - expire blocks this job created.
    live_ids = {}
    for arr in active:
        try:
            live_ids[arr["name"]] = {r["id"] for r in arr_paged(arr, "/blocklist")}
        except Exception as exc:  # noqa: BLE001
            log("  !! %s blocklist fetch failed: %s" % (arr["name"], exc))
    # A failed fetch must not look like "entry is gone" and untrack things.
    for arr in active:
        if arr["name"] not in live_ids:
            log("  skipping phase 2 (incomplete blocklist view)")
            save_state(state)
            return 0

    log("  expiring blocks older than %g days" % BLOCK_DAYS)
    pruned, untracked = prune_expired(state, live_ids)
    log("  unblocked %d, untracked %d, still tracking %d"
        % (pruned, untracked, len(state["blocked"])))

    save_state(state)
    return 0


if __name__ == "__main__":
    sys.exit(main())
