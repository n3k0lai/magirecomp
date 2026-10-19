# Magi-Nation

Matching disassembly of the retail Game Boy Color game Magi Nation (USA). The local ROM is the judge.

This file is the only place the rules live; `README.md` is for people. Every rule has an ID, and a rule a tool can enforce names its check. Nicholai decides rule wording, what counts as DONE, and deleting anything git cannot restore. Everything else goes ahead without asking, including fixing a check that wrongly blocks honest work, as long as it still refuses everything it refused before.

## Goal

**DONE is a pair, code and data** (2026-10-18, adapted from Alchemy). DONE code is the bytes of instructions in committed source; DONE data is every other byte committed source assembles to, `ds` fill shown apart. Bytes pulled from the local ROM with `INCBIN` count as zero. `make progress` prints both, per bank with the humanizing debt (C3). 100% is both figures at 100% with `out/magination.gbc` byte-identical to `roms/magination.gbc`.

Matching is not the finish. The project is finished when every placeholder has an evidence-backed name (S4), every asset is editable source our tools build (A1), and the debt counts in C3 are zero.

## Where things are

- `src/` is the Magi-Nation build; `src/scaffold.asm` is the link scaffold: one payload (`INCLUDE`, `INCBIN` or `ds`) per `SECTION`.
- `roms/magination.gbc` is the local oracle (gitignored). `roms/keepers-quest.gbc` is a different ROM and is not part of the build. `rom.sha1` is the built image's hash.
- `scripts/lib/` holds what every tool shares: the scaffold, symbols, addresses (`rom.py`), the SM83 decoder (`sm83.py`) and the text byte count (`asmlen.py`).
- `scripts/xref.py`, `scripts/lift.py`, `scripts/propagate.py` and `scripts/worker.py` are the worker (W1-W10). `scripts/llm/` holds the model adapters for naming rounds.
- `scripts/own/` holds the data generators (music, palettes, sprite and script lists, map sources, RLE graphics) and the bank survey; `scripts/rle/` and `scripts/gfx/` the asset codecs.
- `scripts/check_tree.py` (publication rules), `scripts/check_rules.py` (everything else a tool can check), `scripts/progress.py` (the count), `scripts/report.py` (objdiff report), `config/categories.txt` (report categories), `config/ratchets.tsv` (counts that may only fall).
- `disassembly/` is mgbdis notes from `make notes`, `out/` is build output, `overnight/` is worker state and `metrics.csv`; all three are gitignored.
- `docs/pipeline-audit.md` records why the worker is built this way; `docs/progress-history.tsv` the count after each worker run.

## Rules

### Legal

- **L1** Never commit, upload or publish a ROM, the Nintendo boot logo (`$0104`-`$0133`) or any other copy of the original game files. _Check: `make check` (check_tree.py), pre-commit hook._
- **L2** Evidence comes only from our own ROM dumps, this repository and public hardware documentation. Never import another project's Magi-Nation disassembly, maps or asset rips.
- **L3** No leaked SDKs, proprietary compiler output or MusyX sources.

### The oracle judges and never feeds

- **O1** ROM bytes reach the build only through `INCBIN "roms/magination.gbc", START, LENGTH`. Source re-encodes bytes: instructions, tables a lifted reader reads (W4), and assets our tools encode (A1). A paste of bytes nobody reads, a binary, or the logo is not source. _Check: `make check`._
- **O2** One name per place, defined where its bytes are, as a label. A `DEF NAME EQU $XXXX` that names a lifted ROM label's address is an alias; aliases may only fall. _Check: check_rules.py ratchet `def_alias`; `make propagate` removes them mechanically._
- **O3** `disassembly/` is notes; `make notes` overwrites it. Never commit it or point the build at it.
- **O4** `rgbfix` may fix the header and global checksums (`-f hg`); never the logo (`-f l`, `-v`, `--validate`). The header (`$0100`-`$014F`) stays `INCBIN`.

### Counting

- **C1** DONE code and DONE data as in Goal, header excluded, measured by `make progress` from the committed text: an instruction's length comes from its mnemonic and operands, macros expanded. _Check: `make test` (`progress.py --check-map`: the text count equals the linker map for every pure-code section)._
- **C2** The whole image judges. A unit counts only when `make compare` matches `rom.sha1`; a per-range diff is a diagnostic, never a pass.
- **C3** Humanizing debt is counted, as Alchemy counts its tagged devices: placeholder labels (S4), raw `$XXXX` flow targets, DEF aliases (O2) and `DEVICE` tags (S5). All but placeholders may only fall; placeholders rise with mechanical lifts and fall with naming rounds. _Check: check_rules.py against `config/ratchets.tsv`._
- **C4** Describe this repository as a matching disassembly. Never call it clean-room.
- **C5** A change to what counts, a rule or a check lands as its own commit with DONE before and after in its message, never mixed with new source.

### Source

