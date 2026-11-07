#!/usr/bin/env python3
"""heating-agent: watches thermostat electricity use in Home Assistant and proposes
smarter heating, taking the weather forecast into account.

Nothing is ever changed without approval. Every proposal goes to the phone as a
Home Assistant actionable notification (Apply / Skip); only Apply changes a
thermostat. Unanswered proposals expire.

Flow
  1. Every SCAN_INTERVAL_HOURS (outside QUIET_HOURS) the agent collects:
       - each climate entity's state, setpoint, room, and heating demand (%),
       - hourly heating-demand statistics and whole-house meter kWh for the last
         HISTORY_DAYS, from the recorder's long-term statistics,
       - the hourly and daily forecast from WEATHER_ENTITY,
       - the heating schedule automations and the past decisions you made.
     The thermostats only report demand (% of time the heater is on), so energy is
     estimated as HEATER_WATTS x demand and checked against the meter.
  2. An LLM (through LiteLLM) reads that snapshot and returns proposals as JSON.
  3. Proposals pass through fixed guardrails (setpoint range, no turning heat off or
     down during a cold snap, no repeating something you skipped recently).
  4. What is left is sent as one notification. The agent listens on the HA
     websocket for the button press and applies the batch only on Apply.
  The weather is also checked every hour without the LLM. When the forecast low
  drops below COLD_THRESHOLD_C, an extra scan runs right away (quiet hours do not
  hold it back), so cold-weather changes are proposed before the cold arrives.

LiteLLM exposes this service as an A2A agent (see ../litellm/config.yaml). It
answers JSON-RPC message/send with plain-text commands:
  report | status    latest analysis and pending proposals
  scan               run a new analysis now (results arrive as a notification)
  apply <id>         apply a pending proposal batch
  skip <id>          discard a pending proposal batch
  anything else      question answered by the LLM from the latest snapshot
"""

from __future__ import annotations

import json
import os
import secrets
import sys
import threading
import time
import traceback
import urllib.error
import urllib.request
from datetime import datetime, timedelta, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from zoneinfo import ZoneInfo

from websockets.sync.client import connect as ws_connect


def env(name: str, default: str | None = None) -> str:
    value = os.environ.get(name, default)
    if value is None:
        sys.exit(f"missing required environment variable {name}")
    return value


HA_URL = env("HA_URL").rstrip("/")
HA_TOKEN = env("HA_TOKEN")
LITELLM_URL = env("LITELLM_URL").rstrip("/")
LITELLM_KEY = env("LITELLM_KEY")
MODEL = env("MODEL", "gemma4-26b")
LLM_TIMEOUT = int(env("LLM_TIMEOUT", "900"))  # a cold model swap alone can take minutes
# Free-form questions over A2A. LiteLLM gives the agent about a minute to answer.
CHAT_TIMEOUT = int(env("CHAT_TIMEOUT", "50"))
TZ = ZoneInfo(env("TZ", "UTC"))

# Empty means every climate.* entity.
CLIMATE_ENTITIES = [e.strip() for e in env("CLIMATE_ENTITIES", "").split(",") if e.strip()]
WEATHER_ENTITY = env("WEATHER_ENTITY", "weather.forecast_home")
# The meter and its $/kWh come from Home Assistant's Energy settings (the grid
# source), so changing the price there is picked up on the next scan. These two only
# override that when set.
METER_ENTITY_OVERRIDE = env("METER_ENTITY", "")
ENERGY_PRICE_OVERRIDE = env("ENERGY_PRICE", "")
# Rated heater wattage behind each thermostat, e.g. {"climate.x": 2000}. Anything
# missing uses DEFAULT_HEATER_WATTS. These turn heating demand into kWh, so the
# estimates are only as good as these numbers.
HEATER_WATTS: dict[str, float] = json.loads(env("HEATER_WATTS", "{}"))
DEFAULT_HEATER_WATTS = float(env("DEFAULT_HEATER_WATTS", "1500"))
HISTORY_DAYS = int(env("HISTORY_DAYS", "7"))

# HA notify services (without the "notify." prefix) that receive proposals.
NOTIFY_SERVICES = [s.strip() for s in env("NOTIFY_SERVICES").split(",") if s.strip()]

SCAN_INTERVAL_HOURS = float(env("SCAN_INTERVAL_HOURS", "6"))
QUIET_HOURS = env("QUIET_HOURS", "22-7")  # local hours with no routine notifications
PROPOSAL_TTL_MINUTES = int(env("PROPOSAL_TTL_MINUTES", "120"))
SKIP_COOLDOWN_HOURS = float(env("SKIP_COOLDOWN_HOURS", "24"))

