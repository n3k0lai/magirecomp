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
   from 16:5EEB (maps 2/44), 1F:590A (map 219, entered from 1D:4FEF and 1D:5048) and 2A:5E57 (maps 182/183). It falls through
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

9. **`$8E` after a forge (was "resume when `$CD49 != 0`").** CopyPrefixedBlockToD000 runs before the window
   opens and plants hScriptPtr one past the list with handler `$0A66`, so the `ret nz` taken after a forge
   (CommitOtherChoiceFive sets `$CD49 = 1`) runs the bytes after the list; the BC it pops is dead. A cancel
   (`$FE`) leaves `$CD49 = 0` and the op enters its second record. FlagDirectScriptFromEntryEnd (04:5494)
   sets `$CD1F` when `$A122 >= $D0`, which enters the first record. The port already continued past the list;
   it now also keeps `$CD49`. Test: tests/engine/mn_forge_ring_test.lua.
10. **The route planner plans layer walks.** World.moves gives each direction's step/hop/enter/exit/bump with
    the `$C12A`-`$C12C` gates of the current family (World.gatesFor), and both planners in src/mn/Boot.lua
    search (cell, family) states. Neither stops on a goal inside a `$02` band. Test:
    tests/engine/mn_planner_layers_test.lua. The 186 headless run gives the same route and map changes as
    before, with no VM errors.

11. **2A:50AE preset selector.** Nothing in INCBIN picks it: map 42's entry (2A:514C) installs script list
    21:4248 as its step-trigger list (`$64`), whose ten key-1 records are 2A:50AA, 50AC, 50AE, 50CE, 50D9,
    50E3, 50EA, 5100, 5107 and 5115. Cells `$C0`-`$C9` pick them, so 50AE is the `$C2` cell of what is a
    debug/preset room. 2A:5123 also names 4248 and nothing reaches it. 50AE runs `$91 $00`, six `$2C` adds,
    `$A3A5 := 999`, `$A123 := 1` and enters 1F:500C.
12. **`$91` BranchBank1OnScriptByte was a no-op in the port.** A zero byte runs FillSRAMAfterZeroScriptByte
    (01:466D): `$00` over `$A019`-`$A6A3`, `$FF` over sEntryIds `$A118`-`$A121`, and in the next SRAM bank
    `$FF` over `$1E10` bytes from `$A025`, then Copy7646IntoNextSRAMBank (02:4799) puts the `$1F` bytes at
    02:7646 at `$A000` there. A nonzero byte runs FillSRAMAfterNonzeroScriptByte (01:46B2): `$00` over
    `$0581` bytes from `$A123`. The real new-game uses are 2A:6D3B (`$00`) and 2A:6E1B (`$01`), both before
    1F:500C. VM.fillSRAM does this; the 02:7646 bytes are read from the ROM at run time. Test:
    tests/engine/mn_op91_sram_fill_test.lua.

13. **Running scripts in "sprite" banks (was Still open 2).** opcode_05.asm's CopyThreeScriptBytesAndHandler
    always installs DispatchScriptOpcode as the handler for operand 9-11, with no bank test. The port used to
    pick by bank (0E/0F/10/11/20/25). It now picks by content: Sprites.isAnim is true only when every op
    reachable from the field is `$4C`/`$4D`/`$4E`/`$4F` (following `$46`) up to a loop or `$42`/`$94`/`$12`.
    Those still decode statically. Everything else runs on the VM as the record's thread, and each
    `$4C`-`$4F` it reaches calls the animAt hook, which rebuilds the object's sprite from that point. `$09`
    uses the same test. Fields that changed class: 0E:5EA8 and 11:7596 (maps 123, 80), 11:7039 (`$47` random
    pick, map 236), 11:75C8 (`$48`, map 268), 11:7900 (`$40`, map 196), 25:7211/731F/739D (map 237),
    25:746C/747F/74DE/751E (map 236), and 25:68D8. `$09` targets that changed: 0F:4A1E, 0F:4A83, 10:5CA1,
    0F:6D60 and 11:7647; none of them is slot 0, so the slot-0 player release still holds. Headless runs on
    maps 80, 123, 196, 236, 237 and 268 have no VM errors. On 237, slot 0 now runs 25:7211 as a stand-in, so
    the player is hidden behind the choreography record. Tests: tests/engine/mn_record_script_anim_test.lua
    and tests/engine/mn_player_record_test.lua.

## Still open (the code can't answer yet)

Settled on fix/mn-secrets2: **what shows during `$4E` frames** is nothing. RepeatTwoScriptBytes queues
no sprite list, FinishFrame's HideLeftoverSprites ($0625) resets wShadowOAMCursor ($C728) every frame and
parks the slots nobody rewrote, and the record callbacks draw only through their scripts' own
QueueSpriteList calls. The port hides the object on those frames (`Sprites.tick`, `o.hidden`); the rock
fall (11:7532) is unseen while it lifts and shows only as it drops. Test: mn_op4e_test.

Also settled on fix/mn-secrets2, from the code:

- **Owner of 1F:581F.** Map 191's trigger list 21:499C has cell `$C1` at 9,8; it runs 15:6066 (the
  Core Glyph text), then 15:6085 does `$45` into 1F:579A, a `$93` startup on map 219 that fills slot 0
  with 1F:585D and slots 2-4 with 586C, 58B1 and 58BC. 585D's `$5A` reaches the talk walk 1F:4C27, and at
  1F:4D7F it does `$9B 58 54` then `$09` (RunScriptInSlot, not `$04`) slot 4 on 1F:581F, a slot
  sequence (frames 0E:6E1A, 6E2E, 6E38, 6E1A, 6E24). The `$45` into 29:4000 sits at 1F:590A in the same
  file; 590A is entered from 1D:4FEF and 1D:5048 (map 223), and 1D:4FEF from 23:7CAF (map 64) <-
  13:5E2E (map 61). The port's `$45`, `$5A` and `$09` paths already run this chain.
