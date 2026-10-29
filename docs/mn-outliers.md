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

1. **Owner of 1F:581F.** It's reached through a `$04` at 1F:4D83, and no map entry walk reaches that.
2. **What shows during `$4E` frames.** RepeatTwoScriptBytes queues no sprite list. Whether the object's
   last list stays on screen or nothing is drawn depends on how the sprite queue is cleared each frame, and
   that code isn't traced. The port keeps the last image. For the rock fall (11:7532: 10 frames at dy -16,
   then 40 at +4) that means the rock shows while it's lifted.
3. **Conveyors `$A0`-`$A7` and warps that land mid-layer.** Not modelled yet. The ride gates (60E7 /
   5F25) are no longer here: the boat is reachable from 236 entry 4 (2F:46C0) and from 258/40 onto map
   281, and mn.Ride implements it (see docs/mn-engines.md, "Boat"). Ride outliers left for Nicholai:
   the two `$5B07` slot-0 records (a tail into CommitScriptRecord that never reads the pad, so the port
   doesn't treat them as the player); the boat's first facing; whether the `$65A4` encounter roll on 281
   compares against the boat or Tony; and whether the talk hit-test or the 01:641D window decides a
   re-board when both could fire.
4. **186 `$C3`-`$C6`** (1F:62A1-62BC). No base cell, overlay cell or `$7F`/`$80` write reachable from 186
   produces those values. They look like dead data, but that isn't proven.
5. **5C7A entry-anim timing** is still INCBIN.

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
3. **`$29` and `$67`** have no use in any decoded script. `$29` is `jp $7449` in the current
   script bank (a lone `ret` in bank 2, arbitrary bytes elsewhere); `$67` calls `$2F37`,
   still INCBIN. The port logs both.
4. **`$41` phase**: exact only when the host provides `h.frame` (hMainLoopCounter); otherwise
   the port waits the worst case, 4 x (count + 1).
5. **Map-40 data runs**: the reachable `$38` (02:4126, 51:5604) and `$9D` (7B:478F) uses and
   species 131 at 51:5614 sit inside map 40 at offsets that look like data read as code.
6. **Forge `$CD50`**: on the `$8E` path SpendNewEntryMeasures runs `[$CD50]` - 1 passes with
   whatever `$CD50` holds; the port reproduces that, and which value the game has there at
   each forge is not traced.
