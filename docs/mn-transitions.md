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
(test: mn_bg_ring_test).

## Camera split (`$82`/`$84`, ClampMapCamera) - in progress on fix/mn-cam-split

### Handoff (2026-10-29)

Ready to merge (fix/mn-cam-split, suite and both seeds run on the pushed
tree): step 1 (`MapCamera`, `mapCam` recorded, not read) and step 4 (no
"camera clamp shift", no `camRow == 0` override, `$84` sets the visible
camera to the clamped pixel value, `$16` walkers move by their own pan
delta, objects walking in from below the map cross its edge cells). Tavel
Gorge now matches PyBoy frame for frame (measured values below).

Remaining: steps 1-3 below (`camPix` set only by the `$93` redraw, the
`scrollDelta` edge tests from `mapCam` and `$C842`, the sprite cull from
`mapCam`); the map 220 Tony and Eidon `13:58C2` re-checks; a screen check of
map 0 (the old shift fired there as -5,-5; PyBoy shows no object move).

### What the asm keeps

Two cameras, not one:

- **Logical camera**: wMapColumn/wMapRow (`$C85F`/`$C860`) plus the fine bytes
  `$C85D`/`$C85E` (0-15). `$82` (CenterFineScrollOnScriptBase, `$1E30`, from
  `$C18E`/`$C18F`) and `$84` (CenterFineScrollOnScriptWord, `$1E8E`, from its
  word) store cell - 5 (StoreMapCellFromDEMinus5, byte wrap) and fine 8
  (FINE_SCROLL_CENTER) and nothing else. The `$2F37` header unpack (`$65`,
  `$67`) zeroes all four.
- **Visible scroll**: wCameraPixelX/Y (`$C935`/`$C934`, 8-bit), copied to
  rSCX/rSCY by FlushQueuedScroll at VBlank. Overworld writers: ClampMapCamera
  (rebuilds both as cell * 16 + fine) and the two scroll steps (add the
  clamped delta, the same delta they add to the fine bytes). The bank 4
  screens write their own values; they are not the field.
- **Map pointer / seam address**: `$C861` and `$C863`/`$C864` are built only
  by ClampMapCamera and moved by the steps. `$82`/`$84` leave them.

ClampMapCamera (`clamp_map_camera.asm`) runs only from DrawMetatileWindow
(FinishStartup, `$93`, LCD off) and SeedCameraAndEnterLoop. It pins: width 10
-> column 0 fine 0 (bit 3); column 0 or >= width -> column 0 fine 0 (bit 2);
column >= `$C845` -> `$C845` fine 15 (bit 1); `$C846` = `$FF` -> row 0 fine 0
(bit 7); row 0 or >= `$C846` + 10 -> row 0 fine 0 (bit 6); row >= `$C846` ->
`$C846` fine 15 (bit 5). A pin at limit 0 sets both bits of its axis. Fine 8
survives only strictly inside the limits.

QueueSpriteList draws an object at cell * 16 + fine - `$C935` (+8) and
cell * 16 + fine - `$C934` (+16), 8-bit; it culls with the logical camera
(cell in column-2..column+11, row-2..row+10). So with the LCD on, an `$82` or
`$84` moves neither the BG nor the sprites; it moves the cull window, the next
`$93` redraw, and where the steps' edge tests stop (they test the fine bytes
and the `$C842` flags, not the pixels).

### Measured in PyBoy (2026-10-29)

Headless PyBoy 2.8.1 (`window='null'`, `sound_emulated=False`,
`sound_volume=0`, full mute env), new game to Tavel Gorge, hooks on `$82`,
`$84`, DrawMetatileWindow, ClampMapCamera, `$16`'s add (`$0D97`), `$83`'s
resume (`$1E5F`) and FinishFrame (`$08BB`); per-frame object records.

- Map 0: three `$84 $0000` store column/row 251 fine 8; the clamp gives
  0/0 fine 0 (`$C842` = `$44`). No record moves.
- Map 216 (`$C845`/`$C846`/`$C847` = 1/0/12): `$82` with `$C18E`/`$C18F` =
  6,4 stores column 1, row 255, fine 8,8; the `$93` clamp gives column 1
  fine 15, row 0 fine 0 (`$C935`/`$C934` = 31/0, `$C842` = `$62`).
- Map 219 (header 1/0/12; collision rows 0-9, rows 10+ read 0; row 9 all
  `$08`): `$84 $0807` stores 2,3 fine 8,8; the `$93` clamp gives column 1
  fine 15, row 0 fine 15 (`$C935`/`$C934` = 31/15, `$C842` = `$62`).
  Records: 0 at 6,14; 2 at 5,12; 3 at 7,12; 4 at 6,8, all fine 8,8. None
  moves at the `$84` or the clamp.
- The kids walk 1 px a frame from frame 1630 (row 12) to 1773 (row 3),
  144 px, through row 9, at one rate. From frame 1726 one `$16` add per
  frame (`1F:50D2`, 00,FF, `$FFA6` 48 -> 1) runs to 1773: `$C934` steps
  15 -> 0 by frame 1741, the kids move all 48 px. Slot 4 stays at 6,8.

