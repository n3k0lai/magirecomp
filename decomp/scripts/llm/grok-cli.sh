#!/usr/bin/env bash
# WORKER_LLM_CMD adapter that uses the grok CLI login the old hearth loop used
# (no API key needed on a machine where `grok` is logged in).
# Context pack on stdin, reply on stdout, {"tokens": N} on stderr.
# One turn, no tools: the pack already holds everything (AGENTS.md W6).
set -euo pipefail
command -v grok >/dev/null || { echo "grok CLI not on PATH" >&2; exit 127; }
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/pack.md"
args=(--prompt-file "$tmp/pack.md" --verbatim --no-auto-update --disable-web-search
      --no-subagents --output-format json --max-turns 1 --effort "${WORKER_EFFORT:-low}"
      --tools "" --cwd "$tmp")
[ -n "${WORKER_MODEL:-}" ] && args=(--model "$WORKER_MODEL" "${args[@]}")
out=$(grok "${args[@]}")
jq -r '.text // ""' <<<"$out"
jq -c '{tokens: ((.usage.input_tokens // 0) + (.usage.output_tokens // 0) + (.usage.cache_read_input_tokens // 0))}' <<<"$out" >&2
