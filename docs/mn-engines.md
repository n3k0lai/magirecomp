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
| `$02` layer walk | CountCellRun 3+ with `$C9A6 >= 5` swaps to the `$02` layer heads (`$C12A`/`$C12C`) | owned by fix/mn-river-cavein | outlier here (other branch) |
| Step triggers | cells `$C0`+ run the map's trigger list on entry | `Overworld` triggers | tested (`mn_trigger_live_test`, `mn_down_trigger_wake_test`) |
| Grass encounters | grass cells -> encounter script with `$47` picks and `$2E` battle | `Grass.lua` | tested (`mn_grass_test`, `mn_op47_test`) |
| Random record pick | `$47` PickScriptRecordByDividerMod (`$1484`) + AddDividerStep (`$FFA9`) | `ScriptVM` | tested (`mn_op47_test`) |
| Cell writes | `$80` WriteScriptBytesAcrossWramBanks, `$81` banks 6 and 4 | `ScriptVM` | tested (`mn_expr_store_test`, `mn_push_test`) |
| Wait for a cell value | `$1A` Opcode1A polls WRAM3 `[[FF93]]` | `ScriptVM` | tested (`mn_standin_hop_test`) |
| Chests | `$A4` PlantOffset7ThenStoreFF (247 reachable) | `ScriptVM` | tested (`mn_chest_test`) |
| Item gives | `$87`/`$88` (66 reachable) | `ScriptVM`, `ops/Travel` | tested (`mn_chest_test`, `mn_energy_refill_test`, `mn_ops_travel_test`) |
| Cave-in scatter | `$11` Opcode11 (`$0C7E`) -> `$0C8F` (INCBIN, SC_PickMapCellFromDiv) | `Overworld.scatter` (PyBoy-derived) | outlier |
| Hidden `$B0` spots | map-entry fallback 19:4BE0 checks action `$2A` on a `$B0` cell (map 105); lone `$B0` cells on maps 101, 108 | none | outlier |

The dispatcher's own comment leaves what `$C9A6` counts open. The port treats it as the
upgrade level the story stores at `$A3A3` (docs/mn-story-graph.md); the thresholds 1, 2
and 5 are the ones the asm compares.

No other puzzle kinds (levers, ice, ordered or timed switches) have their own
engine in the lifted asm: they are map scripts built from the ops below (`$80` cell
writes, `$53`-`$62` posts and waits, `$1A` polls, `$A5`-`$AF` SRAM flags).

## Cutscene routines