# Guardrails, applied after the LLM and never overridden by it.
MIN_SETPOINT = float(env("MIN_SETPOINT", "15"))
MAX_SETPOINT = float(env("MAX_SETPOINT", "23"))
COLD_THRESHOLD_C = float(env("COLD_THRESHOLD_C", "-12"))  # forecast low that counts as a cold snap
COLD_LOOKAHEAD_HOURS = int(env("COLD_LOOKAHEAD_HOURS", "36"))
COLD_MIN_SETPOINT = float(env("COLD_MIN_SETPOINT", "17"))  # floor while a cold snap is forecast

PORT = int(env("PORT", "8080"))
AGENT_URL = env("AGENT_URL", f"http://heating-agent:{PORT}/")
STATE_FILE = env("STATE_FILE", "/data/state.json")

ACTION_PREFIX = "HEATING_"
NOTIFY_TAG = "heating-agent"


def log(*args) -> None:
    print(datetime.now(TZ).strftime("%Y-%m-%d %H:%M:%S"), *args, flush=True)


def now_local() -> datetime:
    return datetime.now(TZ)


# ---------------------------------------------------------------- persistent state

state_lock = threading.RLock()
scan_lock = threading.Lock()


def load_state() -> dict:
    try:
        with open(STATE_FILE) as f:
            data = json.load(f)
    except FileNotFoundError:
        data = {}
    except Exception:
        log("state file unreadable, starting fresh")
        traceback.print_exc()
        data = {}
    data.setdefault("pending", {})  # batch id -> batch
    data.setdefault("decisions", [])  # newest last
    data.setdefault("last_scan", 0)
    data.setdefault("last_cold_scan", 0)
    data.setdefault("last_report", "")
    data.setdefault("last_snapshot", None)
    return data


STATE = load_state()


def save_state() -> None:
    with state_lock:
        os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
        tmp = STATE_FILE + ".tmp"
        with open(tmp, "w") as f:
            json.dump(STATE, f, indent=1, default=str)
        os.replace(tmp, STATE_FILE)


def record_decision(batch: dict, outcome: str) -> None:
    with state_lock:
        STATE["decisions"].append(
            {
                "time": now_local().isoformat(timespec="minutes"),
                "batch": batch["id"],
                "outcome": outcome,
                "cold_snap": batch.get("cold_snap", False),
                "changes": batch["changes"],
            }
        )
        STATE["decisions"] = STATE["decisions"][-50:]
        save_state()


# ---------------------------------------------------------------- Home Assistant


def http_json(method: str, url: str, headers: dict, body=None, timeout: int = 30):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method, headers={"Content-Type": "application/json", **headers})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            raw = resp.read()
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"{method} {url} -> {e.code}: {e.read()[:500]!r}") from None
    if not raw:
        return None
    try:
        return json.loads(raw)
    except ValueError:
        return raw.decode(errors="replace")


def ha(method: str, path: str, body=None, timeout: int = 30):
    return http_json(method, f"{HA_URL}{path}", {"Authorization": f"Bearer {HA_TOKEN}"}, body, timeout)


def ha_template(template: str) -> str:
    return str(ha("POST", "/api/template", {"template": template})).strip()


def ha_service(domain: str, service: str, data: dict, return_response: bool = False):
    suffix = "?return_response" if return_response else ""
    return ha("POST", f"/api/services/{domain}/{service}{suffix}", data)


def ws_url() -> str:
    return HA_URL.replace("https://", "wss://").replace("http://", "ws://") + "/api/websocket"


def ws_open():
    ws = ws_connect(ws_url(), max_size=32 * 1024 * 1024, open_timeout=20)
    hello = json.loads(ws.recv(timeout=20))
    if hello.get("type") != "auth_required":
        raise RuntimeError(f"unexpected websocket greeting: {hello}")
    ws.send(json.dumps({"type": "auth", "access_token": HA_TOKEN}))
    reply = json.loads(ws.recv(timeout=20))
    if reply.get("type") != "auth_ok":
        raise RuntimeError(f"websocket auth failed: {reply}")
    return ws


def ws_request(payload: dict, timeout: int = 60):
    """One websocket command on its own short-lived connection."""
    with ws_open() as ws:
        ws.send(json.dumps({"id": 1, **payload}))
        while True:
            msg = json.loads(ws.recv(timeout=timeout))
            if msg.get("id") == 1 and msg.get("type") == "result":
                if not msg.get("success"):
                    raise RuntimeError(f"{payload['type']} failed: {msg.get('error')}")
                return msg.get("result")


def notify(message: str, title: str = "Heating agent", data: dict | None = None) -> None:
    for service in NOTIFY_SERVICES:
        try:
            ha_service("notify", service, {"title": title, "message": message, "data": {"tag": NOTIFY_TAG, **(data or {})}})
        except Exception as e:
            log(f"notify.{service} failed: {e}")


def clear_notification() -> None:
    for service in NOTIFY_SERVICES:
        try:
            ha_service("notify", service, {"message": "clear_notification", "data": {"tag": NOTIFY_TAG}})
        except Exception as e:
            log(f"clearing notify.{service} failed: {e}")


