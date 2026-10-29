# Magi-Nation puzzle engines, cutscene routines and transitions

A game-wide inventory of the mechanisms the overworld scripts use, each tied to the
handler in the decomp (`~/Code/magination/src/*.asm`) and to the port module that
implements it. Addresses are ROM bank:address; script opcodes are the bank-1 dispatch
($0A66) entries named in `src/mn/Opcodes.lua`. Every one of the 176 opcodes ($00-$AF)
has a lifted entry in the decomp; where the entry hands off to a continuation that is
still INCBIN, the status says so.

Status words:

- **tested**: implemented from the asm and covered by a made-up-bytes test (named).
- **implemented**: implemented from the asm, no dedicated test yet.
- **outlier**: the asm (or part of it) is still INCBIN, or the port models it some other
  way. The behaviour is listed in `docs/mn-outliers.md` (Secrets and engines) rather than
  guessed.

Reachability counts come from `tools/mn_secrets.py` (block graph from every map root).

## Puzzle engines

The A button on the overworld runs `DispatchCellAboveOnButtonA` (01:4C6E) and its
left/right/below siblings. The cell byte in WRAM bank 5 picks the engine.

| Engine | Trigger (asm) | Port | Status |
|---|---|---|---|
| Push block (Crystal Gloves) | cell `$09` and `$C9A6 >= 1`; plants 01:5597 (ResumeLeftWhileDownRecord) via PlantHandlerAndHeadWord; WalkTwoCells* | `Push.lua` | tested (`mn_push_test`) |
| Kick / stamp (Orwin's bracelet) | cell `$0B` and `$C9A6 >= 2`; plants 01:55E3, StampMapCellInWramBanks (01:4B2D, sound `$19`, metatile `$FC`) | `Kick.lua` | tested (`mn_kick_test`) |
| Talk / use cells | any cell with bit 5 or 6 set (bit 7 clear) -> SaveCellBelowAndStageThirdScript (A list) | `Overworld` A list | tested (`mn_alist_order_test`, `mn_use_record_test`) |
| Short count / plain cell | high bits clear, bit 7 set, or `$C9A6` too low -> CommitScriptAndRecordHead | `Overworld` | implemented |
| Hop / run over gaps | CountCellRun, runs of 1 and 2 | `World.hop` | tested (`mn_hop_test`, `mn_standin_hop_test`) |
| `$01`/`$02` layer walks | CountCellRun (01:517C), dispatch 01:51B6 and the ProbeCells rule; 3+ runs with `$C9A6 >= 5` use the layer heads (`$C12A`/`$C12C`) | `World`, `Overworld` (story branch, merged) | tested (`mn_layer_walk_test.lua`, `mn_gates_test.lua`) |
| Step triggers | cells `$C0`+ run the map's trigger list on entry | `Overworld` triggers | tested (`mn_trigger_live_test`, `mn_down_trigger_wake_test`) |
| Grass encounters | grass cells -> encounter script with `$47` picks and `$2E` battle | `Grass.lua` | tested (`mn_grass_test`, `mn_op47_test`) |
| Random record pick | `$47` PickScriptRecordByDividerMod (`$1484`) + AddDividerStep (`$FFA9`) | `ScriptVM` | tested (`mn_op47_test`) |
| Cell writes | `$80` WriteScriptBytesAcrossWramBanks, `$81` banks 6 and 4 | `ScriptVM` | tested (`mn_expr_store_test`, `mn_push_test`) |
| Wait for a cell value | `$1A` Opcode1A polls WRAM3 `[[FF93]]` | `ScriptVM` | tested (`mn_standin_hop_test`) |
| Chests | `$A4` PlantOffset7ThenStoreFF (247 reachable) | `ScriptVM` | tested (`mn_chest_test`) |
| Item gives | `$87`/`$88` (66 reachable) | `ScriptVM`, `ops/Travel` | tested (`mn_chest_test`, `mn_energy_refill_test`, `mn_ops_travel_test`) |
| Cave-in scatter | `$11` Opcode11 (`$0C7E`) -> PickMapCellFromDiv: a cell from rDIV inside the camera view, matched against its WRAM-5 byte (MatchWRAM5ScriptByte) | `ScriptVM`, `Overworld.scatter` | tested (`mn_op11_test`) |
| Hidden `$B0` spots | Start-menu use of item `$2A` on a `$B0` cell: SetupCommand4D (6:`$6DDF`) stores `$C724`/`$C725` and plants the `$95` fallback; 19:48F6 / 19:4BE0 / 19:4D5F (maps 101, 105, 108) | `ui/start/Machine`, `Overworld` | tested (`mn_command4d_test`) |

The dispatcher's own comment leaves what `$C9A6` counts open. The port treats it as the
upgrade level the story stores at `$A3A3` (docs/mn-story-graph.md); the thresholds 1, 2
and 5 are the ones the asm compares.

No other puzzle kinds (levers, ice, ordered or timed switches) have their own
engine in the lifted asm: they are map scripts built from the ops below (`$80` cell
writes, `$53`-`$62` posts and waits, `$1A` polls, `$A5`-`$AF` SRAM flags).

### Boat (bank 1 $60E7 / $5F25 / $6405 / $641D)

- Mount (`$60E7`): $C12B = 0, $C12A = $01, so water ($01) is floor and land ($00) is solid. The record
  in the boat's slot carries the player; Tony is hidden.
- Dock (`$5F25`): A facing a $00 cell. $C12B = $01, $C12A = 0, the boat is parked by `$6405` and
  22:40AD runs (music $07).
- Re-board (GateCellNearFirstRecord 01:641D): the facing is record 0's (the player's); the windows are
  up d = b, e in [c, c+1]; down d = b, e in [c-1, c]; left d in [b, b+1], e in [c-1, c+1]; right
  d in [b-1, b], e in [c-1, c+1]. `$64D1` runs the tail 22:40C2 in the boat's slot. The gate reads
  the `$FFAB` latch of `$FFAA` bit 2, which every A dispatch sets whatever the faced cell. It runs the
  frame after the press, so a list script staged by that press (`$C716`), an open window (`$C6EE`) or
  a filled scratch (wRecordState) blocks it.
