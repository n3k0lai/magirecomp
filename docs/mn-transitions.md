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
mailboxes, the A list, the player cell or the BG map. The `$2F37` header
unpack still zeroes the logical camera (`$C85F`/`$C860`), the fine bytes, the
load latches and their countdowns, the one-frame deltas (`$C843`/`$C844`) and
sets `$C842` to `$44`. `$2DDC` stores the row stride at `$C6CF` and clears the
live step (`$C6D2`/`$C6D3`). Neither writes `wCameraPixelX`/`wCameraPixelY`,
and neither snaps the player.

The 123 inventory `live` rows are classified in
`docs/mn-inventory/live-transitions.tsv`. 114 are executed loads and a `$93`
runs earlier on every path, so the LCD is still off (`FinishStartup` has not
reached `TurnOnLCD`). 105 of those have `$93` as the previous instruction.
`chains()` does not show that `$93`: a root block starts at the `$65`. The
other 9 bytes are not executed `$65`s (a `$9F` strip, an operand of another
op, or the leftover at `1B:6EFD`). No executed row in that set is a thread or
talk load with the LCD on.

Port: `Overworld.loadArea` (map data, palettes, atlas, the `$2F37`/`$2DDC`
bytes). It does not snap. `enterMap` is the port-only start used by boot,
saves and harness legs, and it snaps after the load. Header bytes 1-2
(`$C849`) are not in the cached map def; nothing in the port reads them.

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

`$65` does move the logical camera: its `$2F37` header unpack zeroes
wMapColumn/wMapRow (`$C85F`/`$C860`), the fine bytes and the scroll deltas,
while rSCX/rSCY (copied from wCameraPixelX/Y at VBlank) stay put. The port
does those clears on every `$65` and still keeps camOff/camFix when the LCD
is on. `$82`/`$84` drop both (test: mn_bg_ring_test, mn_load65_test). The
player's fine position is left where it was. Among the executed live rows,
`12:6184` and `17:4D90` do run `$6B` glyph countdowns before `$82`, and both
are reached only after `$93` and before `$94`, so those countdowns are
RunScriptLoop passes, not presented frames.

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
from the byte at address `$0000`. `ld c, [hl]` reads through the bus, and
below `$4000` that is fixed ROM bank 0, so the port draws that ROM byte at ring
slot (0, 0) (test: mn_store_redraw_test). Other words outside the map plane
(stale words from an earlier, larger map; banked ROM; other RAM) are not
modelled.

`$67` (CallScriptUnpackHeaderAndBlock) calls the same `$2F37` header unpack
as a map load, which zeroes the map column and row and the fine scroll, but
no camera seed or BG redraw follows it. The asm leaves the camera at the map
origin with the old tiles in VRAM; the port unpins the camera (`camOff`,
`camFix` cleared, so it follows Tony) and patches every cell at once. No
decoded script uses `$67`, so the difference is never reached.

## Not modelled

- Seam palette timing. StepHorizontalScroll (`07:4CF5`) queues the 8 px tile
  column entering the view (`$C863`, wrapped to 32) and sets `$C891` = 2; each
  later step halves it (`sra`). CopyQueuedColumn copies the countdown into
  wColumnLoadLatch (`$C892`), and FlushQueuedScroll writes rSCX/rSCY and then
  the strip to VRAM bank (latch & 1): bank 0 (tile ids) on 2, bank 1
  (attributes: palette, VRAM bank, flips) on 1. StepVerticalScroll does the
  same for rows through `$C86A`. The new SCX lands with the tile pass, so for
  one frame the column or row that just scrolled in (the 1-4 px of it on
  screen) shows the new tile ids with the old slot's attributes. The port
  draws 16 px metatiles from a baked atlas and has no per-tile attribute
  plane, so it draws both passes at once; the latches themselves are
  modelled (`Overworld:stepEdgeLatches`) for the `$7E`/`$7F` stall.
- A `$65` with the LCD on between maps with different tile sets (see above).
- Ring slots written while off screen (an Opcode03Continue redraw at a column
  offset of 11-15) are not recorded; only the view is.
- The port camera follows the player (`cameraXY`); the ROM's absolute
  wMapColumn/wMapRow plus fine scroll are not reproduced pixel for pixel, so
  the latches come from 8 px crossings of the port camera.