# ---------------------------------------------------------------- data collection


def stat_start(row: dict) -> datetime:
    start = row["start"]
    if isinstance(start, (int, float)):
        return datetime.fromtimestamp(start / 1000, tz=timezone.utc).astimezone(TZ)
    return datetime.fromisoformat(start).astimezone(TZ)


def discover_thermostats(states: list[dict]) -> list[dict]:
    by_id = {s["entity_id"]: s for s in states}
    ids = CLIMATE_ENTITIES or sorted(e for e in by_id if e.startswith("climate."))
    out = []
    for eid in ids:
        s = by_id.get(eid)
        if s is None:
            log(f"{eid} not found in Home Assistant, skipping")
            continue
        a = s["attributes"]
        demand_sensor = ha_template(
            "{{ device_entities(device_id('%s')) | select('match', 'sensor\\..*heating_demand') | first | default('') }}" % eid
        )
        humidity_sensor = ha_template(
            "{{ device_entities(device_id('%s')) | select('match', 'sensor\\..*humidity') | first | default('') }}" % eid
        )
        out.append(
            {
                "entity_id": eid,
                "room": ha_template("{{ area_name('%s') or '' }}" % eid) or a.get("friendly_name", eid),
                "hvac_mode": s["state"],
                "hvac_action": a.get("hvac_action"),
                "current_temperature": a.get("current_temperature"),
                "setpoint": a.get("temperature"),
                "heating_demand_pct": a.get("pi_heating_demand"),
                "humidity_pct": (by_id.get(humidity_sensor) or {}).get("state") if humidity_sensor else None,
                "heater_watts": float(HEATER_WATTS.get(eid, DEFAULT_HEATER_WATTS)),
                "demand_sensor": demand_sensor or None,
            }
        )
    return out


def energy_settings(states: list[dict]) -> tuple[str, float | None, str]:
    """Meter entity, $/kWh, and where the price came from.

    Read from the grid source in Home Assistant's Energy settings. The price there is
    either a fixed number or an entity (e.g. a time-of-use tariff sensor), whose
    current state is used. Env overrides win when set.
    """
    meter, price, source = "", None, "not configured"
    try:
        prefs = ws_request({"type": "energy/get_prefs"}) or {}
    except Exception as e:
        log(f"energy/get_prefs failed: {e}")
        prefs = {}
    grids = []
    for src in prefs.get("energy_sources", []):
        if src.get("type") == "grid":
            # Older Home Assistant versions nest the import meters under flow_from.
            grids += src.get("flow_from") or [src]
    grids = [g for g in grids if g.get("stat_energy_from")]
    pick = next((g for g in grids if g["stat_energy_from"] == METER_ENTITY_OVERRIDE), grids[0] if grids else None)
    if pick:
        meter = pick["stat_energy_from"]
        if pick.get("entity_energy_price"):
            state = next((s for s in states if s["entity_id"] == pick["entity_energy_price"]), None)
            try:
                price, source = float(state["state"]), pick["entity_energy_price"]
            except (TypeError, ValueError, KeyError):
                log(f"price entity {pick['entity_energy_price']} has no usable state")
        elif pick.get("number_energy_price") is not None:
            price, source = float(pick["number_energy_price"]), "Home Assistant energy settings"
    if METER_ENTITY_OVERRIDE:
        meter = METER_ENTITY_OVERRIDE
    if ENERGY_PRICE_OVERRIDE:
        price, source = float(ENERGY_PRICE_OVERRIDE), "ENERGY_PRICE env"
    return meter, price, source


def cost(kwh: float, price: float | None) -> float | None:
    return round(kwh * price, 2) if price is not None else None


