# Shadow Geyser mechanics

Survey for routing. Paraphrase of the decomp (routine names and bank:address
only). Cell counts for the Underneath geyser were checked against the ROM
block planes. Anything marked **guess** was not confirmed from a routine.

Port support is against this tree: `src/mn/World.lua` (walk), `src/mn/Overworld.lua`
(step, A, encounters), `src/mn/Kick.lua`, `src/mn/ScriptVM.lua`, `src/mn/ops/Flow.lua`.

## Underneath Shadow Geyser

Opens at story word 9 (`15:4BB0`). The Underneath world map is 279; cell 34,21
enters map 122 while the story word is 8 or 9. Cleared at story word 0x0A
(`13:6C68` on map 133, Core Stone 2).

Maps in the door graph: 122 (mouth), 125, 126, 127, 128, 129, 130, 131, 132,
133 (core). Map 123 is loaded from the story-8 appearance scene in the same
bank-15 script as the mouth (`15:4F3E`); it is not in the 125-133 door graph
and was not surveyed room by room.

### Mechanics

| Mechanic | What the game does | Port |
|---|---|---|
| Floor `$00`, wall `$08` | Probe treats `$00` as open and `$08`-$7F as occupied (`probe_cells_up.asm` and the other seven probes). | yes. `World.walkable`. |
| Colored gates `$04` `$05` `$06` `$07` | Not ledges, ice, or conveyors. `WriteC12APatternBank5` (`05:6C08`) stores `00 FF FF 00 FF FF FF FF` at `$C12A`, so `$00` and `$03` start open and `$01`, `$02`, `$04`-$07` start solid. Opcode `$85` (`ApplyScriptByteToC12E`, `01:45E6`) then rewrites only the four bytes for `$04`-$07`: a set bit in the operand makes that cell solid, a clear bit makes it open. Every puzzle room shares SRAM `$A224`. State 1 opens `$06` only, state 2 opens `$05`, state 3 opens `$04`, state 4 opens `$07`. State 0 (first visit) leaves all four solid. Stepping a pad stores the new state and copies door glyphs (`opcode $6B`). | **no** for collision. Opcode `$85` is `stageC12E` in `ops/Flow.lua` and writes `$C12E`-$C131`, but `World.walkable` treats `$04`-$07` as floor. Glyph copies do run (`Overworld.glyphCopy`). |
| Step pads `$C0+` | Low 6 bits index the bank-$21 list from opcode `$64`. Kind 1 up, 2 down, 3 right, 4 left, any other kind from every side (`StageThirdScriptFromMarkedCell`). Kind 0 pads here are the gate setters. Edge kinds are doors. | yes. `World.trigger` / `Overworld` step. |
| Dig walls `$0B` | A on the faced cell, only when SRAM `$A3A3` >= 2 (Crystal Gloves). The cell becomes open floor and metatile `$FC` (`StampMapCellInWramBanks`). | yes. `Kick.try`. |
| Push blocks `$09` | None on these planes (count 0). | n/a. `Push.lua` exists for other maps. |
| Conveyors `$A0`-$A7` | `AddCellDirectionStep` (`01:5E65`) shoves the step. None on these planes. | n/a. Not wired into the walker. |
| Encounter grass `$82` | Walkable (`probe` leaves a cell >= `$80` clear). Opcode `$32` arms a countdown (`AdvanceCell82Countdown`, `01:41D8`, every even frame while `$C6D8` is set). When it expires, the third script runs. Every grass room in this dungeon points that script at `13:5F7C`: one shared table of eight wild fights (`PickScriptRecordByDividerMod`), not a per-map table. Countdown table word is `$419C`. | **partial**. Opcode `$32` stores the bytes (`setThirdScript`). Nothing in `Overworld` calls the countdown, so grass never starts a fight. Walker object encounters (`$65A4`) are a different path. `MN_NOENC` only skips those slot encounters. |
| A-press `$40`-$45` | Index into the bank-$21 list from opcode `$69`, cell value minus `$40`. In this dungeon those scripts are chests (`opcode $A4`, `PlantOffset7ThenStoreFF`) except the four core switches. | yes for the A dispatch (`Overworld` A on bit 5/6). Chest grant is partial (below). |
| Chests | `$A4`: SRAM flag word, mask, reward category and id, map-cell word. Flag already set shows the empty line (`22:405B`); else the reward, flag bit, cell becomes `$FF`. Categories follow opcode `$88`: 0 items (`$A3A7`), 2 a roster byte (`$A019`), 3 a spell (`$A5A5`). Flag bytes used here: `$A328` `$A329` `$A32A` `$A33D` `$A33E` `$A33F` `$A346`. | **partial**. `ScriptVM` opcode `$A4` runs, and `giveReward` increments category 0. Category 2 and 3 return success without writing the roster or spell byte. |
| Core switches | Map 133 cells `$40`-$43` are opcode `$A3` one-shots on SRAM `$A125` masks 1, 2, 4, 8. Each fresh press advances `$A225` from 0 through 4 and copies a rectangle of cells (`opcode $7E`) that opens a different core passage. Entry of 133 replays the rectangles for the saved `$A225` (`13:6BB4` / `6BE5` / `6C0D` / `6C35`). `$A125` is wiped when the story word changes, so the switches reset if you leave the chapter. | **partial**. `$A3` and `$7E` handlers exist. `$7E` copies only when the VM is not in map setup, so the entry replay does not restore the passages. A press during play does copy. |
| Doors | Opcode `$02` rebases the cell, or opcode `$01` names an absolute cell, then opcode `$45` enters the other map's script. South exit of 122 saves a return triple and enters world map 279 at cell 33,21 (`2F:44F9`). | yes. `ScriptVM` opcodes `$01` `$02` `$45` `$65`, `Overworld.enterMap`. |
| Geyser flag | `$A2B2` is 1 while the mouth scene is up (`15:4BB4`), cleared when you step into 125 (`15:481D`) and when you return to 279 (`2F:44F9`), set again when the stone is taken (`13:6C68`). | yes. Plain SRAM stores. |
| Ogar | Core loads an actor at cell 29,20 whose script `13:6C7E` runs on entry and reaches the duel `13:604F` (opcode `$25`, opponent id `$5A`, level `$14`, battle-script word `$4023`). The win tail is `13:6CD9`: story word 0x0A, reload 133, copy the closed-geyser cells. A second actor at 18,20 answers A with `13:6C68`, which also stores story 0x0A, sets `$A2B2` and `$A3A4` to 3, and saves return script `15:4812`. The scene fills a talk record early, so the pad is likely held until the duel; that lock was not play-tested. | **partial**. The same director-duel opcodes as the Naroom guardian are implemented (`battleBegin`, opcode `$2B`). This fight was not run. `$A3A4` is only known here as the byte `13:6C68` sets to 3. |
| Closed geyser | If the story word is already 0x0A, room entries that test it fall into `13:6440`, a camera pan that loops. | yes for the branch (`opcode $43` / `$83`). Not checked on screen. |
| Urns, keys, `$09` blocks | No item test and no push block in the entry or step scripts read here. | n/a. |

`$03` is open in the default pattern and `$01`/`$02` are solid, but none of these planes use them. Map 122 has no `$04`-$07`, no `$82`, and no `$0B`: it is the mouth (floor, wall, two trigger indexes).

