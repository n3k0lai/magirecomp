# Magi-Nation (GBC) port plan — gen1recomp model

Local fork of bryanthaboi/gen1recomp (upstream HEAD e50c396e, origin remote removed,
nothing pushed). Decomp source of truth: a private working tree branch `integration`
(98.76% byte-matching). Goals: 3D, Android, added content, live multiplayer.

## How gen1recomp is built (what we studied)
- **ROM -> cache import**: `src/import/RomImporter.lua` (first-boot UI, SHA-1 check,
  cache ownership) + `RomExtractor.lua` (tables, text, pictures -> private
  `data/generated/*.lua`, `assets/generated/**/*.png`, audio programs). The ROM is
  released after import; gameplay reads only the cache. `tools/build_data.py` is
  a Python dev mirror for verification.
- **Core**: `src/core/Game*.lua` (one service owner per generation: Game, Game2, Game3),
  `FixedStep` 60 Hz, `Input`, `StateStack`, `SaveData`, `ChipAudio`/`ChipSynth`.
- **Render**: `Renderer` (160x144 canvas, integer scaling), `TileRenderer`
  (SpriteBatch per map), `SpriteRenderer`, `Font`/`TextBox`, `Camera`, `Transition`,
  `GbcPalette`, `ShaderFX`, and `Pipelines.lua` — the **render pipeline registry**
  that mods use (`render_pipelines:register("voxel", {drawWorld=fn})`); the
  famous voxel 3D view is a pipeline, not core.
- **World**: `Map`, `MapLoader`, `Player`, `NPC`, `Collision`, `Warp`, `Encounter`,
  `OverworldController`. **Script**: coroutine `ScriptRunner` + `Commands` +
  `Flags`; hand-ported per-map scripts in `data/scripts/`.
- **Battle/pokemon/box/inventory**: all Pokémon-specific.
- **Online**: `src/online` relay client (protocol v2, lockstep arena battles),
  `src/link` LAN link, `src/net` TLS.
- **Platforms**: `conf.lua` LÖVE 11.5; `mobile/android` vendored love-android 11.5a,
  `scripts/build_android.sh` / `scripts/build.sh android`; also iOS, Switch,
  Linux AppImage/Flatpak, ARM handhelds. Mods: `src/mods` + `docs/modding*`.

## Reuse as-is (engine shell)
FixedStep, Input/GamepadMap/TouchControls, StateStack, Renderer/PixelCanvas/
Letterbox/Zoom/ShaderFX, **Pipelines** (3D hook), Camera, Transition, SaveData/
SaveSerializer, Logger, Platform/HostShell, the importer *pattern* (validate SHA-1,
decode to private cache), mods loader, all build/packaging scripts incl. Android,
online relay transport (`src/online/Client`, protocol framing) and `src/link` session layer.

## Replace with Magi-Nation equivalents
| gen1recomp | Magi-Nation replacement | Decomp source |
|---|---|---|
| RomExtractor tables | `src/mn/MnRom.lua` (started) + MnExtractor | bank $4F map sources, UnpackBytes, rle_gfx |
| TileRenderer metatiles (4x4 Gen1 blocks) | 2x2 metatiles, 256/map, tile+attr planes, two VRAM banks, signed $9000 addressing | load_five_banked_map_sources.asm, copy_map_records.asm |
| GbcPalette from SGB/GBC tables | per-map 8 BG palettes (slot 0); OBJ palettes via `rgb` macro data | gen_palettes.py |
| Map/Collision/Warp | slot-4 block record (per-cell behaviour), warps from event scripts | needs decoding of block values |
| ScriptRunner Commands | interpreter for the 176-opcode MN script engine (data, not hand ports) | scripts/script/opcodes.py, event_runs.json |
| Font/charmap, TextBox | MN charmap + text banks | scripts/text |
| ChipAudio programs | MN music driver format + wave frames | scripts/own/music-format.md, gen_music.py |
| SpriteRenderer walkers | MN sprite lists + sprite-animation scripts | gen_sprite_lists.py, anim decomp |
| battle/, pokemon/, box/ | Magi/creature/spell card-ish battle system, Animite, energy | battle code is lifted asm; rules must be ported by hand |
| online arena battle | MN battle lockstep + overworld presence | reuse transport, new messages |

## Milestones
1. **M0 (done today)**: ROM decoder slice — all 369 map-source records decode
   (palettes, VRAM tile copy, metatiles, map, block) and render headless to PNG.