- While riding, `$C18E`/`$C18F` (slot 0's record) stay on the cell Tony boarded from, and `$65A4`
  step-on records compare against that cell (`ow.rec0`).
- `$93` (FinishStartup -> SetupDefaultState) starts with WriteC12APattern (05:6C08), which puts
  00 FF FF 00 FF FF FF FF back at $C12A. That is what ends a ride when a step trigger such as 2F:466C
  (C6 on 281) lands Tony back on 236 through 25:7129. The port does the same and also clears its own
  layer state.
- Slot-0 records with heads `$5D81`, `$5B1E`, `$5B41`, `$5B6E`, `$5D47` or `$5B07` read the pad, so they are the
  player. 2F:466C fills slot 0 with `$5B41`. `$5D47` (mid `$5D3E`) trampolines to `$5B6E` (PixelWalk idle)
  because WalkPointerSlots leaves A = `$47` (bit 6 clear). `$5B07` (21:78EB, 19:7D92) reads only A: no walk, and A
  always tests the cell above (4C6E). It still runs the `$82` countdown (4212).

### Pixel motion (mn.Motion, mn.PixelWalk)

- mn.Motion: SaveStepThenApplyOrDispatch (05:682D), the cell probes and their handler table, the
  conveyor cells `$A0`-`$A7` (01:5E65) and the once-per-entry step triggers (01:422E).
- mn.PixelWalk: the `$5B41` head family (idle `$5B6E`, up `$5D3E` / mid-entry `$5D47` trampoline),
  which takes fine steps every frame from fine 8,8 (FillScriptRecord0808); a conveyor cell adds to
  the step. Boot's planner holds the pad while it runs. Tests: mn_motion_test, mn_pixelwalk_test,
  mn_stale_head_test.

## Cutscene routines

| Routine | Opcode / asm | Port | Status |
|---|---|---|---|
| Frame wait | `$00` Opcode00, `$94` MarkScriptDone21B2 | `ScriptVM` | tested (`mn_op4c4d_test`, `mn_op4e_test`) |
| Countdowns | `$20`/`$24` ArmCountdown, `$40` ScriptByteCountdown | `ScriptVM` | tested (`mn_kick_test`, `mn_op47_test`) |
| Random idle pause | `$41` Bank1NibblePhaseCountdown: table[AddDividerStep & `$0F`], phase `(hMainLoopCounter & 3) == 3` | `ScriptVM` | tested (`mn_op47_test`); phase needs `h.frame` (outlier when absent) |
| Split-byte countdowns | `$70`/`$71`/`$74` ($FFA7 low 6 x ($FFA6 high 2 + 1)) | `ScriptVM` | implemented |
| `$CCA6` countdowns | `$76`/`$77`/`$7A` (`$1C17`/`$1C4A`/`$1BE4`): SetCCA6 countdown, then the bank-7 tails | `ops/Panels` | tested (`mn_panel_tails_test`) |
| Sprite list animation | `$4C` QueueRepeatedSpriteList, `$4D` StepScriptSpritePointerTable | `Sprites`, `ScriptVM` | tested (`mn_op4c4d_test`) |
| Fine-step motion | `$4E` RepeatTwoScriptBytes (`$15AB`): count frames of (`$C6D2`, `$C6D3`) | `ScriptVM`, `Sprites.frames`; no list is queued, so the object is hidden on those frames | tested (`mn_op4e_test`) |
| Offset sprite lists | `$4F` QueueRepeatedOffsetSpriteList (`$1643`) | `ScriptVM`, `Sprites` | tested (`mn_op4e_test`, `mn_offset_list_test`): steps are raw screen X/Y with no wall test, first list drawn on the op's frame |
| Object dormancy | `$05`, `$0C` set record bit 7, `$0B` clears it | `ScriptVM`, `Overworld` | tested (`mn_record_carry_test`, `mn_down_trigger_wake_test`) |
| Thread sync (posts and waits) | `$53`-`$62` (C6F8-C6FD) | `ScriptVM` | tested (`mn_use_record_test`) |
| Camera to the script base | `$82` CenterFineScrollOnScriptBase (`$1E30`): column/row = base - 5, fine = 8 | `h.centerCamera` | tested (`mn_door_rebase_test`, `mn_grass_test`) |
| Camera to a word | `$84` CenterFineScrollOnScriptWord | `ScriptVM` | implemented |
| Camera pan deltas | `$83` AddScriptDeltasUntilZero (`$1E45`): (count, dx, dy) per frame into `$C843`/`$C844` | `h.pan` | implemented |
| Scroll nudge | `$7C` (`$1D4C`, cells - 5), `$7D` (`$1D6B`, record cell, floored) -> NudgeCameraDeltas 01:4587 | `Overworld.nudgeStep` | tested (`mn_nudge_test`) |
| Camera seed | `$86` SeedCameraAndEnterLoop (`$20` camera box) | `ops/Travel` | tested (`mn_ops_travel_test`) |
| Fades | `$6E`/`$6F`/`$76`/`$77`/`$79`/`$7A` (bank 7 `$4850`/`$4837`/`$489D`/`$48FD`/`$481E`/`$4870`): target `$C72B`, live `$C7AB`, split-byte countdown | `ops/Panels`, `LivePalette` | tested (`mn_palette_ops_test`, `mn_panel_tails_test`) |
| Palette colour | `$6C` StageColorWordThenCall5C00 | `ops/Panels` | tested (`mn_ops_panels_test`) |
| Window | `$9B` open (proceeds when `$C6EE == 2`), `$9A` wait `$C6EE == 0`, `$99` FinishWindowYSlide, `$9D` wait `$C6EE == 2` | `ScriptVM`, `ops/Flow` | tested (`mn_op9d_test`, `mn_window_slide_test`): `$C6EE` 0/1/2, WY from the slide table, exact frame counts |
| Music and sound | `$1B`/`$1C` slots, `$1D`/`$1E`/`$21` requests, `$1F` index, `$22`/`$23`/`$30` | `ScriptVM`, `SfxOut` | tested (`mn_sfx_test`, `mn_sfx_out_test`) |
| Input lock | scripts run with the player frozen while the main record runs; `PollScriptLoopButtons` only toggles `$C9C7` on Start | `Overworld` | implemented |
| Screen shake | none: no shake routine exists in the lifted asm (`scratch_through_shake_records.asm` is a move-name table) | n/a | none found |

## Transitions

| Transition | Opcode / asm | Port | Status |
|---|---|---|---|
| Door / warp | `$02` pair (new = old - lo + hi), `$00` copies it, `$65` loads the map (LoadFiveBankedMapSources) | `ScriptVM`, `Overworld` | tested (`mn_door_rebase_test`, `mn_trigger_live_test`) |
| Map records | `$69`, `$6A` CallScriptMapRecordsThenFillC72B, `$68` unpack to WRAM 4/6 | `ScriptVM`, `ops/Records` | tested (`mn_ops_travel_test`, `mn_ops_records_test`) |
| Travel / ferry menus | `$8B`, `$8C`, `$8D`, `$8F`, `$90` | `ops/Travel` | tested (`mn_ops_travel_test`, `mn_ui_shop_test`) |
| Battle entry | `$25` -> bank 4 `$6416`: TurnOffLCD (a cut, no fade), the intro record runs until `$C708` clears, then bank 2 `$5E6D` | `Battle.new` | implemented: no fade on entry |
| Battle exit | DispatchNonzeroD016 (02:6316): a loss (`$D016` = 3) fills all 16 palettes' target with `$7FFF` ($07:4850, `$C9D8` = `$0F`) and runs `$20` passes of ApplyPanelRowWords at one channel unit a pass, a frame each; a win, an escape or any other code goes straight to TurnOffLCD; then the `$D3CD` (or `$D3D0` on a loss) script continues | `Battle:finish` | tested (`mn_battle_exit_fade_test`): the old 20-frame alpha fade was a guess |
| Battle animations | move, Fight and spell animations are scripts staged by StagePointerUnlessD0B6Matches (02:472E; bank `$4C`, or the spell record's `+$1F` bank and `+$20/$21` pointer) and run by RunStagedPointerScript (04:71ED; B skips through HandleScriptLoopB); summons are CountdownPanelCallbacks (04:61EB, 21 frames, 20 card tiles) | `Battle:playAnim` / `Battle:playSummon` over `mn.fx.Gen` (the game's own code from the 02:472E stop, frame by frame) | tested (`mn_battle_anims_test`): the Fight cut-in equals the Glade capture frame for frame; the 8-frame white stand-in is only a fallback when no ROM is imported |
| Battle entry | `$25` LoadMapRecord, `$2E` creature setup, `$27` halt | `ScriptVM`, `battle/` | tested (`mn_battle_engine_test`, `mn_battle_director_test`) |
| Startup / reset | `$93` FinishStartup, `$97` ReenterReset | `ScriptVM`, `ops/Flow` | tested (`mn_ops_flow_test`) |
| LCD-off branches | `$A0`-`$A2` | `ops/Flow` | tested (`mn_ops_flow_test`) |
| Unpack header + block | `$67`: UnpackMapHeaderIntoWRAMBank3 (`$2F37`: stride `$C847`, word `$C849`, camera limits, `$C848` = row limit + `$0A`, scroll state cleared, `$C842` = `$44`, packed plane to WRAM 3, 1-8x stride table at `$C84D`) then UnpackBlockIntoWRAMBank5 (`$2DDC`), then the next op | `ops/Records` (`host.unpackMap` swaps both live planes) | tested (`mn_unpack_map_test`); no decoded script uses it |
| Bank jump | `$29` `jp $7449` in the script bank (bank 2: a lone `ret`) | logged; no use in any decoded script | outlier (unused) |
| Record loop / `$1126` | `$38` (C706 record, `$C9C6`/`$C9C7`-gated loop), `$39` pair countdown | `ops/Panels` | tested (`mn_record_loop_test`) |
