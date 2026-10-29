# Map transitions (asm audit, 2026-10-28)

What the ROM does on a scene change, and where the port matches it.

## `$65` CallScriptBankedPtrThenResume (`$1820`)

Calls LoadFiveBankedMapSources (`$2E15`) and nothing else:

1. FillC72BFromBCThenBank7 (BG palettes),
2. CopyMapRecords,
3. UnpackToWRAMBank2,
4. the WRAM 3 header unpack (metatile plane),
5. the WRAM 5 unpack (collision plane).

It does not touch the object records, the threads, the `$C6F5`-`$C6FD`
mailboxes, the A list, the player cell or the BG map. Every `$65` in the
decoded event scripts names bank `$4F` with a record-aligned pointer. Most sit
right after `$93`; nearly all others have `$93` earlier in the same script; a
few are thread or talk scene changes with the LCD on.

Port: `Overworld.loadArea` (map data, palettes, atlas). `enterMap` is the
port-only start used by boot, saves and harness legs.

## `$93` FinishStartup

Turns the LCD off and reinstalls the default state:

- `$CCA5` cleared;
- SetupDefaultState (`default_state.asm`): `$C6DE`, the idle/VBlank/STAT
  pointers, `$C728`/`$C729`, `$C931`-`$C933`, `$C9C5`/`$C9C6`, `$C9FF` script
  word, `$C937`, `$C188`, `$C6D8` (cell-`$82` countdown enable), `$CCA6`,
  `$C6F3`, `$C6EF` = 3, `$FFAA`/`$FFAB` = 3;
- InitQuadRecords (`$28A9`): `00 00 02 14` at `$C70E` and `$C71C`, `$C6F5`-
  `$C6F8`, `$C6FA`, `$C6FC` cleared (`$C6F9`, `$C6FB`, `$C6FD` are left);
- the same pattern at `$C715`.

Port: the `$93` branch applies `boot/Title.lua`'s DEFAULTS table, the same
bytes the boot path stores. Grass stays off after a door until the new map's
`$32` arms it again.

## `$45` EnterScriptFromLookup

A bank and pointer jump; the new script dispatches the same frame. Port:
`jump()`.

## Arrival facing

The facing is record byte 0 (`hRecordHead`). FillScriptRecord0808 skips byte 0
and InitPointerList only sets bit 7 and clears bit 6, so the facing carries
through a door. Port: `self.facing` is kept across `$65`.

## Not modelled

- A `$65` with the LCD on writes no BG map; the ROM shows the old tiles until
  a later redraw (`$82`/`$84` recenter, `$93`). The port draws the new map at
  once.
- Seam palette timing (the column/row streamer and the palette upload are not
  frame-split in the port).
- BG ring aliasing (the 32x32 tile map wraps every 16 cells).
- The port still resets its own camera overrides (camOff/camFix) on `$65`.
