# Open questions for Nicholai (static audit)

Everything below was checked against the decomp source (asm and decoded evscripts). "Verified" means the
port now follows the cited routine and a made-up-byte test pins it. An open item is one the code can't
answer yet: the routine is still INCBIN, or no static caller exists. Nothing here is a guess.

## Resolved by the code

1. **`$01`/`$02` layer walks.** Verified against CountCellRun (01:517C), the dispatch at 01:51B6 and the
   ProbeCells rule: a cell `>= $80` is clear, `$08-$7F` is occupied, and `< $08` is occupied when
   `[$C12A+cell] != 0`. Layer 2 heads slide and layer 1 heads walk on the held pad. Port: World.lua and
   Overworld.lua. Tests: tests/engine/mn_layer_walk_test.lua and mn_gates_test.lua.
2. **`$4C`/`$4D` in map scripts.** ScriptVM now waits each record's frame count (the `$4C` sum, or entries
   x count for `$4D`). It no longer skips them.
3. **What starts the bank-`$29` chain.** 29:4000 is a single `$86` (seed_camera_loop.asm). `$45` enters it
   from 16:5EEB (maps 2/44), 1F:581F (through a `$04` at 1F:4D83) and 2A:5E57 (maps 182/183). It falls through
   into the 29:4001 stub chain, which is the travel-card tour. 187's 29:4DF2 entry is part of that tour, not
   a gameplay door.
4. **Harness hacks.** Every MN_* switch is opt-in (MN_NOENC, MN_GOD, MN_FORGE, MN_PICK, MN_SNAP_*, MN_LOAD and
   others). MN_NODORM is the inverse: records are dormant unless it's set. The suites run with no MN_* vars.
5. **Story stores the walk didn't find.** All of them are now attributed (docs/mn-story-graph.md). The
   misses came from the tool, not the game. It read `$05` operand 12-14 as the running script, but
   opcode_05.asm puts the running script at operand 9-11. It also stopped at `$86`/`$94`/`$8E`, and those ops
   resume.
6. **`$A3A3` / `$C9A6` levels and 186 -> 187.** `$C9A6` is copied from `$A3A3` (01:613A). The level stores
   are:

   | Level | Sites |
   |---|---|
   | 0 | 1F:5014, 1C:426B |
   | 1 | 14:6B30 (story `$04` battle tail) |
   | 2 | 1D:4660 (story `$07`), 2A:510A |
   | 3 | 19:7B66 (map 250), 1C:4168 (map 362), 2A:5118 |
   | 4 | 2F:472F/473C (story `$12`, from map 368's `$05` running script 1C:49BC) |
   | 5 | 19:63C3 (maps 290/283, story `$17`), 2A:50CE preset, 2A:5123 unused |

   On the story path, level 5 comes after 186: `$10` is maps 187-189. The only earlier source is the 2A:50AE
   preset selector (maps 40/42). `$A123` is written only by `$A9`/`$AD` story stores.
7. **`$4E` RepeatTwoScriptBytes.** Verified against repeat_two_script_bytes.asm (commit d9783293, from the
   fix/mn-secrets branch). For `count` passes it sets the fine deltas `$C6D2`/`$C6D3` and queues no sprite
   list, then the next op runs. Count 0 is two bytes long. The port used to multiply the next record's count,
   which made the 11:7532 rock fall 10x too long. `$4F` is in the same commit. Test:
   tests/engine/mn_op4e_test.lua.

8. **Fades and palette ops (was "fade length").** There is no fixed fade length. Disassembled from the ROM
   at runtime (bank 7 is INCBIN in the decomp): `$C72B` is the target block (8 BG then 8 OBJ palettes),
   `$C7AB` the live block that the planted callback 07:4575 uploads. `$C9D8` picks rows (`$07` BG, `$0F` all,
   `$87` OBJ, `$F0` last OBJ palette).
   - `$6E` (07:4850) fills the target rows with one word and uploads nothing; `$6F` (07:4837) fills the live
     rows and uploads: an instant set. `$79` (07:481E) copies target to live.
   - A fade is `$76` (live steps toward the target rows, 07:489D), `$77` (live steps toward one word,
     07:48FD, which does not reload the `$C830` step count) or `$7A` (07:4870 RotatePaletteColors, modes
     4/3/other). Each runs the split-byte countdown: N ticks (`& $3F`, 0 = 256) of P frames (top two bits + 1),
     one 5-bit step per channel per tick. `$76 $20` from black is 32 ticks of 1 frame.
   - `$70` (07:416B) rotates colors 1-3 of BG palettes 0-2 (slot 0) or 3-5: the water/lava cycling, 131 uses.
     `$71` (07:41CB) steps those toward a word (color 0 of the slot's last palette too unless `$C9E2`/`$C9E3`).
     `$74` (07:42E3 / 4787) permutes channels: 1 r<->b, 2 g<->b, 3 r<->g then falls into r<->b (so b,r,g),
     other g,b,r.
   - `$65` (2EC3) puts the map's 32 BG words in both blocks at once; `$66` (2EE9) does the same for OBJ.
   Port: src/mn/ops/Panels.lua runs these on VM RAM; the field draws through `$C7AB` (src/mn/LivePalette.lua,
   palette-index map images from the importer). The old 16-frame overlay fade and the `$C6F3` 64-frame
   startup fade are gone: `$C6F3` is only ever written (00:08AD, 00:21A9). What the screen shows at startup is
   whatever the scripts' own ops set (most often `$6F $0F $7FFF`, all white, in the 60 bytes before a `$93`;
   `$6F $87 $0040` appears once). OBJ colors go through a base-to-live map of the `$21:$5CC0` block; where two
   OBJ palettes share a base color the lower one wins, which only differs from the hardware when an op
   touches some OBJ palettes and not others. Test: tests/engine/mn_palette_ops_test.lua.

## Still open (the code can't answer yet)

1. **`$8E` resume when `$CD49 != 0`.** CallBank4_5494ThenEnterScript does `ret nz` with the saved BC. The
   resume point after that return is in INCBIN, so the port's "continue at list+len" can't be confirmed.
2. **2A:50AE preset selector.** The code that picks which preset (level 3 or 5) runs is still INCBIN.
3. **Owner of 1F:581F.** It's reached through a `$04` at 1F:4D83, and no map entry walk reaches that.
4. **Running scripts in "sprite" banks.** opcode_05.asm always runs operand 9-11 as the record's script. The
   port only threads it outside banks 0E/0F/10/11/20/25, and it decodes those banks statically
   (Sprites.frames). That's exact for pure `$4C`/`$4D`/`$4E`/`$46` anims. It isn't exact for the bank-25
   choreography scripts 25:7211, 731F, 739D, 746C, 747F, 74DE, 751E (maps 236, 237, 240, 368) or 25:68D8,
   all of which hold flow and story ops. None of these are in stories `$01`-`$0F` or the 186 area. Fixing it
   means running every record on the VM with sprite queueing. That's a design change, so I left it for you.
5. **What shows during `$4E` frames.** RepeatTwoScriptBytes queues no sprite list. Whether the object's
   last list stays on screen or nothing is drawn depends on how the sprite queue is cleared each frame, and
   that code isn't traced. The port keeps the last image. For the rock fall (11:7532: 10 frames at dy -16,
   then 40 at +4) that means the rock shows while it's lifted.