### Door graph

Trigger index is the cell's low 6 bits. Landings are the `$02` rebase (or the `$01` pair) checked against the other map's edge cells.

- **Geyser mouth [122]** (13 by 27). South edge, moving down, returns to the Underneath world map [279] at 33,21. The up-trigger at 6,13 enters the entry hall [125] at 14,49 and clears `$A2B2`.
- **Entry hall [125]** (30 by 50). A dig field across the north (144 soft-dirt cells) and one `$06` gate on row 46 (four cells). Pads at 16,44 and 16,48 select state 1, which is the state that opens that gate. South edge back to the mouth. West edge to the west gallery [126]. East edge to the southeast gallery [132]. North edge to the core's south door [133]. One chest on `$40` at 14,31 (spell category).
- **West gallery [126]** (32 by 47). All four gate colors, an 8-cell dig pocket in the southwest, six chests (`$40`-$45`). East edge back to [125]. North edge to the north gallery [129]. West edge to the side chamber [127]. An interior pad (cells around 4,8) fades to the core at cell 4,8. Gate pads: state 3 at 23,6 and 16,44; state 2 at 26,6; state 1 at 4,16 and 15,36; state 4 at 22,25 and 20,43.
- **Side chamber [127]** (30 by 30). Encounter grass, one chest at 4,5, east edge back to [126]. No colored gates.
- **Dig maze [128]** (30 by 20). 204 soft-dirt cells, no grass, no A-list. North edge to the south of [129]. Two pads set the shared color even though this room has no colored cells: state 1 at 4,15, state 4 at 25,7.
- **North gallery [129]** (32 by 47). All four colors, a 12-cell dig patch, one spell chest at 6,28. South edge (x 22-25) back to [126]. Another south edge (x 7-10) to the dig maze [128] (absolute pair 13,2; the entry script also names a spawn at 5,5, so the landing cell is the pair only when that cell is open). East edge to [130]. Interior pad at 6,23 fades to the core. Gate pads: state 3 at 15,28; state 2 at 13,10; state 4 at 19,36. The list has a state-1 script with no `$C6` cell on this plane.
- **Northeast gallery [130]** (32 by 47). All four colors, two chests. West edge back to [129]. South edge to [132]. Interior pad at 31,36 fades to the core at 26,41. Gate pads: state 3 at 21,31 and 16,36; state 1 at 28,9 and 6,20; state 4 at 10,25, 3,31 and 28,31. No cell for the state-2 list entry.
- **Southeast gallery [132]** (32 by 47). All four colors, chests on `$40` `$41` `$42` `$44` (the list also has `$43` and `$45` scripts with no cell). West edge back to [125]. North edge back to [130]. Interior pad fades to the core at 31,6. Gate pads: state 3 at 9,32 and 28,35; state 2 at 13,6, 4,11, 27,19 and 16,32; state 1 at 26,6; state 4 at 14,6, 22,19 and 28,40.
- **Core east room [131]** (45 by 35). Encounter grass only, one chest at 33,18. West edge enters the core's east door.
- **Core [133]** (40 by 40). South edge back to [125], east edge to [131]. Four interior pads: 4,36 to [129], 2,6 to [126], 32,4 to [132], 32,37 to [130]. Four one-shot switches at 30,17 / 2,31 / 13,6 / 2,21 (`$A125` bits, advancing `$A225`). 33 soft-dirt cells in the northeast corner. Ogar's actor at 29,20; the stone actor at 18,20. Grass uses the shared encounter table. No colored-gate cells; the passages are the `$7E` copies.

The color is global. A pad in one room closes the other three colors everywhere, including the hall you came through, until you step a pad for the color you need.

### Gaps (intern jobs)

1. **Colored-gate collision.** Port the `$C12A` occupancy test from `probe_cells_up.asm` (and the seven sibling probes) into `World.walkable`: a cell below `$08` is solid when `$C12A` plus that cell is nonzero. Keep the default pattern from `WriteC12APatternBank5` (so `$04`-$07` start solid) and the live bytes opcode `$85` already writes. Update the stale "meaning unknown" comment on `stageC12E` in `src/mn/ops/Flow.lua`. Test: a synthetic plane with a `$06` cell, `$C130` = `$FF` blocks, `$C130` = 0 allows, and the other three colors stay blocked. Headless: story word 9, `MN_START=125`, walk at the row-46 gate before and after the pad at 16,48; the four `$06` cells should open only after the pad, and a `$04` cell on a later map should still block.

