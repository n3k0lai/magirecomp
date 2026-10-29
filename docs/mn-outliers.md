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
5. **Fade length.** `$6E`/`$6F` stage `$C9D8`/`$C9DA` and call bank 7 `$4837`/`$4850` with callback `$4575`,
   and all three are INCBIN. The port's 16-frame fade isn't derived from code.
6. **What shows during `$4E` frames.** RepeatTwoScriptBytes queues no sprite list. Whether the object's
   last list stays on screen or nothing is drawn depends on how the sprite queue is cleared each frame, and
   that code isn't traced. The port keeps the last image. For the rock fall (11:7532: 10 frames at dy -16,
   then 40 at +4) that means the rock shows while it's lifted.
7. **Gate modes 5F25/60E6, conveyors `$A0`-`$A7`, and warps that land mid-layer.** They aren't modelled. No
   story `$01`-`$0F` or 186 script reaches them in the static graph.
8. **186 `$C3`-`$C6`** (1F:62A1-62BC). No base cell, overlay cell or `$7F`/`$80` write reachable from 186
   produces those values. They look like dead data, but that isn't proven.
9. **5C7A entry-anim timing** is still INCBIN.
10. **The route planner doesn't plan layer walks.** The engine now walks layers, but the planner doesn't
    route through them.
