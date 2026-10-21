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

`██████████████░░░░░░` **71.79% DONE**: 1,505,462 / 2,097,072 bytes (measured 2026-10-21 at `59b48ab5`)

| | Bytes | Share of the image |
| --- | ---: | ---: |
| **DONE** | **1,505,462** | **71.79%** |
| DONE code | 86,159 | 4.11% |
| DONE data | 1,419,303 | 67.68% |
| still INCBIN | 591,610 | 28.21% |
<!-- decomp-progress:end -->

The figures are measured on the full working tree of the disassembly, which
is not public: most of what it has converted since the start is data copied
from the cartridge (graphics, dialogue, scripts, maps), and that stays out of
this repository. `decomp/` here publishes the code part only (see below).

The measured figures are committed as
[decomp/progress.json](decomp/progress.json). On every push to `master` that
changes that file, [decomp-progress.yml](.github/workflows/decomp-progress.yml)
redraws the bar, chart and bank map from it and publishes them to the
[`progress`](https://github.com/n3k0lai/magirecomp/tree/progress) branch, which
also keeps the running `history.tsv` the chart is drawn from. The table above
is refreshed from the same file with `make readme` in `decomp/`.

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

Running `love .` with no flags opens the MagiRecomp launcher.

Progress on the story is tracked in [docs/story-checklist.md](docs/story-checklist.md);
the porting plan is in [docs/mn-port-plan.md](docs/mn-port-plan.md).

## The matching disassembly (`decomp/`)

`decomp/` rebuilds a byte-identical *Magi Nation (USA)* image with RGBDS from
the code part of the disassembly: the routines lifted to assembly, the link
scaffold, the build and progress tooling. Every range that holds data
(graphics, text, scripts, maps, music, tables) is read from your own ROM with
`INCBIN`, so no game data is in this repository. See
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