def usage_history(thermostats: list[dict], meter_entity: str, price: float | None) -> dict:
    end = datetime.now(timezone.utc).replace(minute=0, second=0, microsecond=0)
    start = end - timedelta(days=HISTORY_DAYS)
    ids = [t["demand_sensor"] for t in thermostats if t["demand_sensor"]]
    if meter_entity:
        ids.append(meter_entity)
    stats = ws_request(
        {
            "type": "recorder/statistics_during_period",
            "start_time": start.isoformat(),
            "end_time": end.isoformat(),
            "statistic_ids": ids,
            "period": "hour",
            "types": ["mean", "change"],
        }
    ) or {}

    day_cut = now_local() - timedelta(hours=24)
    heating_by_hour: dict[datetime, float] = {}
    rooms = []
    for t in thermostats:
        rows = stats.get(t["demand_sensor"] or "", [])
        kw = t["heater_watts"] / 1000
        daily: dict[str, float] = {}
        profile_sum = [0.0] * 24
        profile_n = [0] * 24
        kwh_24h = 0.0
        for r in rows:
            if r.get("mean") is None:
                continue
            ts = stat_start(r)
            kwh = kw * r["mean"] / 100  # one hour at mean demand
            daily[ts.strftime("%a %m-%d")] = daily.get(ts.strftime("%a %m-%d"), 0) + kwh
            profile_sum[ts.hour] += r["mean"]
            profile_n[ts.hour] += 1
            heating_by_hour[ts] = heating_by_hour.get(ts, 0) + kwh
            if ts >= day_cut:
                kwh_24h += kwh
        total = sum(daily.values())
        rooms.append(
            {
                "entity_id": t["entity_id"],
                "room": t["room"],
                "est_kwh_last_24h": round(kwh_24h, 2),
                f"est_kwh_last_{HISTORY_DAYS}d": round(total, 1),
                f"est_cost_last_{HISTORY_DAYS}d": cost(total, price),
                "est_kwh_per_day": {d: round(v, 1) for d, v in daily.items()},
                # Average heating demand (%) by local hour of day, 0..23.
                "avg_demand_by_hour": [round(profile_sum[h] / profile_n[h]) if profile_n[h] else None for h in range(24)],
            }
        )

    meter = None
    rows = stats.get(meter_entity, []) if meter_entity else []
    if rows:
        daily: dict[str, float] = {}
        total = kwh_24h = 0.0
        idle_hours: list[float] = []
        for r in rows:
            change = r.get("change")
            if change is None or change < 0:
                continue
            ts = stat_start(r)
            daily[ts.strftime("%a %m-%d")] = daily.get(ts.strftime("%a %m-%d"), 0) + change
            total += change
            if ts >= day_cut:
                kwh_24h += change
            if ts in heating_by_hour and heating_by_hour[ts] < 0.05:
                idle_hours.append(change)
        est_heat_total = sum(heating_by_hour.values())
        base = sorted(idle_hours)[len(idle_hours) // 2] if idle_hours else None
        meter = {
            "entity_id": meter_entity,
            "kwh_last_24h": round(kwh_24h, 2),
            f"kwh_last_{HISTORY_DAYS}d": round(total, 1),
            f"cost_last_{HISTORY_DAYS}d": cost(total, price),
            "kwh_per_day": {d: round(v, 1) for d, v in daily.items()},
            "estimated_heating_share_pct": round(100 * est_heat_total / total) if total else None,
            # Median meter use in hours with no heating; compare against the heating
            # estimates to see whether HEATER_WATTS is roughly right.
            "median_kwh_per_hour_without_heating": round(base, 2) if base is not None else None,
        }
    return {"rooms": rooms, "whole_house_meter": meter}


def weather_snapshot(states: list[dict]) -> dict:
    current = next((s for s in states if s["entity_id"] == WEATHER_ENTITY), None)
    out: dict = {"entity_id": WEATHER_ENTITY}
    if current:
        a = current["attributes"]
        out["now"] = {"condition": current["state"], "temperature": a.get("temperature"), "wind_speed": a.get("wind_speed"), "humidity": a.get("humidity")}
    for kind in ("hourly", "daily"):
        try:
            resp = ha_service("weather", "get_forecasts", {"entity_id": WEATHER_ENTITY, "type": kind}, return_response=True)
            out[kind] = resp["service_response"][WEATHER_ENTITY]["forecast"]
        except Exception as e:
            log(f"{kind} forecast failed: {e}")
            out[kind] = []

    # Coldest point coming up, from the hourly forecast (falls back to daily lows).
    horizon = now_local() + timedelta(hours=COLD_LOOKAHEAD_HOURS)
    coldest = None
    for f in out["hourly"]:
        ts = datetime.fromisoformat(f["datetime"]).astimezone(TZ)
        if ts <= horizon and f.get("temperature") is not None and (coldest is None or f["temperature"] < coldest[1]):
            coldest = (ts, f["temperature"])
    if coldest is None:
        for f in out["daily"][:2]:
            low = f.get("templow", f.get("temperature"))
            if low is not None and (coldest is None or low < coldest[1]):
                coldest = (datetime.fromisoformat(f["datetime"]).astimezone(TZ), low)
    out["coldest_next_hours"] = {"hours": COLD_LOOKAHEAD_HOURS, "time": coldest[0].isoformat(timespec="minutes"), "temperature": coldest[1]} if coldest else None
    out["cold_snap"] = bool(coldest and coldest[1] <= COLD_THRESHOLD_C)

    # Keep the prompt small: every 3rd hour for 48h, 5 days of daily.
    out["hourly"] = [
        {"time": f["datetime"][5:16], "temp": f.get("temperature"), "wind": f.get("wind_speed"), "condition": f.get("condition")}
        for f in out["hourly"][:48:3]
    ]
    out["daily"] = [
        {"date": f["datetime"][:10], "high": f.get("temperature"), "low": f.get("templow"), "condition": f.get("condition")}
        for f in out["daily"][:5]
    ]
    return out


def heating_schedule(states: list[dict]) -> list[dict]:
    """Time-based automations that touch heating, summarised for the prompt."""
    out = []
    for s in states:
        if not s["entity_id"].startswith("automation."):
            continue
        a = s["attributes"]
        name = a.get("friendly_name", s["entity_id"])
        if "heat" not in name.lower() and "thermostat" not in name.lower():
            continue
        entry = {"name": name, "enabled": s["state"] == "on"}
        try:
            cfg = ha("GET", f"/api/config/automation/config/{a['id']}")
            entry["at"] = [t.get("at") for t in cfg.get("triggers", cfg.get("trigger", [])) if t.get("at")]
            entry["sets"] = sorted({str(x.get("hvac_mode") or x.get("data", {}).get("hvac_mode") or x.get("data", {}).get("temperature")) for x in cfg.get("actions", cfg.get("action", []))})
            entry["thermostats"] = len(cfg.get("actions", cfg.get("action", [])))
        except Exception:
            pass
        out.append(entry)
    return out


def collect() -> dict:
    states = ha("GET", "/api/states")
    thermostats = discover_thermostats(states)
    meter_entity, price, price_source = energy_settings(states)
    snapshot = {
        "time": now_local().isoformat(timespec="minutes"),
        "energy_price_per_kwh": price,
        "energy_price_source": price_source,
        "thermostats": thermostats,
        "usage": usage_history(thermostats, meter_entity, price),
        "weather": weather_snapshot(states),
        "schedule": heating_schedule(states),
    }
    for t in thermostats:
        t.pop("demand_sensor", None)
    return snapshot


# ---------------------------------------------------------------- LLM


PLAN_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["summary", "observations", "proposals"],
    "properties": {
        "summary": {"type": "string"},
        "observations": {"type": "array", "items": {"type": "string"}},
        "proposals": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "required": ["entity_id", "action", "temperature", "hvac_mode", "reason"],
                "properties": {
                    "entity_id": {"type": "string"},
                    "action": {"type": "string", "enum": ["set_temperature", "set_hvac_mode"]},
                    "temperature": {"type": ["number", "null"]},
                    "hvac_mode": {"type": ["string", "null"], "enum": ["heat", "off", None]},
                    "reason": {"type": "string"},
                },
            },
        },
    },
}