- **S1** Committed game source lives in `src/` (or a project's `src/`). Instructions, tables with readers, and files our tools encode are source.
- **S2** Graphics are PNGs `rgbgfx` converts in the build: `gfx/NAME.png` builds `out/gfx/NAME.2bpp`, `src/gfx/NAME.asm` INCBINs it unsized. Convert a ROM range with `scripts/gfx/convert.py`; per-asset flags live in `gfx/gfx.mk`.
- **S3** One retail ROM is in scope: Magi Nation (USA), SHA-1 `9972a7bca43210b4b6c0b3f6ee5d1957a865e12d`.
- **S4** Every name rests on evidence: the code that uses it, the table or id that reaches it, in-game text. An unknown keeps a neutral placeholder that spells its file address, `sub_XXXXXX` for code and `unk_XXXXXX` for data, never a guess; a placeholder is honest and costs nothing. Local labels are `.l_XXXX` (CPU address) until named. Header comments say what the bytes are shown to do and who reaches them. _Check: check_rules.py (a placeholder sits at the address it spells)._
- **S5** A forced encoding (a `db` standing in for an instruction RGBDS would encode differently) carries `; DEVICE: reason` on its line. _Check: check_rules.py ratchet `device`._

### Assets

- **A1** Data a routine reads from another bank is an asset: it becomes source only through a codec (decoder to editable source, encoder in the build) checked on every stream of its kind, as `scripts/own/gen_*.py`, `scripts/rle/` and `scripts/gfx/` do. Raw `db` rows are for small tables in their reader's bank only (W4).

### Work

- **W1** Mechanical first. `make worker` lifts every target that has evidence (W3, W4), runs symbol propagation, then naming rounds if a model is configured. A model never writes bytes.
- **W2** The match gate: a unit is committed only when `make compare` matches `rom.sha1` and `make check` passes. Anything else is reverted and logged, never committed as a guess. One failing unit is retried alone so it cannot sink a batch. _Check: worker.py `gate`, pre-commit hook._
- **W3** Code is lifted only where a call, jump or far call from lifted code lands (`scripts/xref.py`). The routine is decoded with every branch followed, must end in `ret`/`reti`/`jp` inside its INCBIN, contiguously, with no invalid opcode and no lifted reference landing inside an instruction. Bytes after a `ret`, or a run that merely decodes, are not evidence. _Check: lift.py `plan_code`; check_rules.py (`; Reached from:` header)._
- **W4** A table is lifted only where a pointer load in the same bank lands, up to the next lifted byte and at most 512 bytes, with no code evidence inside (a suffix that decodes to a clean routine touching named RAM or calling a known label). Each pointer target inside gets a label. An existing `DEF` of that address becomes the label. _Check: lift.py `plan_table`; check_rules.py (`; Read by:` names real labels)._
- **W5** A range whose bytes are not understood stays INCBIN: no bytes-as-instructions fragments (address-only `BankNAtXXXX` labels, headers that admit the bytes are unexplained, invalid opcodes as `db`, `rst $38` runs, jumps into RAM). _Check: check_rules.py and the pre-commit hook run `scripts/own/check_fragments.py`._
- **W6** A model sees one context pack (`worker.py pack LABEL`, about 1-2k tokens: the unit, the lines that use it, similar named code) and answers in one round. It never reads the repository, runs tools, or retries with a new guess.
- **W7** Every attempt appends a row to `overnight/own/metrics.csv` (target, kind, bytes, model rounds, tokens, seconds, result, commit). `make stats` reports rounds and tokens per match and matches per hour.
- **W8** A naming round replies `NAME`, `EVIDENCE` and `COMMENT`. The tool refuses a name that is not PascalCase, already exists, or whose evidence cites no `file:line` of the pack; `KEEP` keeps the placeholder. The rename is byte-identical and goes through W2.
- **W9** The worker commits locally on the current branch and never pushes. Run `make verify` (check, compare, test, progress) before committing by hand. After cloning, `make setup` points git at `.hooks/`.
- **W10** Splice, build and commit hold `overnight/own/lock`; model calls run outside it, so naming rounds may run in parallel.

## Commands

```
make setup      # git config core.hooksPath .hooks
make build      # assemble src/ into out/magination.gbc
make compare    # build, cmp against the local ROM, check rom.sha1
make progress   # DONE code and DONE data, per bank, and the debt counts
make check      # publication rules and check_rules.py
make test       # tool tests (text count vs map, report, worker tools)
make verify     # check, compare, test, progress
make report     # objdiff report version 2, after the image matches
make targets    # every evidence-backed target and why the others are skipped
make lift N=10  # lift up to N targets: build, compare, commit only matches
make propagate  # DEF aliases and raw operands become labels, verified
make worker     # lift until none is left, propagate, NAMES=n naming rounds
make stats      # rounds, tokens and matches per hour from metrics.csv
make notes      # regenerate gitignored mgbdis notes
make info       # header fields of the local ROMs
make clean      # delete out/
```

