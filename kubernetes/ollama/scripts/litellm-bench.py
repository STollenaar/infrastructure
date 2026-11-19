#!/usr/bin/env python3
"""End-to-end benchmark of the models behind LiteLLM.

Goes through the same path as real callers (ingress -> LiteLLM -> llama-swap ->
llama-server / sd-server), so the numbers include proxy overhead and every request
shows up in the LiteLLM Logs/spend view.

Per chat model: one warm-up request (absorbs a llama-swap model swap, which can take
minutes from NFS), then RUNS streamed requests measuring time to first token
(thinking tokens count as the first token) and generation speed. Image models get
one timed generation.

Usage:
  LITELLM_KEY=sk-... ./litellm-bench.py                 # every model LiteLLM lists
  LITELLM_KEY=sk-... ./litellm-bench.py qwen3.5-9b      # just these
Env: LITELLM_URL (default https://llm.home.spicedelver.me), RUNS (3), MAX_TOKENS (256)
"""
import json
import os
import sys
import time
import urllib.request

URL = os.environ.get("LITELLM_URL", "https://llm.home.spicedelver.me").rstrip("/")
KEY = os.environ.get("LITELLM_KEY") or sys.exit("set LITELLM_KEY")
RUNS = int(os.environ.get("RUNS", "3"))
MAX_TOKENS = int(os.environ.get("MAX_TOKENS", "256"))
PROMPT = ("Explain, in about 200 words, how a refrigerator moves heat from inside "
          "to outside. Use plain language.")
HEADERS = {"Authorization": f"Bearer {KEY}", "Content-Type": "application/json"}


def request(path, body=None, timeout=900):
    req = urllib.request.Request(URL + path, headers=HEADERS,
                                 data=json.dumps(body).encode() if body else None)
    return urllib.request.urlopen(req, timeout=timeout)


def model_modes():
    """model_name -> mode, from LiteLLM's model info."""
    with request("/model/info") as r:
        data = json.load(r)["data"]
    return {m["model_name"]: (m.get("model_info") or {}).get("mode") or "chat" for m in data}


def chat_once(model):
    body = {"model": model, "messages": [{"role": "user", "content": PROMPT}],
            "max_tokens": MAX_TOKENS, "stream": True,
            "stream_options": {"include_usage": True}}
    start = time.monotonic()
    first = None
    usage = {}
    with request("/v1/chat/completions", body) as r:
        for raw in r:
            line = raw.decode().strip()
            if not line.startswith("data:") or line == "data: [DONE]":
                continue
            chunk = json.loads(line[5:])
            usage = chunk.get("usage") or usage
            for c in chunk.get("choices") or []:
                d = c.get("delta") or {}
                if first is None and (d.get("content") or d.get("reasoning_content")):
                    first = time.monotonic()
    end = time.monotonic()
    out = usage.get("completion_tokens", 0)
    gen_s = end - (first or end)
    return {"ttft": (first or end) - start, "total": end - start,
            "prompt_tokens": usage.get("prompt_tokens", 0), "out_tokens": out,
            "tok_s": (out - 1) / gen_s if out > 1 and gen_s > 0 else 0.0}


def bench_chat(model):
    print(f"\n== {model}  (warm-up: may include a model load)")
    w = chat_once(model)
    print(f"   warm-up  ttft {w['ttft']:7.2f}s  total {w['total']:7.2f}s")
    runs = [chat_once(model) for _ in range(RUNS)]
    for i, r in enumerate(runs, 1):
        print(f"   run {i}    ttft {r['ttft']:7.2f}s  {r['out_tokens']:4d} tok  "
              f"{r['tok_s']:6.1f} tok/s  total {r['total']:7.2f}s")
    avg = lambda k: sum(r[k] for r in runs) / len(runs)
    print(f"   avg      ttft {avg('ttft'):7.2f}s                 {avg('tok_s'):6.1f} tok/s")


def bench_image(model):
    print(f"\n== {model}  (image, 512x512; includes a model load if not resident)")
    start = time.monotonic()
    with request("/v1/images/generations",
                 {"model": model, "prompt": "a red fox in fresh snow, photo", "size": "512x512"}) as r:
        ok = bool(json.load(r).get("data"))
    print(f"   {'ok' if ok else 'no image returned'}  {time.monotonic() - start:7.2f}s")


def main():
    modes = model_modes()
    wanted = sys.argv[1:] or sorted(modes)
    for model in wanted:
        try:
            (bench_image if modes.get(model) == "image_generation" else bench_chat)(model)
        except Exception as e:  # keep going so one broken model doesn't hide the rest
            print(f"   FAILED: {e}")


if __name__ == "__main__":
    main()