def system_prompt() -> str:
    return f"""You manage electric baseboard heating in a home in {TZ.key}. You get a JSON
snapshot: each thermostat (room, mode, setpoint, current temperature, heating demand),
estimated electricity use per room (heater watts x demand) and the whole-house meter,
the weather forecast, the existing time-based heating schedule, and the decisions the
homeowner made on your earlier proposals.

Your job: make the heating cheaper without making the home uncomfortable, and protect
the home when it gets very cold.
- Look for waste: rooms heated hard while likely unused, setpoints higher than other
  rooms for no clear reason, heat fighting very cold or windy hours at peak demand.
- Weather: when a cold snap is forecast (coldest temperature <= {COLD_THRESHOLD_C} C, see
  weather.cold_snap), do not turn heat off or lower setpoints below {COLD_MIN_SETPOINT} C.
  Prefer keeping rooms warm through the cold rather than letting them cool and
  recovering at full power; suggest keeping heat on in rooms the schedule turns off.
  On mild days, suggest small setbacks.
- Setpoints must stay between {MIN_SETPOINT} and {MAX_SETPOINT} C. Change at most 2 C at a time.
- Only propose changes that apply now; you run again every few hours.
- Respect past decisions: if the homeowner skipped a similar change recently, do not
  propose it again unless conditions changed (for example a cold snap).
- Propose nothing if things look fine. Fewer, well-reasoned changes are better.
- Each reason is one short sentence the homeowner reads on a phone, with the
  expected effect (kWh or $ where you can estimate it).
summary: 2-3 sentences on usage and weather. observations: up to 5 short findings."""


def llm(messages: list[dict], timeout: int, schema: dict | None = None, max_tokens: int = 1500) -> str:
    body: dict = {
        "model": MODEL,
        "messages": messages,
        "temperature": 0.2,
        "max_tokens": max_tokens,
        # Gemma 4 thinks by default: a plan took 5+ minutes, nearly all of it
        # thousands of hidden reasoning tokens before the JSON started. The prompt
        # already spells out the rules, so answer directly (as media-qc does).
        "chat_template_kwargs": {"enable_thinking": False},
    }
    if schema:
        body["response_format"] = {"type": "json_schema", "json_schema": {"name": "heating_plan", "schema": schema, "strict": True}}
    resp = http_json("POST", f"{LITELLM_URL}/v1/chat/completions", {"Authorization": f"Bearer {LITELLM_KEY}"}, body, timeout)
    choice = resp["choices"][0]
    if choice.get("finish_reason") == "length":
        raise RuntimeError(f"model hit max_tokens ({max_tokens}) before finishing")
    return choice["message"]["content"]


