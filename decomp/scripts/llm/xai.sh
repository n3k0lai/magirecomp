#!/usr/bin/env bash
# WORKER_LLM_CMD adapter for the naming round (AGENTS.md W8).
# Context pack on stdin, reply on stdout, {"tokens": N} on stderr.
# One request, no tools, no repo reading. Needs XAI_API_KEY in the
# environment; this script never prints it.
#   WORKER_LLM_CMD=scripts/llm/xai.sh python3 scripts/worker.py name sub_0C0AE9
set -euo pipefail
: "${XAI_API_KEY:?set XAI_API_KEY (see scripts/llm/README.md)}"
model="${WORKER_MODEL:-grok-code-fast-1}"
resp=$(jq -n --arg m "$model" --rawfile p /dev/stdin \
  '{model:$m, temperature:0, max_tokens:400,
    messages:[{role:"system",content:"You name routines and tables in a Game Boy matching disassembly. Answer only from the evidence in the pack. Reply KEEP when it does not prove a name."},
              {role:"user",content:$p}]}' |
  curl -sS --fail-with-body https://api.x.ai/v1/chat/completions \
    -H "Authorization: Bearer $XAI_API_KEY" -H "Content-Type: application/json" -d @-)
jq -r '.choices[0].message.content' <<<"$resp"
jq -c '{tokens: (.usage.total_tokens // 0)}' <<<"$resp" >&2