2. **M1 Importer**: MnExtractor writes cache (map atlases + Lua map defs), SHA-1 gate,
   boot into a map viewer state through gen1recomp's StateStack/Renderer.
3. **M2 Walkable world**: decode block-record collision values, player sprite from
   sprite lists/anim scripts, camera, map transitions/warps (from scripts).
4. **M3 Script VM**: run MN event scripts directly (opcode table from decomp), text
   boxes with MN charmap, flags in save.
5. **M4 Audio**: port MN music driver into ChipAudio.
6. **M5 Battle**: port battle rules from lifted asm; data from ROM.
7. **M6 3D**: register an MN `render_pipelines` entry (voxel/heightmap from metatile
   attrs + block behaviour), reuse gen1recomp's 3D camera code.
8. **M7 Android**: `scripts/build_android.sh` with MN branding; touch skin.
9. **M8 Multiplayer**: overworld presence + lockstep battles over the existing relay
   protocol (own relay instance). **M9 Content**: mods API for new maps/scripts.

## Current slice
- `src/mn/MnRom.lua`: pure-Lua decoder (no LÖVE dependency).
- `tools/mn_slice`: headless LÖVE app (`t.window=nil`, ImageData->PNG, no xvfb):
  `love tools/mn_slice <rom> <index|all> <outdir>`.
- Unknowns: the meaning
  of block values; the map index -> world location table; OBJ layer.

## M1/M2 status (2026-10-13)
- LCDC: TurnOnLcd/DefaultVBlank write $E3 -> bit 4 clear -> BG tiles use signed
  $8800 addressing (id<128 at $9000). Matches MnRom.tileBase.
- `love . --mn [--rom roms/magination.gbc] [--viewer] [--mn-test outdir]`
  (branch at the top of main.lua -> src/mn/Boot.lua, uses src/core/StateStack).
- `src/mn/MnImporter.lua`: SHA-1 gate (9972a7bc...), decodes 369 maps to
  `<save>/mn_cache/maps/NNN.{png,lua}` + manifest; ROM released after import (~8 s).
- `src/mn/World.lua`: cell plane semantics (see header comments, cited routines).
- Warps: map-entry scripts = `93 65 <ptr $4F> ...` (706 found, all 369 maps);
  `$64` sets the bank-$21 trigger list; `$05` slot 0 = player spawn cell.
  Trigger scripts are walked statically (BFS through $45/$43/$47/$49/$4B/$8E/$9C
  targets) to the first entry script: 872/1073 triggers resolve. `$02` rebases
  the player position (x - b0 + b1). Story-state lookups take every branch, so
  the first-found destination is not always the one the story would pick.
- `src/mn/Overworld.lua`: 16-frame cell walk, collision, direction-gated triggers,
  warp. `src/mn/Viewer.lua`: browse maps, Tab overlays the cell plane.
- Player sprite is a placeholder rectangle; sprite-list decode is next (M2b).

## M2b/M3 status (2026-10-13, second pass)
- Player walker: bank $20 QueueSpriteList lists $44AC-$4523 (head tiles 00-05
  + body, OBJ VRAM bank 1 $8000), animated by the bank-$20 sprite-anim scripts
  ($4C records frames/dy/dx/list: down $526E, up $51BF, right $53CC, left $531D;
  $4D idle tables $518F-$51B3). OBJ palettes: opcode $66 block $21:$5CC0.
  Exported at import to mn_cache/player.{png,lua}.
- `src/mn/ScriptVM.lua`: coroutine VM. Implemented: $93 $65 $64 $69 $66 $05 $02
  $45 $AC $43 $49 $4B $A5 $A6 $A7 $9F, pick/8E branches; LookupWordAt1234
  indices 0-22 over a flat memory model (story word = SRAM $A123). Everything
  else logs once and skips by its operand size.
- Overworld runs map-entry scripts, step triggers ($C0+ via the $64 list) and
  A-button cells ($40+ via the $69 list, index v-$40) through the VM; the $05
  slot-0 spawn of the chosen entry script places the player (unless $02 rebased).
- Text: $9F strips (ASCII + $FF/$FE line, $FD end), LOVE font for now.

## 3D / mobile requirements (from user, 2026-10-13)
- 3D view should extend render distance beyond the original screen edges, using the whole decoded map, plus neighbouring maps or extended terrain past map edges.
- Must be playable on any phone, foldables included: the screen size fits whatever aspect ratio it gets, and the layout adjusts live when a foldable opens or closes.