def plan(snapshot: dict) -> dict:
    with state_lock:
        decisions = STATE["decisions"][-15:]
    content = json.dumps({"snapshot": snapshot, "past_decisions": decisions}, default=str)
    raw = llm([{"role": "system", "content": system_prompt()}, {"role": "user", "content": content}], LLM_TIMEOUT, PLAN_SCHEMA)
    return json.loads(raw)


# ---------------------------------------------------------------- guardrails


def change_key(c: dict) -> str:
    return f"{c['entity_id']}:{c['action']}:{c.get('temperature')}:{c.get('hvac_mode')}"


def vet(proposals: list[dict], snapshot: dict) -> tuple[list[dict], list[str]]:
    thermostats = {t["entity_id"]: t for t in snapshot["thermostats"]}
    cold = snapshot["weather"]["cold_snap"]
    cutoff = now_local() - timedelta(hours=SKIP_COOLDOWN_HOURS)
    with state_lock:
        recently_skipped = {
            change_key(c)
            for d in STATE["decisions"]
            if d["outcome"] in ("skipped", "expired") and datetime.fromisoformat(d["time"]) >= cutoff
            for c in d["changes"]
        }
    kept, dropped, seen = [], [], set()
    for p in proposals:
        eid = p.get("entity_id")
        t = thermostats.get(eid)
        why = None
        if t is None:
            why = "unknown thermostat"
        elif eid in seen:
            why = "more than one change for the same thermostat"
        elif p["action"] == "set_temperature":
            temp = p.get("temperature")
            if temp is None:
                why = "no temperature given"
            else:
                temp = round(float(temp) * 2) / 2
                p["temperature"] = temp
                if not MIN_SETPOINT <= temp <= MAX_SETPOINT:
                    why = f"{temp} C is outside {MIN_SETPOINT}-{MAX_SETPOINT} C"
                elif cold and temp < COLD_MIN_SETPOINT:
                    why = f"cold snap: {temp} C is below the {COLD_MIN_SETPOINT} C floor"
                elif t["setpoint"] is not None and abs(temp - t["setpoint"]) < 0.5:
                    why = "no change"
                elif t["setpoint"] is not None and abs(temp - t["setpoint"]) > 2:
                    why = "more than 2 C at once"
            p["hvac_mode"] = None
        elif p["action"] == "set_hvac_mode":
            mode = p.get("hvac_mode")
            if mode not in ("heat", "off"):
                why = f"unsupported mode {mode}"
            elif cold and mode == "off":
                why = "cold snap: heat stays on"
            elif mode == t["hvac_mode"]:
                why = "no change"
            p["temperature"] = None
        else:
            why = f"unsupported action {p['action']}"
        if why is None and change_key(p) in recently_skipped:
            why = f"skipped in the last {SKIP_COOLDOWN_HOURS:g}h"
        if why:
            dropped.append(f"{eid}: {why}")
            continue
        seen.add(eid)
        p["room"] = t["room"]
        p["from"] = t["setpoint"] if p["action"] == "set_temperature" else t["hvac_mode"]
        kept.append(p)
    return kept, dropped


def describe(c: dict) -> str:
    if c["action"] == "set_temperature":
        return f"{c['room']}: {c['from']} -> {c['temperature']} C"
    return f"{c['room']}: heat {c['from']} -> {c['hvac_mode']}"


# ---------------------------------------------------------------- scan, apply


def in_quiet_hours(at: datetime) -> bool:
    try:
        a, b = (int(x) for x in QUIET_HOURS.split("-"))
    except ValueError:
        return False
    return a <= at.hour < b if a < b else at.hour >= a or at.hour < b


def scan(reason: str) -> str:
    if not scan_lock.acquire(blocking=False):
        return "A scan is already running."
    try:
        log(f"scan started ({reason})")
        snapshot = collect()
        result = plan(snapshot)
        changes, dropped = vet(result.get("proposals", []), snapshot)
        w = snapshot["weather"]
        cold_line = ""
        if w.get("coldest_next_hours"):
            c = w["coldest_next_hours"]
            cold_line = f"Coldest in next {c['hours']}h: {c['temperature']} C at {c['time'][11:16]}" + (" (cold snap)" if w["cold_snap"] else "")
        report = "\n".join(
            [f"Heating report {snapshot['time']}", result.get("summary", ""), cold_line]
            + [f"- {o}" for o in result.get("observations", [])]
            + ([f"Not proposed (guardrails): {'; '.join(dropped)}"] if dropped else [])
        )

        with state_lock:
            STATE["last_scan"] = time.time()
            STATE["last_report"] = report
            STATE["last_snapshot"] = snapshot
            # A new analysis replaces anything still waiting.
            for old in list(STATE["pending"].values()):
                record_decision(old, "superseded")
            STATE["pending"].clear()
            batch = None
            if changes:
                batch = {
                    "id": secrets.token_hex(3),
                    "created": time.time(),
                    "cold_snap": w["cold_snap"],
                    "changes": [
                        {k: c[k] for k in ("entity_id", "room", "action", "temperature", "hvac_mode", "from", "reason")}
                        for c in changes
                    ],
                }
                STATE["pending"][batch["id"]] = batch
            save_state()

        log(report.replace("\n", " | "))
        if batch:
            lines = [f"{describe(c)} - {c['reason']}" for c in batch["changes"]]
            title = "Cold snap: heating proposal" if w["cold_snap"] else "Heating proposal"
            notify(
                "\n".join(lines) + f"\n\n{result.get('summary', '')}\nExpires in {PROPOSAL_TTL_MINUTES} min. (id {batch['id']})",
                title=title,
                data={
                    "actions": [
                        {"action": f"{ACTION_PREFIX}APPLY_{batch['id']}", "title": "Apply"},
                        {"action": f"{ACTION_PREFIX}SKIP_{batch['id']}", "title": "Skip"},
                    ],
                    "importance": "high" if w["cold_snap"] else "default",
                    "ttl": 0,
                    "priority": "high",
                },
            )
            return report + "\n\nProposed (sent to your phone, id " + batch["id"] + "):\n" + "\n".join(lines)
        return report + "\n\nNo changes proposed."
    finally:
        scan_lock.release()


