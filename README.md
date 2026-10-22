# MagiRecomp

**A 3D Magi Nation recompilation for LÖVE.**

MagiRecomp rebuilds the Game Boy Color RPG *Magi Nation* (USA) as a native
LÖVE (Lua) program, with the long-term goal of a 3D presentation of Magi Nation.
The game data and graphics come from a ROM **you supply**; no ROM image is
included in this repository, and the LÖVE rebuild reads game data only from a
private cache it builds from your ROM.

> Based on the Pokemon Gen 1 Recompilation Project by BOIS CLUB GAMES, LLC
> (https://github.com/bryanthaboi/gen1recomp)

MagiRecomp is a **modified fork** of that project (fork created and modified
in October 2026). It is **not** an official BOIS CLUB GAMES, LLC product, is
not endorsed by them, and is not the upstream Gen1Recomp project. For
Gen1Recomp itself (its releases, support, and community) go to the upstream
repository linked above.

Magi Nation is the property of its respective rights holders. Pokemon and all
related names are the property of Nintendo, Creatures Inc., and GAME FREAK inc.

## Decomp progress

How much of *Magi Nation* (USA) the matching disassembly in `decomp/` rebuilds
from source. A byte counts as DONE only when committed source (not an `INCBIN`
of the cartridge) assembles to it and the whole image still matches the
retail ROM; the header is left out. Code is instructions, data is everything
else. The headline is the DONE count from `make progress`, not objdiff's
per-category figures.

<!-- decomp-progress:start -->
[![decomp DONE](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/n3k0lai/magirecomp/progress/badge.json)](decomp/README.md)

<img src="https://raw.githubusercontent.com/n3k0lai/magirecomp/progress/progress.svg" width="838" alt="Magi Nation (USA) decomp: DONE code and data" />
<img src="https://raw.githubusercontent.com/n3k0lai/magirecomp/progress/chart.svg" width="838" alt="DONE over time" />
<img src="https://raw.githubusercontent.com/n3k0lai/magirecomp/progress/banks.svg" width="838" alt="DONE per ROM bank" />

`████████░░░░░░░░░░░░` **39.83% DONE**: 835,317 / 2,097,072 bytes (measured 2026-10-19 at `d80f43b3`)

| | Bytes | Share of the image |
| --- | ---: | ---: |
| **DONE** | **835,317** | **39.83%** |
| DONE code | 86,132 | 4.11% |
| DONE data | 749,185 | 35.73% |
| still INCBIN | 1,261,755 | 60.17% |
<!-- decomp-progress:end -->

The bar, chart and bank map are redrawn on every push to `master` that touches
`decomp/` by [decomp-progress.yml](.github/workflows/decomp-progress.yml) and
published to the [`progress`](https://github.com/n3k0lai/magirecomp/tree/progress)
branch, which also keeps the running `history.tsv` the chart is drawn from. No
ROM is needed for that: the count reads only the committed source. The table
above is refreshed with `make readme` in `decomp/`.

## What is in this repository

| Path | What it is |
| --- | --- |
| `src/mn/` | The Magi Nation LÖVE rebuild: ROM import, script VM, overworld, battle, font, sprites, music. |
| `src/import/MagiLauncher.lua` | MagiRecomp's own launcher (written for this fork). |
| `src/import/RomImport.lua` | GPL ROM import / verification / cache-extraction logic. |
| `decomp/` | A matching disassembly of Magi Nation (USA) for RGBDS, with progress reporting for decomp trackers. |
| everything else | The inherited engine from the Pokemon Gen 1 Recompilation Project, under its GPL license. |

### The launcher

The upstream project's launcher is proprietary to BOIS CLUB GAMES, LLC and is
**not** part of this fork (see `LICENSE.MD`, Additional Terms, term 2). It has
been removed. MagiRecomp ships its own small launcher
(`src/import/MagiLauncher.lua`), which shows the required credit, lists the
games the engine can start, imports a dropped ROM, and starts a ready game. It
is a work in progress.

## Running the Magi Nation rebuild

1. Install [LÖVE 11.5](https://love2d.org).
2. Put your own legally obtained *Magi Nation (USA)* Game Boy Color ROM at
   `roms/magination.gbc` (SHA-1 `9972a7bca43210b4b6c0b3f6ee5d1957a865e12d`).
   `roms/` is git-ignored; never commit a ROM.
3. Run `love . --mn` from the repository root. The first run imports the ROM
   into a private cache in LÖVE's save directory.

### What is (and is not) in this repository

No ROM image, and no graphics, tile maps, palettes, music or text taken from
one, are committed here or shipped with the rebuild. Everything the rebuild
shows is read from the ROM you supply at import time and kept in a private
cache in LÖVE's save directory (`mn_cache/`), which is never uploaded. The
battle screen's scenes (backdrop, creature pictures, Tony's sprite and
portraits, attack and elimination animations) are produced the same way:
`src/mn/fx/Gen.lua` runs the game's own battle code, translated instruction by
instruction to Lua (`src/mn/fx/Blocks.lua`, built by `tools/mn_fx/`), on your
ROM and records the frames it draws into `mn_cache/battle_scenes.lua`. The
translated code holds the game's instructions only; the tiles, maps and
palettes they copy come from your ROM. Earlier revisions carried PyBoy frame
captures of those scenes (`src/mn/data_battle_scenes.lua`,
`src/mn/data_battle_capture.json`); they have been removed from the whole
history. Magi Nation is the property of its rights holders; this project is
not affiliated with or endorsed by them.

Running `love .` with no flags opens the MagiRecomp launcher.

Progress on the story is tracked in [docs/story-checklist.md](docs/story-checklist.md);
the porting plan is in [docs/mn-port-plan.md](docs/mn-port-plan.md).

## The matching disassembly (`decomp/`)

`decomp/` rebuilds a byte-identical *Magi Nation (USA)* image from assembly
source with RGBDS. Progress counts only code and data that is lifted to
source and matches (INCBIN placeholders count as 0%). See
[decomp/README.md](decomp/README.md) and [decomp/decomp.yaml](decomp/decomp.yaml).
The ROM is never committed; CI restores it from a repository secret to build
the progress report and checks that the report carries no ROM bytes.

## License

MagiRecomp is distributed under the GNU General Public License version 3 with
the Additional Terms (GPLv3 Section 7) in [LICENSE.MD](LICENSE.MD), exactly as
the upstream project is. All upstream copyright and author notices are kept.
See [NOTICE.md](NOTICE.md) for what this fork changed and when.

Required attribution (LICENSE.MD term 1):

> Based on the Pokemon Gen 1 Recompilation Project by BOIS CLUB GAMES, LLC
> (https://github.com/bryanthaboi/gen1recomp)

## Thanks

To BOIS CLUB GAMES, LLC and the Gen1Recomp contributors for the engine this
fork builds on, and to [pret](https://github.com/pret) for showing what a
matching disassembly can be.
