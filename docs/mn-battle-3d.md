# Battle presentation in 3D (design + roadmap)

Status: prototype on branch `battle-3d`, behind `MN_BATTLE3D=1` (off by default).
The battle rules are untouched: the 3D layer only *watches* the events that
`mn.battle.Engine` already produces and spends exactly the frames the 2D screen
would have spent.

## 1. How battles run today (survey)

**Two layers.**
- `src/mn/battle/Engine.lua` is a byte-level port of the game's battle code
  (bank 2 $47D1-$5188, with tables in banks 5 and 7). `Engine.round(s)` resolves a
  whole round up front and returns a list of events: `msg`, `act {slot, species,
  target}`, `anim {script, actorSlot, targetSlot}`, `damage {slot, amount,
  species}`, `summon`, `appear`, `eliminated`, `end`, ...
- `src/mn/Battle.lua` is the screen. A coroutine (`script()`) loops
  *pending → legal → choose → play(Engine.round(s))*. `update()` resumes it once
  per game frame; `draw()` paints the 160x144 canvas that `Boot` scales up.

**How a battle starts.**
- Opcode `$25` (battle begin) collects the following `$2E/$AA/$AB` ops.
- Opcode `$27` runs the battle to the end. The Korg duel is a `$27` duel.
- A *director duel* is `$25` plus a script loop on `$2B` (e.g. the map-25
  guardian at 1A:603B): `Battle:startDirector` raises `$D3C2` every round and
  waits up to 600 frames for the script's `$2B` to clear it, then applies the
  ops the script queued.

**2D presentation.** All art is generated at runtime from the player's ROM by
`mn.fx.Gen`, which runs the game's own drawing code (`mn.fx.Cgb`) on the Glade
Weebo battle (op `$25` at 14:4158) and stores the result in the private cache
`mn_cache/battle_scenes.lua` (never committed). `Ppu.scene(name)` returns
frames/layers: `backdrop`, `menu`, `target`, `slot`, `idle`, ... and the clips
`fight_weebo_tony`, `fight_weebo_furok`, `fight_furok_weebo`, `elim_top`.
Only species $1C, $53 and $4B have pictures; everything else is a name card.
A damage event plays the matching clip (or a 16-frame flash); summon is an
8-frame white fade; elimination uses the `elim_top` frames.

**What the original game does** (decomp references, `~/Code/magination/src`):
- `StagePointerUnlessD0B6Matches` (bank 2 $472E) starts a move animation: it is
  skipped when `$D0B6 == $D103` (self-target), stores bank/pointer at
  `$C9CC/$C9CA`, sets `$C9C5/$C9C6`, copies `$D0DB→$C9E0` and `$D112→$C9E1`, and
  calls bank 4 $71ED. The script record at `$C706` is (bank $4C, $4000,
  handler $0A66). So every battle animation is a **bank-$4C script** run by the
  same script VM as the overworld (see `docs/battle-4c.md`).
- Fight uses `Script5225` (Engine `SPECIAL[0x517D]`); spells take theirs from
  the group record at +$1F..+$21 (`docs/mn-battle-tables.md`).
- Move/menu records in bank 5, 16 bytes each: 5:5EBE (Summon..Run),
  5:5EFE (Spell..Beam), 5:60BE (Flash..Frenzy), 5:62EE (Scratch..Shake), list at
  5:5EAE.
- Sprite lists for the effects live in banks $0E-$11, $25, $40, $41 (table at
  05:5D16). Script ops `$46/$4C/$4D` have no codec yet (`docs/codec-workers.md`).
- Blinking (hit flash) is `QueueBlinkSprite` (`$CCA8/$CD7F/$CD80/$CCB9`).

**Branch state.** `battle-system` has no commits that are not on master (it is
fully merged and 100+ commits behind). New work lives on `battle-3d`.

**LÖVE 11.5 3D toolbox.** `love.graphics.newMesh` with a 3-float
`VertexPosition`, `setCanvas({canvas, depth = true})`, `setDepthMode("lequal",
true)`, custom GLSL shaders with `mat4` uniforms (row-major tables are sent with
`shader:send(name, "row", m)` or transposed by hand). Rendering into a canvas
flips Y. g3d (MIT, GPL-compatible) would be acceptable, but the prototype uses
~120 lines of its own math (`src/mn/b3d/Mat4.lua`) and vendors nothing.

## 2. Target design

1. **Arena per region.** A floor plane and a back wall, textured from that
   region's battle backdrop (generated from the ROM at runtime, like today).
   Later: per-region props (Naroom trees, Underneath stalactites, ...) built
   from the region's own map tiles, extruded into boxes.
2. **Creatures as billboards**, using the runtime sprites the 2D screen already
   has (pictures, else name cards). Cylindrical billboards (they turn about Y to
   face the camera) with blob shadows. Phase 3 adds optional *extrusion*: each
   opaque pixel of the sprite becomes a voxel column of depth 1-2, built into a
   single mesh once per species.
3. **Camera** with a default 3/4 view, an intro orbit, a cut to a low side view
   for each attack, a dolly-in on big hits, and a pull-back on eliminations.
   Shots are data (a clip table) so they can be tuned without touching code.