6. **Gate modes 5F25/60E6, conveyors `$A0`-`$A7`, and warps that land mid-layer.** They aren't modelled. No
   story `$01`-`$0F` or 186 script reaches them in the static graph.
7. **186 `$C3`-`$C6`** (1F:62A1-62BC). No base cell, overlay cell or `$7F`/`$80` write reachable from 186
   produces those values. They look like dead data, but that isn't proven.
8. **5C7A entry-anim timing** is still INCBIN.
9. **The route planner doesn't plan layer walks.** The engine now walks layers, but the planner doesn't
    route through them.

## Secrets and engines (fix/mn-secrets)

Unresolved items from docs/mn-secrets.md and docs/mn-engines.md. None is guessed in the port.

1. **Thunder Hyren (id 71)** is only summoned in Unused_Script_19_62AA, a bank-19 gauntlet no
   map root reaches. Is it cut content, or entered from bank code still INCBIN?
2. **Bolt Hyren (id 9)** has no `$2E` anywhere. Creatures can also come from bank-4 `$8E`
   (CallBank4_5494, INCBIN); ids 55, 69, 84, 86-108 are in the same position.
3. **Map 167** (Cave/Mush Hyren room) has no script warp in. Its only references are an
   unused run at 10:4B2A-4B42 and word references at 15:6E0B and 59:5CC2.
4. **Sound test** (bank 7 `$5997`/`$59CA`): the caller is INCBIN, so the way in is unknown.
5. **Hidden `$B0` spots** (maps 101, 105, 108): what action `$2A` is has not been traced.
6. **`$11` cave-in scatter** (`$0C7E` -> `$0C8F`, SC_PickMapCellFromDiv) is INCBIN; the port's
   `Overworld.scatter` comes from PyBoy observation, not the asm.
7. **`$29`, `$38`, `$39`, `$67`** hand off to INCBIN code; the port logs them. Reachable uses
   of `$38` (02:4126, 51:5604) and `$9D` (7B:478F) sit inside map 40 at offsets that look like
   data read as code (species 131 at 51:5614 too).
8. **`$76`/`$77`/`$7A`** count `$FFA6` down and fall into an INCBIN tail; the port waits on the
   last operand byte.
9. **`$41` phase**: exact only when the host provides `h.frame` (hMainLoopCounter); otherwise
   the port waits the worst case, 4 x (count + 1).
10. **`$6E`/`$6F` fades and `$99`/`$9A`/`$9B` window slides**: the bank-7/bank-1 targets are
    INCBIN; the port uses its own fade and text-box timing.
11. **`$4F` offset lists** add dx/dy to the object cell each frame; the port's sprite model
    applies them as cell steps, not fine-pixel motion. `Sprites.firstImage` takes the first
    list image as the initial frame (assumption).
12. **Post-game**: content gated after story `$1A` was not inventoried.
