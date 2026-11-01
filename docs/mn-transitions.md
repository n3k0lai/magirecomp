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

`$65` does move the logical camera: its `$2F37` header unpack zeroes
wMapColumn/wMapRow (`$C85F`/`$C860`), the fine bytes and the scroll deltas,
while rSCX/rSCY (copied from wCameraPixelX/Y at VBlank) stay put. A static
scan of all 706 `65 xx xx 4F` sites finds every one followed, before any
frame wait, by `$82` or `$84` (or by `$45`/`$47` into a script that does),
and those two store the column, row and fine bytes outright. So the port
keeps camOff/camFix across an LCD-on `$65`, and `$82`/`$84` drop both
(test: mn_bg_ring_test). `loadArea` also sets `mapCam` to the origin, which
is the `$2F37` clear of the logical camera.

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

## Camera split

The asm keeps a logical camera and a pixel camera.

- Logical: wMapColumn/wMapRow (`$C85F`/`$C860`) and fine X/Y (`$C85D`/`$C85E`, 0-15). `$82` and `$84` store cell − 5 and fine 8 (`StoreMapCellFromDEMinus5`, bias `$FB`). They do not call ClampMapCamera and they do not write rSCX/rSCY.
- Pixels: `$C935`/`$C934`, copied to rSCX/rSCY. ClampMapCamera (`clamp_map_camera.asm`) rebuilds them. Callers are DrawMetatileWindow under `$93`, and `$86`. The window is 11 columns by 10 rows. `$C847` is the width. `$C845` is the rightmost camera column. `$C846` is the bottom camera row, or `$FF` when `$C846 + $0A` wraps to 9. `$C842` collects the edge flags: bit 3 when the width is 10, bit 2 at column 0 fine 0, bit 1 on the column limit at fine 15, bit 7 when there is no vertical scroll, bit 6 at row 0, bit 5 on the row limit at fine 15. A column of 0 or at/past the width pins to column 0 fine 0. A column from `$C845` up to the width pins to that column, fine 15. Rows use the same shape against `$C846 + $0A`. Inside both limits the fine byte stays as stored, so the fine 8 from `$82`/`$84` survives. Header unpack `$2F37` (used by `$65` and `$67`) zeroes the logical camera and stores `$C842 = $44`. Header bytes 3 and 4 are the column and row limits.

Port (`mn.MapCamera`):

- `$84` stores the raw logical camera on `mapCam` and sets the visible camera (`camFix`) to the unwrapped pin (column × 16 + fine). Objects stay where they were placed. A header limit of 0 leaves fine 15, and a later step may still travel through fine 0..15.
- `$82` stores the logical camera from the player cell and clears `camFix`/`camOff`, so the visible camera follows the player.
- `$65` (`loadArea`) and `$67` (`unpackMap`) set `mapCam` to the origin. An LCD-on `$65` still keeps `camOff`/`camFix`.
- `$83` and `$16` sum into one frame delta. `scrollDelta` clamps it to ±4 and to pixel 0 or limit × 16 + 15 (or W − 160 / H − 144 when the header bytes are absent). `panFrame` steps `mapCam` by that applied delta.
- `$16` posts the scroll pair. The walker moves by the nested script's `$C6D2`/`$C6D3` step (`Sprites.tick`).
- `$86` runs the same clamp on the VM's camera bytes and writes `$C842`, `$C935`/`rSCX` and `$C934`/`rSCY`.

Tests: `mn_map_camera_test`, `mn_scroll_edge_test`, `mn_bg_ring_test`, `mn_ops_travel_test`. What the asm leaves open is in `docs/mn-outliers.md` (Camera split, 2026-11-01).

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
- Scroll-edge latches (`$C892`/`$C86A`) come from 8 px crossings of the port's visible camera. `$84` sets that camera to the ClampMapCamera pin in full map pixels (the ROM's rSCX/rSCY are 8-bit). `$82` leaves it following the player. The remaining gaps are under Camera split (2026-11-01) in `docs/mn-outliers.md`.