| Routine | Opcode / asm | Port | Status |
|---|---|---|---|
| Frame wait | `$00` Opcode00, `$94` MarkScriptDone21B2 | `ScriptVM` | tested (`mn_op4c4d_test`, `mn_op4e_test`) |
| Countdowns | `$20`/`$24` ArmCountdown, `$40` ScriptByteCountdown | `ScriptVM` | tested (`mn_kick_test`, `mn_op47_test`) |
| Random idle pause | `$41` Bank1NibblePhaseCountdown: table[AddDividerStep & `$0F`], phase `(hMainLoopCounter & 3) == 3` | `ScriptVM` | tested (`mn_op47_test`); phase needs `h.frame` (outlier when absent) |
| Split-byte countdowns | `$70`/`$71`/`$74` ($FFA7 low 6 x ($FFA6 high 2 + 1)) | `ScriptVM` | implemented |
| `$CCA6` countdowns | `$76`/`$77`/`$7A` (`$1C17`/`$1C4A`/`$1BE4`): countdown then INCBIN tail | `ScriptVM` waits the last byte | outlier |
| Sprite list animation | `$4C` QueueRepeatedSpriteList, `$4D` StepScriptSpritePointerTable | `Sprites`, `ScriptVM` | tested (`mn_op4c4d_test`) |
| Fine-step motion | `$4E` RepeatTwoScriptBytes (`$15AB`): count frames of (`$C6D2`, `$C6D3`) | `ScriptVM`, `Sprites.frames` | tested (`mn_op4e_test`) |
| Offset sprite lists | `$4F` QueueRepeatedOffsetSpriteList (`$1643`) | `ScriptVM`, `Sprites` | tested (`mn_op4e_test`); cell vs fine motion is an outlier note |
| Object dormancy | `$05`, `$0C` set record bit 7, `$0B` clears it | `ScriptVM`, `Overworld` | tested (`mn_record_carry_test`, `mn_down_trigger_wake_test`) |
| Thread sync (posts and waits) | `$53`-`$62` (C6F8-C6FD) | `ScriptVM` | tested (`mn_use_record_test`) |
| Camera to the script base | `$82` CenterFineScrollOnScriptBase (`$1E30`): column/row = base - 5, fine = 8 | `h.centerCamera` | tested (`mn_door_rebase_test`, `mn_grass_test`) |
| Camera to a word | `$84` CenterFineScrollOnScriptWord | `ScriptVM` | implemented |
| Camera pan deltas | `$83` AddScriptDeltasUntilZero (`$1E45`): (count, dx, dy) per frame into `$C843`/`$C844` | `h.pan` | implemented |
| Scroll nudge | `$7C` (`$1D4C`, cells - 5), `$7D` (`$1D6B`, record cell, floored) -> NudgeCameraDeltas 01:4587 | `Overworld.nudgeStep` | tested (`mn_nudge_test`) |
| Camera seed | `$86` SeedCameraAndEnterLoop (`$20` camera box) | `ops/Travel` | tested (`mn_ops_travel_test`) |
| Fades | `$6E` (bank 7 `$4850`), `$6F` (`$4837`) to/from a BGR555 colour; targets INCBIN | `h.fade` | outlier (fade curve) |
| Palette colour | `$6C` StageColorWordThenCall5C00 | `ops/Panels` | tested (`mn_ops_panels_test`) |
| Window | `$9B` open (proceeds when `$C6EE == 2`), `$9A` wait `$C6EE == 0`, `$99` FinishWindowYSlide, `$9D` wait `$C6EE == 2` | `ScriptVM`, `ops/Flow` | `$9D` tested (`mn_op9d_test`); `$99`/`$9A`/`$9B` implemented (box model; slide continuations INCBIN: outlier) |
| Music and sound | `$1B`/`$1C` slots, `$1D`/`$1E`/`$21` requests, `$1F` index, `$22`/`$23`/`$30` | `ScriptVM`, `SfxOut` | tested (`mn_sfx_test`, `mn_sfx_out_test`) |
| Input lock | scripts run with the player frozen while the main record runs; `PollScriptLoopButtons` only toggles `$C9C7` on Start | `Overworld` | implemented |
| Screen shake | none: no shake routine exists in the lifted asm (`scratch_through_shake_records.asm` is a move-name table) | n/a | none found |

## Transitions

| Transition | Opcode / asm | Port | Status |
|---|---|---|---|
| Door / warp | `$02` pair (new = old - lo + hi), `$00` copies it, `$65` loads the map (LoadFiveBankedMapSources) | `ScriptVM`, `Overworld` | tested (`mn_door_rebase_test`, `mn_trigger_live_test`) |
| Map records | `$69`, `$6A` CallScriptMapRecordsThenFillC72B, `$68` unpack to WRAM 4/6 | `ScriptVM`, `ops/Records` | tested (`mn_ops_travel_test`, `mn_ops_records_test`) |
| Travel / ferry menus | `$8B`, `$8C`, `$8D`, `$8F`, `$90` | `ops/Travel` | tested (`mn_ops_travel_test`, `mn_ui_shop_test`) |
| Battle entry | `$25` LoadMapRecord, `$2E` creature setup, `$27` halt | `ScriptVM`, `battle/` | tested (`mn_battle_engine_test`, `mn_battle_director_test`) |
| Startup / reset | `$93` FinishStartup, `$97` ReenterReset | `ScriptVM`, `ops/Flow` | tested (`mn_ops_flow_test`) |
| LCD-off branches | `$A0`-`$A2` | `ops/Flow` | tested (`mn_ops_flow_test`) |
| Unpack header + block | `$67` (`$2F37` INCBIN) | not implemented; 0 reachable uses | outlier |
| Bank jump | `$29` `jp $7449` (INCBIN) | logged | outlier |
| Record loop / `$1126` | `$38`, `$39` (targets INCBIN) | logged | outlier |