## M4 plan: 3D view + mobile (2026-10-13, third pass)

### 3D view
- **Reuse gen1recomp's tilt path.** `src/render/Tilt.lua` + the perspective mesh shader
  in `Renderer.lua` (~l.547-600, `tiltMesh`) already draw a perspective-correct
  quad of the playfield canvas. Step 1 is to point that at the MN overworld canvas
  instead of the Pokémon `Playfield`, so `Overworld:draw` renders into a
  canvas larger than 160x144 that `Tilt` projects.
- **Render distance.** We already cache each map as one full PNG (`mn_cache/maps/NNN.png`)
  plus a metatile atlas (`NNN_meta.png`) for patching cells at runtime. A 3D
  camera can sample the whole map, not just the 20x18-tile window. Past the map
  edges: (a) the warp table (`MnRom:resolveWarp`) gives neighbouring maps, so
  edge-adjacent maps can be drawn as extra quads at their offset; (b) if there is no
  neighbour, extend the terrain by repeating the edge metatile row/column with a
  fog fade, which needs no new data.
- **Height.** MN maps are pre-shaded pseudo-isometric art (see map 216's geyser
  chamber), so true heightmaps aren't in the data. Phase 1: one flat ground plane,
  with sprites (player, NPCs) as camera-facing billboards anchored at their cell's
  foot. Phase 2: per-cell height from the block data (cell semantics
  in `World.lua`: blocking cells $01-$3F become low raised walls), fed to a
  `love.graphics.newMesh` grid in place of the single quad.
- **Sprites.** `Sprites.drawList` already builds per-list images. For 3D, write them
  into one atlas per map so a single mesh batch can draw every NPC.

### Mobile / Android (foldables)
- gen1recomp's Android target and `src/core/TouchControls.lua` carry over
  unchanged. The MN states only read `input(k)` as up/down/left/right/a/b,
  the same keys TouchControls emits.
- **Any aspect ratio.** Treat 160x144 as a minimum, not a fixed size. On
  `love.resize(w, h)`, recompute the integer scale `s = floor(min(w/160, h/144))`
  and widen the view in tiles to `ceil(w/s/16)` by `ceil(h/s/16)`, since the whole map
  is cached. Keep the text box anchored bottom-centre, 160 px wide, scaled by
  `s`. This is the same live path a foldable opening or closing goes through
  (LÖVE fires `resize`, so no restart).
- Use `love.window.getSafeArea()` for notches/hinges; lay touch controls out
  in the safe area outside the game rect when the screen is wide (unfolded), and as an overlay when it's tall.
- Audio: MnMusic currently renders a whole song to a static SoundData
  (~60 s @ 22 kHz mono, ~2.6 MB). On mobile, render in a worker thread and stream
  through a QueueableSource. gen1recomp's `ChipAudio` worker already does this
  for its own synth, so MN songs should become one more "program" there.

### Status of the pieces M4 depends on
- Song data: decoded (`src/mn/MnMusic.lua`, all 41 SongList entries). Instruments
  (MusyX programs) are still approximated as pulse/triangle/noise.
- NPC animation + `$15` movement schedules work, so billboards will animate.

## Opening + music pass (2026-10-13, fourth pass)

### Opening (new game)
- Flow, confirmed in PyBoy: map 216 (geyser chamber) -> step onto the lit door
  trigger `2A:6CB5` ("New game?" Yes/No, `$9C`) -> `2A:6CD7` warning ->
  `$91` SRAM fill -> `1F:500C`/`5011` loads map 219 (Tavel Gorge), spawns
  slots 0/2/3/4, glyph-copies the kids' tiles, `$84 $0807` camera, then `$94`.
- `$94` (MarkScriptDone21B2) **yields one frame and continues**, so the
  director `1F:5084` (title card "Tavel Gorge / 5:32pm / Tuesday") runs.
- Each `$05` spawn whose anim field is not a sprite bank is the object's
  **script record**; the VM runs one coroutine per slot (`VM:spawnThread`).
  Sync is the C6F8/C6FA/C6FC mailboxes: `$56-$58` post, the frame tick
  copies to C6F9/B/D, `$60-$62` wait for a value. `$15`/`$16` are timed anim
  schedules that block their script; `$14` sets an anim; `$09` swaps a slot script.
- `$5B` from an actor plants the `$C71B` record; we run it as the dialogue
  thread once `[C6F3]` (title-card flag) is 1. That is `1F:4019`, the whole
  cave conversation, which plays line-for-line like the real game.
