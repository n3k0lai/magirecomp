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

## BG map ring

`$9800` holds 16 x 16 metatile cells: BuildMetatilePointers (`07:4C53`) puts
cell (column, row) at `$9800 + (row & 15) * 64 + (column & 15) * 2`. The view
is 11 x 10 cells, so the scroll seam keeps the slots under the view equal to
the view. What writes the ring:

- the seam (StepHorizontalScroll `07:4CF5` / StepVerticalScroll `07:5198`),
  when the fine scroll crosses an 8 px line;
- DrawMetatileWindow, called only by FinishStartup (`$93`) before the LCD is on;
- single-cell redraws through the `07:4CA1` VBlank callback: Opcode03Continue
  (`01:4617`, after its 16-cell test) and the `$A0`-`$A4` store tail.

`$82` and `$84` only store wMapColumn/wMapRow (StoreMapCellFromDEMinus5,
`$1D3D`) and the fine scroll; they draw nothing. With the LCD on, a camera
jump shows each on-screen cell's ring slot until the seam draws it.

Port (`Overworld:ringRecord`/`ringApply`/`ringFrame`): the ring is recorded
from the view once a pass; `$82`/`$84` with the LCD on apply it, and a cell
that differs from WRAM 3 is stale until it leaves the view (`flushStale`).
`$93` (host `lcdOff`) redraws the view from WRAM 3. The LCD is off under
`vm.init` and from `$93` until RunScriptLoop parks.

## `$65` with the LCD on

The BG map and the scroll are left as they were, so the old cells stay on
screen until the seam draws them, and the port keeps camOff/camFix. Palettes
are uploaded the same pass. CopyMapRecords (`$2FC0`, record copy `$2FE5`) runs
with the LCD on and no STAT wait, so how much of a different tile set lands is
down to PPU timing. The port keeps the old cells only when both maps' metatile
atlases are identical; otherwise it draws the new map at once and logs
`lcd-on $65: tile set differs`.

## Edge reload stall (`$7E`/`$7F`)

StagedByteEdgeCheck runs Opcode03Continue (`01:4617`) on each staged cell. With
the LCD on, a cell in the camera's edge column (offset 0 or 10) waits while
wColumnLoadLatch (`$C892`) is set, and a cell in the edge row (offset 0 or 9)
waits while wRowLoadLatch (`$C86A`) is set. The same cell is retried the next
pass. CopyQueuedColumn copies the countdown into `$C892`: 2 on the tile pass,
1 on the attribute pass a pass later. FlushQueuedScroll clears it at VBlank.
Port: `Records.cellInView`, `Overworld:stepEdgeLatches`.

## Stores with no A cell (`$A0`-`$A4` tail, `$26CC`)

With the LCD on, StoreEThroughWordInWram3 always redraws the cell at
`$C99D`/`$C99C` with the WRAM 3 byte at the word in `$C99E`, whatever cell the
store wrote. There is no view test: the redraw goes to that cell's ring slot,
and shows on whichever on-screen cell shares it. The stored cell itself keeps
its old tiles until the seam draws it. A store before any A cell was saved
reads `$C99C`-`$C99F` as left by Reset (zero), so it redraws ring slot (0, 0)
from the byte at address `$0000`; the port does not model a word outside the
map plane.

## Not modelled

- Seam palette timing: the attribute pass lands a pass after the tile pass
  (`$C891` 2 then 1); the port draws both at once.
- A `$65` with the LCD on between maps with different tile sets (see above).
- Ring slots written while off screen (an Opcode03Continue redraw at a column
  offset of 11-15) are not recorded; only the view is.
- The port camera follows the player (`cameraXY`); the ROM's absolute
  wMapColumn/wMapRow plus fine scroll are not reproduced pixel for pixel, so
  the latches come from 8 px crossings of the port camera.
