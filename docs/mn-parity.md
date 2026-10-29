# MN script VM and motion head parity

Port vs decomp for every script opcode ($00-$AF) and the layer motion heads.
Generated from the decomp sources (handler files, event-script listings) and
the port's handler sites; no ROM bytes here. Regenerate when handlers move.

## Method

- Handler coverage: every opcode in the decomp table has a port handler
  (`src/mn/ScriptVM.lua` `op == 0xNN` chains or `src/mn/ops/*.lua` via
  `OpExt.lua`), except $29 (see below).
- Operand lengths: `src/mn/Opcodes.lua` `M.LEN` against the operand bytes that
  follow each opcode in the decomp's disassembled event scripts. 154 of 176
  opcodes appear there; every fixed length matches the most common run and is
  observed at least once. Record forms (`rec3`-`rec6`) fit n records plus the
  $00 terminator at every use. The other variable forms (`expr*`, `pick`,
  `tab`, `blk*`, `strip`, `range7`, `exact5`, `repeat2`) are not split cleanly
  by the listings and are checked through `MnRom:insn` and their tests. The 22 opcodes not used by any
  listed script are checked against their handler only.
- Semantics: handler-by-handler reading of the asm, with tests named in the
  table. Motion heads: `src/mn/LayerHeads.lua` header lists the asm routines
  each head translates.

## Fixed in the sweep

- $5D-$5F, $60-$62: a satisfied wait plants INITIAL_SCRIPT_HANDLER and
  returns, so the next opcode runs the following frame. The port ran it the
  same frame; it now yields one frame (`mn_next_pass_test`).
- $34, $35, $A9, $91: same pattern (plant INITIAL_SCRIPT_HANDLER, call, ret); the
  port went on in the same pass and now yields one frame.
- $30: its tail (07:584A, CallCallback then `jp [$C840]`) runs 07:56ED
  FillTilemapRect22x20 in every script use: tile $FF / attribute $8F painted
  over the 22x20 rectangle at [$C863] as 11x10 blocks of 2x2 tiles, one block a
  frame in the spiral order of the call list at 07:56FD (110 frames). The port
  skipped it; `mn.Spiral` now holds the field for those frames with the order
  read from the ROM (`mn_spiral_test`). Its FinishStartup tail ($2158) runs
  after the spiral, so the rest of the stream runs in the startup loop below.

## Pass boundaries

A handler that ends in `jp DispatchScriptOpcode` (or `jp INITIAL_SCRIPT_HANDLER`)
runs the next opcode in the same pass; one that plants INITIAL_SCRIPT_HANDLER
and `ret`s ends the record's pass, so the next opcode runs next frame. Checked:
$48, $4A, $5D-$62, $73, $75, $78, $79, $7B, $34, $35, $A9, $91, $6B (one tile a
pass), $26-$2F (operands to $D392, then the pass ends) match; $91's zero path
runs 2:4799. $96 ends in `jp INITIAL_SCRIPT_HANDLER`, which is $0A66
DispatchScriptOpcode itself, so its next op runs in the same pass; the port had
yielded a frame (fixed, `mn_startup_passes_test`). Open: $25.
$20 (opcode_20_arm_countdown.asm) and $24 (opcode_20.asm) are sound-selector
setups that end in `jp DispatchScriptOpcode`; the port had waited operand frames
for both. They now run in the same pass and arm the driver: $24 a music fade-out
(SoundSelectBit0), $20 the SoundCountdown sound or, with $C924 already set,
Opcode21's request (`mn_sound_ops_test`). $1F now also writes the driver's
$C92A/$C92C, so a fade starts from $0F.

A pass is not a frame while FinishStartup's RunScriptLoop runs
(run_script_record.asm): from $93, or the $30 spiral's `jp FinishStartup`, until
the main record parks or $94 sets wScriptDone, the passes repeat back to back
with the LCD off, and record threads wait for MainLoop's FinishFrame. The port
marks that span with `startupPending` and `VM:inStartup()` (main record only).
Per-pass step handlers that count $FFA6 down and `ret` take no frames there:
$40, $4C, $4D, $4E, $4F, $6B; nor do the pass ends $48, $13, $A9, $91, $4A, $80,
$81, $03, $0D, $78 and $7E/$7F's cell steps, whose LCD-off path also skips the
edge check (`mn_startup_passes_test`, `mn_edge_stall_test`). Polls that wait on
another record or the frame counter ($5B, $5C, $1A, mailboxes) still take a frame.

