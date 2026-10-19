# Magi-Nation disassembly

Part of [MagiRecomp](../README.md). Run every command below from this `decomp/` directory.

Matching disassembly of the retail Game Boy Color game **Magi Nation** (USA), developed and published by Interactive Imagination in 2001.

The cartridge image is not in this repository. Put your own dump at `roms/magination.gbc`. [roms/README.md](roms/README.md) has the No-Intro hash. Keeper's Quest can sit beside it and is not part of the build.

The local ROM is the oracle. `src/scaffold.asm` includes it with `INCBIN` until a range is replaced by source that assembles to the same bytes. `make progress` counts only those replaced bytes. Rules for what may be committed are in [AGENTS.md](AGENTS.md).

## Tools

The Nix flake provides [RGBDS](https://rgbds.gbdev.io/) and [mgbdis](https://github.com/mattcurrie/mgbdis) v3.0.

```sh
nix develop
make setup
```

`make` enters the shell on its own for RGBDS commands. `make setup` points git at `.hooks/`, which refuses a commit that copies the ROM or the Nintendo boot logo.

| Target | What it does |
| --- | --- |
| `make build` | Assemble `src/` to `out/magination.gbc`. |
| `make compare` | Build, then compare that image to `roms/magination.gbc` and to `rom.sha1`. |
| `make progress` | Print DONE code and DONE data, per bank, and the humanizing debt. |
| `make report` | Write `out/report.json` after the image matches the retail ROM. |
| `make readme` | Refresh the progress block in the MagiRecomp README and draw the visualizer into `out/progress/`. |
| `make check` | Refuse tracked ROMs, dumped disassembly, and the boot logo, and run the rule checks. |
| `make test` | Test the tools against the build. |
| `make verify` | Run `check`, `compare`, `test`, and `progress`. |
| `make notes` | Regenerate mgbdis notes in `disassembly/`. Overwrites that directory. |
| `make info` | Print header fields for both local ROMs. |
| `make clean` | Delete `out/`. |
| `make targets` | List the targets the worker can lift and why the others are skipped. |
| `make lift` | Lift up to `N` evidence-backed targets; commit only exact matches. |
| `make propagate` | Replace address aliases and raw operands with labels, verified. |
| `make worker` | Lift until nothing with evidence is left, propagate, then `NAMES=n` naming rounds. |
| `make stats` | Model rounds, tokens and matches per hour from the worker's metrics. |

## The worker

The worker lifts mechanically. Where lifted code calls or jumps to bytes still included from the ROM, `scripts/lift.py` decodes that routine and writes it with a placeholder name (`sub_0C0AE9`); where lifted code loads a pointer to a small table in its own bank, it writes the table with its readers in the header. The build then has to match the retail image and `make check` has to pass, or nothing is committed. Address aliases (`DEF Foo EQU $4A3C` where a label already sits) become the label, the same way.

A model is used for one thing: naming a placeholder from a short context pack (`python3 scripts/worker.py pack sub_0C0AE9` shows it). It has to cite the lines that prove the name; otherwise the placeholder stays. Set `WORKER_LLM_CMD` to an adapter in `scripts/llm/` (an xAI API key, or a logged-in `grok` CLI). Everything is logged to `overnight/own/metrics.csv`, which is gitignored. The worker commits locally and never pushes. [docs/pipeline-audit.md](docs/pipeline-audit.md) explains why it works this way and what it replaced.

`make report` writes `out/report.json` (objdiff report version 2). `decomp.yaml` names the USA ROM, and `config/categories.txt` tags banks: bank `$30` is audio, a section that is mostly instructions is code, and everything else, including what is still `INCBIN`, is data. The header stays out of the totals. In MagiRecomp, `.github/workflows/decomp-report.yml` (at the repository root) builds the report on a runner that receives the ROM through the `BASEROM_B64` secret and uploads `usa_report`. decomp.dev has no Game Boy platform yet, so the project is not listed there yet.

The public figure is the DONE count from `make progress` (INCBIN counts as 0). It is drawn in the MagiRecomp README by `scripts/progress_visual.py`; `.github/workflows/decomp-progress.yml` republishes the images to the `progress` branch on every push to `master`. On 2026-10-19 it was 835,317 of 2,097,072 bytes, **39.83%** (code 86,132 B, data 749,185 B).

`disassembly/` and `out/` are gitignored. `make notes` is a reading aid. The build does not use it.
