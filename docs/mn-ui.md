# mn UI screens (`src/mn/ui/*.lua`)

Menus, choice windows, shops, and the title screen are **screens**: small
self-contained modules that own input and draw over the 160×144 frame until they
finish. Game data (tiles, glyphs, text, palettes, prices) is read from the
player's ROM at runtime (`ctx.rom:u8(MnRom.off(ptr, bank))`, or the importer's
cache). Nothing ROM-derived is committed.

## Contract

```lua
local Screen = require("mn.ui.Name")
local scr = Screen.new(ctx)   -- ctx = { rom, vm, ow, input, log }
local result = scr:update()   -- once per frame; nil while open, a value (usually a table) when done
scr:draw()                    -- draws into the current 160x144 canvas
```

- `ctx.input(kind)`: `"a"`, `"b"`, `"start"`, `"select"` give true on a fresh press, and `"dir"` gives
  `"up"`/`"down"`/`"left"`/`"right"` or nil while it is held. This is the same function Overworld uses.
- `ctx.vm` is the live ScriptVM (`vm:rd8/wr8` for WRAM/SRAM state, the same flat
  `vm.mem` the opcodes use), `ctx.rom` the script ROM, `ctx.ow` the Overworld, and `ctx.log`
  a list of log lines.
- A screen writes its result into WRAM/SRAM the way the game's routine does (the
  script that opened it reads the bytes back). The returned value is for the caller
  and tests.

## Opening a screen

- From a VM opcode handler (inside a script coroutine): `local r = vm.host.runOverlay(scr)`
  opens it, waits frame by frame until it closes, and returns its result. In the LCD-off
  map-setup run (`vm.init`) it returns nil without opening anything.
- From engine code: `ow` host `overlay(scr, function(result) ... end)`.
- Title screen / Start menu are wired in `Boot.lua` / `Overworld.lua` by the reviewer.

## Headless harness

```
MN_KEYS="w30,down,down,a" MN_FRAMES=400 ~/Code/interns/bin/mn-headless \
  love . --mn --rom <rom> --mn-test /tmp/out --mn-ui Name
```
This runs `src/mn/ui/Name.lua` as the only screen (Overworld at `MN_START`, default 1,
entry script not run). It writes `frame_NNNN_mapXXX.png` every 8 frames and prints
`[mn-ui] Name result {...} at frame N`. Each key token is pressed for one frame, and `wN` waits N
frames. `src/mn/ui/Probe.lua` is the minimal example. Never run plain `love`.