wLCDC ($C936) is modelled in the VM: $E3 (LCDC_PLAY) from VM.new, 0 at $93
(FinishStartup's TurnOffLCD), $E3 again where the port ends the startup loop ($94,
$42/$12), 0 for a map-setup record (LcdOffSetup) with TurnOnLCDIfOff after it, and 0 at
$38 (with wScriptDone 0), which the record's $94 turns back on ($E3) through TurnOnLCDIfOff
(install_script_record_loop_bank4.asm).
$44, $A0-$A4, the $D392 pass tail and Overworld:lcdOn read it, so a startup script
takes the LCD-off branches as the asm does, not only map setup.

## Known divergences (intentional)

- Mailboxes ($C6F8-$C6FD). Hardware `AddAndShiftUnknown` copies C6F8 to C6F9
  (and FA->FB, FC->FD) every frame, zeros included, so a post is readable for
  one frame. The port's main VM and record threads don't tick in one lockstep
  loop (text boxes pause the main VM), so `VM:tickThreads` latches nonzero
  posts until the next post instead. Waiters ($5D-$5F, $60-$62) therefore see
  a post later than one frame; nothing found so far relies on a post expiring.
- $29 JumpScriptBank7449: unused by every decomp script; the port logs it
  (docs/mn-outliers.md, Secrets and engines #3).
- $16 pans ride the camera, so a walker stops where the camera stops
  (PyBoy-checked; see the handler comment).

## Motion heads

- $02 layer entries 5C7A/5CF5/5D70/5BFF: $4C hop then the $4D slide at 4 px a
  frame; slides 5CB3/5D2E/5DA9/5C38 4 px a frame on one axis; bumps
  5CC3/5D3E/5DB9/5C48 ease out and back. 5C7A is locked against the ROM by
  `mn_layer_heads_test` (MN_ROM): 23 frames net +29 px, slide begins the same
  pass as the last $4C step (asm: zero count dispatches $4D). The other
  entries mirror it on their axis (left/right x net +-63 over 30 frames).
- Plant timing: planting (4ED4 -> CommitScriptRecord) runs no script frame;
  the first step is the next frame, port and asm alike.
- $01 layer idle 56DC, walk heads 5798/5818/58A7/5936, RunHeadWordScript
  5DB5: `mn_layer_heads_test` (made-up scripts), plus `mn_layer_walk_test`
  and `mn_planner_layers_test` for the walker built on them.
- Ride, push, kick, hop, pixel walk: `mn_ride_mode_test`, `mn_push_test`,
  `mn_kick_test`, `mn_hop_test`, `mn_standin_hop_test`, `mn_pixelwalk_test`,
  `mn_motion_test`.

## Opcodes

| Op | Name | Decomp handler | Port LEN | Length check | Port handler | Notes |
|----|------|----------------|----------|--------------|--------------|-------|
| $00 | WaitFrame | opcode_00.asm | 0 | ok | ScriptVM:261 |  |
| $01 | SetC9A1Pair | opcode_01.asm | 2 | ok | ScriptVM:254 |  |
| $02 | SetScriptPairLoHi | opcode_02.asm | 4 | ok | ScriptVM:256 |  |
| $03 | IndexedAddAndStore | opcode_03.asm | 7 | ok | ops/Records:66 |  |
| $04 | SlotWordToWramBanks6And4 | opcode_04.asm | 5 | ok | ops/Records:90 |  |
| $05 | FillScriptRecord0808 | fill_script_record_0808.asm | 14 | ok | ScriptVM:245 |  |
| $06 | LookupTwoIndices | opcode_06.asm | 2 | ok | ops/Records:120 |  |
| $07 | LookupIndexThenTwoBytes | opcode_07.asm | 3 | ok | ScriptVM:591 |  |
| $08 | CopySixScriptBytesFromOffset3 | copy_six_script_bytes.asm | 7 | ok | ops/Records:134 |  |
| $09 | RunScriptInSlot | opcode_09.asm | 4 | ok | ScriptVM:555 |  |
| $0A | SetSlotByte9 | opcode_0a.asm | 2 | ok | ops/Records:147 |  |
| $0B | TestSlotBit6 | opcode_0b.asm | 1 | ok | ScriptVM:351 |  |
| $0C | SlotIndexThenYield | opcode_0c.asm | 1 | ok | ScriptVM:451 |  |
| $0D | RecordAddAndStore | opcode_0d.asm | 6 | ok | ops/Records:74 |  |
| $0E | AddWordStoreTwoBytes | opcode_0e.asm | 4 | unused in decomp scripts | ops/Records:97 |  |
| $0F | CopySlotRecordFields | opcode_0f.asm | 1 | ok | ops/Records:171 |  |
| $10 | QueueHeadWord | opcode_10.asm | 2 | ok | ops/Records:200 |  |
| $11 | PickMapCellFromDiv | pick_map_cell_from_div.asm | 1 | ok | ScriptVM:508 |  |
| $12 | InstallParkedScript | install_parked_script.asm | 0 | ok | ScriptVM:361, ScriptVM:362 | does not set wScriptDone: a main-record park in the startup loop spins (VM:startupPark, guard + outlier log); tests/engine/mn_startup_park_test.lua |
| $13 | SetRecordHeadWord | opcode_13.asm | 2 | ok | ScriptVM:270 |  |
| $14 | SetSlotSecondScript | opcode_14.asm | 3 | ok | ScriptVM:382 |  |
| $15 | SlotScriptSequence | opcode_15.asm | rec4 | rec4: records+terminator, ok | ScriptVM:385 |  |
| $16 | SlotScriptSequenceScroll | opcode_16.asm | rec6 | rec6: records+terminator, ok | ScriptVM:397 | pan rides the camera (PyBoy: 13:58C2, 1F:50CD) |
| $17 | CopySixScriptBytesFromOffset3_17 | copy_six_script_bytes.asm | 6 | ok | ops/Records:179 |  |
| $18 | SetSpriteTileBase | opcode_18.asm | 1 | ok | ops/Records:187 |  |
| $19 | SetHeadBit7AndYield | opcode_19.asm | 0 | ok | ScriptVM:548 |  |
| $1A | WaitForMatchByte | opcode_1a.asm | 1 | ok | ScriptVM:494 |  |
| $1B | SetSoundSlotA | opcode_1b.asm | 1 | ok | ScriptVM:452 |  |
| $1C | SetSoundSlotB | opcode_1c.asm | 1 | ok | ScriptVM:453 |  |
| $1D | SoundRequest2 | opcode_1d.asm | 0 | ok | ScriptVM:613 |  |
| $1E | SoundRequest4 | opcode_1e.asm | 0 | unused in decomp scripts | ops/Flow:404 |  |
| $1F | SetSoundIndex | opcode_1f.asm | 1 | ok | ScriptVM:596 |  |
| $20 | ArmCountdown | opcode_20_arm_countdown.asm | 1 | ok | ops/Flow:461 | no frame: with $C924 clear, $C924 = 2 and $C925 = sound index (SoundCountdown installs it, SoundCountdownIdle restores the driver when it stops); with $C924 set, falls into Opcode21 ($C91F = 1). The driver's song sequencer ($3D4A/$57FC countdowns, $599D lower expiry) runs the installed sound, so $C924 clears when the song really ends, not on a fixed count (mn_sound_ops_test, mn_music_seq_test) |
| $21 | SoundRequest1 | opcode_21.asm | 0 | ok | ScriptVM:454 |  |
| $22 | SetC92CSoundSelect4 | opcode_22.asm | 1 | unused in decomp scripts | ops/Flow:405 |  |
| $23 | SetC929SoundSelect2 | opcode_23.asm | 1 | ok | ops/Flow:406 |  |
| $24 | SetSoundStateC928 | opcode_20.asm | 1 | ok | ops/Flow:460 | no frame: $C929 = hi nibble + 1, $C928 = 0, wSoundSelect = 1; the selector writes wSoundIndex $FF and SoundSelectBit0 fades $C92C down every $C929 frames, then drops the music gate; field music stops there (mn_sound_ops_test) |
| $25 | LoadMapRecord | opcode_25.asm | 6 | ok | ScriptVM:283 | 04:6416 traced: InitWram7BeforeReset, LoopWhileD0D5, DispatchNonzeroD016, ContinueStartup ($2158); Reset is never reached. Every battle returns through the last $31 record ($D3CD win, $D3D0 loss) and restores [$C923] (mn_battle_director_test) |
| $26 | CopyScriptToD392_26 | copy_script_to_d392.asm | 4 | ok | ScriptVM:293 | 2:73AC; operands to $D392 (WRAM 7, $C937 = 7); the bank-2 tail returns, so the pass ends (mn_battle_director_test). The port collects the op for its battle engine (director: one pass per $D3C2 raise) |
| $27 | HaltClearD3C2 | opcode_27.asm | 0 | ok | ScriptVM:339 |  |
| $28 | CopyScriptToD392 | copy_script_to_d392.asm | 4 | ok | ScriptVM:293 | 2:73DD; operands to $D392 (WRAM 7, $C937 = 7); the bank-2 tail returns, so the pass ends (mn_battle_director_test) |
| $29 | JumpScriptBank7449 | opcode_29.asm | - | unused in decomp scripts | - | no port handler; logged (outlier: docs/mn-outliers.md) |
| $2A | CopyScriptToD392_2A | copy_script_to_d392.asm | 1 | unused in decomp scripts | ops/Flow:408 | 2:744A; operands to $D392 (WRAM 7, $C937 = 7); the bank-2 tail returns, so the pass ends (mn_battle_director_test) |
| $2B | ScriptHandlerUntilD3C2 | script_handler_until_d3c2.asm | 0 | ok | ScriptVM:306 |  |
| $2C | CopyScriptToD392_2C | copy_script_to_d392.asm | 2 | ok | ScriptVM:293, ScriptVM:301 | 2:7477; operands to $D392 (WRAM 7, $C937 = 7); the bank-2 tail returns, so the pass ends (mn_battle_director_test) (mn_forge_ring_test) |
| $2D | CopyD392ClearD396 | opcode_2d.asm | 4 | unused in decomp scripts | ScriptVM:293 | clears $D396, then 2:752D; operands to $D392 (WRAM 7, $C937 = 7); the bank-2 tail returns, so the pass ends (mn_battle_director_test) |
| $2E | CopyScriptToD392_2E | copy_script_to_d392.asm | 5 | ok | ScriptVM:293 | 2:752D; operands to $D392 (WRAM 7, $C937 = 7); the bank-2 tail returns, so the pass ends (mn_battle_director_test) |
| $2F | CopyScriptToD392_2F | copy_script_to_d392.asm | 4 | ok | ops/Flow:407 | 2:7595; operands to $D392 (WRAM 7, $C937 = 7); the bank-2 tail returns, so the pass ends (mn_battle_director_test) |
| $30 | SetC840SoundThenBank7 | opcode_30.asm | 3 | ok | ScriptVM:278 | 07:56ED spiral wipe, 110 frames (mn_spiral_test); saves $C920 to $C923; the wipe ends in `jp FinishStartup`, applied after the spiral (mn_battle_director_test) |
| $31 | SetTailScripts | opcode_31.asm | 6 | ok | ScriptVM:593 |  |
| $32 | SetThirdScript | opcode_32.asm | 5 | ok | ops/Flow:398 |  |
| $33 | PlantRecord30 | plant_record_30.asm | 0 | ok | ops/Panels:497 |  |
| $34 | StageC9E4ThenCall704B | stage_c9e4_then_call_704b.asm | 1 | ok | ops/Panels:507 | ends the pass (mn_next_pass_test) |
| $35 | StageC9D8ThenCall7055 | stage_c9d8_then_call_7055.asm | 1 | unused in decomp scripts | ops/Panels:536 | ends the pass (mn_next_pass_test) |
| $36 | PlantC9FA08AndPtr6DE9 | plant_c9fa08_ptr_6de9.asm | 0 | unused in decomp scripts | ops/Panels:560 |  |
| $37 | PlantC9FA10AndPtr6DF9 | plant_c9fa10_ptr_6df9.asm | 0 | unused in decomp scripts | ops/Panels:561 |  |
| $38 | InstallScriptRecordLoopBank4 | install_script_record_loop_bank4.asm | 3 | ok | ops/Panels:976 | TurnOffLCD (wLCDC 0) and wScriptDone 0 at the op; the next `$94` runs TurnOnLCDIfOff (wLCDC $E3) |
| $39 | StageHandler1126 | stage_handler_1126.asm | 3 | ok | ops/Panels:1024 |  |
| $3A | PlantLimit30At6C0C | plant_limit_30_at_6c0c.asm | 0 | ok | ops/Panels:498 |  |
| $3B | PlantLimit24At6C3C | plant_limit_24_at_6c3c.asm | 0 | ok | ops/Panels:499 |  |
| $3C | ScriptCountdownCall715B | script_countdown_call_715b.asm | 3 | unused in decomp scripts | ops/Panels:565 |  |
| $3D | PlantLimit54At6C60 | plant_limit_54_at_6c60.asm | 0 | ok | ops/Panels:500 |  |
| $3E | PlantLimitA8At6CB4 | plant_limit_a8_at_6cb4.asm | 0 | unused in decomp scripts | ops/Panels:501 |  |
| $3F | PlantLimit1DAt6D5C | plant_limit_1d_at_6d5c.asm | 0 | ok | ops/Panels:502 |  |
| $40 | ScriptByteCountdown | script_byte_countdown.asm | 1 | ok | ScriptVM:674 |  |
| $41 | Bank1NibblePhaseCountdown | bank1_nibble_phase_countdown.asm | 2 | ok | ScriptVM:754 | hMainLoopCounter holds during the startup loop and every other loop outside GameLoop (Grass.outsideMainLoop); phase 3 there dispatches with no frame; tests/engine/mn_startup_counter_test.lua |
| $42 | InstallParkedScript_42 | install_parked_script.asm | 0 | ok | ScriptVM:361 | does not set wScriptDone: a main-record park in the startup loop spins (VM:startupPark, guard + outlier log); a thread's park leaves startup pending; tests/engine/mn_startup_park_test.lua |
| $43 | LookupWordAt1234 | sram_lookup_install_script.asm | expr3 | expr3: via MnRom:insn | ScriptVM:705 |  |
| $44 | SkipTwoUnlessLcdOff | skip_two_unless_lcd_off.asm | 2 | ok | ScriptVM:684 | LCD off = modelled wLCDC $C936 == 0 (vm:lcdOff), incl. the startup loop; tests/engine/mn_wlcdc_test.lua |
| $45 | EnterScriptFromLookup | enter_script_from_lookup.asm | 3 | ok | ScriptVM:696 |  |
| $46 | FollowScriptWord | follow_script_word.asm | 2 | ok | ScriptVM:360 |  |
| $47 | PickScriptRecordByDividerMod | pick_script_record_by_divider_mod.asm | pick | pick: via MnRom:insn | ScriptVM:777 |  |
| $48 | PlantInitialScriptHandler | plant_initial_script_handler.asm | 0 | ok | ScriptVM:489 | ends the pass |
| $49 | SelectScriptByLookupRange | select_script_by_lookup_range.asm | range7 | range7: via MnRom:insn | ScriptVM:712 |  |
| $4A | InstallScriptFromBC | install_script_from_bc.asm | 3 | ok | ops/Flow:402 | ends the pass |
| $4B | SelectScriptByExactWord | select_script_by_exact_word.asm | exact5 | exact5: via MnRom:insn | ScriptVM:712, ScriptVM:715 |  |
| $4C | QueueRepeatedSpriteList | queue_repeated_sprite_list.asm | rec5 | rec5: records+terminator, ok | ScriptVM:217, ScriptVM:455 | 20:5C7A locked by mn_layer_heads_test (MN_ROM) |
| $4D | StepScriptSpritePointerTable | step_script_sprite_pointer_table.asm | tab | tab: via MnRom:insn | ScriptVM:217, ScriptVM:470 |  |
| $4E | RepeatTwoScriptBytes | repeat_two_script_bytes.asm | repeat2 | repeat2: via MnRom:insn | ScriptVM:217, ScriptVM:477 |  |
| $4F | QueueRepeatedOffsetSpriteList | queue_repeated_offset_sprite_list.asm | rec5 | rec5: records+terminator, ok | ScriptVM:217, ScriptVM:461 |  |
| $50 | FillPointedRecord0C5F | fill_pointed_record_0c5f.asm | 8 | ok | ops/Panels:477 |  |
| $51 | NoOp | jump_dispatch_script_opcode.asm | 0 | unused in decomp scripts | ScriptVM:488 |  |
| $52 | PlantAddend01FFFromScript | plant_addend_01ff_from_script.asm | 1 | unused in decomp scripts | ops/Records:209 |  |
| $53 | ArmC6F8UnlessSet | arm_c6f8_unless_set.asm | 0 | ok | ScriptVM:416 |  |
| $54 | ArmC6FAUnlessSet | arm_c6fa_unless_set.asm | 0 | ok | ScriptVM:416 |  |
| $55 | ArmC6FCUnlessSet | arm_c6fc_unless_set.asm | 0 | ok | ScriptVM:416 |  |
| $56 | StoreByteAtC6F8 | store_script_byte_at_c6f8.asm | 1 | ok | ScriptVM:366 | mailbox post; box full -> retry next frame (same as asm) |
| $57 | StoreByteAtC6FA | store_script_byte_at_c6fa.asm | 1 | ok | ScriptVM:366 | mailbox post; box full -> retry next frame |
| $58 | StoreByteAtC6FC | store_script_byte_at_c6fc.asm | 1 | ok | ScriptVM:366 | mailbox post; box full -> retry next frame |
| $59 | FillWScriptRecordFromScript | fill_wscript_record_from_script.asm | 3 | ok | ops/Flow:399 |  |
| $5A | FillScriptRecordC70DFromScript | fill_script_record_c70d_from_script.asm | 3 | ok | ScriptVM:444 |  |
| $5B | FillScriptRecordC71BUnlessC6EEIs1 | fill_script_record_c71b_unless_c6ee.asm | 3 | ok | ScriptVM:572 |  |
| $5C | StageNextScriptIfByteAtMostC6F7 | stage_next_script_if_byte_at_most_c6f7.asm | 2 | ok | ScriptVM:427 | rendezvous via C6F5/C6F6/C6F7, same carry rule as AddAndShiftUnknown |
| $5D | LoadC6F9ThenPlantHandlerUnlessZero | load_c6f9_then_plant_handler_unless_zero.asm | 0 | ok | ScriptVM:421 | next opcode next frame (mn_next_pass_test) |
| $5E | LoadC6FBThenPlantHandlerUnlessZero | load_c6fb_then_plant_handler_unless_zero.asm | 0 | ok | ScriptVM:421 | next opcode next frame |
| $5F | LoadC6FDThenPlantHandlerUnlessZero | load_c6fd_then_plant_handler_unless_zero.asm | 0 | ok | ScriptVM:421 | next opcode next frame |
| $60 | LoadC6F9ThenMatchScriptByte | load_c6f9_then_match_script_byte.asm | 1 | ok | ScriptVM:373 | reads C6F9; next opcode next frame (mn_next_pass_test); latch: see Mailboxes |
| $61 | MatchScriptByteThenPlantHandler | match_script_byte_then_plant_handler.asm | 1 | ok | ScriptVM:373 | reads C6FB; next opcode next frame |
| $62 | MatchScriptByteThenPlantHandler_62 | match_script_byte_then_plant_handler.asm | 1 | ok | ScriptVM:373 | reads C6FD; next opcode next frame |
| $63 | CallBankedWordThenResume | call_banked_word_then_resume.asm | 3 | ok | ops/Travel:183 |  |
| $64 | ReadBank21ByteThenResume | read_bank21_byte_then_resume.asm | 2 | ok | ScriptVM:242 |  |
| $65 | CallScriptBankedPtrThenResume | call_script_banked_ptr_then_resume.asm | 3 | ok | ScriptVM:238 |  |
| $66 | CallScriptBankedPtrThenCall2EE9 | call_script_banked_ptr_then_call_2ee9.asm | 3 | ok | ScriptVM:244 |  |
| $67 | CallScriptUnpackHeaderAndBlock | call_script_unpack_header_and_block.asm | 6 | unused in decomp scripts | ops/Records:362 |  |
| $68 | CallScriptUnpackIntoWRAM4And6 | call_script_unpack_wram4_and_wram6.asm | 6 | ok | ops/Records:344 |  |
| $69 | CallScriptPtrThenMapScriptBank | call_script_ptr_then_map_script_bank.asm | 2 | ok | ScriptVM:243 |  |
| $6A | CallScriptMapRecordsThenFillC72B | call_script_map_records_then_fill_c72b.asm | 6 | ok | ops/Travel:193 | records past bank $3C (14:6029 -> 7C) read from the full ROM (mn_ops_travel_test) |
| $6B | ArmCopyGlyphFromScript | arm_copy_glyph_from_script.asm | 7 | ok | ScriptVM:365 | one 16-byte tile per pass (CopyGlyph $2949), the next op one pass after the last; count 0 is 256; all at once with the LCD off: map setup and the startup loop (mn_op6b_glyph_passes_test, mn_startup_passes_test) |
| $6C | StageColorWordThenCall5C00 | stage_color_word_then_call_5c00.asm | 3 | ok | ops/Panels:583 |  |
| $6D | SaveScriptPtrAndSplitByte | save_script_ptr_and_split_byte.asm | 1 | ok | ops/Panels:596 |  |
| $6E | StageScriptByteWordAndSavePtr | stage_script_byte_word_and_save_ptr.asm | 3 | ok | ops/Panels:668 |  |
| $6F | StageScriptByteWordAndSavePtr_6F | stage_script_byte_word_and_save_ptr.asm | 3 | ok | ops/Panels:681 |  |
| $70 | StorePanelSlotThenCall416B | store_panel_slot_then_call_416b.asm | 2 | ok | ops/Panels:825 |  |
| $71 | ArmCountdown1AE8AndDecFFA6 | arm_countdown_1ae8_and_dec_ffa6.asm | 4 | ok | ops/Panels:836 |  |
| $72 | ArmCountdownHandlerAndDecFFA6 | arm_countdown_handler_and_dec_ffa6.asm | 2 | unused in decomp scripts | ops/Panels:863 |  |
| $73 | StagePairPtrPanelThenCall35F1 | stage_pair_ptr_panel_then_call_35f1.asm | 4 | ok | ops/Panels:1060 | ends the pass |
| $74 | SetCountdownHandler1B7D | set_countdown_handler_1b7d.asm | 3 | ok | ops/Panels:849 |  |
| $75 | StorePanelSlotCall4333 | store_panel_slot_call_4333.asm | 1 | ok | ops/Panels:1076 | ends the pass |
| $76 | SetCCA6Countdown1C17 | set_cca6_countdown_1c17.asm | 2 | ok | ops/Panels:695 |  |
| $77 | SetCCA6Countdown1C4A | set_cca6_countdown_1c4a.asm | 4 | unused in decomp scripts | ops/Panels:710 |  |
| $78 | StagePairSourceThenCopyWords | stage_pair_source_then_copy_words.asm | 4 | ok | ops/Records:222 | ends the pass |
| $79 | StoreScriptByteCall481E | store_script_byte_call_481e.asm | 1 | ok | ops/Panels:741 | ends the pass |
| $7A | SetCCA6Countdown1BE4 | set_cca6_countdown_1be4.asm | 3 | unused in decomp scripts | ops/Panels:728 |  |
| $7B | StoreScriptByteCall48DC | store_script_byte_call_48dc.asm | 1 | unused in decomp scripts | ops/Panels:1088 | ends the pass |
| $7C | StageBiasedCellsForScrollNudge | stage_biased_cells_for_scroll_nudge.asm | 3 | ok | ScriptVM:533, ScriptVM:536 |  |
| $7D | StageFlooredCellsForScrollNudge | stage_floored_cells_for_scroll_nudge.asm | 3 | ok | ScriptVM:533 |  |
| $7E | StageEightScriptBytesCopy | stage_eight_script_bytes.asm | 8 | ok | ops/Records:322 |  |
| $7F | StageEightScriptBytesCopy_7F | stage_eight_script_bytes.asm | 8 | ok | ops/Records:331 |  |
| $80 | WriteScriptBytesAcrossWramBanks | write_script_bytes_across_wram_banks.asm | 6 | ok | ScriptVM:490 |  |
| $81 | WriteScriptBytesThroughBanks6And4 | write_script_bytes_through_banks_6_and_4.asm | 6 | unused in decomp scripts | ops/Records:106 |  |
| $82 | CenterFineScrollOnScriptBase | center_fine_scroll_on_script_base.asm | 0 | ok | ScriptVM:349 |  |
| $83 | AddScriptDeltasUntilZero | add_script_deltas_until_zero.asm | rec3 | rec3: records+terminator, ok | ScriptVM:676 |  |
| $84 | CenterFineScrollOnScriptWord | center_fine_scroll_on_script_word.asm | 2 | ok | ScriptVM:611 |  |
| $85 | StageScriptByteEnterBank1 | stage_script_byte_enter_bank1.asm | 1 | ok | ops/Flow:401 |  |
| $86 | SeedCameraAndEnterLoop | seed_camera_loop.asm | 0 | ok | ops/Travel:154 |  |
| $87 | CopyThreeBytesCallBank7 | copy_three_c9fc_bank7.asm | 3 | ok | ScriptVM:655 |  |
| $88 | CopyThreeBytesCall7465 | copy_three_call_7465.asm | 3 | ok | ops/Travel:217 |  |
| $89 | LoadSRAMScriptAndDispatch | load_sram_script_dispatch.asm | 0 | ok | ScriptVM:503 |  |
| $8A | CallBank7ThenLoadSRAMScript | call_bank7_then_load_sram_script.asm | 0 | ok | ScriptVM:503 |  |
| $8B | CallBank3ThenDispatchScript | call_bank3_then_dispatch.asm | 0 | ok | ops/Travel:238 |  |
| $8C | RewindCopyThenCall5400 | rewind_copy_then_call_5400.asm | blk0 | blk0: via MnRom:insn | ops/Travel:254 |  |
| $8D | CallBank3_5AAEThenDispatch | call_bank3_5aae_then_dispatch.asm | 0 | ok | ops/Travel:275 |  |
| $8E | EnterScriptFromLookup_8E | enter_script_from_lookup.asm | blk8e | blk8e: via MnRom:insn | ScriptVM:784 |  |
| $8F | RewindCopyThenCall7025 | rewind_copy_then_call_7025.asm | blk0 | blk0: via MnRom:insn | ops/Travel:297 |  |
| $90 | CopyPrefixedBlockThenCall66BE | copy_prefixed_then_call_66be.asm | blk3 | blk3: via MnRom:insn | ops/Travel:315 |  |
| $91 | BranchBank1OnScriptByte | branch_bank1_on_script_byte.asm | 1 | ok | ScriptVM:610 | ends the pass (mn_next_pass_test); zero path fills both banks and runs Copy7646IntoNextSRAMBank (2:4799), also on a new game with no save images (mn_op91_sram_fill_test) |
| $92 | StageSavedScriptPairThenBank7 | stage_saved_script_pair.asm | 1 | ok | ops/Save:125 |  |
| $93 | FinishStartup | finish_startup.asm | 0 | ok | ScriptVM:220 |  |
| $94 | MarkScriptDone21B2 | mark_script_done_21b2.asm | 0 | ok | ScriptVM:352 | sets wScriptDone $C705, the only end of FinishStartup's loop (VM:endStartup); tests/engine/mn_startup_park_test.lua |
| $95 | CopyFallbackScriptRecord | copy_fallback_script_record.asm | 3 | ok | ops/Flow:400 |  |
| $96 | SaveScriptTripleToSRAM | save_script_triple.asm | 3 | ok | ScriptVM:498 |  |
| $97 | ReenterReset | reenter_reset.asm | 0 | ok | ops/Flow:403 |  |
| $98 | FormatPointedSRAMByteThenResume | format_pointed_sram_byte.asm | 2 | ok | ops/Save:155 |  |
| $99 | FinishWindowYSlide | finish_window_y_slide.asm | 0 | ok | ops/Flow:355 |  |
| $9A | WaitC6EEZero | opcode_9a.asm | 0 | ok | ops/Flow:366 |  |
| $9B | Opcode9BContinue | opcode_9b.asm | 2 | ok | ops/Flow:331 |  |
| $9C | CommitArmedSlotChoice | commit_armed_slot_choice.asm | pick | pick: via MnRom:insn | ScriptVM:748 |  |
| $9D | WaitC6EETwo | opcode_9d.asm | 0 | unused in decomp scripts | ops/Flow:321 |  |
| $9E | FormatSRAMWord | opcode_9e.asm | 2 | ok | ops/Save:164 |  |
| $9F | StageStripTextFromScript | stage_strip_text_from_script.asm | strip | strip: via MnRom:insn | ScriptVM:728 |  |
| $A0 | BranchWhenLCDOff | branch_when_lcd_off.asm | 10 | ok | ops/Flow:449 | LCD off = modelled wLCDC $C936 == 0 (vm:lcdOff), incl. the startup loop; tests/engine/mn_wlcdc_test.lua |
| $A1 | PlantParkedHandlerWhenLCDOff | plant_parked_handler_when_lcd_off.asm | 10 | ok | ops/Flow:450 | LCD off = modelled wLCDC $C936 == 0 (vm:lcdOff), incl. the startup loop; tests/engine/mn_wlcdc_test.lua; the LCD-off park leaves wScriptDone alone (VM:startupPark, tests/engine/mn_startup_park_test.lua) |
| $A2 | BranchParkedScriptWhenLCDOff | branch_parked_script_when_lcd_off.asm | 9 | ok | ops/Flow:451 | LCD off = modelled wLCDC $C936 == 0 (vm:lcdOff), incl. the startup loop; tests/engine/mn_wlcdc_test.lua; the LCD-off park leaves wScriptDone alone (VM:startupPark, tests/engine/mn_startup_park_test.lua) |
| $A3 | PlantScriptPtrReadSramByte | plant_script_ptr_read_sram.asm | 9 | ok | ScriptVM:708 | LCD off = modelled wLCDC $C936 == 0 (vm:lcdOff), incl. the startup loop; tests/engine/mn_wlcdc_test.lua |
| $A4 | PlantOffset7ThenStoreFF | plant_offset7_then_store_ff.asm | 7 | ok | ScriptVM:686 | LCD off = modelled wLCDC $C936 == 0 (vm:lcdOff), incl. the startup loop; tests/engine/mn_wlcdc_test.lua |
| $A5 | OrSramMaskWhenLookup | or_sram_mask_when_lookup.asm | expr_wb | expr_wb: via MnRom:insn | ScriptVM:725 |  |
| $A6 | StoreLookupLowIntoSram | store_lookup_low_into_sram.asm | expr_w | expr_w: via MnRom:insn | ScriptVM:722 |  |
| $A7 | StoreLookupWordIntoSram | store_lookup_word_into_sram.asm | expr_w | expr_w: via MnRom:insn | ScriptVM:722, ScriptVM:724 |  |
| $A8 | CallScriptBank40B7 | call_script_bank_40b7.asm | 0 | unused in decomp scripts | ops/Panels:1104 |  |
| $A9 | StoreScriptWordAtA123 | store_script_word_at_a123.asm | 2 | ok | ScriptVM:600 | ends the pass (mn_next_pass_test) |
| $AA | StoreScriptByteInWramBank | store_script_byte_in_wram_bank.asm | 4 | ok | ScriptVM:697 |  |
| $AB | StoreScriptWordInWramBank | store_script_word_in_wram_bank.asm | 5 | unused in decomp scripts | ScriptVM:697 |  |
| $AC | StoreScriptByteInSram | store_script_byte_in_sram.asm | 3 | ok | ScriptVM:704 |  |
| $AD | StoreScriptWordInSram | store_script_word_in_sram.asm | 4 | ok | ops/Save:114 |  |
| $AE | AndScriptMaskIntoSram | and_script_mask_into_sram.asm | 3 | ok | ScriptVM:589 |  |
| $AF | OrScriptMaskIntoSram | or_script_mask_into_sram.asm | 3 | ok | ScriptVM:587 |  |
