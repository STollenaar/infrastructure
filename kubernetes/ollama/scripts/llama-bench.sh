#!/usr/bin/env bash
# Raw llama.cpp throughput for every chat model configured in llama-swap, measured
# with llama-bench inside the llama-swap pod (same image, same Vulkan build, same
# GGUFs from the HF cache on the PVC).
#
# llama-bench needs the GPU to itself, so llama-swap is paused for the duration:
# that unloads every model and rejects inference requests until it is resumed,
# which the EXIT trap does even if a run fails or is interrupted.
#
# Usage: llama-bench.sh [repo-filter]     e.g. llama-bench.sh gemma
# Env:   P (prompt tokens, 512)  N (generated tokens, 128)  R (repetitions, 3)
set -euo pipefail

NS=ollama
TARGET=deploy/llama-swap
P=${P:-512}
N=${N:-128}
R=${R:-3}
filter=${1:-}

k() { kubectl -n "$NS" exec "$TARGET" -c llama-swap -- "$@"; }
api() { k curl -sf -o /dev/null -w '%{http_code}' -X POST "http://127.0.0.1:8080/api/models/$1"; }

# The -hf repo:quant of each llama-server entry, straight from the live config.
mapfile -t repos < <(k sh -c "grep -o -- '-hf [^ \"]*' /etc/llama-swap/config/config.yaml | cut -d' ' -f2 | sort -u")

echo "pausing llama-swap (models unloaded, requests rejected until resumed)"
if ! api pause >/dev/null; then
  echo "pause not supported by this llama-swap; unloading instead (requests may reload a model mid-run)"
  api unload >/dev/null
fi
trap 'api resume >/dev/null 2>&1 || true; echo "llama-swap resumed"' EXIT

for repo in "${repos[@]}"; do
  [[ -n $filter && $repo != *"$filter"* ]] && continue
  echo
  echo "== $repo  (pp$P / tg$N, $R reps)"
  # HF_HOME comes from the container env, so -hf resolves to the cached GGUF.
  k llama-bench -hf "$repo" -ngl 999 -p "$P" -n "$N" -r "$R" -o md
done