2. **Grass encounters.** Call `AdvanceCell82Countdown` (`advance_cell82_countdown.asm`, with the even-frame gate in `step_cell82_on_even_pass.asm`) from the overworld while the player stands on `$82` and `$C6D8` is set. Opcode `$32` already stages the script and the countdown table. When the countdown hits zero, run the third script the way `StageThirdScriptFromC6DB` does. Test: synthetic `$82` cell, armed third script that sets a WRAM byte, step until that byte changes; a non-`$82` cell must not. Headless: `MN_START=127` (almost all grass, no gates), leave `MN_NOENC` unset, confirm a `[vm]` battle setup from `13:5F7C` rather than an unimplemented opcode. Do not print the fight table.

3. **Core passage replay.** `ScriptVM` opcode `$7E` skips the copy during map setup, so `13:6B33`'s `$A225` replay never changes cells. Copy during init as well, or run that select after setup. Test: set `$A225` to 1, run `13:6B33` as an init script on a synthetic map, assert the destination rect matches the source. Headless: enter 133 twice with `$A225` = 1 and confirm the same cells are open the second time without pressing a switch.

4. **Chest categories 2 and 3.** `Overworld.giveReward` only increments item counts. Opcode `$A4` still sets the flag, so a spell or roster chest is consumed and grants nothing. Grant category 3 the way opcode `$87` writes `$A5A5`, and category 2 the way opcode `$88` addresses `$A019`. Test: synthetic `$A4` with category 3 sets the spell byte and the flag; a second A takes the empty branch `22:405B`. Headless: the entry-hall chest at 125,14,31 (category 3) should change SRAM, not only the metatile.

Ogar's duel is not a separate gap until someone runs it: the opcodes match the guardian duel that is already ported. If a headless start of `13:604F` hits `[vm] unimplemented`, that opcode is the job.

## Cald Shadow Geyser

Not surveyed yet.

## Orothe Shadow Geyser

Not surveyed yet.

## Arderial geyser and the Core

Not surveyed yet.