4. **Animation timeline driven by battle events.** Every engine event maps to a
   clip (`attack`, `summon`, `elim`, `intro`, later `spell`, `heal`, `status`).
   Each clip is given the *exact* frame budget the 2D path uses, so timing,
   RNG and outcomes stay identical. Later, the bank-$4C script named in the
   `anim` event picks the effect (sparks, beams, colours) instead of a generic
   one.
5. **Classic 2D fallback.** `MN_BATTLE3D` unset (default) = today's screen,
   byte for byte. Later a settings toggle replaces the env var.
6. **Viewport tie-in (Fold 7).** The 3D scene renders into its own depth
   canvas at any size (`MN_B3D_SIZE`, default 480x432) and is composited into
   the 160x144 game canvas today. Once `docs/mn-viewport.md` lands a wider
   game canvas, the presenter is asked for that size instead (one call site,
   `P:draw(x, y, w, h)`), and the menus/message box stay as 2D overlays.

## 3. Architecture

```
Engine.round(s) ──events──▶ Battle:play() ──▶ 2D path (unchanged)
                                │
                                └─(MN_BATTLE3D)─▶ Presenter (mn.b3d)
                                                    ├─ Timeline: clips with frame budgets
                                                    ├─ camera(sample) → view/proj Mat4
                                                    └─ render(): arena, billboards, sparks
```

- **Logic never sees the presenter.** All events are computed before `play()`
  runs; the presenter only reads them. It holds no battle state of its own
  except which slots are shown/gone.
- **Event bus (next step).** Replace the direct `p3d:attack(...)` calls in
  `Battle:play()` with `Battle:emit(ev, frames)`; subscribers (2D screen, 3D
  presenter, SFX, a recorder for tests) each consume the same stream. The
  2D path becomes one subscriber, which makes the toggle a pure swap.
- **Determinism.** The presenter steps in `Battle:update()` (one step per game
  frame), not in `draw()`, so frame-saving runs are reproducible.

Files in the prototype:
- `src/mn/b3d/Mat4.lua`: row-major 4x4 math (perspective, lookAt, rotY, ...).
- `src/mn/b3d/Timeline.lua`: clips (`attack`, `summon`, `elim`, `intro`) →
  per-slot pose offsets and a camera clip. Pure Lua, unit-tested.
- `src/mn/b3d/Presenter.lua`: LÖVE meshes, shader, camera, compositing,
  optional PNG dump (`MN_B3D_SHOT=dir`, `MN_B3D_EVERY=n`).
- `src/mn/Battle.lua`: ~25 lines, all behind `self.p3d`.
- `tests/engine/mn_b3d_test.lua`.

## 4. Roadmap (intern-sized jobs)

Each job: own branch, no push, Ene reviews. Never commit PNGs or ROM data.

| # | Job | Files | Acceptance | Decomp refs |
|---|---|---|---|---|
| 1 | **Event bus** | `src/mn/Battle.lua`, new `src/mn/battle/Bus.lua`, `tests/engine/mn_battle_bus_test.lua` | `play()` emits every event once with its frame budget; 2D output identical (frame PNG hashes for the Weebo battle unchanged, `MN_BATTLE_TEST`); director test green | — |
| 2 | **Per-region arena** | `src/mn/b3d/Arena.lua`, `src/mn/fx/Gen.lua` (backdrop per region) | backdrop chosen by the battle's region; floor/wall textured; unit test for region → backdrop key | battle background layout in bank 2 (native, see battle-4c.md) |
| 3 | **Anim-script effects** | `src/mn/b3d/Effects.lua`, `tests/engine/mn_b3d_effects_test.lua` | the `anim.script` pointer selects colour/shape of the effect for Fight (4C:5225) and the spell group records; table keyed by pointer only (no ROM bytes) | 2:472E, 4C:5225, group record +$1F..+$21, 05:5D16 |
| 4 | **Sprite extrusion** | `src/mn/b3d/Extrude.lua` + test | builds one mesh per species from ImageData alpha; ≤ 4k triangles for 32x40 | — |
| 5 | **Camera shot table** | `src/mn/b3d/Shots.lua` | intro/attack/elim/heal shots as data; each shot has a unit test that the target stays in frame | — |
| 6 | **Status + heal + spell clips** | `src/mn/b3d/Timeline.lua` | new clips for the remaining event kinds, budgets equal to 2D | QueueBlinkSprite ($CCA8...) |
| 7 | **Viewport integration** | `src/mn/b3d/Presenter.lua`, after viewport branch merges | renders at the game canvas size from `mn-viewport.md`; menus as overlays | — |
| 8 | **Settings toggle** | settings screen + `Battle.lua` | toggle persists in the save's settings, env var still overrides | — |

Phase A (now): jobs 1, 5. Phase B: 2, 3, 6. Phase C: 4, 7, 8.

## 5. Running the prototype

```
MN_BATTLE3D=1 MN_B3D_SHOT=/tmp/b3d MN_B3D_EVERY=4 \
  ~/Code/interns/bin/mn-headless love . --mn --rom <rom> --mn-test /tmp/out
```
(`MN_BATTLE_TEST` boots straight into the Weebo battle, but only in the
non-test boot path; under `--mn-test` load a snapshot and route into a battle.)
