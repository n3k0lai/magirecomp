# MN viewport: flexible screen size and zoom

The Magi-Nation port draws into a logical canvas that can be larger than the
Game Boy's 160x144. The canvas follows the window's shape, so a tall phone, a
square foldable or a desktop window each see more of the map instead of black
bars. Game logic does not change.

Code: `src/mn/Viewport.lua` (pure math), `src/mn/EdgeFill.lua` (out-of-map
tiles), `src/mn/EdgeFillMaps.lua` (per-map overrides), wiring in
`src/mn/Boot.lua` and `src/mn/Overworld.lua`. Tests:
`tests/engine/mn_viewport_test.lua`.

## Design

### Two cameras

- **Logic camera.** `Overworld:cameraXY` and the camera opcodes ($84, $7C,
  $16) are untouched and still work in a 160x144 frame. Triggers, scripts,
  `cameraCell`, the route harness and the debug log (`MN_RDBG`) all read this
  camera.
- **Render camera.** `Viewport.wideCamera(cx, cy, mapW, mapH, vw, vh)` is
  derived from the logic camera each frame. It centres the bigger view on the
  classic frame, shifts it to stay inside the map when the map is big enough
  (a map smaller than the view is centred), and always keeps the whole classic
  frame in view. With a
  160x144 view it returns the logic camera exactly, so classic output is
  pixel-identical to before.

### What draws where

- Field (map, patches, objects, player) uses the render camera over the full
  view. When the view is wider than classic, objects that are outside both the
  map and the classic frame are skipped (`Viewport.offstage`). The game
  "parks" actors off-map, and those used to be hidden by the screen edge.
- Text box, overlays, full-screen pictures, battles, the start menu and other
  UI draw in a 160x144 frame centred in the view (`Overworld:classicFrame`,
  scissored). Screens that are not wide-aware are drawn centred on black.
- Fades cover the whole view.

### Zoom levels

`Viewport.compute(ww, wh, {zoom, pixel})` turns a window size (device pixels)
into a logical size, a scale and letterbox offsets.

| zoom | name    | scale                               |
|------|---------|-------------------------------------|
| 0    | classic | largest integer that fits 160x144   |
| 1    | fill    | same scale as classic, more world   |
| 2    | wide    | about 3/4 of the classic scale      |
| 3    | wider   | about 1/2 of the classic scale      |

The logical size is whatever fits at that scale (rounded down to even), never
below 160x144 and capped at 640x864 (40x54 metatiles); past the cap it
letterboxes. Scales stay integer for crisp pixels. `pixel=false`, or a window
smaller than 160x144, allows a fractional scale.

### Galaxy Z Fold7 numbers