- Empirical (not yet proven from code): cutscene spawns with y >= map height
  sit 3 rows up (emulator OAM); `$16` phases animate in place; objects stop at
  cells != 0. Portraits (`$9B` window positions) are not drawn yet.

### Music
- Tempo formula verified: onset autocorrelation of PyBoy's capture and ours both
  peak at 0.97 s; pitch alignment best at 0 semitones / 0 lag.
- Instruments: program map -> stream index into bank $30's SoundStreamTable
  (songs use streams $26-$31). `MnMusic.instrument` reads channel (`snd_skip`),
  duty, NR43 noise, start volume, decay/cut/slide events, hold. `renderGB`
  is a 4-channel monophonic APU model (wave channel an octave down, wave from
  WaveRecords[3]). Tuned so register energy matches the capture
  (bass/mid/high 0.21/0.37/0.42 vs real 0.20/0.39/0.41).
- Open: phase scripts (vibrato), `snd_cmd01/03`, wave sweeps and the
  12-frame streamed sample (WaveRecords[0]), per-voice stealing rules.
- Final tuning: `snd_slide` treated as ~no pitch change for music (full-rate
  slides dropped spectral correlation with the capture from 0.72 to 0.59);
  lowpass 6 kHz. renderGB vs PyBoy: correlation 0.717 (plain synth 0.636),
  bass/mid/high 0.22/0.41/0.38 vs real 0.20/0.39/0.41, same 0.97 s beat.

## Camera clamp / spawn shift (solved)
`$84` sets wMapColumn/Row = E-5 / D-5 unclamped; the scroll code clamps them to
map-record byte 3 (w-11, last column) and byte 4 (last row). Objects placed
before `$84` keep their offset to the unclamped camera, so they move by
(unclamped - clamped). Tavel Gorge: row 3 -> 0 = the 3-row shift. Cached as
`camCol`/`camRow` (cache v7); `Overworld.cameraCell` applies it.

## Sound driver findings (bank $30)
- Period word is an 8.8 note number; summed from $DF15 + $DF1D + $DF23.
- cmd $01 ArmChannelVibrato: step (1/256 semitone), half-period frames;
  latch triangle added to $DF1D, which is cleared every frame.
- cmd $03 ArmChannelRamp: signed step/frame, fold limit (8.8).
- "Phase" ($11/$27/$0F scripts) is a software *volume* envelope (level 0-$0F
  in $DF70), not vibrato.
- Wave channel: snd_duty picks wave record (song $2D uses 3). Record 0 is the
  timer-streamed sample used by SFX $20/$25 (`MN_SAMPLE_OUT=x.wav`); rate
  assumes 1 block/frame until TMA ($DF08) is traced.
- Hold instruments (snd_wait $01) sustain to the next note on the channel;
  this removed the opening gaps/burst (capture corr 0.717 -> 0.900).
- snd_slide still off: semitone-unit slides lower corr (0.85).

## Story past the cave (M3.5)
- Text always starts at window column 5 (PyBoy $9C00 rows 1/3), portrait or not.
- Music master gain 0.54 = raw PyBoy level (AC rms 0.184, peak 0.60 of 4ch*15).
- Slot 0 with a script record is Tony's stand-in object: its thread runs,
  input is blocked, and op19 / op09-to-a-sprite-bank hands control back.
- Record bit 7 (op05/op0C set, op0B clear) = dormant: thread does not run.
- $53-$55 arm mailbox with $FF; $5D-$5F wait for any post; $5A runs the C70D
  record; $AF ORs SRAM; $43 targeting itself is a per-frame poll.
- One talk record at a time ($5B waits for the previous to end).
- A map reload from a thread (op65) is a scene change: objects persist.
- Clamp shift applies to slots 2+, not slot 0 (PyBoy map 220: Tony row 25).
- Reached: 219 talk -> Tony -> 220 -> 221 -> 222 item -> collapse -> map 40
  Eidon -> free control. No battle yet.
- Open: map-40 scene-1 sprites (Furoks carrying Tony, Tony's own sprite) are
  garbled; "Oh no! I'm trapped!!" + dark interlude (real) not shown; unimplemented
  $11 $1B $1C $21 $38 $39 $48 $6E $70 $71 $74 $76 $79 $7C $7E $96.
- Test: MN_ROUTE="220:far,221:far" MN_START=216 MN_IDLE_ON=219 MN_FRAMES=22000.