So the asm has no spawn shift: the view opens at `$C934` = 15 and the `$16`
pans it to 0, and a `$16` walker moves by its own delta even when the
camera is pinned.

### What the port does today

`h.cameraCell` (`$84`) clamps at once (cell * 16, capped at `camCol` * 16 +
15 and W - 160) and sets the visible `camFix` at once; no object moves
(step 4 done; the old "camera clamp shift" moved Tavel Gorge's kids 3 rows).
A `$16` walker moves by its own pan delta every frame, clamped or not, and
an object walking in from below the map crosses the edge cells until it
reaches an open one. The port run of the intro now gives the PyBoy numbers:
kids 7,12 -> 7,3 over 144 frames, pan from row 6, camera 31,15 -> 31,0. `h.centerCamera` (`$82`) unpins the
camera so it follows Tony. `mapView` (`$11`) and `nudge` (`$7C`/`$7D`) read
the visible `camFix`; `scrollDelta` edge tests read `cameraXY`. With the LCD
on, `$82`/`$84` apply the BG ring ("BG map ring" above), which models a
visible jump the asm reading above says does not happen.

### Step 1 (done on the branch)

`src/mn/MapCamera.lua`: `center` (`$82`/`$84` store), `origin` (`$2F37`),
`step` (fine crossings into the column/row, byte wrap), `clamp`
(ClampMapCamera with the `$C842` flags and the 8-bit pixel bytes), `limits`
(def.w / camCol / camRow as `$C847`/`$C845`/`$C846`). Overworld records
`self.mapCam`: `$84` (`cameraCell`), `$82` (`centerCamera`, from
`vm:playerCell()`), `loadArea` (origin), `panFrame` (the applied step).
Nothing reads it yet, so no output changes. Test: `mn_map_camera_test`.

### Next steps

1. Visible scroll as its own value (`camPix`, the `$C935`/`$C934` analogue):
   only the `$93` redraw (`lcdOff` -> DrawMetatileWindow) sets it, from
   `MapCamera.clamp(limits, mapCam)`, which also writes back the pinned
   `mapCam`; the steps add to it. `$82`/`$84` with the LCD on stop touching
   `camFix`/the ring. Keep the port's follow camera for walking (the walk
   path sets the logical camera through the steps in the asm; check
   `$2F37`/walk code before replacing `cameraXY`'s follow).
2. `scrollDelta` edge tests against `mapCam` and the flags (`$C842`) instead
   of the visible pixels.
3. Sprite cull from `mapCam`; `mapView` from the `$C861` analogue (clamp or
   steps only), `nudge` from `mapCam`.
4. Done: dropped the "camera clamp shift" and the `camRow == 0` override
   (PyBoy values above).

### Calibration impact

- **Tavel Gorge kids (`1F:500C`/`50CD`, map 219)**: settled by the PyBoy
  read above (no shift; view 15 -> 0; kids walk 12 -> 3). Earlier note: the
  port moved the
  kids 3 rows up and kept the view at row 0. By the asm reading, `$84
  $0807` stores row 3 fine 8; a later `$93` would clamp it to row 0 fine 15
  (row limit 0), i.e. `$C934` = 15, not 0, and the kids would keep their
  cells. That does not by itself give PyBoy's picture (kids 3 rows up, on
  screen), so before step 4: read `$C85F`/`$C860`/`$C85D`/`$C85E`/
  `$C934`/`$C935`, the kids' records and LCDC in PyBoy (headless) right after
  the `$84` and again after the next `$93`/`$94`. Until then the shift stays.
  The `$16` carry model (kids stay on row 3, `mn_scroll_edge_test`) does not
  depend on this: the camera is at the map top and the summed steps clamp
  to 0 (checked in a headless intro run: no camera offset on map 219).
- **Map 220 Tony** (row 25 after a 3-row walk from 28): slot 0 is exempt from
  the shift; with the split nothing moves, so this needs the same PyBoy read.
- **Eidon `13:58C2`** (8 cells right): the carry rides the applied step; if
  step 2 changes which steps are refused, re-check the arrival cell.
- **`mn_bg_ring_test`**: `cameraCell(10, 4)` -> `cameraXY` 160,64 and
  `cameraCell(16, 0)` showing old ring slots encode the LCD-on jump; step 1
  would make them `$84` stores with no visible move (fine 8 at the next
  redraw: 168,72 with that test's fallback limits, `mn_map_camera_test`).
- **`mn_scroll_edge_test`**, **`mn_nudge_test`**, **`mn_op11_test`**,
  `mn_load65_test`, `mn_door_rebase_test`, `mn_pixelwalk_test`,
  `mn_standin_pair_test`, `mn_pair_wram_test`, `mn_motion_test`: they set
  or read `camFix`/`cameraXY`; each needs a look when the visible camera
  changes owner.
- **Seeds**: the default (map 2 -> 277) and chase (map 4) routes; run both
  on the tree before any of steps 1-4 reaches master.

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
  `MapCamera` (see "Camera split") records the logical camera alongside;
  nothing reads it yet.
