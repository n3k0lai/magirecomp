# Pipeline audit and redesign (2026-10-18)

## What ran before

**hearth (overnight loop, Oct 9-11).** One model session per "slice": the
next uncovered byte, a prompt, about 9 turns. 3,707 slices logged; 3,591
committed, 66 reverted, 50 empty. The median slice used 9 turns and 206k
tokens (mostly cached input). The total logged cost was $304.81.

**own worker (Oct 13).** One unit per model call, scored by a byte diff.
73 attempts: 55 committed, 9 skipped, 6 rejected, 2 failed.

## What was wrong

1. **The model did deterministic work.** Byte-matching SM83 asm is
   mechanical: decoding, splitting at labels, and re-emitting are exact.
   Every slice still paid for a model session to do it.
2. **The rules pushed models to guess.** The old W6 rule banned
   address-only labels, so every unit had to arrive with a name. With no
   evidence behind them, names were guesses, and guesses spread.
3. **There was no hard gate on one rule set.** Rules lived in several
   prompts (`slice_prompt*.md`, the hearth config). The commit check was a
   per-slice byte diff, not `make compare` plus the rule checks over the
   whole tree.
4. **Progress was mis-measured.** `make report` / `test_report` was broken
   at HEAD: 45 sections mixed code and data, and some bank-end sections
   stopped short where the linker fills. The report counted all source as
   code, and there was no code/data split.
5. **Aliases piled up as debt.** 450 `DEF name EQU $xxxx` aliases pointed at
   ROM addresses that already had labels. Some carried RAM-style `w`
   prefixes on ROM data.
6. **Nobody saw that the code was finished.** No call, jump, or far call
   lands in an INCBIN hole any more. Code is 100% lifted (86,132 bytes).
   The 1.26 MB left is data: graphics, maps, text, and music. That needs
   codecs, not more model slices.

## What changed

- **AGENTS.md** is now the single home for rules. It has rule IDs
  (L, O, C, S, A, W), and the tool that checks each rule is named next to it.
- **Counting.** `make progress` reports DONE code and DONE data separately
  (`--banks` per bank, `--record` writes to `docs/progress-history.tsv`).
  `--check-map` validates the text-based instruction lengths against the
  linker map: 1,431 sections, 0 disagree.
- **`make check`** runs `check_tree` and `check_rules`. The rules cover
  placeholder addresses, headers, and fragments. The ratchets in
  `config/ratchets.tsv` may only go down (def_alias, raw_flow, device). The
  pre-commit hook runs the check.
- **Mechanical tools.**
  - `xref.py` finds every call, jump, far call, and pointer, with banks
    resolved.
  - `lift.py` plans and splices units. Code is lifted only where flow lands.
    Tables are lifted only for same-bank pointer loads, ≤512 B, with no code
    evidence inside them. Cross-bank data is an asset and needs a codec.
  - `propagate.py` turns DEF aliases into labels.
  - `test_lift_replay.py` checks that `lift.py` re-emits every matched
    routine byte-identically: 1,457 routines, 0 differ.
- **worker.py** runs targets, lift, propagate, pack, name, run, and stats.
  - Every batch must pass `make compare` and `make check`. If a batch fails,
    each unit is retried alone, and only units that match are committed.
  - Each attempt writes one row to `overnight/own/metrics.csv`: rounds,
    tokens, seconds, result, and commit.
  - Models only name things, from a context pack. A name must be PascalCase,
    new, and cite a file:line in the pack. Otherwise the `sub_`/`unk_`
    placeholder stays.
- **Removed (git history keeps them):** hearth/, the old own worker,
  slice prompts and checks, targets.txt files, revert_fragments, bench
  JSONs, projects/catalog, and the OCaml flake packages.

## Before / after

| | before | after |
|---|---|---|
| DONE (magination) | 834,797 B (39.81%) | 835,317 B (39.83%) |
| DONE code | 86,132 B | 86,132 B (all flow targets lifted) |
| DONE data (incl. ds fill) | 748,665 B | 749,185 B |
| DEF aliases (ratchet) | 450 | 219 |
| model rounds per match | ~9 turns, ~206k tokens | 0 rounds, 0 tokens (mechanical) |
| matches per hour | — | 165 (8 table lifts, 175 s of worker time) |
| make report / test_report | broken | passing |

The proof batch was 8 bank `$30` sound tables, 520 B. One of them
(`CountdownMasks`) failed the gate on its first try, was discarded, and
matched after a lift fix.

## Still open

- Naming rounds need a model. Set `WORKER_LLM_CMD=scripts/llm/xai.sh` with
  `XAI_API_KEY`, or use `scripts/llm/grok-cli.sh` on a machine with the
  grok CLI logged in. The grok-cli adapter is untested.
- Data codecs for the INCBIN banks (`$0D`-`$4F` and up), in the style of
  the `scripts/own/gen_*` generators.
- Ratchets to bring down: raw_flow 475 and def_alias 219.