def apply_batch(batch_id: str) -> str:
    with state_lock:
        batch = STATE["pending"].pop(batch_id, None)
        save_state()
    if batch is None:
        return f"No pending proposal {batch_id} (already handled or expired)."
    results = []
    for c in batch["changes"]:
        try:
            if c["action"] == "set_temperature":
                ha_service("climate", "set_temperature", {"entity_id": c["entity_id"], "temperature": c["temperature"]})
            else:
                ha_service("climate", "set_hvac_mode", {"entity_id": c["entity_id"], "hvac_mode": c["hvac_mode"]})
            results.append(f"done: {describe(c)}")
        except Exception as e:
            results.append(f"FAILED: {describe(c)} ({e})")
    record_decision(batch, "applied")
    text = "\n".join(results)
    log(f"applied {batch_id}: {text}")
    notify(text, title="Heating changes applied")
    return text


def skip_batch(batch_id: str, outcome: str = "skipped") -> str:
    with state_lock:
        batch = STATE["pending"].pop(batch_id, None)
        save_state()
    if batch is None:
        return f"No pending proposal {batch_id}."
    record_decision(batch, outcome)
    log(f"{outcome} {batch_id}")
    if outcome == "expired":
        clear_notification()
    return f"Proposal {batch_id} {outcome}; nothing was changed."


# ---------------------------------------------------------------- background loops


def scheduler() -> None:
    last_weather_check = 0.0
    last_attempt = 0.0  # a failed scan is retried after 30 minutes, not every tick
    while True:
        try:
            now = time.time()
            with state_lock:
                expired = [b["id"] for b in STATE["pending"].values() if now - b["created"] > PROPOSAL_TTL_MINUTES * 60]
            for bid in expired:
                skip_batch(bid, "expired")

            if now - last_weather_check >= 3600:
                last_weather_check = now
                states = ha("GET", "/api/states")
                w = weather_snapshot(states)
                with state_lock:
                    recent_cold_scan = now - STATE["last_cold_scan"] < 12 * 3600
                if w["cold_snap"] and not recent_cold_scan:
                    last_attempt = now
                    with state_lock:
                        STATE["last_cold_scan"] = now
                        save_state()
                    scan(f"cold snap forecast: {w['coldest_next_hours']}")
                    continue

            with state_lock:
                due = now - STATE["last_scan"] >= SCAN_INTERVAL_HOURS * 3600
            if due and now - last_attempt >= 1800 and not in_quiet_hours(now_local()):
                last_attempt = now
                scan("scheduled")
        except Exception:
            traceback.print_exc()
        time.sleep(60)


def event_listener() -> None:
    """Applies or skips a batch when a notification button is pressed."""
    while True:
        try:
            with ws_open() as ws:
                ws.send(json.dumps({"id": 1, "type": "subscribe_events", "event_type": "mobile_app_notification_action"}))
                log("listening for notification actions")
                for raw in ws:
                    msg = json.loads(raw)
                    if msg.get("type") != "event":
                        continue
                    action = msg["event"]["data"].get("action", "")
                    if not action.startswith(ACTION_PREFIX):
                        continue
                    verb, _, bid = action[len(ACTION_PREFIX):].partition("_")
                    if verb == "APPLY":
                        threading.Thread(target=apply_batch, args=(bid,), daemon=True).start()
                    elif verb == "SKIP":
                        skip_batch(bid)
        except Exception as e:
            log(f"websocket listener: {e}; reconnecting in 15s")
            time.sleep(15)


# ---------------------------------------------------------------- A2A server