- **186 `$C3`-`$C6`** are dead data. 186 has one entry (1F:688B) and list 21:4E14. Its base plane holds
  only C0, C1, C2, C7, C8 and C9; its A-list overlay 69:7AD0 (1F:62D4) has none of C3-C6. The overlays
  that do (6D:6EBF, 6A:5D88) are 187-sized and applied by 187's scripts (1F:699C, 69D0, 6B69, 6C91,
  6E67); loading 186 rewrites all 4096 cells. 187's C0-C5 (1F:6910-693D) enter 186 at the same pairs,
  so 1F:62A1-62BC are the unused reverse rows. No `$04`/`$80` cell write on 186 makes C3-C6.
- **Warps that land mid-layer** don't exist: every target entry runs `$93`, which resets the layer
  gates and refills slot 0.
- **Conveyors `$A0`-`$A7`** (01:5E65 inside the `$5B41` family) are implemented: mn.Motion (05:682D,
  the probes, 422E) and mn.PixelWalk. Tests: mn_motion_test, mn_pixelwalk_test.
- **`$5B07`** (21:78EB, 19:7D92, script 20:5BDF) is the player held in place: 4AF0, then
  StepCell82EveryFourthFrame (01:4212), then DispatchCellAboveOnButtonA (01:4C6E), then
  CommitScriptRecord. No pad walk; a newly pressed A tests the cell above whatever the facing.
  Port: Overworld `frozenPass`. Test: mn_frozen_head_test.
- **Re-board vs the A dispatch.** Every A dispatch sets `$FFAA` bit 2 before it reads the cell (the
  faced cell is never tested for the latch). FinishFrame copies it to `$FFAB`, and the parked boat's
  `$6405` runs 01:641D in its own pass on the next frame, needing wRecordState = 0, `$C6EE` = 0 and
  `$C716` = 0. So a list script staged by the A press blocks the re-board, while a push or kick does
  not. Talk records use the same gate (StageScratchThenPlantHeadWord64D1, 01:63ED) in slot order; one
  that fires sets wRecordState and blocks later slots, while `$6405` does not. The port keeps its talk
  hit-test first (exact when the talker's slot is the lower one), runs push/kick/list next, and then
  the boat. The port's old "blocked faced cell" condition is gone. Test: mn_frozen_head_test.
- **`$65A4` while riding** compares the record's cell with `$C18E`/`$C18F`, slot 0's record. Only
  Opcode00 (01:4426) and slot 0's own commit write those, and 22:40C2 (`$0C`, `$1F`, `$13`, `$45`)
  doesn't move Tony. So during a ride the roll is against the cell Tony boarded from, not the boat.
  Port: `ow.rec0` (mn.Ride), used by the step-on check. Test: mn_ride_mode_test.

1. **The boat's first facing.** With no direction held, `$60FD` picks the idle tail from
   hRecordHead & 3, which is the boat record's opening byte. Opcode05 skips that byte, so the value is
   whatever the slot's last occupant left (InitPointerList only sets bit 7 and clears bit 6). The port
   doesn't mirror record byte 0 across occupants and keeps Tony's facing until the first direction.
2. **5C7A entry-anim timing** (layer-2 heads, the story worker's area; report only). The table gives
   dy -2,-2,-1,-1, 0 x4, +2 x6, +3 x4, +4 x2, then +1 x3: net 35 px over 23 frames. The 5CB3 slide
   that follows moves 4 px a frame; the port slides 1.
3. **5D47** (inside ResumeOtherLeftCellScript) is treated as a pad head, but its dispatcher isn't lifted.
4. **The layer-1 pixel heads** are not implemented in the port yet.

## Secrets and engines (fix/mn-secrets)

Unresolved items from docs/mn-secrets.md and docs/mn-engines.md. None is guessed in the port.
Resolved on fix/mn-secrets2 and removed from this list: Bolt and the other unsummoned ids
(the ring forge, lifted), the sound test (unreferenced), the hidden `$B0` spots (Start-menu
use of item `$2A`, SetupCommand4D), the `$11` scatter (PickMapCellFromDiv), `$38`/`$39`,
`$76`/`$77`/`$7A`, the `$99`/`$9A`/`$9B` slides, `$4F` screen-space motion and the
post-game (story `$19`/`$1A`).

1. **Thunder Hyren (id 71)**: obtainable through the forge, but its battle in
   Unused_Script_19_62AA has no caller. Cut content: nothing in the ROM reaches it.
2. **Map 167** (Cave/Mush Hyren room) has no script warp in. Its only references are an
   unused run at 10:4B2A-4B42 and word references at 15:6E0B and 59:5CC2.
3. **`$29`** has no use in any decoded script. It is `jp $7449` in the current script bank (a
   lone `ret` in bank 2, arbitrary bytes elsewhere). The port logs it. (`$67` has no use either,
   but `$2F37` is source now and the port runs it: ops/Records, `mn_unpack_map_test`.)
4. **`$41` phase**: exact only when the host provides `h.frame` (hMainLoopCounter); otherwise
   the port waits the worst case, 4 x (count + 1).
5. **Map-40 data runs**: the reachable `$38` (02:4126, 51:5604) and `$9D` (7B:478F) uses and
   species 131 at 51:5614 sit inside map 40 at offsets that look like data read as code.
6. **Forge `$CD50`**: on the `$8E` path SpendNewEntryMeasures runs `[$CD50]` - 1 passes with
   whatever `$CD50` holds; the port reproduces that, and which value the game has there at
   each forge is not traced.