Panel sizes from Samsung's announcement
(https://news.samsung.com/global/samsung-galaxy-z-fold7-raising-the-bar-for-smartphones):
main screen 8.0" 2184x1968, cover screen 6.5" 2520x1080 (21:9).

| window            | classic   | fill          | wide         | wider         |
|-------------------|-----------|---------------|--------------|---------------|
| cover, 1080x2520  | 160x144 x6  | 180x420 x6  | 270x630 x4   | 360x840 x3    |
| main, 1968x2184   | 160x144 x12 | 164x182 x12 | 218x242 x9   | 328x364 x6    |
| main, 2184x1968   | 160x144 x13 | 168x150 x13 | 242x218 x9   | 364x328 x6    |
| cover, 2520x1080  | 160x144 x7  | 360x154 x7  | 504x216 x5   | 640x360 x3 (capped) |

These are full-panel figures. On a device the safe area and the credit line
take a little off, so the real numbers come out slightly smaller.

### Live resize

`love.draw` recomputes the layout each frame. When the size changes (fold,
unfold, rotate, window drag) the canvas is rebuilt at the new size. Layout
works in device pixels (`love.graphics.getDPIScale`) and uses
`love.window.getSafeArea` when it is available. A band at the bottom keeps the
required attribution line visible.

### Edge fill (tiles outside the map)

A wide view can show past the map's edges. `EdgeFill.build(def, mode, ov)`
returns a function giving a metatile for any cell outside the map. The tiles
are chosen at runtime from the map the player's ROM already loaded; no
graphics are stored in the repo.

Modes (`MN_VIEW_FILL` or a per-map override):

- `block` (default): for each side, the most common 2x2 block in the outer two
  rows or columns, tiled on absolute parity so 2x2 patterns (trees, walls)
  stay aligned. Corners use the most common block of the whole ring. Falls
  back to the most common single tile.
- `edge`: most common tile of the edge row or column.
- `extend`: repeat the nearest edge tile outward.
- `mirror`: reflect the map at its edge.
- `black`: no fill.

`src/mn/EdgeFillMaps.lua` holds per-map overrides keyed by map number. It may
hold only tile IDs and modes, never graphics:

```lua
return {
  [61]  = { mode = "mirror" },
  [277] = { e = 0x12, corner = { 0x10, 0x11, 0x12, 0x13 } },  -- id or 2x2 table
  [2]   = { mt = 0x05 },                                       -- one tile everywhere
}
```

The table ships empty. It is a hand-tuning point for maps where the guess
looks wrong.

## Settings

| setting | effect |
|---------|--------|
| `MN_VIEW_ZOOM=0..3` | zoom level (normal play defaults to 1, fill) |
| `MN_VIEW_PIXEL=0` | allow fractional scale |
| `MN_VIEW_FILL=block/edge/extend/mirror/black` | edge fill mode for every map |
| `MN_VIEW_SIM=WxH` | act as if the window were this size (testing) |
| `MN_VIEW_WIN=1` | with `MN_VIEW_SIM` and `--mn-test`, also write the composed window as `win_NNNN_mapMMM.png` every 8 frames |
| F7 | cycle zoom |
| F8 | toggle integer/fractional scale |
| three-finger tap | cycle zoom (touch) |

F7, F8 and the tap save to `mn_view.cfg` in the save folder. Env values
override the saved file.

## Harness guarantee

`--mn-test` runs are classic 160x144 unless `MN_VIEW_SIM` is set, and they
never read or write `mn_view.cfg`. With `MN_VIEW_SIM` they still run the same
logic: on the MN_NEWGAME route (maps 1, 277, 2, 61; 2400 frames) the log is
identical to master at every tested size and zoom, and the classic frame PNGs
match master byte for byte.

## Limits

- Scripted pans and `cameraCell` use classic math, so some cutscenes frame
  their subject in the centre 160x144 and show extra map around it.
- Pictures, battles and menus stay 160x144, centred.
- Cutscene actors parked just inside the map, but outside the classic frame,
  can be seen in a wide view.
- Edge fill is a guess. Some maps get a flat colour (map 277's east side is
  plain grass because that is its most common edge tile).
- Android: the manifest has `resizeableActivity="false"`, MN is not wired
  into the Android launcher, and there are no MN touch controls beyond the
  zoom tap. The safe area is only partly handled: the whole view is fitted inside it, but nothing is tuned for the hinge or camera cutouts.

## Next steps

- Android: make the activity resizeable, launch MN from the Android front end,
  add on-screen controls, and test on a real Fold7 across fold and unfold.
- Fill in `EdgeFillMaps.lua` for maps where the guess looks wrong.
- Give scripted scenes a wide-aware pan (opt in per scene).

## What 3D can reuse

- `Viewport.compute` for window, aspect and scale handling.
- The logic camera / render camera split: a 3D camera can be derived from the
  classic camera the same way, with logic still on the 2D grid.
- `EdgeFill` as terrain past the map edge, for a horizon or ground plane.
- `EdgeFillMaps` as the place for per-map hand tuning (IDs only).
- `classicFrame` for keeping 2D UI over a 3D scene.
