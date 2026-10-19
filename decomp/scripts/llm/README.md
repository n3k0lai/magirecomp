# Model adapters

The worker calls a model for one thing only: naming a placeholder
(`sub_XXXXXX`, `unk_XXXXXX`) from the evidence in its context pack
(AGENTS.md W8). Bytes never come from a model; lift.py writes them and the
build judges them.

An adapter is any command that reads the pack on stdin, prints the reply on
stdout, and may print `{"tokens": N}` on stderr so metrics.csv records real
usage (otherwise the worker estimates chars/4).

    export XAI_API_KEY=...            # not stored in the repo or on disk by us
    export WORKER_LLM_CMD=scripts/llm/xai.sh
    python3 scripts/worker.py pack sub_0C0AE9      # see exactly what is sent
    python3 scripts/worker.py name sub_0C0AE9      # one round, verified, committed or logged
    make worker NAMES=20                            # lifts, propagation, then 20 naming rounds

On a machine where the `grok` CLI is logged in, `WORKER_LLM_CMD=scripts/llm/grok-cli.sh` needs no API key. It runs
one turn with no tools.

`WORKER_MODEL` picks the model (default `grok-code-fast-1`). Any other
vendor works the same way: write a script with the same stdin/stdout contract.