def agent_card() -> dict:
    return {
        "protocolVersion": "0.3.0",
        "name": "heating-agent",
        "description": "Watches thermostat electricity use and the weather in Home Assistant and proposes heating changes. Changes are only applied after the homeowner approves them.",
        "url": AGENT_URL,
        "preferredTransport": "JSONRPC",
        "version": "1.0.0",
        "capabilities": {"streaming": False, "pushNotifications": False},
        "defaultInputModes": ["text/plain"],
        "defaultOutputModes": ["text/plain"],
        "skills": [
            {"id": "report", "name": "Heating report", "description": "Latest usage and weather analysis plus pending proposals.", "tags": ["heating", "energy"], "examples": ["report"]},
            {"id": "scan", "name": "Scan now", "description": "Run a new analysis; proposals arrive as a phone notification.", "tags": ["heating"], "examples": ["scan"]},
            {"id": "decide", "name": "Apply or skip", "description": "Apply or skip a pending proposal by id.", "tags": ["heating"], "examples": ["apply a1b2c3", "skip a1b2c3"]},
            {"id": "ask", "name": "Ask", "description": "Questions about heating use, answered from the latest snapshot.", "tags": ["heating"], "examples": ["Which room uses the most power?"]},
        ],
    }


def pending_text() -> str:
    with state_lock:
        batches = list(STATE["pending"].values())
    if not batches:
        return "No pending proposals."
    out = []
    for b in batches:
        out.append(f"Pending {b['id']}:")
        out += [f"  {describe(c)} - {c['reason']}" for c in b["changes"]]
    return "\n".join(out)


def handle_text(text: str) -> str:
    words = text.strip().split()
    cmd = words[0].lower() if words else "report"
    arg = words[1] if len(words) > 1 else ""
    if cmd in ("report", "status"):
        with state_lock:
            report = STATE["last_report"] or "No scan has run yet."
        return f"{report}\n\n{pending_text()}"
    if cmd == "scan":
        if scan_lock.locked():
            return "A scan is already running."
        threading.Thread(target=scan, args=("requested over A2A",), daemon=True).start()
        return "Scan started. Proposals (if any) will arrive as a phone notification; ask for 'report' in a few minutes."
    if cmd in ("apply", "approve") and arg:
        return apply_batch(arg)
    if cmd in ("skip", "reject") and arg:
        return skip_batch(arg)
    with state_lock:
        snapshot = STATE["last_snapshot"]
        report = STATE["last_report"]
    if not snapshot:
        return "No scan has run yet. Send 'scan' first."
    try:
        return llm(
            [
                {"role": "system", "content": "Answer questions about this home's heating from the snapshot. Be brief. You cannot change anything; tell the user to reply 'scan' for new proposals."},
                {"role": "user", "content": json.dumps({"snapshot": snapshot, "latest_report": report, "question": text}, default=str)},
            ],
            CHAT_TIMEOUT,
            max_tokens=600,
        )
    except Exception as e:
        log(f"chat answer failed: {e}")
        return f"(The model did not answer in time; here is the latest report.)\n\n{report}"


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def send_json(self, code: int, body: dict) -> None:
        data = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path in ("/.well-known/agent-card.json", "/.well-known/agent.json"):
            self.send_json(200, agent_card())
        elif self.path == "/healthz":
            self.send_json(200, {"ok": True})
        else:
            self.send_json(404, {"error": "not found"})

    def do_POST(self):
        try:
            req = json.loads(self.rfile.read(int(self.headers.get("Content-Length", 0))) or b"{}")
        except ValueError:
            return self.send_json(400, {"jsonrpc": "2.0", "id": None, "error": {"code": -32700, "message": "parse error"}})
        rid = req.get("id")
        if req.get("method") != "message/send":
            return self.send_json(200, {"jsonrpc": "2.0", "id": rid, "error": {"code": -32601, "message": f"method {req.get('method')} not supported"}})
        msg = (req.get("params") or {}).get("message") or {}
        text = " ".join(p.get("text", "") for p in msg.get("parts", []) if p.get("kind", "text") == "text")
        try:
            answer = handle_text(text)
        except Exception as e:
            traceback.print_exc()
            answer = f"Error: {e}"
        result = {
            "kind": "message",
            "messageId": secrets.token_hex(8),
            "role": "agent",
            "parts": [{"kind": "text", "text": answer}],
        }
        if msg.get("contextId"):
            result["contextId"] = msg["contextId"]
        self.send_json(200, {"jsonrpc": "2.0", "id": rid, "result": result})


def main() -> None:
    if not NOTIFY_SERVICES:
        sys.exit("NOTIFY_SERVICES is empty: proposals need somewhere to go")
    threading.Thread(target=event_listener, daemon=True).start()
    threading.Thread(target=scheduler, daemon=True).start()
    log(f"heating-agent listening on :{PORT}")
    ThreadingHTTPServer(("", PORT), Handler).serve_forever()


if __name__ == "__main__":
    main()
