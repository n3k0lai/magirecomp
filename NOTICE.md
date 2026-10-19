# NOTICE

Based on the Pokemon Gen 1 Recompilation Project by BOIS CLUB GAMES, LLC
(https://github.com/bryanthaboi/gen1recomp)

Copyright (C) 2026 BOIS CLUB GAMES, LLC (the original program).
Modifications Copyright (C) 2026 MagiRecomp contributors.

## This is a modified version (GPLv3 section 5)

MagiRecomp is a modified version of the Pokemon Gen 1 Recompilation Project.
It was forked from https://github.com/bryanthaboi/gen1recomp and modified
starting in **October 2026** to become a 3D Magi Nation recompilation. It
remains licensed under the GNU General Public License version 3 together with
the Additional Terms (GPLv3 Section 7) in [LICENSE.MD](LICENSE.MD). LICENSE.MD
is kept unchanged.

### Changes made in October 2026

- **Proprietary launcher removed** (LICENSE.MD term 2). These files were deleted
  and are not distributed by this fork: `src/import/LauncherView.lua`,
  `src/import/LauncherSettings.lua`, `src/import/OnlinePanel.lua` (and the
  `src/import/online/` panels it drove), `src/import/CartLabelArt.lua`,
  `src/import/CartShape.lua`, `src/mods/LauncherMods.lua`, `assets/launcher/`,
  `assets/labels/`, and `src/import/RomImporter.lua` (which mixed launcher UI
  with GPL import logic). The launcher splash/theme-video helpers that only
  played `assets/launcher/` media were removed with it. Tests that exercised
  the removed launcher were removed.
- **GPL import logic kept**: the ROM import, verification, and cache
  extraction logic from `RomImporter.lua` now lives in
  `src/import/RomImport.lua`, with the original copyright notice.
- **New launcher**: `src/import/MagiLauncher.lua`, written from scratch for
  MagiRecomp. It shows the required credit.
- **Names and marks** (LICENSE.MD term 3): BOIS CLUB GAMES / Gen1Recomp / G1R
  logos and the platform icons generated from them were replaced with
  MagiRecomp artwork. Window titles, the issue-report link, and the update
  check now point at MagiRecomp, not the upstream project.
- **Magi Nation**: the Magi Nation LÖVE rebuild (`src/mn/`) and a matching
  disassembly (`decomp/`) were added.

## Required credit

Every MagiRecomp launcher, front end, title, about, or credits screen must
show, visibly:

> Based on the Pokemon Gen 1 Recompilation Project by BOIS CLUB GAMES, LLC
> (https://github.com/bryanthaboi/gen1recomp)

The string lives in `src/core/Attribution.lua`; use it rather than retyping it.

## Third-party content

No ROM image is included, and the LÖVE engine ships no data extracted from a
ROM; players supply their own ROM. `decomp/` holds disassembly source in the
usual form of matching-decompilation projects; building it still requires
the player's own ROM, which is never committed. Magi Nation, Pokemon, and all related names belong to their
respective owners.
