; Magi-Nation (USA) link scaffold.
;
; Every byte currently comes from the local ROM via INCBIN. Those bytes
; are not in this repository. Replace a range by shrinking its INCBIN and
; assembling the same bytes from source in src/. The built ROM must stay
; identical to roms/magination.gbc.
;
; Leave the Nintendo boot logo ($0104-$0133) inside the local ROM.

SECTION "RST 00", ROM0[$0000]
INCLUDE "src/rst_00.asm"

RST00End:

SECTION "Unused RST slots", ROM0[$0003]
INCLUDE "src/unused_rst.asm"

UnusedRSTEnd:

SECTION "VBlank", ROM0[$0040]
INCLUDE "src/vblank.asm"

VBlankEnd:

SECTION "VBlank vector pad", ROM0[$0043]
INCLUDE "src/vblank_vector_pad.asm"

SECTION "LCDC status", ROM0[$0048]
INCLUDE "src/lcdc_status.asm"

LCDCStatusEnd:

SECTION "LCDC status pad", ROM0[$004B]
INCLUDE "src/lcdc_status_pad.asm"

LCDCStatusPadEnd:

SECTION "Timer", ROM0[$0050]
INCLUDE "src/timer.asm"

TimerEnd:

SECTION "Timer pad", ROM0[$0053]
INCLUDE "src/timer_pad.asm"

TimerPadEnd:

SECTION "Serial", ROM0[$0058]
INCLUDE "src/serial.asm"

SerialEnd:

SECTION "Serial pad", ROM0[$0059]
INCLUDE "src/serial_pad.asm"

SerialPadEnd:

SECTION "Joypad", ROM0[$0060]
INCLUDE "src/joypad.asm"

JoypadEnd:

SECTION "Joypad vector pad", ROM0[$0061]
INCLUDE "src/joypad_pad.asm"

JoypadPadEnd:

SECTION "ROM0 from $0100", ROM0[$0100]
    INCBIN "roms/magination.gbc", $0100, $0050

SECTION "Reset", ROM0[$0150]
INCLUDE "src/reset.asm"

SliceEnd:

SECTION "CGB notice text", ROM0[$01D3]
; cgb_notice_text.asm: not published here (it assembles data copied from the ROM)
NoticeText:
    INCBIN "roms/magination.gbc", $1D3, $40

NoticeTextEnd:

SECTION "CGB notice remainder", ROM0[$0213]
; cgb_notice_rest.asm: not published here (it assembles data copied from the ROM)
NoticeTextRest:
    INCBIN "roms/magination.gbc", $213, $29

NoticeTextRestEnd:

SECTION "Non-CGB lockup", ROM0[$023C]
INCLUDE "src/non_cgb.asm"

NonCGBEnd:

SECTION "Draw CGB notice", ROM0[$0242]
; draw_cgb_notice.asm: not published here (it assembles data copied from the ROM)
ShowCGBNotice:
    INCBIN "roms/magination.gbc", $242, $9E

ShowCGBNoticeEnd:

SECTION "Write ascending bytes", ROM0[$02E0]
INCLUDE "src/write_ascending.asm"

WriteAscendingEnd:

SECTION "Main loop", ROM0[$02E6]
INCLUDE "src/main_loop.asm"

MainLoopEnd:

SECTION "Record slot bases", ROM0[$0303]
; record_slot_bases.asm: not published here (it assembles data copied from the ROM)
RecordSlotBases:
    INCBIN "roms/magination.gbc", $303, $40

RecordSlotBasesEnd:

SECTION "Record slot bases tail", ROM0[$0343]
; record_slot_bases_tail.asm: not published here (it assembles data copied from the ROM)
RecordSlotBasesTail:
    INCBIN "roms/magination.gbc", $343, $24

RecordSlotBasesTailEnd:

SECTION "Scale count", ROM0[$0367]
INCLUDE "src/scale_count.asm"

ScaleCountEnd:

SECTION "Bucket from C", ROM0[$03AB]
INCLUDE "src/bucket_from_c.asm"

BucketFromCEnd:

SECTION "Format start digits", ROM0[$041A]
INCLUDE "src/format_start_digits.asm"

SECTION "Divide C by B", ROM0[$04AC]
INCLUDE "src/divide_c_by_b.asm"

DivideCByBEnd:

SECTION "Divide HL by A", ROM0[$04B9]
INCLUDE "src/divide_hl_by_a.asm"

DivideHLByAEnd:

SECTION "Multiply C by B", ROM0[$04CA]
INCLUDE "src/multiply.asm"

MulCByBEnd:

SECTION "Scale L by B", ROM0[$0514]
INCLUDE "src/mul_l_by_b_shift5.asm"

SECTION "Mask DIV by C", ROM0[$053A]
INCLUDE "src/mask_div_by_c.asm"

SECTION "Add divider step", ROM0[$054F]
INCLUDE "src/add_divider_step.asm"

AddDividerStepEnd:

SECTION "Park sprites", ROM0[$0565]
INCLUDE "src/park_sprites.asm"

ParkSpritesEnd:

SECTION "Queue sprite list", ROM0[$0583]
INCLUDE "src/queue_sprite_list.asm"

QueueSpriteListEnd:

SECTION "Append sprite", ROM0[$05FD]
INCLUDE "src/append_sprite.asm"

AppendSpriteEnd:

SECTION "Queue sprite list at cell", ROM0[$0610]
INCLUDE "src/queue_sprite_list_at_cell.asm"

QueueSpriteListAtCellEnd:

SECTION "Hide leftover sprites", ROM0[$0625]
INCLUDE "src/hide_leftover_sprites.asm"

HideLeftoverSpritesEnd:

SECTION "Apply C92C", ROM0[$0652]
INCLUDE "src/apply_c92c.asm"

ApplyC92CEnd:

SECTION "Store $0F at C92C", ROM0[$0659]
INCLUDE "src/store_0f_at_c92c.asm"

Store0FAtC92CEnd:

SECTION "Return at $066F", ROM0[$066F]
INCLUDE "src/ret_066f.asm"

Ret066FEnd:

SECTION "Sound active", ROM0[$0670]
INCLUDE "src/sound_active.asm"

SoundActiveEnd:

SECTION "Sound select bit 0", ROM0[$0684]
INCLUDE "src/sound_select_bit0.asm"

SoundSelectBit0End:

SECTION "Sound select bit 1", ROM0[$06C1]
INCLUDE "src/sound_select_bit1.asm"

SoundSelectBit1End:

SECTION "Sound select other", ROM0[$06F4]
INCLUDE "src/sound_select_other.asm"

SoundSelectOtherEnd:

SECTION "Sound request bit 1", ROM0[$06FC]
INCLUDE "src/sound_request_bit1.asm"

SoundRequestBit1End:

SECTION "Sound request bit 1 dead", ROM0[$0705]
INCLUDE "src/sound_request_bit1_dead.asm"

SoundRequestBit1DeadEnd:

SECTION "Sound request bit 2", ROM0[$0709]
INCLUDE "src/sound_request_bit2.asm"

SoundRequestBit2End:

SECTION "Sound slot A", ROM0[$070D]
INCLUDE "src/sound_slot_a.asm"

SoundSlotAEnd:

SECTION "Sound slot B", ROM0[$071D]
INCLUDE "src/sound_slot_b.asm"

SoundSlotBEnd:

SECTION "Sound countdown", ROM0[$072D]
INCLUDE "src/sound_countdown.asm"

SoundCountdownEnd:

SECTION "Sound countdown idle", ROM0[$074F]
INCLUDE "src/sound_countdown_idle.asm"

SoundCountdownIdleEnd:

SECTION "Call HL in bank", ROM0[$0773]
INCLUDE "src/call_hl_in_bank.asm"

CallBankedHLEnd:

SECTION "Jump HL", ROM0[$0789]
INCLUDE "src/jump_hl.asm"

JumpHLEnd:

SECTION "Clamp added byte", ROM0[$078A]
INCLUDE "src/clamp_added_byte.asm"

ClampAddedByteEnd:

SECTION "Mask bytes", ROM0[$0797]
INCLUDE "src/mask_bytes.asm"

MaskBytesEnd:

SECTION "Copy bytes", ROM0[$07A0]
INCLUDE "src/copy_bytes.asm"

CopyHLToDEEnd:

SECTION "OR bytes at HL", ROM0[$07A9]
INCLUDE "src/or_bytes_at_hl.asm"

SECTION "Fill bytes", ROM0[$07B2]
INCLUDE "src/fill_bytes.asm"

FillBytesEnd:

SECTION "XOR bytes at HL", ROM0[$07BA]
INCLUDE "src/xor_bytes_at_hl.asm"

XorHLWithEEnd:

SECTION "Turn off LCD", ROM0[$07C3]
INCLUDE "src/turn_off_lcd.asm"

TurnOffLCDEnd:

SECTION "Turn on LCD", ROM0[$07EA]
INCLUDE "src/turn_on_lcd.asm"

TurnOnLCDEnd:

SECTION "Call callback", ROM0[$080A]
INCLUDE "src/call_callback.asm"

CallCallbackEnd:

SECTION "Default state", ROM0[$082D]
INCLUDE "src/default_state.asm"

DefaultStateEnd:

SECTION "Finish frame", ROM0[$08BB]
INCLUDE "src/finish_frame.asm"

FinishFrameEnd:

SECTION "Refresh frame", ROM0[$095F]
INCLUDE "src/refresh_frame.asm"

RefreshFrameEnd:

SECTION "Wait VBlank flag", ROM0[$09A0]
INCLUDE "src/wait_vblank_flag.asm"

WaitVBlankFlagEnd:

SECTION "Unpack bytes", ROM0[$09AF]
INCLUDE "src/unpack_bytes.asm"

UnpackBytesEnd:

SECTION "Read bank 21 byte", ROM0[$0A09]
INCLUDE "src/read_bank21_byte.asm"

ReadBank21ByteEnd:

SECTION "Read bank 21 script head", ROM0[$0A1D]
INCLUDE "src/read_bank21_script_head.asm"

ReadBank21ScriptHeadEnd:

SECTION "Map script bank", ROM0[$0A3A]
INCLUDE "src/map_script_bank.asm"

MapScriptBankAndCallEnd:

SECTION "Dispatch script opcode", ROM0[$0A66]
INCLUDE "src/dispatch_script_opcode.asm"

DispatchScriptOpcodeEnd:

SECTION "Copy three script bytes", ROM0[$0A95]
INCLUDE "src/copy_three_script_bytes.asm"

CopyThreeScriptBytesEnd:

SECTION "Copy three script bytes and handler", ROM0[$0A9F]
INCLUDE "src/copy_three_script_bytes_and_handler.asm"

CopyThreeScriptBytesAndHandlerEnd:

SECTION "Store script pair 02 14", ROM0[$0AB1]
INCLUDE "src/store_script_pair_0214.asm"

StoreScriptPair0214End:

SECTION "Fill script record 08 08", ROM0[$0ABD]
INCLUDE "src/fill_script_record_0808.asm"

FillScriptRecord0808End:

SECTION "Copy two script bytes and handler", ROM0[$0ADC]
INCLUDE "src/copy_two_script_bytes_and_handler.asm"

CopyTwoScriptBytesAndHandlerEnd:

SECTION "Script opcode 00", ROM0[$0AEB]
INCLUDE "src/opcode_00.asm"

Opcode00End:

SECTION "Script opcode 01", ROM0[$0AF6]
INCLUDE "src/opcode_01.asm"

Opcode01End:

SECTION "Script opcode 02", ROM0[$0B03]
INCLUDE "src/opcode_02.asm"

Opcode02End:

SECTION "Script opcode 03", ROM0[$0B22]
INCLUDE "src/opcode_03.asm"

Opcode03End:

SECTION "Script opcode 04", ROM0[$0B72]
INCLUDE "src/opcode_04.asm"

Opcode04End:

SECTION "Script opcode 05", ROM0[$0B9A]
INCLUDE "src/opcode_05.asm"

Opcode05End:

SECTION "Script opcode 06", ROM0[$0BA9]
INCLUDE "src/opcode_06.asm"

Opcode06End:

SECTION "Script opcode 07", ROM0[$0BCF]
INCLUDE "src/opcode_07.asm"

Opcode07End:

SECTION "Script opcode 08", ROM0[$0BDC]
INCLUDE "src/opcode_08.asm"

Opcode08End:

SECTION "Script opcode 09", ROM0[$0BE2]
INCLUDE "src/opcode_09.asm"

Opcode09End:

SECTION "Script opcode 0A", ROM0[$0BFA]
INCLUDE "src/opcode_0a.asm"

Opcode0AEnd:

SECTION "Script opcode 0B", ROM0[$0C07]
INCLUDE "src/opcode_0b.asm"

Opcode0BEnd:

SECTION "Script opcode 0C", ROM0[$0C2B]
INCLUDE "src/opcode_0c.asm"

Opcode0CEnd:

SECTION "Script opcode 0D", ROM0[$0C43]
INCLUDE "src/opcode_0d.asm"

Opcode0DEnd:

SECTION "Script opcode 0E", ROM0[$0C49]
INCLUDE "src/opcode_0e.asm"

Opcode0EEnd:

SECTION "Script opcode 0F", ROM0[$0C4F]
INCLUDE "src/opcode_0f.asm"

Opcode0FEnd:

SECTION "Script opcode 10", ROM0[$0C6D]
INCLUDE "src/opcode_10.asm"

Opcode10End:

SECTION "Script opcode 11", ROM0[$0C7E]
INCLUDE "src/opcode_11.asm"

Opcode11End:

SECTION "Map bank 1 and jump", ROM0[$0C8F]
INCLUDE "src/map_bank1_and_jump.asm"

MapBank1AndJumpEnd:

SECTION "Match WRAM bank 5 script byte", ROM0[$0C9A]
INCLUDE "src/match_wram5_script_byte.asm"

MatchWRAM5ScriptByteEnd:

SECTION "Install opcode 11 handler", ROM0[$0CD4]
INCLUDE "src/install_opcode11_handler.asm"

InstallOpcode11HandlerEnd:

SECTION "Script opcode 12", ROM0[$0CDD]
INCLUDE "src/opcode_12.asm"

Opcode12End:

SECTION "Script opcode 13", ROM0[$0CEF]
INCLUDE "src/opcode_13.asm"

Opcode13End:

SECTION "Script opcode 14", ROM0[$0D0C]
INCLUDE "src/opcode_14.asm"

Opcode14End:

SECTION "Script opcode 15", ROM0[$0D21]
INCLUDE "src/opcode_15.asm"

Opcode15End:

SECTION "Script opcode 16", ROM0[$0D63]
INCLUDE "src/opcode_16.asm"

Opcode16End:

SECTION "Script opcode 17", ROM0[$0DC6]
INCLUDE "src/opcode_17.asm"

Opcode17End:

SECTION "Script opcode 18", ROM0[$0DCC]
INCLUDE "src/opcode_18.asm"

Opcode18End:

SECTION "Script opcode 19", ROM0[$0DD3]
INCLUDE "src/opcode_19.asm"

Opcode19End:

SECTION "Script opcode 1A", ROM0[$0DE4]
INCLUDE "src/opcode_1a.asm"

Opcode1AEnd:

SECTION "Lookup script index pointer", ROM0[$0DFB]
INCLUDE "src/lookup_script_index_pointer.asm"

LookupScriptIndexPointerEnd:

SECTION "Copy six script bytes", ROM0[$0E09]
INCLUDE "src/copy_six_script_bytes.asm"

CopySixScriptBytesEnd:

SECTION "Script opcode 1B", ROM0[$0E22]
INCLUDE "src/opcode_1b.asm"

Opcode1BEnd:

SECTION "Script opcode 1C", ROM0[$0E2A]
INCLUDE "src/opcode_1c.asm"

Opcode1CEnd:

SECTION "Script opcode 1D", ROM0[$0E32]
INCLUDE "src/opcode_1d.asm"

Opcode1DEnd:

SECTION "Script opcode 1E", ROM0[$0E3A]
INCLUDE "src/opcode_1e.asm"

Opcode1EEnd:

SECTION "Script opcode 1F", ROM0[$0E42]
INCLUDE "src/opcode_1f.asm"

Opcode1FEnd:

SECTION "Script opcode 20", ROM0[$0E63]
INCLUDE "src/opcode_20.asm"

Opcode20End:

SECTION "Script opcode 23", ROM0[$0E79]
INCLUDE "src/opcode_23.asm"

Opcode23End:

SECTION "Script opcode 22", ROM0[$0E92]
INCLUDE "src/opcode_22.asm"

Opcode22End:

SECTION "Script opcode 20 arm countdown", ROM0[$0EA8]
INCLUDE "src/opcode_20_arm_countdown.asm"

Opcode20ArmCountdownEnd:

SECTION "Script opcode 21", ROM0[$0EBD]
INCLUDE "src/opcode_21.asm"

Opcode21End:

SECTION "Script opcode 25", ROM0[$0EC5]
INCLUDE "src/opcode_25.asm"

Opcode25End:

SECTION "Script opcode 26", ROM0[$0F31]
INCLUDE "src/opcode_26.asm"

Opcode26End:

SECTION "Script opcode 27", ROM0[$0F39]
INCLUDE "src/opcode_27.asm"

Opcode27End:

SECTION "Script opcode 28", ROM0[$0F46]
INCLUDE "src/opcode_28.asm"

Opcode28End:

SECTION "Script opcode 29", ROM0[$0F4E]
INCLUDE "src/opcode_29.asm"

Opcode29End:

SECTION "Script opcode 2A", ROM0[$0F51]
INCLUDE "src/opcode_2a.asm"

Opcode2AEnd:

SECTION "Script opcode 2B", ROM0[$0F59]
INCLUDE "src/opcode_2b.asm"

Opcode2BEnd:

SECTION "Script handler until $D3C2", ROM0[$0F66]
INCLUDE "src/script_handler_until_d3c2.asm"

ScriptHandlerUntilD3C2End:

SECTION "Script opcode 2C", ROM0[$0F6E]
INCLUDE "src/opcode_2c.asm"

Opcode2CEnd:

SECTION "Script opcode 2D", ROM0[$0F76]
INCLUDE "src/opcode_2d.asm"

Opcode2DEnd:

SECTION "Script opcode 2E", ROM0[$0F82]
INCLUDE "src/opcode_2e.asm"

Opcode2EEnd:

SECTION "Script opcode 2F", ROM0[$0F8A]
INCLUDE "src/opcode_2f.asm"

Opcode2FEnd:

SECTION "Script opcode 30", ROM0[$0F92]
INCLUDE "src/opcode_30.asm"

Opcode30End:

SECTION "Script opcode 31", ROM0[$0FDF]
INCLUDE "src/opcode_31.asm"

Opcode31End:

SECTION "Script opcode 32", ROM0[$0FFE]
INCLUDE "src/opcode_32.asm"

Opcode32End:

SECTION "Copy script bytes to $D392", ROM0[$1020]
INCLUDE "src/copy_script_to_d392.asm"

CopyScriptToD392End:

SECTION "Plant $30 record and join $11D9", ROM0[$1049]
INCLUDE "src/plant_record_30.asm"

PlantRecord30End:

SECTION "Stage $C9E4 and call bank 4", ROM0[$105B]
INCLUDE "src/stage_c9e4_then_call_704b.asm"

StageC9E4ThenCall704BEnd:

SECTION "Stage $C9D8 and call bank 4", ROM0[$1088]
INCLUDE "src/stage_c9d8_then_call_7055.asm"

StageC9D8ThenCall7055End:

SECTION "Install script record and loop bank 4", ROM0[$10AF]
INCLUDE "src/install_script_record_loop_bank4.asm"

InstallScriptRecordLoopBank4End:

SECTION "Stage handler $1126", ROM0[$110C]
INCLUDE "src/stage_handler_1126.asm"

StageHandler1126End:

SECTION "Script handler $1126", ROM0[$1126]
INCLUDE "src/script_handler_1126.asm"

ScriptHandler1126End:

SECTION "Mark script done", ROM0[$1141]
INCLUDE "src/mark_script_done.asm"

MarkScriptDoneEnd:

SECTION "Plant limit $30 at $6C0C", ROM0[$1151]
INCLUDE "src/plant_limit_30_at_6c0c.asm"

PlantLimit30At6C0CEnd:

SECTION "Plant limit $24 at $6C3C", ROM0[$1162]
INCLUDE "src/plant_limit_24_at_6c3c.asm"

PlantLimit24At6C3CEnd:

SECTION "Script countdown then call $715B", ROM0[$1173]
INCLUDE "src/script_countdown_call_715b.asm"

ScriptCountdownCall715BEnd:

SECTION "Plant limit $54 at $6C60", ROM0[$11A8]
INCLUDE "src/plant_limit_54_at_6c60.asm"

PlantLimit54At6C60End:

SECTION "Plant limit $A8 at $6CB4", ROM0[$11B9]
INCLUDE "src/plant_limit_a8_at_6cb4.asm"

PlantLimitA8At6CB4End:

SECTION "Plant limit $1D at $6D5C", ROM0[$11CA]
INCLUDE "src/plant_limit_1d_at_6d5c.asm"

PlantLimit1DAt6D5CEnd:

SECTION "Resume script dispatch", ROM0[$11D9]
INCLUDE "src/resume_script_dispatch.asm"

ResumeScriptDispatchEnd:

SECTION "Plant $C9FA $08 and pointer $6DE9", ROM0[$11F6]
INCLUDE "src/plant_c9fa08_ptr_6de9.asm"

PlantC9FA08AndPtr6DE9End:

SECTION "Plant $C9FA $10 and pointer $6DF9", ROM0[$1207]
INCLUDE "src/plant_c9fa10_ptr_6df9.asm"

PlantC9FA10AndPtr6DF9End:

SECTION "Copy BC, plant handler, call $6AFA", ROM0[$1216]
INCLUDE "src/copy_bc_plant_handler_call_6afa.asm"

CopyBCPlantHandlerCall6AFAEnd:

SECTION "Lookup word table", ROM0[$1234]
; lookup_word_table.asm: not published here (it assembles data copied from the ROM)
LookupWordTable:
    INCBIN "roms/magination.gbc", $1234, $2E

LookupWordTableEnd:

SECTION "Lookup index 0", ROM0[$1262]
INCLUDE "src/lookup_index_0.asm"

LookupIndex0End:

SECTION "Lookup index 1", ROM0[$1277]
INCLUDE "src/lookup_index_1.asm"

LookupIndex1End:

SECTION "Lookup index 2", ROM0[$1281]
INCLUDE "src/lookup_index_2.asm"

LookupIndex2End:

SECTION "Lookup index 3", ROM0[$128B]
INCLUDE "src/lookup_index_3.asm"

LookupIndex3End:

SECTION "Lookup index 4", ROM0[$1295]
INCLUDE "src/lookup_index_4.asm"

LookupIndex4End:

SECTION "Lookup index 5", ROM0[$129E]
INCLUDE "src/lookup_index_5.asm"

LookupIndex5End:

SECTION "Lookup index 6", ROM0[$12A4]
INCLUDE "src/lookup_index_6.asm"

LookupIndex6End:

SECTION "Lookup index 7", ROM0[$12AB]
INCLUDE "src/lookup_index_7.asm"

LookupIndex7End:

SECTION "Lookup index 8", ROM0[$12B5]
INCLUDE "src/lookup_index_8.asm"

LookupIndex8End:

SECTION "Lookup index 9", ROM0[$12C5]
INCLUDE "src/lookup_index_9.asm"

LookupIndex9End:

SECTION "Lookup index 10", ROM0[$12D8]
INCLUDE "src/lookup_index_10.asm"

LookupIndex10End:

SECTION "Lookup index 11", ROM0[$12E7]
INCLUDE "src/lookup_index_11.asm"

LookupIndex11End:

SECTION "Lookup index 12", ROM0[$12F1]
INCLUDE "src/lookup_index_12.asm"

LookupIndex12End:

SECTION "Lookup index 13", ROM0[$12FB]
INCLUDE "src/lookup_index_13.asm"

LookupIndex13End:

SECTION "Lookup index 14", ROM0[$1300]
INCLUDE "src/lookup_index_14.asm"

LookupIndex14End:

SECTION "Lookup index 15", ROM0[$1305]
INCLUDE "src/lookup_index_15.asm"

LookupIndex15End:

SECTION "Lookup index 16", ROM0[$1318]
INCLUDE "src/lookup_index_16.asm"

LookupIndex16End:

SECTION "Lookup index 17", ROM0[$132B]
INCLUDE "src/lookup_index_17.asm"

LookupIndex17End:

SECTION "Lookup index 18", ROM0[$133C]
INCLUDE "src/lookup_index_18.asm"

LookupIndex18End:

SECTION "Lookup index 19", ROM0[$134D]
INCLUDE "src/lookup_index_19.asm"

LookupIndex19End:

SECTION "Lookup index 20", ROM0[$135E]
INCLUDE "src/lookup_index_20.asm"

LookupIndex20End:

SECTION "Lookup index 21", ROM0[$136F]
INCLUDE "src/lookup_index_21.asm"

LookupIndex21End:

SECTION "Lookup index 22", ROM0[$1378]
INCLUDE "src/lookup_index_22.asm"

LookupIndex22End:

SECTION "Lookup two words", ROM0[$138E]
INCLUDE "src/lookup_two_words.asm"

LookupTwoWordsEnd:

SECTION "Lookup word at $1234", ROM0[$1397]
INCLUDE "src/lookup_word_at_1234.asm"

LookupWordAt1234End:

SECTION "Script byte countdown", ROM0[$13A5]
INCLUDE "src/script_byte_countdown.asm"

ScriptByteCountdownEnd:

SECTION "Bank 1 nibble phase countdown", ROM0[$13C5]
INCLUDE "src/bank1_nibble_phase_countdown.asm"

Bank1NibblePhaseCountdownEnd:

SECTION "Park script after opcode 12", ROM0[$1402]
INCLUDE "src/install_parked_script.asm"

InstallParkedScriptEnd:

SECTION "SRAM lookup install script", ROM0[$1418]
INCLUDE "src/sram_lookup_install_script.asm"

SRAMLookupInstallScriptEnd:

SECTION "Lookup zero installs dispatcher", ROM0[$1443]
INCLUDE "src/lookup_zero_install_dispatcher.asm"

LookupZeroInstallDispatcherEnd:

SECTION "Skip two unless LCD off", ROM0[$1459]
INCLUDE "src/skip_two_unless_lcd_off.asm"

SkipTwoUnlessLcdOffEnd:

SECTION "Enter script from lookup", ROM0[$1465]
INCLUDE "src/enter_script_from_lookup.asm"

EnterScriptFromLookupEnd:

SECTION "Follow script word", ROM0[$147B]
INCLUDE "src/follow_script_word.asm"

FollowScriptWordEnd:

SECTION "Pick script record by divider mod", ROM0[$1484]
INCLUDE "src/pick_script_record_by_divider_mod.asm"

PickScriptRecordByDividerModEnd:

SECTION "Plant initial script handler", ROM0[$149E]
INCLUDE "src/plant_initial_script_handler.asm"

PlantInitialScriptHandlerEnd:

SECTION "Select script by lookup range", ROM0[$14AD]
INCLUDE "src/select_script_by_lookup_range.asm"

SelectScriptByLookupRangeEnd:

SECTION "Install script from BC", ROM0[$1504]
INCLUDE "src/install_script_from_bc.asm"

InstallScriptFromBCEnd:

SECTION "Select script by exact word", ROM0[$151F]
INCLUDE "src/select_script_by_exact_word.asm"

SelectScriptByExactWordEnd:

SECTION "Queue repeated sprite list", ROM0[$1560]
INCLUDE "src/queue_repeated_sprite_list.asm"

QueueRepeatedSpriteListEnd:

SECTION "Repeat two script bytes", ROM0[$15AB]
INCLUDE "src/repeat_two_script_bytes.asm"

RepeatTwoScriptBytesEnd:

SECTION "Step script sprite pointer table", ROM0[$15E8]
INCLUDE "src/step_script_sprite_pointer_table.asm"

StepScriptSpritePointerTableEnd:

SECTION "Queue repeated offset sprite list", ROM0[$1643]
INCLUDE "src/queue_repeated_offset_sprite_list.asm"

QueueRepeatedOffsetSpriteListEnd:

SECTION "Fill pointed record 0C 5F", ROM0[$169B]
INCLUDE "src/fill_pointed_record_0c5f.asm"

FillPointedRecord0C5FEnd:

SECTION "Jump to dispatch script opcode", ROM0[$16BE]
INCLUDE "src/jump_dispatch_script_opcode.asm"

JumpDispatchScriptOpcodeEnd:

SECTION "Plant addend 01 FF from script", ROM0[$16C1]
INCLUDE "src/plant_addend_01ff_from_script.asm"

PlantAddend01FFFromScriptEnd:

SECTION "Arm C6F8 unless set", ROM0[$16D1]
INCLUDE "src/arm_c6f8_unless_set.asm"

ArmC6F8UnlessSetEnd:

SECTION "Arm C6FA unless set", ROM0[$16DE]
INCLUDE "src/arm_c6fa_unless_set.asm"

ArmC6FAUnlessSetEnd:

SECTION "Arm C6FC unless set", ROM0[$16EB]
INCLUDE "src/arm_c6fc_unless_set.asm"

ArmC6FCUnlessSetEnd:

SECTION "Store script byte at C6F8", ROM0[$16F8]
INCLUDE "src/store_script_byte_at_c6f8.asm"

StoreScriptByteAtC6F8End:

SECTION "Store script byte at C6FA", ROM0[$1705]
INCLUDE "src/store_script_byte_at_c6fa.asm"

StoreScriptByteAtC6FAEnd:

SECTION "Store script byte at C6FC", ROM0[$1712]
INCLUDE "src/store_script_byte_at_c6fc.asm"

StoreScriptByteAtC6FCEnd:

SECTION "Fill wScriptRecord from script", ROM0[$171F]
INCLUDE "src/fill_wscript_record_from_script.asm"

FillWScriptRecordFromScriptEnd:

SECTION "Fill script record at C70D", ROM0[$1725]
INCLUDE "src/fill_script_record_c70d_from_script.asm"

FillScriptRecordC70DFromScriptEnd:

SECTION "Fill script record at C71B unless C6EE is 1", ROM0[$172B]
INCLUDE "src/fill_script_record_c71b_unless_c6ee.asm"

FillScriptRecordC71BUnlessC6EEIs1End:

SECTION "Stage next script if byte at most C6F7", ROM0[$1737]
INCLUDE "src/stage_next_script_if_byte_at_most_c6f7.asm"

StageNextScriptIfByteAtMostC6F7End:

SECTION "Dispatch if C6F6 is zero else mark it", ROM0[$1756]
INCLUDE "src/dispatch_if_c6f6_is_zero_else_mark.asm"

DispatchIfC6F6IsZeroElseMarkItEnd:

SECTION "Load C6F9 then plant handler unless zero", ROM0[$177C]
INCLUDE "src/load_c6f9_then_plant_handler_unless_zero.asm"

LoadC6F9ThenPlantHandlerUnlessZeroEnd:

SECTION "Load C6FB then plant handler unless zero", ROM0[$1782]
INCLUDE "src/load_c6fb_then_plant_handler_unless_zero.asm"

LoadC6FBThenPlantHandlerUnlessZeroEnd:

SECTION "Load C6FD then plant handler unless zero", ROM0[$1788]
INCLUDE "src/load_c6fd_then_plant_handler_unless_zero.asm"

LoadC6FDThenPlantHandlerUnlessZeroEnd:

SECTION "Load C6F9 then match script byte", ROM0[$178E]
INCLUDE "src/load_c6f9_then_match_script_byte.asm"

LoadC6F9ThenMatchScriptByteEnd:

SECTION "Load C6FB then match script byte", ROM0[$1794]
INCLUDE "src/load_c6fb_then_match_script_byte.asm"

LoadC6FBThenMatchScriptByteEnd:

SECTION "Load C6FD then match script byte", ROM0[$179A]
INCLUDE "src/load_c6fd_then_match_script_byte.asm"

LoadC6FDThenMatchScriptByteEnd:

SECTION "Copy three script bytes then dispatch", ROM0[$17A0]
INCLUDE "src/copy_three_script_bytes_then_dispatch.asm"

CopyThreeScriptBytesThenDispatchEnd:

SECTION "Plant initial script handler unless zero", ROM0[$17B2]
INCLUDE "src/plant_initial_script_handler_unless_zero.asm"

PlantInitialScriptHandlerUnlessZeroEnd:

SECTION "Match script byte then plant handler", ROM0[$17BF]
INCLUDE "src/match_script_byte_then_plant_handler.asm"

MatchScriptByteThenPlantHandlerEnd:

SECTION "Call banked word then resume script", ROM0[$17D7]
INCLUDE "src/call_banked_word_then_resume.asm"

CallBankedWordThenResumeEnd:

SECTION "Read bank 21 byte then resume script", ROM0[$17FA]
INCLUDE "src/read_bank21_byte_then_resume.asm"

ReadBank21ByteThenResumeEnd:

SECTION "Call script banked pointer then resume", ROM0[$1820]
INCLUDE "src/call_script_banked_ptr_then_resume.asm"

CallScriptBankedPtrThenResumeEnd:

SECTION "Call script banked pointer then call $2EE9", ROM0[$1843]
INCLUDE "src/call_script_banked_ptr_then_call_2ee9.asm"

CallScriptBankedPtrThenCall2EE9End:

SECTION "Call script unpack header and block", ROM0[$1866]
INCLUDE "src/call_script_unpack_header_and_block.asm"

CallScriptUnpackHeaderAndBlockEnd:

SECTION "Call script unpack into WRAM 4 and 6", ROM0[$18A9]
INCLUDE "src/call_script_unpack_wram4_and_wram6.asm"

CallScriptUnpackIntoWRAM4And6End:

SECTION "Call script ptr then map script bank", ROM0[$18EC]
INCLUDE "src/call_script_ptr_then_map_script_bank.asm"

CallScriptPtrThenMapScriptBankEnd:

SECTION "Call script map records then fill C72B", ROM0[$1903]
INCLUDE "src/call_script_map_records_then_fill_c72b.asm"

CallScriptMapRecordsThenFillC72BEnd:

SECTION "Arm CopyGlyph from script", ROM0[$1946]
INCLUDE "src/arm_copy_glyph_from_script.asm"

ArmCopyGlyphFromScriptEnd:

SECTION "Save script ptr and split byte", ROM0[$1997]
INCLUDE "src/save_script_ptr_and_split_byte.asm"

SaveScriptPtrAndSplitByteEnd:

SECTION "Store low six bits into FFA7", ROM0[$19A7]
INCLUDE "src/store_low_six_bits_into_ffa7.asm"

StoreLowSixBitsIntoFFA7End:

SECTION "Reload high bits into FFA6", ROM0[$19AD]
INCLUDE "src/reload_high_bits_into_ffa6.asm"

ReloadHighBitsIntoFFA6End:

SECTION "Copy next script word or C9E5", ROM0[$19B9]
INCLUDE "src/copy_next_script_word_or_c9e5.asm"

CopyNextScriptWordOrC9E5End:

SECTION "Store script byte at C9D8", ROM0[$19D3]
INCLUDE "src/store_script_byte_at_c9d8.asm"

StoreScriptByteAtC9D8End:

SECTION "Stage script byte word and save ptr", ROM0[$19D9]
INCLUDE "src/stage_script_byte_word_and_save_ptr.asm"

StageScriptByteWordAndSavePtrEnd:

SECTION "Step bank 7 callback countdown", ROM0[$19E8]
INCLUDE "src/step_bank7_callback_countdown.asm"

StepBank7CallbackCountdownEnd:

SECTION "Stage color word then call $5C00", ROM0[$1A16]
INCLUDE "src/stage_color_word_then_call_5c00.asm"

StageColorWordThenCall5C00End:

SECTION "Call $5C29 after countdown", ROM0[$1A44]
INCLUDE "src/call_5c29_after_countdown.asm"

Call5C29AfterCountdownEnd:

SECTION "Stage script byte word then call $4850", ROM0[$1A6F]
INCLUDE "src/stage_script_byte_word_then_call_4850.asm"

StageScriptByteWordThenCall4850End:

SECTION "Stage script byte word then call $4837", ROM0[$1A88]
INCLUDE "src/stage_script_byte_word_then_call_4837.asm"

StageScriptByteWordThenCall4837End:

SECTION "Store panel slot then call $416B", ROM0[$1AB0]
INCLUDE "src/store_panel_slot_then_call_416b.asm"

StorePanelSlotThenCall416BEnd:

SECTION "Arm countdown $1AE8 and dec $FFA6", ROM0[$1ADB]
INCLUDE "src/arm_countdown_1ae8_and_dec_ffa6.asm"

ArmCountdown1AE8AndDecFFA6End:

SECTION "Stage script word panel then bank 7", ROM0[$1AEE]
INCLUDE "src/stage_script_word_panel_then_bank7.asm"

StageScriptWordPanelThenBank7End:

SECTION "Map bank 7 and call $41CB", ROM0[$1B04]
INCLUDE "src/map_bank7_call_41cb.asm"

MapBank7Call41CBEnd:

SECTION "Arm countdown handler and dec FFA6", ROM0[$1B0E]
INCLUDE "src/arm_countdown_handler_and_dec_ffa6.asm"

ArmCountdownHandlerAndDecFFA6End:

SECTION "Store panel slot and call $41BD", ROM0[$1B21]
INCLUDE "src/store_panel_slot_call_41bd.asm"

StorePanelSlotCall41BDEnd:

SECTION "Stage pair ptr panel then call $35F1", ROM0[$1B3E]
INCLUDE "src/stage_pair_ptr_panel_then_call_35f1.asm"

StagePairPtrPanelThenCall35F1End:

SECTION "Set countdown handler $1B7D", ROM0[$1B70]
INCLUDE "src/set_countdown_handler_1b7d.asm"

SetCountdownHandler1B7DEnd:

SECTION "Store pair then call $42E3", ROM0[$1B83]
INCLUDE "src/store_pair_then_call_42e3.asm"

StorePairThenCall42E3End:

SECTION "Store panel slot and call $4333", ROM0[$1BA0]
INCLUDE "src/store_panel_slot_call_4333.asm"

StorePanelSlotCall4333End:

SECTION "Set $CCA6 and countdown $1BE4", ROM0[$1BD2]
INCLUDE "src/set_cca6_countdown_1be4.asm"

SetCCA6Countdown1BE4End:

SECTION "Store script byte and panel then call $4870", ROM0[$1BEA]
INCLUDE "src/store_script_byte_panel_call_4870.asm"

StoreScriptBytePanelCall4870End:

SECTION "Set $CCA6 and countdown $1C17", ROM0[$1C05]
INCLUDE "src/set_cca6_countdown_1c17.asm"

SetCCA6Countdown1C17End:

SECTION "Store C9D8 then apply panel row", ROM0[$1C1D]
INCLUDE "src/store_c9d8_then_apply_panel_row.asm"

StoreC9D8ThenApplyPanelRowEnd:

SECTION "Set $CCA6 and countdown $1C4A", ROM0[$1C38]
INCLUDE "src/set_cca6_countdown_1c4a.asm"

SetCCA6Countdown1C4AEnd:

SECTION "Reload script word then step eighty", ROM0[$1C50]
INCLUDE "src/reload_word_then_step_eighty.asm"

ReloadWordThenStepEightyEnd:

SECTION "Stage pair source then copy words", ROM0[$1C6E]
INCLUDE "src/stage_pair_source_then_copy_words.asm"

StagePairSourceThenCopyWordsEnd:

SECTION "Store script byte then call $481E", ROM0[$1CCA]
INCLUDE "src/store_script_byte_call_481e.asm"

StoreScriptByteCall481EEnd:

SECTION "Store script byte then call $48DC", ROM0[$1CFA]
INCLUDE "src/store_script_byte_call_48dc.asm"

StoreScriptByteCall48DCEnd:

SECTION "Nudge scroll deltas from script byte", ROM0[$1D2A]
INCLUDE "src/nudge_scroll_deltas_from_script_byte.asm"

NudgeScrollDeltasFromScriptByteEnd:

SECTION "Store map cell from DE minus 5", ROM0[$1D3D]
INCLUDE "src/store_map_cell_from_de_minus5.asm"

StoreMapCellFromDEMinus5End:

SECTION "Stage biased cells for scroll nudge", ROM0[$1D4C]
INCLUDE "src/stage_biased_cells_for_scroll_nudge.asm"

StageBiasedCellsForScrollNudgeEnd:

SECTION "Stage floored cells for scroll nudge", ROM0[$1D6B]
INCLUDE "src/stage_floored_cells_for_scroll_nudge.asm"

StageFlooredCellsForScrollNudgeEnd:

SECTION "Write script bytes across WRAM banks", ROM0[$1DA4]
INCLUDE "src/write_script_bytes_across_wram_banks.asm"

WriteScriptBytesAcrossWramBanksEnd:

SECTION "Write script bytes through banks 6 and 4", ROM0[$1DE1]
INCLUDE "src/write_script_bytes_through_banks_6_and_4.asm"

WriteScriptBytesThroughBanks6And4End:

SECTION "Center fine scroll on script base", ROM0[$1E30]
INCLUDE "src/center_fine_scroll_on_script_base.asm"

CenterFineScrollOnScriptBaseEnd:

SECTION "Add script deltas until zero", ROM0[$1E45]
INCLUDE "src/add_script_deltas_until_zero.asm"

AddScriptDeltasUntilZeroEnd:

SECTION "Center fine scroll on script word", ROM0[$1E8E]
INCLUDE "src/center_fine_scroll_on_script_word.asm"

CenterFineScrollOnScriptWordEnd:

SECTION "Stage eight script bytes", ROM0[$1E9F]
INCLUDE "src/stage_eight_script_bytes.asm"

StageEightScriptBytesEnd:

SECTION "Plant bank 1 handler 4552", ROM0[$1EDA]
INCLUDE "src/plant_bank1_handler_4552.asm"

PlantBank1Handler4552End:

SECTION "Stage script byte and enter bank 1", ROM0[$1EE7]
INCLUDE "src/stage_script_byte_enter_bank1.asm"

StageScriptByteEnterBank1End:

SECTION "Copy prefixed block to D000", ROM0[$1EF5]
INCLUDE "src/copy_prefixed_block_to_d000.asm"

CopyPrefixedBlockToD000End:

SECTION "Run script record", ROM0[$1F1A]
INCLUDE "src/run_script_record.asm"

RunScriptRecordEnd:

SECTION "Seed camera and enter loop", ROM0[$1F50]
INCLUDE "src/seed_camera_loop.asm"

SeedCameraAndEnterLoopEnd:

SECTION "Copy three bytes and call bank 7", ROM0[$1FAF]
INCLUDE "src/copy_three_c9fc_bank7.asm"

CopyThreeBytesCallBank7End:

SECTION "Copy three bytes and call bank 7 at $7465", ROM0[$1FD4]
INCLUDE "src/copy_three_call_7465.asm"

CopyThreeBytesCall7465End:

SECTION "Load SRAM script and dispatch", ROM0[$1FF9]
INCLUDE "src/load_sram_script_dispatch.asm"

LoadSRAMScriptAndDispatchEnd:

SECTION "Call bank 7 then load SRAM script", ROM0[$2035]
INCLUDE "src/call_bank7_then_load_sram_script.asm"

CallBank7ThenLoadSRAMScriptEnd:

SECTION "Call bank 3 then dispatch script", ROM0[$2045]
INCLUDE "src/call_bank3_then_dispatch.asm"

CallBank3ThenDispatchScriptEnd:

SECTION "Rewind, copy counted block, call bank 3", ROM0[$205E]
INCLUDE "src/rewind_copy_then_call_5400.asm"

RewindCopyThenCall5400End:

SECTION "Call bank 3 at $5AAE then dispatch", ROM0[$2070]
INCLUDE "src/call_bank3_5aae_then_dispatch.asm"

CallBank3_5AAEThenDispatchEnd:

SECTION "Call bank 4 at $5494 then enter script", ROM0[$2089]
INCLUDE "src/call_bank4_5494_then_enter_script.asm"

CallBank4_5494ThenEnterScriptEnd:

SECTION "Rewind, copy counted block, call bank 3 at $7025", ROM0[$20C8]
INCLUDE "src/rewind_copy_then_call_7025.asm"

RewindCopyThenCall7025End:

SECTION "Copy prefixed block, call bank 3 at $66BE", ROM0[$20DA]
INCLUDE "src/copy_prefixed_then_call_66be.asm"

CopyPrefixedBlockThenCall66BEEnd:

SECTION "Branch on script byte in bank 1", ROM0[$20E9]
INCLUDE "src/branch_bank1_on_script_byte.asm"

BranchBank1OnScriptByteEnd:

SECTION "Stage saved script pair then bank 7", ROM0[$2108]
INCLUDE "src/stage_saved_script_pair.asm"

StageSavedScriptPairThenBank7End:

SECTION "Finish startup", ROM0[$2158]
INCLUDE "src/finish_startup.asm"

FinishStartupEnd:

SECTION "Mark script done at 21B2", ROM0[$21B2]
INCLUDE "src/mark_script_done_21b2.asm"

MarkScriptDone21B2End:

SECTION "Copy fallback script record", ROM0[$21C2]
INCLUDE "src/copy_fallback_script_record.asm"

CopyFallbackScriptRecordEnd:

SECTION "Save script triple to SRAM", ROM0[$21D1]
INCLUDE "src/save_script_triple.asm"

SaveScriptTripleToSRAMEnd:

SECTION "Reenter reset", ROM0[$2200]
INCLUDE "src/reenter_reset.asm"

ReenterResetEnd:

SECTION "Setup window", ROM0[$2203]
INCLUDE "src/setup_window.asm"

SetupWindowTilemapEnd:

SECTION "Pointed SRAM byte digits", ROM0[$2250]
; format_pointed_sram_byte.asm: not published here (it assembles data copied from the ROM)
PointedByteWords:
    INCBIN "roms/magination.gbc", $2250, $6

SECTION "Pointed SRAM byte digits @$002256", ROM0[$2256]
FormatPointedSRAMByteThenResume:
    INCBIN "roms/magination.gbc", $2256, $1F

FormatPointedSRAMByteThenResumeEnd:

SECTION "Script opcode 99", ROM0[$2275]
INCLUDE "src/opcode_99.asm"

Opcode99End:

SECTION "Script opcode 9A", ROM0[$2297]
INCLUDE "src/opcode_9a.asm"

Opcode9AEnd:

SECTION "Script opcode 9B", ROM0[$22A7]
INCLUDE "src/opcode_9b.asm"

Opcode9BEnd:

SECTION "Script opcode 9B handler", ROM0[$22C4]
INCLUDE "src/opcode_9b_handler.asm"

Opcode9BHandlerEnd:

SECTION "Script opcode 9B countdown", ROM0[$230A]
INCLUDE "src/opcode_9b_countdown.asm"

Opcode9BCountdownEnd:

SECTION "Script opcode 9C", ROM0[$2338]
INCLUDE "src/opcode_9c.asm"

Opcode9CEnd:

SECTION "Commit armed slot choice", ROM0[$23A7]
INCLUDE "src/commit_armed_slot_choice.asm"

CommitArmedSlotChoiceEnd:

SECTION "Script opcode 9D", ROM0[$23D2]
INCLUDE "src/opcode_9d.asm"

Opcode9DEnd:

SECTION "Script opcode 9E", ROM0[$23E2]
INCLUDE "src/opcode_9e.asm"

Opcode9EEnd:

SECTION "Stage strip text from script", ROM0[$2401]
INCLUDE "src/stage_strip_text_from_script.asm"

StageStripTextFromScriptEnd:

SECTION "Run saved strip text", ROM0[$2421]
INCLUDE "src/run_saved_strip_text.asm"

RunSavedStripTextEnd:

SECTION "Arm strip slide followup", ROM0[$24A2]
INCLUDE "src/arm_strip_slide_followup.asm"

ArmStripSlideFollowupEnd:

SECTION "Plant strip handler 24C7", ROM0[$24BC]
INCLUDE "src/plant_strip_handler_24c7.asm"

PlantStripHandler24C7End:

SECTION "Plant strip handler 24D2", ROM0[$24C7]
INCLUDE "src/plant_strip_handler_24d2.asm"

PlantStripHandler24D2End:

SECTION "Arm strip text step", ROM0[$24D2]
INCLUDE "src/arm_strip_text_step.asm"

ArmStripTextStepEnd:

SECTION "Return unless C6EE is two", ROM0[$24EC]
INCLUDE "src/return_unless_c6ee_is_two.asm"

ReturnUnlessC6EEIsTwoEnd:

SECTION "Finish window Y slide", ROM0[$2507]
INCLUDE "src/finish_window_y_slide.asm"

FinishWindowYSlideEnd:

SECTION "Branch when LCD off", ROM0[$254F]
INCLUDE "src/branch_when_lcd_off.asm"

BranchWhenLCDOffEnd:

SECTION "Branch record bits when LCD on", ROM0[$2563]
INCLUDE "src/branch_record_bits_when_lcd_on.asm"

BranchRecordBitsWhenLCDOnEnd:

SECTION "Plant parked handler when LCD off", ROM0[$256B]
INCLUDE "src/plant_parked_handler_when_lcd_off.asm"

PlantParkedHandlerWhenLCDOffEnd:

SECTION "Branch record bits after parked plant", ROM0[$258E]
INCLUDE "src/branch_record_bits_after_parked_plant.asm"

BranchRecordBitsAfterParkedPlantEnd:

SECTION "Branch parked script when LCD off", ROM0[$2596]
INCLUDE "src/branch_parked_script_when_lcd_off.asm"

BranchParkedScriptWhenLCDOffEnd:

SECTION "Branch parked script when LCD on", ROM0[$25AA]
INCLUDE "src/branch_parked_script_when_lcd_on.asm"

BranchParkedScriptWhenLCDOnEnd:

SECTION "Plant parked handler then stage", ROM0[$25B4]
INCLUDE "src/plant_parked_handler_then_stage.asm"

PlantParkedHandlerThenStageEnd:

SECTION "LCD-on BC split after parked handler", ROM0[$25D0]
INCLUDE "src/lcd_on_bc_split_after_parked_handler.asm"

LCDOnBCSplitAfterParkedHandlerEnd:

SECTION "Plant offset 7 then store FF", ROM0[$25DA]
INCLUDE "src/plant_offset7_then_store_ff.asm"

PlantOffset7ThenStoreFFEnd:

SECTION "LCD-on after offset 7 record", ROM0[$25FA]
INCLUDE "src/lcd_on_after_offset7_record.asm"

LCDOnAfterOffset7RecordEnd:

SECTION "OR BC into SRAM before stage", ROM0[$2674]
INCLUDE "src/or_bc_into_sram_before_stage.asm"

OrBCIntoSramBeforeStageEnd:

SECTION "Stage byte past three", ROM0[$2680]
INCLUDE "src/stage_byte_past_three.asm"

StageBytePastThreeEnd:

SECTION "OR BC into SRAM byte", ROM0[$2689]
INCLUDE "src/or_bc_into_sram_byte.asm"

OrBCIntoSramByteEnd:

SECTION "Plant script past record", ROM0[$2695]
INCLUDE "src/plant_script_past_record.asm"

PlantScriptPastRecordEnd:

SECTION "Xor record byte into SRAM", ROM0[$26AB]
INCLUDE "src/xor_record_byte_into_sram.asm"

XorRecordByteIntoSramEnd:

SECTION "Stage byte past four", ROM0[$26B7]
INCLUDE "src/stage_byte_past_four.asm"

StageBytePastFourEnd:

SECTION "Store E through word in WRAM 3", ROM0[$26CC]
INCLUDE "src/store_e_through_word.asm"

StoreEThroughWordInWram3End:

SECTION "Plant script ptr and read SRAM byte", ROM0[$2718]
INCLUDE "src/plant_script_ptr_read_sram.asm"

PlantScriptPtrReadSramByteEnd:

SECTION "OR SRAM mask when lookup", ROM0[$2747]
INCLUDE "src/or_sram_mask_when_lookup.asm"

OrSramMaskWhenLookupEnd:

SECTION "AND complemented mask into SRAM", ROM0[$2772]
INCLUDE "src/and_complemented_mask_into_sram.asm"

AndComplementedMaskIntoSramEnd:

SECTION "Store lookup low byte into SRAM", ROM0[$277E]
INCLUDE "src/store_lookup_low_into_sram.asm"

SECTION "Store lookup word into SRAM", ROM0[$279E]
INCLUDE "src/store_lookup_word_into_sram.asm"

SECTION "Call bank $40B7 then dispatch", ROM0[$27C0]
INCLUDE "src/call_script_bank_40b7.asm"

SECTION "Store script word at SRAM $A123", ROM0[$27C6]
INCLUDE "src/store_script_word_at_a123.asm"

SECTION "Store script byte in WRAM bank", ROM0[$2801]
INCLUDE "src/store_script_byte_in_wram_bank.asm"

StoreScriptByteInWramBankSliceEnd:

SECTION "Store script word in WRAM bank", ROM0[$2815]
INCLUDE "src/store_script_word_in_wram_bank.asm"

StoreScriptWordInWramBankSliceEnd:

SECTION "Store script byte in SRAM", ROM0[$282C]
INCLUDE "src/store_script_byte_in_sram.asm"

StoreScriptByteInSramSliceEnd:

SECTION "Store script word in SRAM", ROM0[$2849]
INCLUDE "src/store_script_word_in_sram.asm"

StoreScriptWordInSramSliceEnd:

SECTION "AND script mask into SRAM", ROM0[$2869]
INCLUDE "src/and_script_mask_into_sram.asm"

AndScriptMaskIntoSramSliceEnd:

SECTION "OR script mask into SRAM", ROM0[$2889]
INCLUDE "src/or_script_mask_into_sram.asm"

OrScriptMaskIntoSramSliceEnd:

SECTION "Write quad records", ROM0[$28A9]
INCLUDE "src/write_quad_records.asm"

WriteQuadRecordsEnd:

SECTION "Add and shift", ROM0[$28E5]
INCLUDE "src/add_and_shift.asm"

AddAndShiftUnknownEnd:

SECTION "Copy script record", ROM0[$290A]
INCLUDE "src/copy_script_record.asm"

CopyScriptBytesEnd:

SECTION "Load script bytes", ROM0[$2928]
INCLUDE "src/load_script_bytes.asm"

LoadScriptBytesEnd:

SECTION "Copy glyph", ROM0[$2949]
INCLUDE "src/copy_glyph.asm"

CopyGlyphEnd:

SECTION "Idle callback", ROM0[$29A4]
INCLUDE "src/idle_callback.asm"

IdleCallbackEnd:

SECTION "Timer overflow", ROM0[$29AF]
INCLUDE "src/timer_overflow.asm"

TimerOverflowEnd:

SECTION "Set timer modulo", ROM0[$29F3]
INCLUDE "src/set_timer_modulo.asm"

SetTimerModuloEnd:

SECTION "LCD STAT", ROM0[$2A07]
INCLUDE "src/lcd_stat.asm"

LCDStatEnd:

SECTION "VBlank handler", ROM0[$2A10]
INCLUDE "src/vblank_handler.asm"

HandleVBlankEnd:

SECTION "Default VBlank", ROM0[$2A49]
INCLUDE "src/default_vblank.asm"

DefaultVBlankEnd:

SECTION "STAT copy LCDC and scroll", ROM0[$2AA8]
INCLUDE "src/stat_copy_lcdc_scroll.asm"

StatCopyLCDCScrollEnd:

SECTION "Empty STAT handler", ROM0[$2AB7]
INCLUDE "src/empty_stat.asm"

EmptyStatEnd:

SECTION "STAT set LCDC objects off", ROM0[$2ABA]
INCLUDE "src/stat_set_lcdc_objects_off.asm"

StatSetLCDCObjectsOffEnd:

SECTION "STAT set play LCDC", ROM0[$2AC1]
INCLUDE "src/stat_set_play_lcdc.asm"

StatSetPlayLCDCEnd:

SECTION "Paint strip cell then idle", ROM0[$2AC8]
INCLUDE "src/paint_strip_cell_then_idle.asm"

PaintStripCellThenIdleEnd:

SECTION "Paint strip map cells", ROM0[$2AF8]
INCLUDE "src/paint_strip_map_cells.asm"

PaintStripMapCellsEnd:

SECTION "Copy glyph then paint cell", ROM0[$2B28]
INCLUDE "src/copy_glyph_then_paint_cell.asm"

CopyGlyphThenPaintCellEnd:

SECTION "Step strip text cell", ROM0[$2B51]
INCLUDE "src/step_strip_text_cell.asm"

StepStripTextCellEnd:

SECTION "Park strip trampoline", ROM0[$2B8C]
INCLUDE "src/park_strip_trampoline.asm"

ParkStripTrampolineEnd:

SECTION "Step map strip glyph", ROM0[$2B8F]
INCLUDE "src/step_map_strip_glyph.asm"

StepMapStripGlyphEnd:

SECTION "Park strip routine", ROM0[$2BBB]
INCLUDE "src/park_strip_routine.asm"

ParkStripRoutineEnd:

SECTION "Strip glyph pointer", ROM0[$2BC8]
INCLUDE "src/strip_glyph_pointer.asm"

LoadStripGlyphPointerEnd:

SECTION "Next strip text byte", ROM0[$2BE4]
INCLUDE "src/next_strip_text_byte.asm"

LoadNextStripTextByteEnd:

SECTION "Format HL byte three digits", ROM0[$2C33]
INCLUDE "src/format_hl_byte_three_digits.asm"

FormatHLByteThreeDigitsEnd:

SECTION "Format HL word three digits", ROM0[$2C57]
INCLUDE "src/format_hl_word_three_digits.asm"

FormatHLWordThreeDigitsEnd:

SECTION "Rewind strip tile and dest", ROM0[$2C7B]
INCLUDE "src/rewind_strip_tile_and_dest.asm"

RewindStripTileAndDestEnd:

SECTION "Run bank 21 script list", ROM0[$2C97]
INCLUDE "src/run_bank21_script_list.asm"

RunBank21ScriptListEnd:

SECTION "Unpack script maps at 9800", ROM0[$2D14]
INCLUDE "src/unpack_script_maps_at_9800.asm"

UnpackScriptMapsAt9800End:

SECTION "Copy map rect to both VRAM banks", ROM0[$2D2C]
INCLUDE "src/copy_map_rect_both_vram.asm"

CopyMapRectToBothVRAMBanksEnd:

SECTION "Copy E columns by D rows", ROM0[$2D40]
INCLUDE "src/copy_e_columns_by_d_rows.asm"

CopyEColumnsByDRowsEnd:

SECTION "Copy prepared map both VRAM from row end", ROM0[$2D55]
INCLUDE "src/copy_map_rect_both_vram_reverse.asm"

CopyPreparedMapBothVRAMFromRowEndEnd:

SECTION "Copy one map rect from row end", ROM0[$2D69]
INCLUDE "src/copy_one_map_rect_from_row_end.asm"

CopyOneMapRectFromRowEndSliceEnd:

SECTION "Prepare map planes at D000", ROM0[$2D8C]
INCLUDE "src/prepare_map_at_d000.asm"

PrepareMapPlanesAtD000End:

SECTION "Unpack map into WRAM bank 6", ROM0[$2DAA]
INCLUDE "src/unpack_map_wram6_both_vram.asm"

UnpackMapIntoWRAM6AndCopyBothEnd:

SECTION "Unpack map into WRAM bank 6 reverse copy", ROM0[$2DC3]
INCLUDE "src/unpack_map_wram6_reverse.asm"

UnpackMapIntoWRAM6AndCopyReverseEnd:

SECTION "Unpack block into WRAM bank 5", ROM0[$2DDC]
INCLUDE "src/unpack_block_wram5.asm"

UnpackBlockIntoWRAMBank5End:

SECTION "Unpack skip 1 into WRAM bank 6", ROM0[$2E04]
INCLUDE "src/unpack_skip1_wram_bank6.asm"

SelectWRAM6Skip1ThenUnpackEnd:

SECTION "Load five banked map sources", ROM0[$2E15]
INCLUDE "src/load_five_banked_map_sources.asm"

SECTION "Copy word pairs", ROM0[$2EB6]
INCLUDE "src/copy_word_pairs.asm"

CopyWordPairsEnd:

SECTION "Fill C72B from BC then bank 7", ROM0[$2EC3]
INCLUDE "src/fill_c72b_from_bc_then_bank7.asm"

FillC72BFromBCThenBank7End:

SECTION "Fill C76B from BC then OBJ palettes", ROM0[$2EE9]
INCLUDE "src/fill_c76b_from_bc_then_obj_palettes.asm"

FillC76BFromBCThenOBJPalettesEnd:

SECTION "Copy E word pairs", ROM0[$2F0F]
INCLUDE "src/copy_e_word_pairs.asm"

CopyEWordPairsEnd:

SECTION "Unpack to WRAM bank 2", ROM0[$2F19]
INCLUDE "src/unpack_to_wram_bank2.asm"

UnpackToWRAMBank2End:

SECTION "Unpack header into WRAM bank 3", ROM0[$2F37]
INCLUDE "src/unpack_header_wram_bank3.asm"

UnpackMapHeaderIntoWRAMBank3End:

SECTION "Unpack skip 5 into WRAM bank 4", ROM0[$2FAC]
INCLUDE "src/unpack_skip5_wram_bank4.asm"

UnpackSkip5ThenTailIntoWRAMBank4End:

SECTION "Copy map records", ROM0[$2FC0]
INCLUDE "src/copy_map_records.asm"

CopyMapRecordsEnd:

SECTION "Copy one VRAM record", ROM0[$2FE5]
INCLUDE "src/copy_one_vram_record.asm"

CopyOneVRAMRecordEnd:

SECTION "Copy one map panel", ROM0[$304E]
INCLUDE "src/copy_one_map_panel.asm"

CopyOneMapPanelEnd:

SECTION "Apply eight C9B3 bytes", ROM0[$3056]
INCLUDE "src/apply_c9b3_bytes.asm"

ApplyC9B3BytesEnd:

SECTION "Stage map panel sources", ROM0[$311F]
INCLUDE "src/stage_map_panel_sources.asm"

StageMapPanelSourcesEnd:

SECTION "Fill map panel tiles", ROM0[$314F]
INCLUDE "src/fill_map_panel_tiles.asm"

FillMapPanelTilesEnd:

SECTION "Load map panels", ROM0[$31D5]
INCLUDE "src/load_map_panels.asm"

LoadMapPanelsEnd:

SECTION "Copy indexed panel block", ROM0[$323F]
INCLUDE "src/copy_indexed_panel_block.asm"

CopyIndexedPanelBlockEnd:

SECTION "Plant indexed panel callback", ROM0[$32A2]
INCLUDE "src/plant_indexed_panel_callback.asm"

PlantIndexedPanelCallbackEnd:

SECTION "Plant panel field 4 callback", ROM0[$32C9]
INCLUDE "src/plant_panel_field4_callback.asm"

PlantPanelField4CallbackEnd:

SECTION "Run indexed panel routine", ROM0[$32DF]
INCLUDE "src/run_indexed_panel_routine.asm"

RunIndexedPanelRoutineEnd:

SECTION "Draw entry fields VRAM0", ROM0[$338D]
INCLUDE "src/draw_entry_fields_vram0.asm"

DrawEntryFieldsVRAM0End:

SECTION "Draw entry fields VRAM1", ROM0[$340B]
INCLUDE "src/draw_entry_fields_vram1.asm"

DrawEntryFieldsVRAM1End:

SECTION "Load C9 record picture", ROM0[$3493]
INCLUDE "src/load_c9_record_picture.asm"

LoadC9RecordPictureEnd:

SECTION "Copy twelve word pairs then write C9E5", ROM0[$358E]
INCLUDE "src/copy_twelve_word_pairs_then_write_c9e5.asm"

CopyTwelveWordPairsThenWriteC9E5End:

SECTION "Copy twelve word pairs at index 0C then write C9E5", ROM0[$35AD]
INCLUDE "src/copy_twelve_word_pairs_index0c_then_write_c9e5.asm"

CopyTwelveWordPairsAtIndex0CThenWriteC9E5End:

SECTION "Copy eight word pairs at index 18", ROM0[$35CC]
INCLUDE "src/copy_eight_word_pairs_index18.asm"

CopyEightWordPairsAtIndex18End:

SECTION "Copy thirty-two word pairs at index 00", ROM0[$35E0]
INCLUDE "src/copy_thirty_two_word_pairs_index00.asm"

CopyThirtyTwoWordPairsAtIndex00End:

SECTION "Map pair bank then copy twelve word pairs", ROM0[$35F1]
INCLUDE "src/map_pair_bank_then_copy_twelve_word_pairs.asm"

MapPairBankThenCopyTwelveWordPairsEnd:

SECTION "Place entry map by DE", ROM0[$3635]
INCLUDE "src/place_entry_map_by_de.asm"

SECTION "Lookup entry E byte", ROM0[$3657]
INCLUDE "src/lookup_entry_e_byte.asm"

SECTION "Lookup entry D byte", ROM0[$3667]
INCLUDE "src/lookup_entry_d_byte.asm"

SECTION "STAT window scroll then bank 4", ROM0[$3677]
INCLUDE "src/stat_window_scroll_then_bank4.asm"

StatWindowScrollThenBank4End:

SECTION "STAT hide window scroll C9C1", ROM0[$36B1]
INCLUDE "src/stat_hide_window_scroll_c9c1.asm"

StatHideWindowScrollC9C1End:

SECTION "Apply C9C0 window then call step four", ROM0[$36C1]
INCLUDE "src/apply_c9c0_window_then_call_step_four.asm"

ApplyC9C0WindowThenCallStepFourEnd:

SECTION "Run C9C0 window VBlank", ROM0[$36F9]
INCLUDE "src/run_c9c0_window_vblank.asm"

RunC9C0WindowVBlankEnd:

SECTION "Entry E byte table base", ROM0[$3758]
; entry_e_byte_zero.asm: not published here (it assembles data copied from the ROM)
EntryEByteTableBase:
    INCBIN "roms/magination.gbc", $3758, $1

SECTION "Entry map tables and STAT add C9BE", ROM0[$3759]
; entry_map_tables_stat_add_c9be.asm: not published here (it assembles data copied from the ROM)
EntryEByteTableTail:
    INCBIN "roms/magination.gbc", $3759, $10

SECTION "Entry map tables and STAT add C9BE @$003769", ROM0[$3769]
EntryDByteTable:
    INCBIN "roms/magination.gbc", $3769, $D

SECTION "Entry map tables and STAT add C9BE @$003776", ROM0[$3776]
StatAddC9BEIntoC9C0:
    INCBIN "roms/magination.gbc", $3776, $20

EntryMapTablesStatAddC9BEEnd:

SECTION "STAT add C9BF into C9C1", ROM0[$3796]
INCLUDE "src/stat_add_c9bf_into_c9c1.asm"

StatAddC9BFIntoC9C1End:

SECTION "Run fixed scroll window VBlank", ROM0[$37AA]
INCLUDE "src/run_fixed_scroll_window_vblank.asm"

RunFixedScrollWindowVBlankEnd:

SECTION "Add BC to record word at +5", ROM0[$3812]
INCLUDE "src/add_bc_to_record_word5.asm"

AddBcToRecordWord5End:

SECTION "Apply rank band step", ROM0[$3821]
INCLUDE "src/apply_rank_band_step.asm"

ApplyRankBandStepEnd:

SECTION "Add DE clamp record word at +9", ROM0[$3847]
INCLUDE "src/add_de_clamp_record_word9.asm"

AddDeClampRecordWord9End:

SECTION "Subtract DE floor record word at +9", ROM0[$3863]
INCLUDE "src/sub_de_floor_record_word9.asm"

SubDeFloorRecordWord9End:

SECTION "Add A cap byte at BC", ROM0[$387E]
INCLUDE "src/add_a_cap_byte_at_bc.asm"

AddACapByteAtBcEnd:

SECTION "Subtract A floor byte at BC", ROM0[$3886]
INCLUDE "src/sub_a_floor_byte_at_bc.asm"

SubAFloorByteAtBcEnd:

SECTION "Add scaled floor cap byte at DE", ROM0[$3892]
INCLUDE "src/add_scaled_floor_cap_byte_at_de.asm"

AddScaledFloorCapByteAtDeEnd:

SECTION "Subtract scaled floor byte at DE", ROM0[$38A6]
INCLUDE "src/sub_scaled_floor_byte_at_de.asm"

SubScaledFloorByteAtDeEnd:

SECTION "OR A into byte at BC", ROM0[$38BE]
INCLUDE "src/or_a_into_byte_at_bc.asm"

OrAIntoByteAtBcEnd:

SECTION "AND CPL A into byte at BC", ROM0[$38C2]
INCLUDE "src/and_cpl_a_into_byte_at_bc.asm"

AndCplAIntoByteAtBcEnd:

SECTION "Store slot pairs 02 14", ROM0[$38C7]
INCLUDE "src/store_slot_pairs_0214.asm"

StoreSlotPairs0214End:

SECTION "Slot record pointer", ROM0[$38DE]
INCLUDE "src/slot_record_ptr.asm"

SlotRecordPtrEnd:

SECTION "Store indexed slot record", ROM0[$38F0]
INCLUDE "src/store_indexed_slot_record.asm"

StoreIndexedSlotRecordEnd:

SECTION "Copy glyph in bank 6", ROM0[$3902]
INCLUDE "src/copy_glyph_in_bank6.asm"

CopyGlyphInBank6End:

SECTION "Add $80 to seven tiles at $9C05", ROM0[$3919]
INCLUDE "src/add80_seven_tiles_9c05.asm"

Add80ToSevenTiles9C05End:

SECTION "Paint entry flag tiles", ROM0[$3931]
INCLUDE "src/paint_entry_flag_tiles.asm"

PaintEntryFlagTilesEnd:

SECTION "Prep HL and store callback high", ROM0[$397E]
INCLUDE "src/prep_hl_store_callback_high.asm"

PrepHlStoreCallbackHighEnd:

SECTION "Push rebuilt HL and add $C9", ROM0[$398B]
INCLUDE "src/push_rebuilt_hl_add_c9.asm"

PushRebuiltHlAddC9End:

SECTION "Map ROM bank", ROM0[$3AB0]
INCLUDE "src/map_rom_bank.asm"

MapRomBankEnd:

SECTION "Decrement wave sample copy", ROM0[$3ABB]
INCLUDE "src/decrement_wave_sample_copy.asm"

DecrementWaveSampleCopyEnd:

SECTION "Feed wave from timer", ROM0[$3AC0]
INCLUDE "src/feed_wave_from_timer.asm"

FeedWaveFromTimerEnd:

SECTION "Stop wave countdown", ROM0[$3B7C]
INCLUDE "src/stop_wave_countdown.asm"

StopWaveCountdownEnd:

SECTION "Copy mapped waveform", ROM0[$3BA1]
INCLUDE "src/copy_mapped_waveform.asm"

CopyMappedWaveformEnd:

SECTION "Stage wave or flat", ROM0[$3BB3]
INCLUDE "src/stage_wave_or_flat.asm"

StageWaveOrFlatEnd:

SECTION "Load waveform", ROM0[$3BEF]
INCLUDE "src/load_waveform.asm"

LoadWaveformEnd:

SECTION "Copy waveform", ROM0[$3C32]
INCLUDE "src/copy_waveform.asm"

CopyWaveformEnd:

SECTION "Run envelope then map saved bank", ROM0[$3C6B]
INCLUDE "src/run_envelope_then_map_saved_bank.asm"

RunEnvelopeThenMapSavedBankEnd:

SECTION "Walk envelope", ROM0[$3C75]
INCLUDE "src/walk_envelope.asm"

WalkEnvelopeEnd:

SECTION "Read pressed buttons", ROM0[$3D2A]
INCLUDE "src/read_pressed_buttons.asm"

ReadPressedButtonsEnd:

SECTION "Read countdown scale", ROM0[$3D4A]
INCLUDE "src/read_countdown_scale.asm"

ReadCountdownScaleEnd:

SECTION "Seed countdown from table", ROM0[$3D65]
INCLUDE "src/seed_countdown_from_table.asm"

SECTION "Advance countdown record", ROM0[$3E3A]
INCLUDE "src/advance_countdown_record.asm"

AdvanceCountdownRecordEnd:

SECTION "Step indexed countdown", ROM0[$3E78]
INCLUDE "src/step_indexed_countdown.asm"

StepIndexedCountdownEnd:

SECTION "Load lower countdown stream", ROM0[$3ED4]
INCLUDE "src/load_lower_countdown_stream.asm"

LoadLowerCountdownStreamEnd:

SECTION "Read expired lower countdown", ROM0[$3F0E]
INCLUDE "src/read_expired_lower_countdown.asm"

SECTION "Add lower countdown delta", ROM0[$3F7D]
INCLUDE "src/add_lower_countdown_delta.asm"

AddLowerCountdownDeltaEnd:

SECTION "Read indexed countdown byte", ROM0[$3FB0]
INCLUDE "src/read_indexed_countdown_byte.asm"

ReadIndexedCountdownByteEnd:

SECTION "ROM0 tail padding", ROM0[$3FCF]
INCLUDE "src/rom0_tail_padding.asm"

SECTION "Restore scratch record", ROMX[$4000], BANK[1]
INCLUDE "src/restore_scratch_record.asm"

SECTION "Copy record to scratch", ROMX[$401E], BANK[1]
INCLUDE "src/copy_record_to_scratch.asm"

SECTION "Take pointer slot", ROMX[$403D], BANK[1]
INCLUDE "src/take_pointer_slot.asm"

SECTION "Return pointer slot", ROMX[$4062], BANK[1]
INCLUDE "src/return_pointer_slot.asm"

ReturnPointerSlotEnd:

SECTION "Walk pointer slots", ROMX[$407D], BANK[1]
INCLUDE "src/walk_pointer_slots.asm"

WalkPointerSlotsEnd:

SECTION "Init pointer list", ROMX[$40D3], BANK[1]
INCLUDE "src/init_pointer_list.asm"

InitPointerListEnd:

SECTION "Write record head", ROMX[$410A], BANK[1]
INCLUDE "src/write_record_head.asm"

WriteRecordHeadSectionEnd:

SECTION "Load record head", ROMX[$412F], BANK[1]
INCLUDE "src/load_record_head.asm"

LoadRecordHeadSectionEnd:

SECTION "Unknown at $415D", ROMX[$415D], BANK[1]
    INCBIN "roms/magination.gbc", $415D, $004E

SECTION "Stage third script if C716", ROMX[$41AB], BANK[1]
; stage_third_script_c716_entry.asm: not published here (it assembles data copied from the ROM)
StageThirdScriptIfC716:
    INCBIN "roms/magination.gbc", $41AB, $1

SECTION "Stage third script from $C6DB", ROMX[$41AC], BANK[1]
INCLUDE "src/stage_third_script_from_c6db.asm"

StageThirdScriptFromC6DBSectionEnd:

SECTION "Advance cell $82 countdown", ROMX[$41D8], BANK[1]
INCLUDE "src/advance_cell82_countdown.asm"

AdvanceCell82CountdownSectionEnd:

SECTION "Step cell $82 every fourth frame", ROMX[$4212], BANK[1]
INCLUDE "src/step_cell82_every_fourth_frame.asm"

StepCell82EveryFourthFrameSectionEnd:

SECTION "Step cell $82 on even pass", ROMX[$4221], BANK[1]
INCLUDE "src/step_cell82_on_even_pass.asm"

StepCell82OnEvenPassSectionEnd:

SECTION "Stage third script from marked cell", ROMX[$422E], BANK[1]
INCLUDE "src/stage_third_script_from_marked_cell.asm"

StageThirdScriptFromMarkedCellEnd:

SECTION "Opcode pointer table", ROMX[$42C3], BANK[1]
; opcode_pointer_table.asm: not published here (it assembles data copied from the ROM)
OpcodePointerTable:
    INCBIN "roms/magination.gbc", $42C3, $40

OpcodePointerTableEnd:

SECTION "Opcode pointer table from $20", ROMX[$4303], BANK[1]
; opcode_pointer_table_20.asm: not published here (it assembles data copied from the ROM)
OpcodePointerTableFrom20:
    INCBIN "roms/magination.gbc", $4303, $40

OpcodePointerTableFrom20End:

SECTION "Opcode pointer table from $40", ROMX[$4343], BANK[1]
; opcode_pointer_table_40.asm: not published here (it assembles data copied from the ROM)
OpcodePointerTableFrom40:
    INCBIN "roms/magination.gbc", $4343, $40

OpcodePointerTableFrom40End:

SECTION "Opcode pointer table from $60", ROMX[$4383], BANK[1]
; opcode_pointer_table_60.asm: not published here (it assembles data copied from the ROM)
OpcodePointerTableFrom60:
    INCBIN "roms/magination.gbc", $4383, $40

OpcodePointerTableFrom60End:

SECTION "Opcode pointer table from $80", ROMX[$43C3], BANK[1]
; opcode_pointer_table_80.asm: not published here (it assembles data copied from the ROM)
OpcodePointerTableFrom80:
    INCBIN "roms/magination.gbc", $43C3, $40

OpcodePointerTableFrom80End:

SECTION "Opcode pointer table from $A0", ROMX[$4403], BANK[1]
; opcode_pointer_table_a0.asm: not published here (it assembles data copied from the ROM)
OpcodePointerTableFromA0:
    INCBIN "roms/magination.gbc", $4403, $20

OpcodePointerTableFromA0End:

SECTION "Opcode 00 in bank 1", ROMX[$4423], BANK[1]
INCLUDE "src/opcode_00_bank1.asm"

Opcode00InBank1End:

SECTION "Pick map cell from DIV", ROMX[$4456], BANK[1]
INCLUDE "src/pick_map_cell_from_div.asm"

PickMapCellFromDivEnd:

SECTION "Copy staged byte into banks 5 and 3", ROMX[$44A6], BANK[1]
INCLUDE "src/copy_staged_byte_banks_5_and_3.asm"

CopyStagedByteIntoBanks5And3End:

SECTION "Advance staged copy", ROMX[$44E1], BANK[1]
INCLUDE "src/advance_staged_copy.asm"

SECTION "Copy staged byte from banks 6 and 4", ROMX[$4552], BANK[1]
INCLUDE "src/copy_staged_byte_banks_6_and_4.asm"

SECTION "Nudge camera deltas", ROMX[$4587], BANK[1]
INCLUDE "src/nudge_camera_deltas.asm"

NudgeCameraDeltasEnd:

SECTION "Apply script byte to C12E", ROMX[$45E6], BANK[1]
INCLUDE "src/apply_script_byte_to_c12e.asm"

ApplyScriptByteToC12EEnd:

SECTION "Opcode 03 scroll edge", ROMX[$4617], BANK[1]
INCLUDE "src/opcode_03_continue.asm"

Opcode03ScrollEdgeEnd:

SECTION "Zero script byte SRAM fill", ROMX[$466D], BANK[1]
INCLUDE "src/fill_sram_after_zero_script_byte.asm"

FillSRAMAfterZeroScriptByteEnd:

SECTION "Nonzero script byte SRAM fill", ROMX[$46B2], BANK[1]
INCLUDE "src/fill_sram_after_nonzero_script_byte.asm"

FillSRAMAfterNonzeroScriptByteEnd:

SECTION "Write fifteen window tiles", ROMX[$46CF], BANK[1]
INCLUDE "src/write_fifteen_window_tiles.asm"

WriteFifteenWindowTilesEnd:

SECTION "Copy fifteen window cells", ROMX[$46E1], BANK[1]
INCLUDE "src/copy_fifteen_window_cells.asm"

CopyFifteenCellsHLToBCEnd:

SECTION "Blank two window spans", ROMX[$470F], BANK[1]
INCLUDE "src/blank_two_window_spans.asm"

BlankTwoWindowSpansEnd:

SECTION "Blank window span rows 0 and 2", ROMX[$472A], BANK[1]
INCLUDE "src/blank_window_span_rows_02.asm"

BlankWindowSpanRows02End:

SECTION "Blank window span row 4", ROMX[$4745], BANK[1]
INCLUDE "src/blank_window_span_row4.asm"

BlankWindowSpanRow4End:

SECTION "Blank window corner block", ROMX[$475A], BANK[1]
INCLUDE "src/blank_window_corner_block.asm"

BlankWindowCornerBlockEnd:

SECTION "Immediate return", ROMX[$47B8], BANK[1]
INCLUDE "src/immediate_return.asm"

ImmediateReturnEnd:

SECTION "Blink window cell", ROMX[$47B9], BANK[1]
INCLUDE "src/blink_window_cell.asm"

BlinkWindowCellEnd:

SECTION "Paint toggled window corner", ROMX[$4806], BANK[1]
INCLUDE "src/paint_toggled_window_corner.asm"

PaintToggledWindowCornerEnd:

SECTION "Copy window span row 2 to row 1", ROMX[$4864], BANK[1]
INCLUDE "src/copy_window_span_row2_to_row1.asm"

CopyWindowSpanRow2ToRow1End:

SECTION "Copy window spans up one row", ROMX[$487C], BANK[1]
INCLUDE "src/copy_window_spans_up_one_row.asm"

SECTION "Copy window spans up onto row 1", ROMX[$489D], BANK[1]
INCLUDE "src/copy_window_spans_up_onto_row1.asm"

SECTION "Copy window position", ROMX[$48BE], BANK[1]
INCLUDE "src/copy_window_position.asm"

CopyWindowPositionEnd:

SECTION "Window Y slide table", ROMX[$48D5], BANK[1]
; window_y_slide_table.asm: not published here (it assembles data copied from the ROM)
WindowYSlideTable:
    INCBIN "roms/magination.gbc", $48D5, $A

SECTION "Opcode 9A body", ROMX[$48DF], BANK[1]
INCLUDE "src/opcode_9a_body.asm"

Opcode9ABodyEnd:

SECTION "Opcode 9A countdown", ROMX[$490E], BANK[1]
INCLUDE "src/opcode_9a_countdown.asm"

Opcode9ACountdownEnd:

SECTION "Clear C6EE resume dispatch", ROMX[$495D], BANK[1]
INCLUDE "src/clear_c6ee_resume_dispatch.asm"

ClearC6EEResumeDispatchEnd:

SECTION "Clear script bank bit", ROMX[$4962], BANK[1]
INCLUDE "src/clear_script_bank_bit.asm"

ClearScriptBankBitEnd:

SECTION "Opcode 9D body", ROMX[$4972], BANK[1]
INCLUDE "src/opcode_9d_body.asm"

Opcode9DBodyEnd:

SECTION "Opcode 9D blank spans", ROMX[$49B3], BANK[1]
INCLUDE "src/opcode_9d_blank_spans.asm"

Opcode9DBlankSpansEnd:

SECTION "Retarget window blank", ROMX[$49CD], BANK[1]
INCLUDE "src/retarget_window_blank.asm"

RetargetWindowBlankEnd:

SECTION "Retarget window row 4", ROMX[$49E2], BANK[1]
INCLUDE "src/retarget_window_row4.asm"

RetargetWindowRow4End:

SECTION "Advance window Y slide", ROMX[$49F7], BANK[1]
INCLUDE "src/advance_window_y_slide.asm"

AdvanceWindowYSlideEnd:

SECTION "Restore dispatch script opcode", ROMX[$4A2E], BANK[1]
INCLUDE "src/restore_dispatch_script_opcode.asm"

RestoreDispatchScriptOpcodeEnd:

SECTION "Stage third script from list index", ROMX[$4A3E], BANK[1]
INCLUDE "src/stage_third_script_from_list_index.asm"

StageThirdScriptFromListIndexEnd:

SECTION "Run two scripts from record", ROMX[$4A6B], BANK[1]
INCLUDE "src/run_two_scripts_from_record.asm"

RunTwoScriptsFromRecordEnd:

SECTION "Run two scripts then touch cell", ROMX[$4A8F], BANK[1]
INCLUDE "src/run_two_scripts_then_touch_cell.asm"

RunTwoScriptsThenTouchCellEnd:

SECTION "Clear record head bit 5", ROMX[$4AB6], BANK[1]
INCLUDE "src/clear_record_head_bit5.asm"

ClearRecordHeadBit5End:

SECTION "Mark zero map cell", ROMX[$4AD5], BANK[1]
INCLUDE "src/mark_zero_map_cell.asm"

MarkZeroMapCellEnd:

SECTION "Nudge camera past follow edge", ROMX[$4AF0], BANK[1]
INCLUDE "src/nudge_camera_past_follow_edge.asm"

NudgeCameraPastFollowEdgeEnd:

SECTION "Stamp map cell in WRAM banks", ROMX[$4B2D], BANK[1]
INCLUDE "src/stamp_map_cell_in_wram_banks.asm"

StampMapCellInWramBanksEnd:

SECTION "Save cell below and stage third script", ROMX[$4B61], BANK[1]
INCLUDE "src/save_cell_below_and_stage_third_script.asm"

SaveCellBelowAndStageThirdScriptEnd:

SECTION "Dispatch cell below on button A", ROMX[$4B7B], BANK[1]
INCLUDE "src/dispatch_cell_below_on_button_a.asm"

DispatchCellBelowOnButtonAEnd:

SECTION "Dispatch cell one column left on button A", ROMX[$4BCC], BANK[1]
INCLUDE "src/dispatch_cell_left_on_button_a.asm"

DispatchCellLeftOnButtonAEnd:

SECTION "Dispatch cell one column right on button A", ROMX[$4C1D], BANK[1]
INCLUDE "src/dispatch_cell_right_on_button_a.asm"

DispatchCellRightOnButtonAEnd:

SECTION "Dispatch cell one row up on button A", ROMX[$4C6E], BANK[1]
INCLUDE "src/dispatch_cell_above_on_button_a.asm"

DispatchCellAboveOnButtonAEnd:

SECTION "Point at the map cell one row down", ROMX[$4CBF], BANK[1]
INCLUDE "src/point_at_cell_one_row_down.asm"

PointAtCellOneRowDownEnd:

SECTION "Point at the map cell one column left", ROMX[$4CDD], BANK[1]
INCLUDE "src/point_at_cell_one_column_left.asm"

PointAtCellOneColumnLeftEnd:

SECTION "Point at the map cell one column right", ROMX[$4CF8], BANK[1]
INCLUDE "src/point_at_cell_one_column_right.asm"

PointAtCellOneColumnRightEnd:

SECTION "Point at the map cell one row up", ROMX[$4D13], BANK[1]
INCLUDE "src/point_at_cell_one_row_up.asm"

PointAtCellOneRowUpEnd:

SECTION "Reject far cell and queue sound", ROMX[$4D33], BANK[1]
INCLUDE "src/reject_far_cell_queue_sound.asm"

RejectFarCellQueueSoundEnd:

SECTION "Stamp two-step cells", ROMX[$4D3C], BANK[1]
INCLUDE "src/stamp_two_step_cells.asm"

SECTION "Walk two cells down", ROMX[$4DB4], BANK[1]
INCLUDE "src/walk_two_cells_down.asm"

WalkTwoCellsDownSectionEnd:

SECTION "Walk two cells left", ROMX[$4DFA], BANK[1]
INCLUDE "src/walk_two_cells_left.asm"

WalkTwoCellsLeftSectionEnd:

SECTION "Walk two cells right", ROMX[$4E3A], BANK[1]
INCLUDE "src/walk_two_cells_right.asm"

WalkTwoCellsRightSectionEnd:

SECTION "Walk two cells up", ROMX[$4E7A], BANK[1]
INCLUDE "src/walk_two_cells_up.asm"

WalkTwoCellsUpSectionEnd:

SECTION "Clear $C12A and set $C12C", ROMX[$4EC2], BANK[1]
INCLUDE "src/clear_c12a_set_c12c.asm"

ClearC12AAndSetC12CEnd:

SECTION "Clear $C12C and set $C12A", ROMX[$4ECB], BANK[1]
INCLUDE "src/clear_c12c_set_c12a.asm"

ClearC12CAndSetC12AEnd:

SECTION "Plant past-two cell run script", ROMX[$4ED4], BANK[1]
INCLUDE "src/plant_past_two_cell_run_script.asm"

PlantPastTwoCellRunScriptEnd:

SECTION "Reload then plant script on down pressed", ROMX[$4EEF], BANK[1]
INCLUDE "src/reload_then_plant_script_on_down.asm"

ReloadThenPlantScriptOnDownPressedEnd:

SECTION "Plant script on down pressed", ROMX[$4EF2], BANK[1]
INCLUDE "src/plant_script_on_down_pressed.asm"

PlantScriptOnDownPressedEnd:

SECTION "Resume head $03 record", ROMX[$4F0D], BANK[1]
INCLUDE "src/resume_head03_record.asm"

ResumeHead03RecordEnd:

SECTION "Resume head $01 record", ROMX[$4FB7], BANK[1]
INCLUDE "src/resume_head01_record.asm"

ResumeHead01RecordEnd:

SECTION "Plant script on other left cell", ROMX[$5015], BANK[1]
INCLUDE "src/plant_script_on_other_left_cell.asm"

PlantScriptOnOtherLeftCellEnd:

SECTION "Plant right past-two cell run script", ROMX[$5028], BANK[1]
INCLUDE "src/plant_right_past_two_cell_run_script.asm"

PlantRightPastTwoCellRunScriptEnd:

SECTION "Reload then plant right pressed head 01", ROMX[$5043], BANK[1]
INCLUDE "src/reload_then_plant_right_pressed_head01.asm"

ReloadThenPlantRightPressedHead01End:

SECTION "Plant right pressed head 01 script", ROMX[$5046], BANK[1]
INCLUDE "src/plant_right_pressed_head01_script.asm"

PlantRightPressedHead01ScriptEnd:

SECTION "Resume head $02 record", ROMX[$5061], BANK[1]
INCLUDE "src/resume_head02_record.asm"

ResumeHead02RecordEnd:

SECTION "Plant other right-cell script", ROMX[$50BF], BANK[1]
INCLUDE "src/plant_other_right_cell_script.asm"

PlantOtherRightCellScriptEnd:

SECTION "Plant bit6 past-two cell run script", ROMX[$50D2], BANK[1]
INCLUDE "src/plant_bit6_past_two_cell_run_script.asm"

PlantBit6PastTwoCellRunScriptEnd:

SECTION "Reload then plant script on up pressed", ROMX[$50ED], BANK[1]
INCLUDE "src/reload_then_plant_script_on_up.asm"

ReloadThenPlantScriptOnUpPressedEnd:

SECTION "Plant script on up pressed", ROMX[$50F0], BANK[1]
INCLUDE "src/plant_script_on_up_pressed.asm"

PlantScriptOnUpPressedEnd:

SECTION "Resume head $00 record", ROMX[$510B], BANK[1]
INCLUDE "src/resume_head00_record.asm"

ResumeHead00RecordEnd:

SECTION "Count cell run", ROMX[$517C], BANK[1]
INCLUDE "src/count_cell_run.asm"

CountCellRunEnd:

SECTION "Dispatch zero step cell run", ROMX[$51B6], BANK[1]
INCLUDE "src/dispatch_zero_step_cell_run.asm"

DispatchZeroStepCellRunEnd:

SECTION "Plant script on one cell run", ROMX[$51D8], BANK[1]
INCLUDE "src/plant_script_on_one_cell_run.asm"

PlantScriptOnOneCellRunEnd:

SECTION "Plant script on two cell run", ROMX[$51E5], BANK[1]
INCLUDE "src/plant_script_on_two_cell_run.asm"

PlantScriptOnTwoCellRunEnd:

SECTION "Dispatch left zero X step cell run", ROMX[$51F2], BANK[1]
INCLUDE "src/dispatch_left_zero_x_step_cell_run.asm"

DispatchLeftZeroXStepCellRunEnd:

SECTION "Plant script on left one cell run", ROMX[$5214], BANK[1]
INCLUDE "src/plant_script_on_left_one_cell_run.asm"

PlantScriptOnLeftOneCellRunEnd:

SECTION "Plant script on left two cell run", ROMX[$5221], BANK[1]
INCLUDE "src/plant_script_on_left_two_cell_run.asm"

PlantScriptOnLeftTwoCellRunEnd:

SECTION "Dispatch zero X step cell run", ROMX[$522E], BANK[1]
INCLUDE "src/dispatch_zero_x_step_cell_run.asm"

DispatchZeroXStepCellRunEnd:

SECTION "Plant script on X step one cell run", ROMX[$5250], BANK[1]
INCLUDE "src/plant_script_on_x_step_one_cell_run.asm"

PlantScriptOnXStepOneCellRunEnd:

SECTION "Plant script on X step two cell run", ROMX[$525D], BANK[1]
INCLUDE "src/plant_script_on_x_step_two_cell_run.asm"

PlantScriptOnXStepTwoCellRunEnd:

SECTION "Dispatch bit6 zero-step cell run", ROMX[$526A], BANK[1]
INCLUDE "src/dispatch_bit6_zero_step_cell_run.asm"

DispatchBit6ZeroStepCellRunEnd:

SECTION "Plant script on bit6 one cell run", ROMX[$528C], BANK[1]
INCLUDE "src/plant_script_on_bit6_one_cell_run.asm"

PlantScriptOnBit6OneCellRunEnd:

SECTION "Plant script on bit6 two cell run", ROMX[$5299], BANK[1]
INCLUDE "src/plant_script_on_bit6_two_cell_run.asm"

PlantScriptOnBit6TwoCellRunEnd:

SECTION "Plant script on Y step bit 1 set", ROMX[$52A6], BANK[1]
INCLUDE "src/plant_script_on_y_step_bit1_set.asm"

PlantScriptOnYStepBit1SetEnd:

SECTION "Resume Y step bit 1 set record", ROMX[$52C5], BANK[1]
INCLUDE "src/resume_y_step_bit1_set_record.asm"

ResumeYStepBit1SetRecordEnd:

SECTION "Finish Y step after camera nudge", ROMX[$52EE], BANK[1]
INCLUDE "src/finish_y_step_after_camera_nudge.asm"

FinishYStepAfterCameraNudgeEnd:

SECTION "Nonzero Y step after camera nudge", ROMX[$5305], BANK[1]
INCLUDE "src/on_nonzero_y_step_after_nudge.asm"

OnNonzeroYStepAfterNudgeEnd:

SECTION "Plant script on left while down bit 1", ROMX[$5313], BANK[1]
INCLUDE "src/plant_script_on_left_while_down_bit1.asm"

PlantScriptOnLeftWhileDownBit1End:

SECTION "Resume left while down bit 1 record", ROMX[$5332], BANK[1]
INCLUDE "src/resume_left_while_down_bit1_record.asm"

ResumeLeftWhileDownBit1RecordEnd:

SECTION "Plant script on right while down bit 1", ROMX[$53A5], BANK[1]
INCLUDE "src/plant_script_on_right_while_down_bit1.asm"

PlantScriptOnRightWhileDownBit1End:

SECTION "Reload then test right held", ROMX[$53C4], BANK[1]
INCLUDE "src/reload_then_test_right_held.asm"

ReloadThenTestRightHeldEnd:

SECTION "Right held from bit 4", ROMX[$53CC], BANK[1]
INCLUDE "src/right_held_from_bit4.asm"

RightHeldFromBit4End:

SECTION "Plant script on up-only bit 1", ROMX[$5437], BANK[1]
INCLUDE "src/plant_script_on_up_only_bit1.asm"

PlantScriptOnUpOnlyBit1End:

SECTION "Resume up-only bit 1 record", ROMX[$5456], BANK[1]
INCLUDE "src/resume_up_only_bit1_record.asm"

ResumeUpOnlyBit1RecordEnd:

SECTION "Plant script when Y step bit 1 is clear", ROMX[$54A4], BANK[1]
INCLUDE "src/plant_script_on_y_step_bit1_clear.asm"

PlantScriptOnYStepBit1ClearEnd:

SECTION "Resume Y step bit 1 clear record", ROMX[$54C3], BANK[1]
INCLUDE "src/resume_y_step_bit1_clear_record.asm"

ResumeYStepBit1ClearRecordEnd:

SECTION "Plant script when left is held with down", ROMX[$5515], BANK[1]
INCLUDE "src/plant_script_on_left_while_down.asm"

PlantScriptOnLeftWhileDownEnd:

SECTION "Resume left while down record", ROMX[$5534], BANK[1]
INCLUDE "src/resume_left_while_down_record.asm"

ResumeLeftWhileDownRecordEnd:

SECTION "Plant script when right is held with down", ROMX[$55AE], BANK[1]
INCLUDE "src/plant_script_on_right_while_down.asm"

PlantScriptOnRightWhileDownEnd:

SECTION "Resume right while down record", ROMX[$55CD], BANK[1]
INCLUDE "src/resume_right_while_down_record.asm"

ResumeRightWhileDownRecordEnd:

SECTION "Plant handler script $B3", ROMX[$5647], BANK[1]
INCLUDE "src/plant_handler_script_b3.asm"

PlantHandlerScriptB3End:

SECTION "Plant script low byte from A", ROMX[$5655], BANK[1]
INCLUDE "src/plant_script_low_from_a.asm"

PlantScriptLowFromAEnd:

SECTION "Resume script-low record", ROMX[$5666], BANK[1]
INCLUDE "src/resume_script_low_from_a_record.asm"

ResumeScriptLowFromARecordEnd:

SECTION "Clear $C12A and set $C12B", ROMX[$56B7], BANK[1]
INCLUDE "src/clear_c12a_set_c12b.asm"

ClearC12AAndSetC12BEnd:

SECTION "Set $C12A and clear $C12B", ROMX[$56C0], BANK[1]
INCLUDE "src/set_c12a_clear_c12b.asm"

SetC12AAndClearC12BEnd:

SECTION "Plant handler when up is clear", ROMX[$56C9], BANK[1]
INCLUDE "src/plant_handler_when_up_clear.asm"

PlantHandlerWhenUpClearEnd:

SECTION "Resume up-clear record head", ROMX[$56DC], BANK[1]
INCLUDE "src/resume_up_clear_record_head.asm"

ResumeUpClearRecordHeadEnd:

SECTION "Stage idle script unless up or down", ROMX[$56EF], BANK[1]
INCLUDE "src/stage_idle_script_unless_up_or_down.asm"

StageIdleScriptUnlessUpOrDownEnd:

SECTION "Plant $59A8 when cell is $01", ROMX[$570D], BANK[1]
INCLUDE "src/plant_59a8_when_cell_is_01.asm"

Plant59A8WhenCellIs01End:

SECTION "Plant $58F5 when cell is $01", ROMX[$5728], BANK[1]
INCLUDE "src/plant_58f5_when_cell_is_01.asm"

Plant58F5WhenCellIs01End:

SECTION "Plant $592F when cell is $01", ROMX[$5743], BANK[1]
INCLUDE "src/plant_592f_when_cell_is_01.asm"

Plant592FWhenCellIs01End:

SECTION "Plant $5969 when cell is $01", ROMX[$575E], BANK[1]
INCLUDE "src/plant_5969_when_cell_is_01.asm"

Plant5969WhenCellIs01End:

SECTION "Plant down idle script", ROMX[$5779], BANK[1]
INCLUDE "src/plant_down_idle_script.asm"

PlantDownIdleScriptEnd:

SECTION "Resume down record head", ROMX[$5798], BANK[1]
INCLUDE "src/resume_down_record_head.asm"

ResumeDownRecordHeadEnd:

SECTION "Plant left record head", ROMX[$57F9], BANK[1]
INCLUDE "src/plant_left_record_head.asm"

PlantLeftRecordHeadEnd:

SECTION "Resume left record head", ROMX[$5818], BANK[1]
INCLUDE "src/resume_left_record_head.asm"

ResumeLeftRecordHeadEnd:

SECTION "Plant right record head", ROMX[$5888], BANK[1]
INCLUDE "src/plant_right_record_head.asm"

PlantRightRecordHeadEnd:

SECTION "Resume right record head", ROMX[$58A7], BANK[1]
INCLUDE "src/resume_right_record_head.asm"

ResumeRightRecordHeadEnd:

SECTION "Plant up idle script", ROMX[$5917], BANK[1]
INCLUDE "src/plant_up_idle_script.asm"

PlantUpIdleScriptEnd:

SECTION "Resume up idle record", ROMX[$5936], BANK[1]
INCLUDE "src/resume_up_idle_record.asm"

ResumeUpIdleRecordEnd:

SECTION "Plant down from direction record", ROMX[$5996], BANK[1]
INCLUDE "src/plant_down_from_direction_record.asm"

PlantDownFromDirectionRecordEnd:

SECTION "Resume down held record", ROMX[$59B5], BANK[1]
INCLUDE "src/resume_down_held_record.asm"

ResumeDownHeldRecordEnd:

SECTION "Down held left or right", ROMX[$59C9], BANK[1]
INCLUDE "src/down_held_left_or_right.asm"

DownHeldLeftOrRightEnd:

SECTION "Left zero cell script", ROMX[$59E7], BANK[1]
INCLUDE "src/run_left_zero_cell_script.asm"

RunLeftZeroCellScriptEnd:

SECTION "Plant left from direction record", ROMX[$59F3], BANK[1]
INCLUDE "src/plant_left_from_direction_record.asm"

PlantLeftFromDirectionRecordEnd:

SECTION "Resume left held record", ROMX[$5A12], BANK[1]
INCLUDE "src/resume_left_held_record.asm"

ResumeLeftHeldRecordEnd:

SECTION "Plant right from direction record", ROMX[$5A55], BANK[1]
INCLUDE "src/plant_right_from_direction_record.asm"

PlantRightFromDirectionRecordEnd:

SECTION "Resume right held record", ROMX[$5A74], BANK[1]
INCLUDE "src/resume_right_held_record.asm"

ResumeRightHeldRecordEnd:

SECTION "Plant up from direction record", ROMX[$5AB7], BANK[1]
INCLUDE "src/plant_up_from_direction_record.asm"

PlantUpFromDirectionRecordEnd:

SECTION "Resume up held record", ROMX[$5AD6], BANK[1]
INCLUDE "src/resume_up_held_record.asm"

ResumeUpHeldRecordEnd:

SECTION "Plant direction dispatch head", ROMX[$5B13], BANK[1]
INCLUDE "src/plant_direction_dispatch_head.asm"

PlantDirectionDispatchHeadEnd:

SECTION "Resume direction dispatch head", ROMX[$5B1E], BANK[1]
INCLUDE "src/resume_direction_dispatch_head.asm"

ResumeDirectionDispatchHeadEnd:

SECTION "Select SRAM bank then down mark", ROMX[$5B41], BANK[1]
; select_sram_bank_then_down_mark.asm: not published here (it assembles data copied from the ROM)
SelectSRAMBankThenDownMark:
    INCBIN "roms/magination.gbc", $5B41, $B

SelectSRAMBankThenDownMarkEnd:

SECTION "Copy SRAM mark then resume down", ROMX[$5B4C], BANK[1]
INCLUDE "src/copy_sram_mark_then_resume_down.asm"

CopySRAMMarkThenResumeDownEnd:

SECTION "Plant down bit 7 clear head", ROMX[$5B5B], BANK[1]
INCLUDE "src/plant_down_bit7_clear_head.asm"

PlantDownBit7ClearHeadEnd:

SECTION "Resume down clear head", ROMX[$5B6E], BANK[1]
INCLUDE "src/resume_down_clear_head.asm"

ResumeDownClearHeadEnd:

SECTION "Resume right script on A", ROMX[$5B9C], BANK[1]
INCLUDE "src/resume_right_script_on_a.asm"

ResumeRightScriptOnAEnd:

SECTION "Dispatch record head on A", ROMX[$5BA7], BANK[1]
INCLUDE "src/dispatch_record_head_on_a.asm"

DispatchRecordHeadOnAEnd:

SECTION "Plant down record and bank", ROMX[$5BC8], BANK[1]
INCLUDE "src/plant_down_record_and_bank.asm"

PlantDownRecordAndBankEnd:

SECTION "Resume down bit 7 record", ROMX[$5BEB], BANK[1]
INCLUDE "src/resume_down_bit7_record.asm"

ResumeDownBit7RecordEnd:

SECTION "Resume down held direction", ROMX[$5C06], BANK[1]
INCLUDE "src/resume_down_held_direction.asm"

ResumeDownHeldDirectionEnd:

SECTION "Plant left record and script bank", ROMX[$5C2F], BANK[1]
INCLUDE "src/plant_left_record_and_bank.asm"

PlantLeftRecordAndBankEnd:

SECTION "Resume left planted record", ROMX[$5C52], BANK[1]
INCLUDE "src/resume_left_planted_record.asm"

ResumeLeftPlantedRecordEnd:

SECTION "Plant right record and script bank", ROMX[$5CA5], BANK[1]
INCLUDE "src/plant_right_record_and_bank.asm"

PlantRightRecordAndBankEnd:

SECTION "Resume right bit 4 record", ROMX[$5CC8], BANK[1]
INCLUDE "src/resume_right_bit4_record.asm"

ResumeRightBit4RecordEnd:

SECTION "Head 01 script skip to step", ROMX[$5CF5], BANK[1]
INCLUDE "src/head01_script_skip_to_step.asm"

Head01ScriptSkipToStepEnd:

SECTION "Plant up held record", ROMX[$5D1B], BANK[1]
; plant_up_held_record.asm: not published here (it assembles data copied from the ROM)
PlantUpHeldRecord:
    INCBIN "roms/magination.gbc", $5D1B, $13

PlantUpHeldRecordEnd:

SECTION "Plant left script high and head", ROMX[$5D2E], BANK[1]
INCLUDE "src/plant_left_script_high_and_head.asm"

PlantLeftScriptHighAndHeadEnd:

SECTION "Resume other left cell script", ROMX[$5D3E], BANK[1]
INCLUDE "src/resume_other_left_cell_script.asm"

ResumeOtherLeftCellScriptEnd:

SECTION "Copy SRAM mark then head 5E10", ROMX[$5D81], BANK[1]
INCLUDE "src/copy_sram_mark_then_head_5e10.asm"

CopySRAMMarkThenHead5E10End:

SECTION "Commit script and record head", ROMX[$5D9B], BANK[1]
INCLUDE "src/commit_script_and_record_head.asm"

CommitScriptRecordEnd:

SECTION "Plant handler and head word", ROMX[$5DA2], BANK[1]
INCLUDE "src/plant_handler_and_head_word.asm"

PlantHandlerAndHeadWordEnd:

SECTION "Run head word script", ROMX[$5DB5], BANK[1]
INCLUDE "src/run_head_word_script.asm"

RunHeadWordScriptEnd:

SECTION "Reload record, run script, point cell", ROMX[$5DE1], BANK[1]
INCLUDE "src/reload_record_run_script_point_cell.asm"

ReloadRecordRunScriptPointCellEnd:

SECTION "Plant down-clear record head", ROMX[$5DFD], BANK[1]
INCLUDE "src/plant_down_clear_record_head.asm"

PlantDownClearRecordHeadEnd:

SECTION "Dispatch held direction from head", ROMX[$5E10], BANK[1]
INCLUDE "src/dispatch_held_direction_from_head.asm"

DispatchHeldDirectionFromHeadEnd:

SECTION "Dispatch record head if A pressed", ROMX[$5E3E], BANK[1]
INCLUDE "src/dispatch_record_head_if_a_pressed.asm"

DispatchRecordHeadIfAPressedEnd:

SECTION "Add cell direction step", ROMX[$5E65], BANK[1]
INCLUDE "src/add_cell_direction_step.asm"

AddCellDirectionStepEnd:

SECTION "Copy far stamp into record", ROMX[$5ED2], BANK[1]
INCLUDE "src/copy_far_stamp_into_record.asm"

CopyFarStampIntoRecordEnd:

SECTION "Run two scripts then store screen Y", ROMX[$5F04], BANK[1]
INCLUDE "src/run_two_scripts_then_store_screen_y.asm"

RunTwoScriptsThenStoreScreenYEnd:

SECTION "Run record script twice", ROMX[$5F0C], BANK[1]
INCLUDE "src/run_record_script_twice.asm"

RunRecordScriptTwiceEnd:

SECTION "Plant bank 22 script on zero byte", ROMX[$5F25], BANK[1]
INCLUDE "src/plant_bank22_script_on_zero_byte.asm"

PlantBank22ScriptOnZeroByteEnd:

SECTION "Plant down record head 5F85", ROMX[$5F66], BANK[1]
INCLUDE "src/plant_down_record_head_5f85.asm"

SECTION "Resume planted down record", ROMX[$5F85], BANK[1]
INCLUDE "src/resume_planted_down_record.asm"

SECTION "Down held from planted record", ROMX[$5F93], BANK[1]
INCLUDE "src/down_held_from_planted_record.asm"

SECTION "Plant left while down record", ROMX[$5FC4], BANK[1]
INCLUDE "src/plant_left_while_down_record.asm"

SECTION "Resume planted left while down", ROMX[$5FE3], BANK[1]
INCLUDE "src/resume_planted_left_while_down.asm"

SECTION "Facing left from planted head", ROMX[$601E], BANK[1]
INCLUDE "src/facing_left_from_planted_head.asm"

SECTION "Plant right while down record", ROMX[$6027], BANK[1]
INCLUDE "src/plant_right_while_down_record.asm"

SECTION "Resume planted right while down", ROMX[$6046], BANK[1]
INCLUDE "src/resume_planted_right_while_down.asm"

SECTION "Facing right from planted head", ROMX[$6081], BANK[1]
INCLUDE "src/facing_right_from_planted_head.asm"

SECTION "Plant up from planted head", ROMX[$608A], BANK[1]
INCLUDE "src/plant_up_from_planted_head.asm"

SECTION "Resume planted head 60A9", ROMX[$60A9], BANK[1]
INCLUDE "src/resume_planted_head_60a9.asm"

SECTION "Facing up from resume 60DE", ROMX[$60DE], BANK[1]
INCLUDE "src/facing_up_from_resume_60de.asm"

FacingUpFromResume60DESectionEnd:

SECTION "Clear C12B and set C12A to 01", ROMX[$60E7], BANK[1]
INCLUDE "src/clear_c12b_set_c12a_01.asm"

SECTION "Plant head word 60FD", ROMX[$60F2], BANK[1]
INCLUDE "src/plant_head_word_60fd.asm"

SECTION "Resume planted head 60FD", ROMX[$60FD], BANK[1]
INCLUDE "src/resume_planted_head_60fd.asm"

SECTION "Copy SRAM mark then head 6167", ROMX[$613A], BANK[1]
INCLUDE "src/copy_sram_mark_then_head_6167.asm"

SECTION "Plant handler and head 6167", ROMX[$6154], BANK[1]
INCLUDE "src/plant_handler_and_head_6167.asm"

SECTION "Resume planted head 6167", ROMX[$6167], BANK[1]
INCLUDE "src/resume_planted_head_6167.asm"

SECTION "Dispatch pressed A on facing cell", ROMX[$619A], BANK[1]
INCLUDE "src/dispatch_pressed_a_on_facing_cell.asm"

SECTION "Return at 61BA", ROMX[$61BA], BANK[1]
INCLUDE "src/return_at_61ba.asm"

SECTION "Plant down record head 61DE", ROMX[$61BB], BANK[1]
INCLUDE "src/plant_down_record_head_61de.asm"

SECTION "Resume planted head 61DE", ROMX[$61DE], BANK[1]
INCLUDE "src/resume_planted_head_61de.asm"

SECTION "Plant left while up record", ROMX[$621C], BANK[1]
INCLUDE "src/plant_left_while_up_record.asm"

SECTION "Resume planted left while up record", ROMX[$623F], BANK[1]
INCLUDE "src/resume_planted_left_while_up_record.asm"

SECTION "Plant right while up record", ROMX[$628C], BANK[1]
INCLUDE "src/plant_right_while_up_record.asm"

SECTION "Resume planted right while up", ROMX[$62AF], BANK[1]
INCLUDE "src/resume_planted_right_while_up.asm"

SECTION "Store vertical step then right cell", ROMX[$62D2], BANK[1]
INCLUDE "src/store_vertical_step_then_right_cell.asm"

SECTION "Plant up record and bank", ROMX[$62FC], BANK[1]
INCLUDE "src/plant_up_record_and_bank.asm"

SECTION "Resume planted up record", ROMX[$631F], BANK[1]
INCLUDE "src/resume_planted_up_record.asm"

SECTION "Run two scripts then replace head word", ROMX[$635C], BANK[1]
INCLUDE "src/run_two_scripts_then_replace_head_word.asm"

RunTwoScriptsThenReplaceHeadWordEnd:

SECTION "rDIV map cell table", ROMX[$638E], BANK[1]
; rdiv_map_cell_table.asm: not published here (it assembles data copied from the ROM)
RdivHighNibbleColumnAdds:
    INCBIN "roms/magination.gbc", $638E, $10

SECTION "rDIV map cell table @$00639E", ROMX[$639E], BANK[1]
RdivLowNibbleRowRecords:
    INCBIN "roms/magination.gbc", $639E, $30

SECTION "Run one script then write head", ROMX[$63CE], BANK[1]
INCLUDE "src/run_one_script_then_write_head.asm"

SECTION "Run two scripts then nudge camera", ROMX[$63E6], BANK[1]
INCLUDE "src/run_two_scripts_then_nudge_camera.asm"

SECTION "Stage scratch then plant head word 64D1", ROMX[$63ED], BANK[1]
INCLUDE "src/stage_scratch_then_plant_head_word_64d1.asm"

SECTION "Plant head word 64D1", ROMX[$6405], BANK[1]
INCLUDE "src/plant_head_word_64d1.asm"

PlantHeadWord64D1End:

SECTION "Gate cell near first record", ROMX[$641D], BANK[1]
INCLUDE "src/gate_cell_near_first_record.asm"

GateCellNearFirstRecordEnd:

SECTION "Run tail script then plant two scripts", ROMX[$64D1], BANK[1]
INCLUDE "src/run_tail_script_then_plant_two_scripts.asm"

RunTailScriptThenPlantTwoScriptsEnd:

SECTION "Fill first record script slots", ROMX[$651A], BANK[1]
INCLUDE "src/fill_first_record_script_slots.asm"

FillFirstRecordScriptSlotsEnd:

SECTION "Call bank 4 then plant head 659D", ROMX[$6586], BANK[1]
INCLUDE "src/call_bank4_then_plant_head_659d.asm"

CallBank4ThenPlantHead659DEnd:

SECTION "Reload record head", ROMX[$659D], BANK[1]
INCLUDE "src/reload_record_head.asm"

ReloadRecordHeadEnd:

SECTION "Plant tail script head when cell matches", ROMX[$65A4], BANK[1]
INCLUDE "src/plant_tail_script_head_when_cell_matches.asm"

PlantTailScriptHeadWhenCellMatchesEnd:

SECTION "Run two scripts then save step and mark bit 1", ROMX[$65D7], BANK[1]
INCLUDE "src/run_two_scripts_then_save_step_and_mark_bit1.asm"

RunTwoScriptsThenSaveStepAndMarkBit1End:

SECTION "Nop pad from $6600", ROMX[$6600], BANK[1]
INCLUDE "src/nop_pad_6600.asm"

NopPad6600End:

SECTION "Nop pad from $66D2", ROMX[$66D2], BANK[1]
INCLUDE "src/nop_pad_66d2.asm"

NopPad66D2End:

SECTION "Bank 1 padding at $6AD2", ROMX[$6AD2], BANK[1]
INCLUDE "src/bank1_padding_6ad2.asm"

Bank1Padding6AD2End:

SECTION "Nop pad from $6ED2", ROMX[$6ED2], BANK[1]
INCLUDE "src/nop_pad_6ed2.asm"

NopPad6ED2End:

SECTION "Bank 1 padding at $72D2", ROMX[$72D2], BANK[1]
INCLUDE "src/bank1_padding_72d2.asm"

Bank1Padding72D2End:

SECTION "Nop pad from $76D2", ROMX[$76D2], BANK[1]
INCLUDE "src/nop_pad_76d2.asm"

NopPad76D2End:

SECTION "Nop pad from $7AD2", ROMX[$7AD2], BANK[1]
INCLUDE "src/nop_pad_7ad2.asm"

NopPad7AD2End:

SECTION "Nop pad from $7ED2", ROMX[$7ED2], BANK[1]
INCLUDE "src/nop_pad_7ed2.asm"

NopPad7ED2End:

SECTION "D0E span pairs", ROMX[$4000], BANK[2]
; d0e_span_pairs.asm: not published here (it assembles data copied from the ROM)
D0ESpanPairs:
    INCBIN "roms/magination.gbc", $8000, $40

D0ESpanPairsEnd:

SECTION "D0E span pairs from $20", ROMX[$4040], BANK[2]
; d0e_span_pairs_20.asm: not published here (it assembles data copied from the ROM)
D0ESpanPairs20:
    INCBIN "roms/magination.gbc", $8040, $40

D0ESpanPairs20End:

SECTION "D0E span pairs from $40", ROMX[$4080], BANK[2]
; d0e_span_pairs_40.asm: not published here (it assembles data copied from the ROM)
D0ESpanPairs40:
    INCBIN "roms/magination.gbc", $8080, $40

D0ESpanPairs40End:

SECTION "D0E span pairs from $60", ROMX[$40C0], BANK[2]
; d0e_span_pairs_60.asm: not published here (it assembles data copied from the ROM)
D0ESpanPairs60:
    INCBIN "roms/magination.gbc", $80C0, $40

D0ESpanPairs60End:

SECTION "D0E span pairs from $80", ROMX[$4100], BANK[2]
; d0e_span_pairs_80.asm: not published here (it assembles data copied from the ROM)
D0ESpanPairs80:
    INCBIN "roms/magination.gbc", $8100, $40

D0ESpanPairs80End:

SECTION "Finish low D103 refresh", ROMX[$4140], BANK[2]
INCLUDE "src/finish_low_d103_refresh.asm"

FinishLowD103RefreshEnd:

SECTION "Plant script 47FD", ROMX[$4540], BANK[2]
INCLUDE "src/plant_script_47fd.asm"

PlantScript47FDEnd:

SECTION "Finish D073 slot 7058", ROMX[$455C], BANK[2]
INCLUDE "src/finish_d073_slot_7058.asm"

FinishD073Slot7058End:

SECTION "Join 459B if D071 is two", ROMX[$458C], BANK[2]
INCLUDE "src/join_459b_if_d071_is_two.asm"

Join459BIfD071IsTwoEnd:

SECTION "Continue after C71B plant", ROMX[$4593], BANK[2]
INCLUDE "src/continue_after_c71b_plant.asm"

ContinueAfterC71BPlantEnd:

SECTION "Try set bit pair at plus 14", ROMX[$463F], BANK[2]
INCLUDE "src/try_set_bit_pair_at_plus14.asm"

TrySetBitPairAtPlus14End:

SECTION "Fill D110 from indexed entry", ROMX[$4653], BANK[2]
INCLUDE "src/fill_d110_from_indexed_entry.asm"

FillD110FromIndexedEntryEnd:

SECTION "Stage name text and script 41C1", ROMX[$46F4], BANK[2]
INCLUDE "src/stage_name_text_and_script_41c1.asm"

StageNameTextAndScript41C1End:

SECTION "Stage pointer unless D0B6 matches", ROMX[$472E], BANK[2]
INCLUDE "src/stage_pointer_unless_d0b6_matches.asm"

StagePointerUnlessD0B6MatchesEnd:

SECTION "Run 560E then wait C71D", ROMX[$477E], BANK[2]
INCLUDE "src/run_560e_then_wait_c71d.asm"

Run560EThenWaitC71DEnd:

SECTION "Copy 7646 into next SRAM bank", ROMX[$4799], BANK[2]
INCLUDE "src/copy_7646_into_next_sram_bank.asm"

Copy7646IntoNextSRAMBankEnd:

SECTION "Stage 4C 5A32 unless zero", ROMX[$47D0], BANK[2]
INCLUDE "src/stage_4c_5a32_unless_zero.asm"

Stage4C5A32UnlessZeroEnd:

SECTION "Stage 4C 4EE1 unless zero", ROMX[$47DA], BANK[2]
INCLUDE "src/stage_4c_4ee1_unless_zero.asm"

Stage4C4EE1UnlessZeroEnd:

SECTION "Stage 4C 57D0 unless zero", ROMX[$47E4], BANK[2]
INCLUDE "src/stage_4c_57d0_unless_zero.asm"

Stage4C57D0UnlessZeroEnd:

SECTION "Stage 4C 53B3 unless zero", ROMX[$47EE], BANK[2]
INCLUDE "src/stage_4c_53b3_unless_zero.asm"

Stage4C53B3UnlessZeroEnd:

SECTION "Stage 4C 4F18 unless zero", ROMX[$47F8], BANK[2]
INCLUDE "src/stage_4c_4f18_unless_zero.asm"

Stage4C4F18UnlessZeroEnd:

SECTION "Set D071 two cap D11C script 490B", ROMX[$4802], BANK[2]
INCLUDE "src/set_d071_two_cap_d11c_script_490b.asm"

SetD071TwoCapD11CThenScript490BEnd:

SECTION "Stage 5640 then bank 5 if accum below 40", ROMX[$4838], BANK[2]
INCLUDE "src/stage_5640_then_bank5_if_accum_below_40.asm"

Stage5640ThenBank5IfAccumBelow40End:

SECTION "Set D071 two mark bit 10", ROMX[$4850], BANK[2]
INCLUDE "src/set_d071_two_mark_bit10.asm"

SetD071TwoMarkBit10End:

SECTION "Stage 4C 4E80 unless zero at 4865", ROMX[$4865], BANK[2]
INCLUDE "src/stage_4c_4e80_unless_zero_4865.asm"

Stage4C4E80UnlessZeroAt4865End:

SECTION "Set D071 two cap D11C script 490B at 486F", ROMX[$486F], BANK[2]
INCLUDE "src/set_d071_two_cap_d11c_script_490b_486f.asm"

SetD071TwoCapD11CThenScript490BAt486FEnd:

SECTION "Stage 4DC6 floor D11C script 45F5 at 48A5", ROMX[$48A5], BANK[2]
INCLUDE "src/stage_4dc6_floor_d11c_script_45f5_48a5.asm"

Stage4DC6FloorD11CScript45F5At48A5End:

SECTION "Stage 4C 4D87 unless zero at 48E3", ROMX[$48E3], BANK[2]
INCLUDE "src/stage_4c_4d87_unless_zero_at_48e3.asm"

Stage4C4D87UnlessZeroAt48E3End:

SECTION "Set D071 two stage 5320 floor D11D script 460D", ROMX[$48ED], BANK[2]
INCLUDE "src/set_d071_two_stage_5320_floor_d11d_script_460d.asm"

SetD071TwoStage5320FloorD11DScript460DEnd:

SECTION "Stage 4C 4E80 store 10s then bank 5", ROMX[$4929], BANK[2]
INCLUDE "src/stage_4c_4e80_store_10s_then_bank5.asm"

Stage4C4E80Store10sThenBank5End:

SECTION "Stage 4C 5698 unless zero at 4951", ROMX[$4951], BANK[2]
INCLUDE "src/stage_4c_5698_unless_zero_at_4951.asm"

Stage4C5698UnlessZeroAt4951End:

SECTION "Stage 4C 596F then bank 5 if accum below 40", ROMX[$495B], BANK[2]
INCLUDE "src/stage_4c_596f_then_bank5_if_accum_below_40.asm"

Stage4C596FThenBank5IfAccumBelow40End:

SECTION "Stage 4C 505A unless zero at 4973", ROMX[$4973], BANK[2]
INCLUDE "src/stage_4c_505a_unless_zero_at_4973.asm"

Stage4C505AUnlessZeroAt4973End:

SECTION "Stage 4C 51D0 then bank 5 if accum below 40", ROMX[$497D], BANK[2]
INCLUDE "src/stage_4c_51d0_then_bank5_if_accum_below_40.asm"

Stage4C51D0ThenBank5IfAccumBelow40End:

SECTION "Stage 4C 56D6 unless zero at 4995", ROMX[$4995], BANK[2]
INCLUDE "src/stage_4c_56d6_unless_zero_at_4995.asm"

Stage4C56D6UnlessZeroAt4995End:

SECTION "Set D071 two stage 5B77 bit 40 name text", ROMX[$499F], BANK[2]
INCLUDE "src/set_d071_two_stage_5b77_bit40_name_text.asm"

SetD071TwoStage5B77Bit40NameTextEnd:

SECTION "Stage 4C 53B3 unless zero at 49BC", ROMX[$49BC], BANK[2]
INCLUDE "src/stage_4c_53b3_unless_zero_at_49bc.asm"

Stage4C53B3UnlessZeroAt49BCEnd:

SECTION "Stage 4C 4E80 then bank 5 if accum below 40", ROMX[$49C6], BANK[2]
INCLUDE "src/stage_4c_4e80_then_bank5_if_accum_below_40.asm"

Stage4C4E80ThenBank5IfAccumBelow40End:

SECTION "Set D071 two scaled DIV name count", ROMX[$49DE], BANK[2]
INCLUDE "src/set_d071_two_scaled_div_name_count.asm"

SetD071TwoScaledDivNameCountEnd:

SECTION "Stage 4C 4FD5 then bank 5 if accum below 40", ROMX[$49F7], BANK[2]
INCLUDE "src/stage_4c_4fd5_then_bank5_if_accum_below_40.asm"

Stage4C4FD5ThenBank5IfAccumBelow40End:

SECTION "Stage 4C 57D0 unless zero at 4A0F", ROMX[$4A0F], BANK[2]
INCLUDE "src/stage_4c_57d0_unless_zero_at_4a0f.asm"

Stage4C57D0UnlessZeroAt4A0FEnd:

SECTION "Stage 4C 4F18 unless zero at 4A19", ROMX[$4A19], BANK[2]
INCLUDE "src/stage_4c_4f18_unless_zero_at_4a19.asm"

Stage4C4F18UnlessZeroAt4A19End:

SECTION "Set D071 two stage 4D5C bit 40 name text", ROMX[$4A23], BANK[2]
INCLUDE "src/set_d071_two_stage_4d5c_bit40_name_text.asm"

SetD071TwoStage4D5CBit40NameTextEnd:

SECTION "Stage 4C 5429 unless zero at 4A40", ROMX[$4A40], BANK[2]
INCLUDE "src/stage_4c_5429_unless_zero_at_4a40.asm"

Stage4C5429UnlessZeroAt4A40End:

SECTION "Set D071 two cap D120 script 48C9", ROMX[$4A4A], BANK[2]
INCLUDE "src/set_d071_two_cap_d120_script_48c9.asm"

SetD071TwoCapD120ThenScript48C9End:

SECTION "Stage 4C 4DC6 unless zero at 4A80", ROMX[$4A80], BANK[2]
INCLUDE "src/stage_4c_4dc6_unless_zero_at_4a80.asm"

Stage4C4DC6UnlessZeroAt4A80End:

SECTION "Stage 4C 52AE unless zero at 4A8A", ROMX[$4A8A], BANK[2]
INCLUDE "src/stage_4c_52ae_unless_zero_at_4a8a.asm"

Stage4C52AEUnlessZeroAt4A8AEnd:

SECTION "Set D071 two floor D11D script 460D", ROMX[$4A94], BANK[2]
INCLUDE "src/set_d071_two_floor_d11d_script_460d.asm"

SetD071TwoFloorD11DScript460DEnd:

SECTION "Stage 4C 5B01 unless zero at 4AC8", ROMX[$4AC8], BANK[2]
INCLUDE "src/stage_4c_5b01_unless_zero_at_4ac8.asm"

SECTION "Stage 4C 53EE unless zero at 4AD2", ROMX[$4AD2], BANK[2]
INCLUDE "src/stage_4c_53ee_unless_zero_at_4ad2.asm"

Stage4C53EEUnlessZeroAt4AD2ScaffoldEnd:

SECTION "Stage 4C 576A unless zero at 4ADC", ROMX[$4ADC], BANK[2]
INCLUDE "src/stage_4c_576a_unless_zero_at_4adc.asm"

Stage4C576AUnlessZeroAt4ADCScaffoldEnd:

SECTION "Stage 4D35 then scaled DIV name count", ROMX[$4AE6], BANK[2]
INCLUDE "src/stage_4d35_then_scaled_div_name_count.asm"

Stage4D35ThenScaledDivNameCountScaffoldEnd:

SECTION "Stage 4F18 bit 08 if accum below 80", ROMX[$4B01], BANK[2]
INCLUDE "src/stage_4f18_bit08_if_accum_below_80.asm"

Stage4F18Bit08IfAccumBelow80ScaffoldEnd:

SECTION "Stage 4C 5854 unless zero at 4B27", ROMX[$4B27], BANK[2]
INCLUDE "src/stage_4c_5854_unless_zero_at_4b27.asm"

Stage4C5854UnlessZeroAt4B27ScaffoldEnd:

SECTION "Stage 4C 57D0 bit 01 then name 01", ROMX[$4B31], BANK[2]
INCLUDE "src/stage_4c_57d0_bit01_then_name_01.asm"

Stage4C57D0Bit01ThenName01ScaffoldEnd:

SECTION "Stage 4C 596F unless zero at 4B4A", ROMX[$4B4A], BANK[2]
INCLUDE "src/stage_4c_596f_unless_zero_at_4b4a.asm"

Stage4C596FUnlessZeroAt4B4AScaffoldEnd:

SECTION "Set D071 two then mark bit 80", ROMX[$4B54], BANK[2]
INCLUDE "src/set_d071_two_mark_bit80.asm"

SetD071TwoMarkBit80ScaffoldEnd:

SECTION "Stage 4C 5205 unless zero at 4B69", ROMX[$4B69], BANK[2]
INCLUDE "src/stage_4c_5205_unless_zero_at_4b69.asm"

Stage4C5205UnlessZeroAt4B69ScaffoldEnd:

SECTION "Stage 4C 5109 unless zero at 4B73", ROMX[$4B73], BANK[2]
INCLUDE "src/stage_4c_5109_unless_zero_at_4b73.asm"

Stage4C5109UnlessZeroAt4B73ScaffoldEnd:

SECTION "Set D071 two stage 4EE1 floor D11F script 45DC", ROMX[$4B7D], BANK[2]
INCLUDE "src/set_d071_two_stage_4ee1_floor_d11f_script_45dc.asm"

SetD071TwoStage4EE1FloorD11FScript45DCScaffoldEnd:

SECTION "Stage 4C 5245 unless zero at 4BB9", ROMX[$4BB9], BANK[2]
INCLUDE "src/stage_4c_5245_unless_zero_at_4bb9.asm"

Stage4C5245UnlessZeroAt4BB9ScaffoldEnd:

SECTION "Stage 4C 59D2 unless zero at 4BC3", ROMX[$4BC3], BANK[2]
INCLUDE "src/stage_4c_59d2_unless_zero_at_4bc3.asm"

Stage4C59D2UnlessZeroAt4BC3ScaffoldEnd:

SECTION "Stage 4C 5A32 unless zero at 4BCD", ROMX[$4BCD], BANK[2]
INCLUDE "src/stage_4c_5a32_unless_zero_at_4bcd.asm"

Stage4C5A32UnlessZeroAt4BCDEnd:

SECTION "Stage pointer 5A32", ROMX[$4BD0], BANK[2]
INCLUDE "src/stage_pointer_5a32.asm"

StagePointer5A32End:

SECTION "Set D071 two then stage 4B79", ROMX[$4BD7], BANK[2]
INCLUDE "src/set_d071_two_stage_4b79.asm"

SetD071TwoStage4B79AndMarkBit40End:

SECTION "Set D071 two then stage 4D35", ROMX[$4BF4], BANK[2]
INCLUDE "src/set_d071_two_stage_4d35.asm"

SetD071TwoStage4D35CallBank7End:

SECTION "Cap D11E then plant script 48B1", ROMX[$4C0A], BANK[2]
INCLUDE "src/cap_d11e_then_plant_script_48b1.asm"

CapD11EThenPlantScript48B1End:

SECTION "Stage 4C 4E80 unless zero", ROMX[$4C40], BANK[2]
INCLUDE "src/stage_4c_4e80_unless_zero.asm"

Stage4C4E80UnlessZeroEnd:

SECTION "Stage 4C 5BC4 unless zero", ROMX[$4C4A], BANK[2]
INCLUDE "src/stage_4c_5bc4_unless_zero.asm"

Stage4C5BC4UnlessZeroEnd:

SECTION "Stage 4C 4C5E then bank 5 if accum below 40", ROMX[$4C54], BANK[2]
INCLUDE "src/stage_4c5e_then_bank5_if_accum_below_40.asm"

Stage4C5EThenBank5IfAccumBelow40End:

SECTION "Stage 4C 5A32 unless zero at 4C6C", ROMX[$4C6C], BANK[2]
INCLUDE "src/stage_4c_5a32_unless_zero_at_4c6c.asm"

Stage4C5A32UnlessZeroAt4C6CEnd:

SECTION "Set D071 two stage 560E bit 40 name text", ROMX[$4C76], BANK[2]
INCLUDE "src/set_d071_two_stage_560e_bit40_name_text.asm"

SetD071TwoStage560EBit40NameTextEnd:

SECTION "Set D071 two mark bit 20", ROMX[$4C93], BANK[2]
INCLUDE "src/set_d071_two_mark_bit20.asm"

SetD071TwoMarkBit20End:

SECTION "Stage 4C 4DC6 unless zero at 4CA8", ROMX[$4CA8], BANK[2]
INCLUDE "src/stage_4c_4dc6_unless_zero_at_4ca8.asm"

Stage4C4DC6UnlessZeroAt4CA8End:

SECTION "Stage 4C 4E4B unless zero at 4CB2", ROMX[$4CB2], BANK[2]
INCLUDE "src/stage_4c_4e4b_unless_zero_at_4cb2.asm"

Stage4C4E4BUnlessZeroAt4CB2End:

SECTION "Stage 4C 5698 unless zero at 4CBC", ROMX[$4CBC], BANK[2]
INCLUDE "src/stage_4c_5698_unless_zero_at_4cbc.asm"

Stage4C5698UnlessZeroAt4CBCEnd:

SECTION "Set D071 two stage 4F64 floor D11E", ROMX[$4CC6], BANK[2]
INCLUDE "src/set_d071_two_stage_4f64_floor_d11e_script_45c2.asm"

SetD071TwoStage4F64FloorD11EScript45C2End:

SECTION "Stage 4C 5805 unless zero", ROMX[$4D02], BANK[2]
INCLUDE "src/stage_4c_5805_unless_zero.asm"

Stage4C5805UnlessZeroEnd:

SECTION "Stage 4C 4D87 unless zero", ROMX[$4D0C], BANK[2]
INCLUDE "src/stage_4c_4d87_unless_zero.asm"

Stage4C4D87UnlessZeroEnd:

SECTION "Stage 4C 5A32 then bank 5 if accum below 40", ROMX[$4D16], BANK[2]
INCLUDE "src/stage_4c_5a32_then_bank5_if_accum_below_40.asm"

Stage4C5A32ThenBank5IfAccumBelow40End:

SECTION "Stage 4C 4D5C unless zero at 4D2E", ROMX[$4D2E], BANK[2]
INCLUDE "src/stage_4c_4d5c_unless_zero_at_4d2e.asm"

Stage4C4D5CUnlessZeroAt4D2EEnd:

SECTION "Stage 4C 5205 unless zero at 4D38", ROMX[$4D38], BANK[2]
INCLUDE "src/stage_4c_5205_unless_zero_at_4d38.asm"

Stage4C5205UnlessZeroAt4D38End:

SECTION "Set D071 two cap D11E add 14 script 48B1", ROMX[$4D42], BANK[2]
INCLUDE "src/set_d071_two_cap_d11e_add14_script_48b1.asm"

SetD071TwoCapD11EAdd14ThenScript48B1End:

SECTION "Stage 4C 5360 unless zero", ROMX[$4D78], BANK[2]
INCLUDE "src/stage_4c_5360_unless_zero.asm"

Stage4C5360UnlessZeroEnd:

SECTION "Stage 4C 5A32 then bank 5 if accum below 40 at 4D82", ROMX[$4D82], BANK[2]
INCLUDE "src/stage_4c_5a32_then_bank5_if_accum_below_40_at_4d82.asm"

Stage4C5A32ThenBank5IfAccumBelow40At4D82End:

SECTION "Set D071 two mark bit 80 at 4D9A", ROMX[$4D9A], BANK[2]
INCLUDE "src/set_d071_two_mark_bit80_at_4d9a.asm"

SetD071TwoMarkBit80At4D9AEnd:

SECTION "Set D071 two cap D11D add 14 script 48F5", ROMX[$4DAF], BANK[2]
INCLUDE "src/set_d071_two_cap_d11d_add14_script_48f5.asm"

SetD071TwoCapD11DAdd14ThenScript48F5End:

SECTION "Stage 4F64 floor D11F script 45DC at 4DE5", ROMX[$4DE5], BANK[2]
INCLUDE "src/stage_4f64_floor_d11f_script_45dc_at_4de5.asm"

Stage4F64FloorD11FScript45DCAt4DE5End:

SECTION "Stage 4C 4D5C unless zero at 4E1D", ROMX[$4E1D], BANK[2]
INCLUDE "src/stage_4c_4d5c_unless_zero_at_4e1d.asm"

Stage4C4D5CUnlessZeroAt4E1DEnd:

SECTION "Set D071 two cap D11E add 0A script 48B1", ROMX[$4E27], BANK[2]
INCLUDE "src/set_d071_two_cap_d11e_add0a_script_48b1.asm"

SetD071TwoCapD11EAdd0AThenScript48B1End:

SECTION "Stage 560E bit 01 if accum below C0", ROMX[$4E5D], BANK[2]
INCLUDE "src/stage_560e_bit01_if_accum_below_c0.asm"

Stage560EBit01IfAccumBelowC0End:

SECTION "Stage 4C 5C67 unless zero", ROMX[$4E7C], BANK[2]
INCLUDE "src/stage_4c_5c67_unless_zero.asm"

Stage4C5C67UnlessZeroEnd:

SECTION "Stage 5854 bit 01 if accum below C0", ROMX[$4E86], BANK[2]
INCLUDE "src/stage_5854_bit01_if_accum_below_c0.asm"

Stage5854Bit01IfAccumBelowC0End:

SECTION "Stage 4C 5109 unless zero at 4EA5", ROMX[$4EA5], BANK[2]
INCLUDE "src/stage_4c_5109_unless_zero_at_4ea5.asm"

Stage4C5109UnlessZeroAt4EA5End:

SECTION "Stage 4C 4BCC unless zero at 4EAF", ROMX[$4EAF], BANK[2]
INCLUDE "src/stage_4c_4bcc_unless_zero_at_4eaf.asm"

Stage4C4BCCUnlessZeroAt4EAFEnd:

SECTION "Set D071 two mark bit 40 at 4EB9", ROMX[$4EB9], BANK[2]
INCLUDE "src/set_d071_two_mark_bit40_at_4eb9.asm"

SetD071TwoMarkBit40At4EB9End:

SECTION "Stage 4C 5320 store 10s then bank 5", ROMX[$4ECE], BANK[2]
INCLUDE "src/stage_4c_5320_store_10s_then_bank5.asm"

Stage4C5320Store10sThenBank5End:

SECTION "Stage 4C 51D0 unless zero at 4EE8", ROMX[$4EE8], BANK[2]
INCLUDE "src/stage_4c_51d0_unless_zero_at_4ee8.asm"

Stage4C51D0UnlessZeroAt4EE8End:

SECTION "Stage 4C 5805 unless zero at 4EF2", ROMX[$4EF2], BANK[2]
INCLUDE "src/stage_4c_5805_unless_zero_at_4ef2.asm"

Stage4C5805UnlessZeroAt4EF2End:

SECTION "Stage 4C 4CB8 unless zero at 4EFC", ROMX[$4EFC], BANK[2]
INCLUDE "src/stage_4c_4cb8_unless_zero_at_4efc.asm"

Stage4C4CB8UnlessZeroAt4EFCEnd:

SECTION "Stage 4C 5889 then bank 5 if accum below 40", ROMX[$4F06], BANK[2]
INCLUDE "src/stage_4c_5889_then_bank5_if_accum_below_40.asm"

Stage4C5889ThenBank5IfAccumBelow40End:

SECTION "Stage 4C 5854 unless zero at 4F1E", ROMX[$4F1E], BANK[2]
INCLUDE "src/stage_4c_5854_unless_zero_at_4f1e.asm"

Stage4C5854UnlessZeroAt4F1EScaffoldEnd:

SECTION "Stage 4C 5854 unless zero at 4F28", ROMX[$4F28], BANK[2]
INCLUDE "src/stage_4c_5854_unless_zero_at_4f28.asm"

Stage4C5854UnlessZeroAt4F28ScaffoldEnd:

SECTION "Stage 4C 55BD then bank 5 if accum below 40", ROMX[$4F32], BANK[2]
INCLUDE "src/stage_4c_55bd_then_bank5_if_accum_below_40.asm"

Stage4C55BDThenBank5IfAccumBelow40ScaffoldEnd:

SECTION "Set D071 two bit 40 name text", ROMX[$4F4A], BANK[2]
INCLUDE "src/set_d071_two_bit40_name_text.asm"

SetD071TwoBit40NameTextScaffoldEnd:

SECTION "Stage 4C 4C7E unless zero at 4F5F", ROMX[$4F5F], BANK[2]
INCLUDE "src/stage_4c_4c7e_unless_zero_at_4f5f.asm"

Stage4C4C7EUnlessZeroAt4F5FEnd:

SECTION "Stage 4C 58CD unless zero at 4F69", ROMX[$4F69], BANK[2]
INCLUDE "src/stage_4c_58cd_unless_zero_at_4f69.asm"

Stage4C58CDUnlessZeroAt4F69End:

SECTION "Stage 4C 4CB8 unless zero at 4F73", ROMX[$4F73], BANK[2]
INCLUDE "src/stage_4c_4cb8_unless_zero_at_4f73.asm"

Stage4C4CB8UnlessZeroAt4F73End:

SECTION "Set D071 two cap D11E add 0A script 48B1 at 4F7D", ROMX[$4F7D], BANK[2]
INCLUDE "src/set_d071_two_cap_d11e_add0a_script_48b1_at_4f7d.asm"

SetD071TwoCapD11EAdd0AThenScript48B1At4F7DEnd:

SECTION "Stage 4C 57D0 store 10s then bank 5 at 4FB3", ROMX[$4FB3], BANK[2]
INCLUDE "src/stage_4c_57d0_store_10s_then_bank5_at_4fb3.asm"

Stage4C57D0Store10sThenBank5At4FB3End:

SECTION "Stage 4C 590B then bank 5 if accum below 40", ROMX[$4FCD], BANK[2]
INCLUDE "src/stage_4c_590b_then_bank5_if_accum_below_40.asm"

Stage4C590BThenBank5IfAccumBelow40End:

SECTION "Stage 5320 floor D11D script 460D bit 40", ROMX[$4FE5], BANK[2]
INCLUDE "src/stage_5320_floor_d11d_script_460d_bit40.asm"

Stage5320FloorD11DScript460DBit40End:

SECTION "Stage 4C 51D0 then cp 40 at 5032", ROMX[$5032], BANK[2]
INCLUDE "src/stage_4c_51d0_then_cp40_at_5032.asm"

Stage4C51D0ThenCp40At5032End:

SECTION "Ret nc else call bank 5 at 4B45", ROMX[$5040], BANK[2]
INCLUDE "src/ret_nc_else_call_bank5_4b45.asm"

RetNcElseCallBank5At4B45End:

SECTION "Set D071 two if D017 and D09A closed", ROMX[$504A], BANK[2]
INCLUDE "src/set_d071_two_if_d017_and_d09a_closed.asm"

SetD071TwoIfD017AndD09AClosedEnd:

SECTION "Stage name count when D017 clear or D09A open", ROMX[$505C], BANK[2]
INCLUDE "src/stage_name_count_when_d017_clear_or_d09a_open.asm"

StageNameCountWhenD017ClearOrD09AOpenEnd:

SECTION "Copy D107 group then script 446D", ROMX[$50E6], BANK[2]
INCLUDE "src/copy_d107_group_then_script_446d.asm"

CopyD107GroupThenScript446DEnd:

SECTION "Stage 4C 5225 unless D0FF or D073 zero", ROMX[$517D], BANK[2]
INCLUDE "src/stage_4c_5225_unless_d0ff_or_d073_zero.asm"

Stage4C5225UnlessD0FFOrD073ZeroEnd:

SECTION "Set D071 name count zero script 424B", ROMX[$5191], BANK[2]
INCLUDE "src/set_d071_name_count_zero_script_424b.asm"

SetD071NameCountZeroScript424BEnd:

SECTION "Set D071 and name count flag to two", ROMX[$51C2], BANK[2]
INCLUDE "src/set_d071_and_name_count_flag_to_two.asm"

SetD071AndNameCountFlagToTwoEnd:

SECTION "Name count zero script 4A29 or D016", ROMX[$51D2], BANK[2]
INCLUDE "src/set_name_count_zero_script_4a29_or_d016.asm"

SetNameCountZeroScript4A29OrD016End:

SECTION "Copy D107 group then script 4A40", ROMX[$5207], BANK[2]
INCLUDE "src/copy_d107_group_then_script_4a40.asm"

CopyD107GroupThenScript4A40End:

SECTION "Load D107 entry then script 4AE0", ROMX[$5272], BANK[2]
INCLUDE "src/load_d107_entry_then_script_4ae0.asm"

LoadD107EntryThenScript4AE0End:

SECTION "Fill D110 then script 4AF5 or 4B0A", ROMX[$5331], BANK[2]
INCLUDE "src/fill_d110_then_script_4af5_or_4b0a.asm"

FillD110ThenScript4AF5Or4B0AEnd:

SECTION "Scale D0E4 pair by D11E", ROMX[$539D], BANK[2]
INCLUDE "src/scale_d0e4_pair_by_d11e.asm"

ScaleD0E4PairByD11EEnd:

SECTION "Scale D0E5 pair by D11F", ROMX[$53CC], BANK[2]
INCLUDE "src/scale_d0e5_pair_by_d11f.asm"

ScaleD0E5PairByD11FEnd:

SECTION "Jitter scaled table byte", ROMX[$53FB], BANK[2]
INCLUDE "src/jitter_scaled_table_byte.asm"

JitterScaledTableByteEnd:

SECTION "Pass if scaled D11D is below the limit", ROMX[$5420], BANK[2]
INCLUDE "src/pass_scaled_d11d.asm"

PassIfScaledD11DBelowLimitEnd:

SECTION "Format fixed word 0172", ROMX[$5487], BANK[2]
INCLUDE "src/format_fixed_word_0172.asm"

FormatFixedWord0172End:

SECTION "Byte from abs delta table", ROMX[$54A3], BANK[2]
; byte_from_abs_delta_table.asm: not published here (it assembles data copied from the ROM)
ByteFromAbsDeltaRows:
    INCBIN "roms/magination.gbc", $94A3, $10

SECTION "Byte from abs delta table @$0094B3", ROMX[$54B3], BANK[2]
ByteFromAbsDeltaTable:
    INCBIN "roms/magination.gbc", $94B3, $26

ByteFromAbsDeltaTableEnd:

SECTION "Raise entries below 100", ROMX[$54D9], BANK[2]
INCLUDE "src/raise_entries_below_100.asm"

RaiseEntriesBelow100End:

SECTION "Raise stored measure", ROMX[$55C3], BANK[2]
INCLUDE "src/raise_stored_measure.asm"

RaiseStoredMeasureEnd:

SECTION "Claim first measure threshold", ROMX[$5657], BANK[2]
INCLUDE "src/claim_first_measure_threshold.asm"

ClaimFirstMeasureThresholdEnd:

SECTION "Copy record name to list tail", ROMX[$56C7], BANK[2]
INCLUDE "src/copy_record_name_to_list_tail.asm"

CopyRecordNameToListTailEnd:

SECTION "Write rank byte two digits", ROMX[$56E8], BANK[2]
INCLUDE "src/write_rank_byte_two_digits.asm"

WriteRankByteTwoDigitsEnd:

SECTION "Write measure word three digits", ROMX[$570A], BANK[2]
INCLUDE "src/write_measure_word_three_digits.asm"

WriteMeasureWordThreeDigitsEnd:

SECTION "Write record+11 two digits", ROMX[$5734], BANK[2]
INCLUDE "src/write_record11_two_digits.asm"

WriteRecord11TwoDigitsEnd:

SECTION "Write record+12 two digits", ROMX[$5756], BANK[2]
INCLUDE "src/write_record12_two_digits.asm"

WriteRecord12TwoDigitsEnd:

SECTION "Write record+13 two digits", ROMX[$5778], BANK[2]
INCLUDE "src/write_record13_two_digits.asm"

WriteRecord13TwoDigitsEnd:

SECTION "Write record+14 two digits", ROMX[$579A], BANK[2]
INCLUDE "src/write_record14_two_digits.asm"

WriteRecord14TwoDigitsEnd:

SECTION "Write record+15 two digits", ROMX[$57BC], BANK[2]
INCLUDE "src/write_record15_two_digits.asm"

WriteRecord15TwoDigitsEnd:

SECTION "Mark indexed tail", ROMX[$57DE], BANK[2]
INCLUDE "src/mark_indexed_tail.asm"

MarkIndexedTailEnd:

SECTION "Spend measure hundred", ROMX[$57F1], BANK[2]
INCLUDE "src/spend_measure_hundred.asm"

SpendMeasureHundredEnd:

SECTION "Run flagged measure script", ROMX[$58FF], BANK[2]
INCLUDE "src/run_flagged_measure_script.asm"

RunFlaggedMeasureScriptSliceEnd:

SECTION "Run rank measure script", ROMX[$596F], BANK[2]
INCLUDE "src/run_rank_measure_script.asm"

RunRankMeasureScriptSliceEnd:

SECTION "Adjust A000 record once", ROMX[$59A3], BANK[2]
INCLUDE "src/adjust_a000_record_once.asm"

AdjustA000RecordOnceEnd:

SECTION "Sample record+12 contribution", ROMX[$59F2], BANK[2]
INCLUDE "src/sample_record12_contribution.asm"

SampleRecord12ContributionEnd:

SECTION "Sample record+13 contribution", ROMX[$5A2B], BANK[2]
INCLUDE "src/sample_record13_contribution.asm"

SampleRecord13ContributionEnd:

SECTION "Sample record+14 contribution", ROMX[$5A64], BANK[2]
INCLUDE "src/sample_record14_contribution.asm"

SampleRecord14ContributionEnd:

SECTION "Sample record+15 contribution", ROMX[$5AAF], BANK[2]
INCLUDE "src/sample_record15_contribution.asm"

SampleRecord15ContributionEnd:

SECTION "Sample record+11 contribution", ROMX[$5AFA], BANK[2]
INCLUDE "src/sample_record11_contribution.asm"

SampleRecord11ContributionEnd:

SECTION "Record contribution tables", ROMX[$5B0F], BANK[2]
; record_contribution_tables.asm: not published here (it assembles data copied from the ROM)
Record11ContributionTable:
    INCBIN "roms/magination.gbc", $9B0F, $8

SECTION "Record contribution tables @$009B17", ROMX[$5B17], BANK[2]
RecordMod10Low:
    INCBIN "roms/magination.gbc", $9B17, $A

SECTION "Record contribution tables @$009B21", ROMX[$5B21], BANK[2]
RecordMod10Mid:
    INCBIN "roms/magination.gbc", $9B21, $A

SECTION "Record contribution tables @$009B2B", ROMX[$5B2B], BANK[2]
RecordMod10High:
    INCBIN "roms/magination.gbc", $9B2B, $A

RecordContributionTablesEnd:

SECTION "Spend new entry measures", ROMX[$5B35], BANK[2]
INCLUDE "src/spend_new_entry_measures.asm"

SpendNewEntryMeasuresEnd:

SECTION "Store claimed record word", ROMX[$5B71], BANK[2]
INCLUDE "src/store_claimed_record_word.asm"

StoreClaimedRecordWordEnd:

SECTION "Halve D110 record word 7", ROMX[$5B88], BANK[2]
INCLUDE "src/halve_d110_record_word7_min1.asm"

HalveD110RecordWord7Min1End:

SECTION "Swap D110 record+11 and record+14", ROMX[$5BA7], BANK[2]
INCLUDE "src/swap_d110_record11_and14.asm"

SwapD110Record11And14End:

SECTION "Grow D110 record+11 by eighth", ROMX[$5BC2], BANK[2]
INCLUDE "src/grow_d110_record11_by_eighth.asm"

GrowD110Record11ByEighthEnd:

SECTION "Shrink D110 record+11 by eighth", ROMX[$5BD0], BANK[2]
INCLUDE "src/shrink_d110_record11_by_eighth.asm"

ShrinkD110Record11ByEighthEnd:

SECTION "Copy 37-byte record", ROMX[$5BDC], BANK[2]
INCLUDE "src/copy_37_byte_record.asm"

Copy37ByteRecordEnd:

SECTION "Set D389 bit 0 and spend", ROMX[$5BEC], BANK[2]
INCLUDE "src/set_d389_bit0_spend_d069.asm"

SetD389Bit0SpendD069End:

SECTION "Adjust D110 in entry bank", ROMX[$5C00], BANK[2]
INCLUDE "src/adjust_d110_in_entry_bank.asm"

AdjustD110InEntryBankEnd:

SECTION "Spend D110 measure hundred", ROMX[$5C0E], BANK[2]
INCLUDE "src/spend_d110_measure_hundred.asm"

SpendD110MeasureHundredEnd:

SECTION "Return at $5C1C", ROMX[$5C1C], BANK[2]
INCLUDE "src/ret_at_5c1c.asm"

RetAt5C1CEnd:

SECTION "Return after D110 SRAM off", ROMX[$5C1D], BANK[2]
INCLUDE "src/return_after_d110_sram_off.asm"

ReturnAfterD110SramOffEnd:

SECTION "Load D110 record", ROMX[$5C1E], BANK[2]
INCLUDE "src/load_d110_record.asm"

LoadD110RecordEnd:

SECTION "Copy SRAM block to HL", ROMX[$5C5C], BANK[2]
INCLUDE "src/copy_sram_block_to_hl.asm"

CopySramBlockToHLEnd:

SECTION "Write D110 record body", ROMX[$5C93], BANK[2]
INCLUDE "src/write_d110_record_body.asm"

WriteD110RecordBodyEnd:

SECTION "Choice scripts at $5CB8", ROMX[$5CB8], BANK[2]
; choice_scripts_5cb8.asm: not published here (it assembles data copied from the ROM)
ScriptAt5CB8:
    INCBIN "roms/magination.gbc", $9CB8, $2

SECTION "Choice scripts at $5CB8 @$009CBA", ROMX[$5CBA], BANK[2]
ScriptAt5CBA:
    INCBIN "roms/magination.gbc", $9CBA, $2

ChoiceScripts5CB8End:

SECTION "Enter D016 mode 2", ROMX[$5CBC], BANK[2]
INCLUDE "src/enter_d016_mode2.asm"

EnterD016Mode2End:

SECTION "Plant script $41E6 then mode 2", ROMX[$5CC1], BANK[2]
INCLUDE "src/plant_script_41e6_then_d016_mode2.asm"

PlantScript41E6ThenD016Mode2End:

SECTION "Refresh slot for low D103", ROMX[$5CDD], BANK[2]
INCLUDE "src/refresh_slot_for_low_d103.asm"

RefreshSlotForLowD103End:

SECTION "Wait until $D3C2 clears", ROMX[$5E5E], BANK[2]
INCLUDE "src/wait_d3c2_clear.asm"

WaitD3C2ClearEnd:

SECTION "Init WRAM bank 7 before reset", ROMX[$5E6D], BANK[2]
INCLUDE "src/init_wram7_before_reset.asm"

InitWram7BeforeResetEnd:

SECTION "Fill focus or fight and four slots", ROMX[$5F4D], BANK[2]
INCLUDE "src/fill_focus_or_fight_and_four_slots.asm"

FillFocusOrFightAndFourSlotsEnd:

SECTION "Dispatch D0B0 script", ROMX[$5FDF], BANK[2]
INCLUDE "src/dispatch_d0b0_script.asm"

DispatchD0B0ScriptEnd:

SECTION "Drive D0B1 choice", ROMX[$6110], BANK[2]
INCLUDE "src/drive_d0b1_choice.asm"

DriveD0B1ChoiceEnd:

SECTION "Set D016 when slots closed", ROMX[$62C1], BANK[2]
INCLUDE "src/set_d016_when_slots_closed.asm"

SetD016WhenSlotsClosedEnd:

SECTION "Dispatch nonzero D016", ROMX[$6316], BANK[2]
INCLUDE "src/dispatch_nonzero_d016.asm"

DispatchNonzeroD016End:

SECTION "OR four $D092 and $D07E bytes", ROMX[$657B], BANK[2]
INCLUDE "src/or_four_d092_and_d07e.asm"

OrFourD092AndD07EEnd:

SECTION "Loop while D0D5", ROMX[$6591], BANK[2]
INCLUDE "src/loop_while_d0d5.asm"

LoopWhileD0D5End:

SECTION "Walk four D092 records", ROMX[$65B7], BANK[2]
INCLUDE "src/walk_four_d092_records.asm"

WalkFourD092RecordsEnd:

SECTION "Clear marks and walk slots", ROMX[$66DD], BANK[2]
INCLUDE "src/clear_marks_and_walk_slots.asm"

ClearMarksAndWalkSlotsEnd:

SECTION "Apply four $D096 slots", ROMX[$6A01], BANK[2]
INCLUDE "src/apply_four_d096_slots.asm"

ApplyFourD096SlotsEnd:

SECTION "Begin D0D5 pass", ROMX[$6AED], BANK[2]
INCLUDE "src/begin_d0d5_pass.asm"

BeginD0D5PassEnd:

SECTION "Dispatch slot 9 by D0F0", ROMX[$6BBA], BANK[2]
INCLUDE "src/dispatch_slot9_by_d0f0.asm"

DispatchSlot9ByD0F0End:

SECTION "Rank eight $D092 slots", ROMX[$6BE7], BANK[2]
INCLUDE "src/rank_d092_slots.asm"

RankEightD092SlotsEnd:

SECTION "Apply marked slot flags", ROMX[$6C7D], BANK[2]
INCLUDE "src/apply_marked_slot_flags.asm"

ApplyMarkedSlotFlagsEnd:

SECTION "Apply D125 when D105 below 5", ROMX[$6DE7], BANK[2]
INCLUDE "src/apply_d125_when_d105_below5.asm"

ApplyD125WhenD105Below5End:

SECTION "Adjust low nibble or toggle bit 5", ROMX[$6F30], BANK[2]
INCLUDE "src/adjust_low_nibble_or_toggle_bit5.asm"

AdjustLowNibbleOrToggleBit5End:

SECTION "OR $D096 unless $D09A is closed", ROMX[$6FB2], BANK[2]
INCLUDE "src/or_d096_quad_unless_d09a_closed.asm"

OrD096QuadUnlessD09AClosedEnd:

SECTION "D0F0 jump words", ROMX[$6FD7], BANK[2]
; d0f0_jump_words.asm: not published here (it assembles data copied from the ROM)
D0F0JumpWords:
    INCBIN "roms/magination.gbc", $AFD7, $22

D0F0JumpWordsEnd:

SECTION "Add 4 to nonzero $D103", ROMX[$6FF9], BANK[2]
INCLUDE "src/add4_to_nonzero_d103.asm"

Add4ToNonzeroD103End:

SECTION "Pick greatest nonzero $D3C4 slot", ROMX[$700B], BANK[2]
INCLUDE "src/pick_greatest_nonzero_d3c4_slot.asm"

PickGreatestNonzeroD3C4SlotEnd:

SECTION "Pick least nonzero $D3C4 slot", ROMX[$7067], BANK[2]
INCLUDE "src/pick_least_nonzero_d3c4_slot.asm"

PickLeastNonzeroD3C4SlotEnd:

SECTION "First nonzero of four bytes", ROMX[$70C3], BANK[2]
INCLUDE "src/first_nonzero_of_four.asm"

FirstNonzeroOfFourEnd:

SECTION "Scale four records into $D3C4", ROMX[$7101], BANK[2]
INCLUDE "src/scale_four_records_into_d3c4.asm"

ScaleFourRecordsIntoD3C4End:

SECTION "Copy four raw record words into $D3C4", ROMX[$712F], BANK[2]
INCLUDE "src/copy_four_raw_record_words.asm"

CopyFourRawRecordWordsEnd:

SECTION "Pick $D092 slot plus 1", ROMX[$714F], BANK[2]
INCLUDE "src/pick_d092_slot_plus1.asm"

SECTION "Copy $D17E word then pick greatest", ROMX[$7162], BANK[2]
INCLUDE "src/copy_d17e_word_then_pick_greatest.asm"

SECTION "Scale $D17E then pick greatest", ROMX[$716C], BANK[2]
INCLUDE "src/scale_d17e_then_pick_greatest.asm"

SECTION "Copy $D17E word then pick max", ROMX[$7176], BANK[2]
INCLUDE "src/copy_d17e_word_then_pick_max.asm"

SECTION "Scale $D17E then pick max", ROMX[$7180], BANK[2]
INCLUDE "src/scale_d17e_then_pick_max.asm"

SECTION "Copy $D392 into $D103", ROMX[$718A], BANK[2]
INCLUDE "src/copy_d392_into_d103.asm"

CopyD392IntoD103End:

SECTION "Pick D096 slot plus 5", ROMX[$7191], BANK[2]
INCLUDE "src/pick_d096_slot_plus5.asm"

PickD096SlotPlus5End:

SECTION "Copy D25A word then pick greatest", ROMX[$71A5], BANK[2]
INCLUDE "src/copy_d25a_word_then_pick_greatest.asm"

CopyD25AWordThenPickGreatestEnd:

SECTION "Scale D25A then pick greatest", ROMX[$71B2], BANK[2]
INCLUDE "src/scale_d25a_then_pick_greatest.asm"

ScaleD25AThenPickGreatestEnd:

SECTION "Copy D25A word then pick max", ROMX[$71BF], BANK[2]
INCLUDE "src/copy_d25a_word_then_pick_max.asm"

CopyD25AWordThenPickMaxEnd:

SECTION "Scale D25A then pick max", ROMX[$71CC], BANK[2]
INCLUDE "src/scale_d25a_then_pick_max.asm"

ScaleD25AThenPickMaxEnd:

SECTION "Clear D103", ROMX[$71D9], BANK[2]
INCLUDE "src/clear_d103.asm"

ClearD103End:

SECTION "OR four D092 bytes", ROMX[$71DE], BANK[2]
INCLUDE "src/or_four_d092_then_branch.asm"

OrFourD092ThenBranchEnd:

SECTION "Match six remainder then pick slot", ROMX[$71EF], BANK[2]
INCLUDE "src/match_six_remainder_then_pick_slot.asm"

MatchSixRemainderThenPickSlotEnd:

SECTION "Match divider remainder to FF", ROMX[$725E], BANK[2]
INCLUDE "src/match_divider_remainder_to_ff.asm"

MatchDividerRemainderToFFEnd:

SECTION "Mark D103 from D096", ROMX[$72A7], BANK[2]
INCLUDE "src/mark_d103_from_d096.asm"

MarkD103FromD096End:

SECTION "Load zero selection then mark D103 nine", ROMX[$72E2], BANK[2]
INCLUDE "src/load_zero_selection_mark_d103_nine.asm"

LoadZeroSelectionMarkD103NineEnd:

SECTION "Pick D091 mark into D103", ROMX[$72FD], BANK[2]
INCLUDE "src/pick_d091_mark_into_d103.asm"

PickD091MarkIntoD103End:

SECTION "Resolve D103 before mark scan", ROMX[$7366], BANK[2]
INCLUDE "src/resolve_d103_before_mark_scan.asm"

ResolveD103BeforeMarkScanEnd:

SECTION "Copy D393 record then dispatch", ROMX[$73AC], BANK[2]
INCLUDE "src/copy_d393_record_then_dispatch.asm"

CopyD393RecordThenDispatchEnd:

SECTION "Load 5EFE record then group dispatch", ROMX[$73DD], BANK[2]
INCLUDE "src/load_5efe_record_then_group_dispatch.asm"

Load5EFERecordThenGroupDispatchEnd:

SECTION "Return at $7449", ROMX[$7449], BANK[2]
INCLUDE "src/ret_at_7449.asm"

RetAt7449End:

SECTION "Plant Focus then copy D0D9 by operand", ROMX[$744A], BANK[2]
INCLUDE "src/plant_focus_then_copy_d0d9_by_operand.asm"

PlantFocusThenCopyD0D9ByOperandEnd:

SECTION "Store script pair then call 5D19", ROMX[$7477], BANK[2]
INCLUDE "src/store_script_pair_then_call_5d19.asm"

StoreScriptPairThenCall5D19End:

SECTION "Apply SummonX record then pick slot", ROMX[$748B], BANK[2]
INCLUDE "src/apply_summonx_record_then_pick_slot.asm"

ApplySummonXRecordThenPickSlotEnd:

SECTION "Finish opcode 2D", ROMX[$752D], BANK[2]
INCLUDE "src/finish_opcode_2d.asm"

FinishOpcode2DEnd:

SECTION "Apply Item block then dispatch", ROMX[$7595], BANK[2]
INCLUDE "src/apply_item_block_then_dispatch.asm"

ApplyItemBlockThenDispatchEnd:

SECTION "Index times 37 plus D147", ROMX[$75FC], BANK[2]
INCLUDE "src/index_times_37_plus_d147.asm"

IndexTimes37PlusD147End:

SECTION "Store D0D9 after low D103", ROMX[$7607], BANK[2]
INCLUDE "src/store_d0d9_after_low_d103.asm"

StoreD0D9AfterLowD103End:

SECTION "Copy D392 record into D0D9", ROMX[$762B], BANK[2]
INCLUDE "src/copy_d392_record_into_d0d9.asm"

CopyD392RecordIntoD0D9End:

SECTION "Menu record at 763F", ROMX[$763F], BANK[2]
; menu_record_763f.asm: not published here (it assembles data copied from the ROM)
MenuRecord763F:
    INCBIN "roms/magination.gbc", $B63F, $2C

MenuRecord763FEnd:

SECTION "Bank 2 nop pad at 766B", ROMX[$766B], BANK[2]
INCLUDE "src/bank2_nop_pad_766b.asm"

Bank2NopPad766BEnd:

SECTION "Bank 2 nop pad at 7A2C", ROMX[$7A2C], BANK[2]
INCLUDE "src/bank2_nop_pad_7a2c.asm"

Bank2NopPad7A2CEnd:

SECTION "Bank 2 padding at $7E2C", ROMX[$7E2C], BANK[2]
INCLUDE "src/bank2_padding_7e2c.asm"

Bank2Padding7E2CEnd:

SECTION "Select slot from high nibble", ROMX[$4000], BANK[3]
INCLUDE "src/select_slot_from_high_nibble.asm"

SECTION "Blank both choice cells", ROMX[$404C], BANK[3]
INCLUDE "src/blank_both_choice_cells.asm"

SECTION "Reload slot position", ROMX[$405F], BANK[3]
INCLUDE "src/reload_slot_position.asm"

SECTION "Stage choice cell", ROMX[$4075], BANK[3]
INCLUDE "src/stage_choice_cell.asm"

StageChoiceCellEnd:

SECTION "Paint staged choice cell", ROMX[$40E2], BANK[3]
INCLUDE "src/paint_staged_choice_cell.asm"

PaintStagedChoiceCellEnd:

SECTION "Queue blink sprite", ROMX[$4100], BANK[3]
INCLUDE "src/queue_blink_sprite.asm"

QueueBlinkSpriteEnd:

SECTION "Refresh choice cursor", ROMX[$4141], BANK[3]
INCLUDE "src/refresh_choice_cursor.asm"

RefreshChoiceCursorEnd:

SECTION "Prep window choice frame", ROMX[$415D], BANK[3]
INCLUDE "src/prep_window_choice_frame.asm"

PrepWindowChoiceFrameEnd:

SECTION "Load armed slot record", ROMX[$417C], BANK[3]
INCLUDE "src/load_armed_slot_record.asm"

LoadArmedSlotRecordEnd:

SECTION "Dispatch masked action", ROMX[$41E3], BANK[3]
INCLUDE "src/dispatch_masked_action.asm"

DispatchMaskedActionEnd:

SECTION "Run window strip passes", ROMX[$4260], BANK[3]
INCLUDE "src/run_window_strip_passes.asm"

RunWindowStripPassesEnd:

SECTION "Copy indexed slot", ROMX[$4274], BANK[3]
INCLUDE "src/copy_indexed_slot.asm"

CopyIndexedSlotEnd:

SECTION "Write ascending at stride", ROMX[$42A2], BANK[3]
INCLUDE "src/write_ascending_at_stride.asm"

WriteAscendingAtStrideEnd:

SECTION "Masked action slot table", ROMX[$42A9], BANK[3]
; masked_action_slot_table.asm: not published here (it assembles data copied from the ROM)
MaskedActionSlotTable:
    INCBIN "roms/magination.gbc", $C2A9, $E

MaskedActionSlotTableEnd:

SECTION "Store selected slot index", ROMX[$42B7], BANK[3]
INCLUDE "src/store_selected_slot_index.asm"

StoreSelectedSlotIndexEnd:

SECTION "Store FE slot index", ROMX[$42BE], BANK[3]
INCLUDE "src/store_fe_slot_index.asm"

StoreFeSlotIndexEnd:

SECTION "Latch selected slot", ROMX[$42C4], BANK[3]
INCLUDE "src/latch_selected_slot.asm"

LatchSelectedSlotEnd:

SECTION "Decrement slot latch", ROMX[$42D4], BANK[3]
INCLUDE "src/decrement_slot_latch.asm"

DecrementSlotLatchEnd:

SECTION "Hold LCD off", ROMX[$42E3], BANK[3]
INCLUDE "src/hold_lcd_off.asm"

HoldLcdOffEnd:

SECTION "Return slot action", ROMX[$42F2], BANK[3]
INCLUDE "src/return_slot_action.asm"

ReturnSlotActionEnd:

SECTION "Drop stacked word then load VRAM", ROMX[$42F3], BANK[3]
INCLUDE "src/drop_stacked_word_then_load_vram.asm"

DropStackedWordThenLoadVRAMEnd:

SECTION "Retarget SRAM slot count", ROMX[$42F7], BANK[3]
INCLUDE "src/retarget_sram_slot_count.asm"

RetargetSramSlotCountEnd:

SECTION "Take SRAM slot into latch", ROMX[$436B], BANK[3]
INCLUDE "src/take_sram_slot_into_latch.asm"

TakeSramSlotIntoLatchEnd:

SECTION "Load both VRAM banks", ROMX[$43BF], BANK[3]
INCLUDE "src/load_both_vram_banks.asm"

LoadBothVRAMBanksEnd:

SECTION "Step slot pair", ROMX[$4415], BANK[3]
INCLUDE "src/step_slot_pair.asm"

StepSlotPairEnd:

SECTION "Run strip passes then finish", ROMX[$4511], BANK[3]
INCLUDE "src/run_strip_passes_then_finish.asm"

RunStripPassesThenFinishEnd:

SECTION "Slot list base table", ROMX[$4524], BANK[3]
; slot_list_base_table.asm: not published here (it assembles data copied from the ROM)
SlotListBaseTable:
    INCBIN "roms/magination.gbc", $C524, $16

SlotListBaseTableEnd:

SECTION "Slot list index 0", ROMX[$453A], BANK[3]
; slot_list_index0.asm: not published here (it assembles data copied from the ROM)
SlotListIndex0:
    INCBIN "roms/magination.gbc", $C53A, $30

SlotListIndex0End:

SECTION "Slot list index 0A", ROMX[$456A], BANK[3]
; slot_list_index_0a.asm: not published here (it assembles data copied from the ROM)
SlotListIndex0A:
    INCBIN "roms/magination.gbc", $C56A, $28

SlotListIndex0AEnd:

SECTION "Slot list index 1", ROMX[$4592], BANK[3]
; slot_list_index1.asm: not published here (it assembles data copied from the ROM)
SlotListIndex1:
    INCBIN "roms/magination.gbc", $C592, $40

SlotListIndex1End:

SECTION "Slot list index 1 tail", ROMX[$45D2], BANK[3]
; slot_list_index1_tail.asm: not published here (it assembles data copied from the ROM)
SlotListIndex1Tail:
    INCBIN "roms/magination.gbc", $C5D2, $10

SlotListIndex1TailEnd:

SECTION "Slot list index 2", ROMX[$45E2], BANK[3]
; slot_list_index2.asm: not published here (it assembles data copied from the ROM)
SlotListIndex2:
    INCBIN "roms/magination.gbc", $C5E2, $38

SlotListIndex2End:

SECTION "Slot list index 9", ROMX[$461A], BANK[3]
; slot_list_index9.asm: not published here (it assembles data copied from the ROM)
SlotListIndex9:
    INCBIN "roms/magination.gbc", $C61A, $30

SlotListIndex9End:

SECTION "Slot list index 4", ROMX[$464A], BANK[3]
; slot_list_index4.asm: not published here (it assembles data copied from the ROM)
SlotListIndex4:
    INCBIN "roms/magination.gbc", $C64A, $38

SlotListIndex4End:

SECTION "Slot list index 3", ROMX[$4682], BANK[3]
; slot_list_index3.asm: not published here (it assembles data copied from the ROM)
SlotListIndex3:
    INCBIN "roms/magination.gbc", $C682, $20

SlotListIndex3End:

SECTION "Slot list index 5", ROMX[$46A2], BANK[3]
; slot_list_index5.asm: not published here (it assembles data copied from the ROM)
SlotListIndex5:
    INCBIN "roms/magination.gbc", $C6A2, $38

SlotListIndex5End:

SECTION "Slot list index 7", ROMX[$46DA], BANK[3]
; slot_list_index7.asm: not published here (it assembles data copied from the ROM)
SlotListIndex7:
    INCBIN "roms/magination.gbc", $C6DA, $40

SlotListIndex7End:

SECTION "Slot list index 7 tail", ROMX[$471A], BANK[3]
; slot_list_index7_tail.asm: not published here (it assembles data copied from the ROM)
SlotListIndex7Tail:
    INCBIN "roms/magination.gbc", $C71A, $28

SlotListIndex7TailEnd:

SECTION "Slot list index 6", ROMX[$4742], BANK[3]
; slot_list_index6.asm: not published here (it assembles data copied from the ROM)
SlotListIndex6:
    INCBIN "roms/magination.gbc", $C742, $40

SlotListIndex6End:

SECTION "Slot list index 6 tail", ROMX[$4782], BANK[3]
; slot_list_index6_tail.asm: not published here (it assembles data copied from the ROM)
SlotListIndex6Tail:
    INCBIN "roms/magination.gbc", $C782, $28

SlotListIndex6TailEnd:

SECTION "Slot list index 8", ROMX[$47AA], BANK[3]
; slot_list_index8.asm: not published here (it assembles data copied from the ROM)
SlotListIndex8:
    INCBIN "roms/magination.gbc", $C7AA, $40

SlotListIndex8End:

SECTION "Slot list index 8 tail", ROMX[$47EA], BANK[3]
; slot_list_index8_tail.asm: not published here (it assembles data copied from the ROM)
SlotListIndex8Tail:
    INCBIN "roms/magination.gbc", $C7EA, $28

SlotListIndex8TailEnd:

SECTION "Slot list index 8 last", ROMX[$4812], BANK[3]
; slot_list_index8_last.asm: not published here (it assembles data copied from the ROM)
SlotListIndex8Last:
    INCBIN "roms/magination.gbc", $C812, $8

SlotListIndex8LastEnd:

SECTION "Shall I make ring text", ROMX[$481A], BANK[3]
; shall_i_make_ring.asm: not published here (it assembles data copied from the ROM)
ShallIMakeRingText:
    INCBIN "roms/magination.gbc", $C81A, $1D

ShallIMakeRingTextEnd:

SECTION "Not enough animite text", ROMX[$4837], BANK[3]
; not_enough_animite_text.asm: not published here (it assembles data copied from the ROM)
NotEnoughAnimiteText:
    INCBIN "roms/magination.gbc", $C837, $1D

SECTION "Not enough animite text @$00C854", ROMX[$4854], BANK[3]
WantEquipOrDestroyText:
    INCBIN "roms/magination.gbc", $C854, $1F

NotEnoughAnimiteTextEnd:

SECTION "Can't restore ring text", ROMX[$4873], BANK[3]
; cant_restore_ring_text.asm: not published here (it assembles data copied from the ROM)
CantRestoreRingText:
    INCBIN "roms/magination.gbc", $C873, $31

CantRestoreRingTextEnd:

SECTION "Which ring replace text", ROMX[$48A4], BANK[3]
; which_ring_replace_text.asm: not published here (it assembles data copied from the ROM)
WhichRingReplaceText:
    INCBIN "roms/magination.gbc", $C8A4, $21

WhichRingReplaceTextEnd:

SECTION "Which ring act on text", ROMX[$48C5], BANK[3]
; which_ring_act_on_text.asm: not published here (it assembles data copied from the ROM)
WhichRingActOnText:
    INCBIN "roms/magination.gbc", $C8C5, $20

WhichRingActOnTextEnd:

SECTION "Too few rings text", ROMX[$48E5], BANK[3]
; too_few_rings_text.asm: not published here (it assembles data copied from the ROM)
TooFewRingsText:
    INCBIN "roms/magination.gbc", $C8E5, $2B

TooFewRingsTextEnd:

SECTION "De-equip rings text", ROMX[$4910], BANK[3]
; deequip_rings_text.asm: not published here (it assembles data copied from the ROM)
DeequipRingsText:
    INCBIN "roms/magination.gbc", $C910, $2B

DeequipRingsTextEnd:

SECTION "Slot pair records from 0", ROMX[$493B], BANK[3]
; slot_pair_records_from_0.asm: not published here (it assembles data copied from the ROM)
SlotPairRecordsFrom0:
    INCBIN "roms/magination.gbc", $C93B, $2F

SlotPairRecordsFrom0End:

SECTION "Slot pair records from 11", ROMX[$496A], BANK[3]
; slot_pair_records_from_11.asm: not published here (it assembles data copied from the ROM)
SlotPairRecordsFrom11:
    INCBIN "roms/magination.gbc", $C96A, $3D

SlotPairRecordsFrom11End:

SECTION "Slot pair records from 27", ROMX[$49A7], BANK[3]
; slot_pair_records_from_27.asm: not published here (it assembles data copied from the ROM)
SlotPairRecordsFrom27:
    INCBIN "roms/magination.gbc", $C9A7, $40

SlotPairRecordsFrom27End:

SECTION "Slot pair records from 43", ROMX[$49E7], BANK[3]
; slot_pair_records_from_43.asm: not published here (it assembles data copied from the ROM)
SlotPairRecordsFrom43:
    INCBIN "roms/magination.gbc", $C9E7, $40

SlotPairRecordsFrom43End:

SECTION "Slot pair records from 59", ROMX[$4A27], BANK[3]
; slot_pair_records_from_59.asm: not published here (it assembles data copied from the ROM)
SlotPairRecordsFrom59:
    INCBIN "roms/magination.gbc", $CA27, $40

SlotPairRecordsFrom59End:

SECTION "Slot pair records from 75", ROMX[$4A67], BANK[3]
; slot_pair_records_from_75.asm: not published here (it assembles data copied from the ROM)
SlotPairRecordsFrom75:
    INCBIN "roms/magination.gbc", $CA67, $40

SlotPairRecordsFrom75End:

SECTION "Slot pair records from 91", ROMX[$4AA7], BANK[3]
; slot_pair_records_from_91.asm: not published here (it assembles data copied from the ROM)
SlotPairRecordsFrom91:
    INCBIN "roms/magination.gbc", $CAA7, $40

SlotPairRecordsFrom91End:

SECTION "Slot pair records from 107", ROMX[$4AE7], BANK[3]
; slot_pair_records_from_107.asm: not published here (it assembles data copied from the ROM)
SlotPairRecordsFrom107:
    INCBIN "roms/magination.gbc", $CAE7, $40

SlotPairRecordsFrom107End:

SECTION "Slot pair records from 123", ROMX[$4B27], BANK[3]
; slot_pair_records_from_123.asm: not published here (it assembles data copied from the ROM)
SlotPairRecordsFrom123:
    INCBIN "roms/magination.gbc", $CB27, $24

SlotPairRecordsFrom123End:

SECTION "Window tilemap at $4B4B", ROMX[$4B4B], BANK[3]
; window_tilemap_4b4b.asm: not published here (it assembles data copied from the ROM)
WindowTilemap4B4B:
    INCBIN "roms/magination.gbc", $CB4B, $40

WindowTilemap4B4BEnd:

SECTION "Window tilemap at $4B8B", ROMX[$4B8B], BANK[3]
; window_tilemap_4b8b.asm: not published here (it assembles data copied from the ROM)
WindowTilemap4B8B:
    INCBIN "roms/magination.gbc", $CB8B, $40

WindowTilemap4B8BEnd:

SECTION "Window tilemap at $4BCB", ROMX[$4BCB], BANK[3]
; window_tilemap_4bcb.asm: not published here (it assembles data copied from the ROM)
WindowTilemap4BCB:
    INCBIN "roms/magination.gbc", $CBCB, $40

WindowTilemap4BCBEnd:

SECTION "Window tilemap at $4C0B", ROMX[$4C0B], BANK[3]
; window_tilemap_4c0b.asm: not published here (it assembles data copied from the ROM)
WindowTilemap4C0B:
    INCBIN "roms/magination.gbc", $CC0B, $40

WindowTilemap4C0BEnd:

SECTION "Window tilemap at $4C4B", ROMX[$4C4B], BANK[3]
; window_tilemap_4c4b.asm: not published here (it assembles data copied from the ROM)
WindowTilemap4C4B:
    INCBIN "roms/magination.gbc", $CC4B, $40

WindowTilemap4C4BEnd:

SECTION "Window tilemap at $4C8B", ROMX[$4C8B], BANK[3]
; window_tilemap_4c8b.asm: not published here (it assembles data copied from the ROM)
WindowTilemap4C8B:
    INCBIN "roms/magination.gbc", $CC8B, $40

WindowTilemap4C8BEnd:

SECTION "Window tilemap at $4CCB", ROMX[$4CCB], BANK[3]
; window_tilemap_4ccb.asm: not published here (it assembles data copied from the ROM)
WindowTilemap4CCB:
    INCBIN "roms/magination.gbc", $CCCB, $40

WindowTilemap4CCBEnd:

SECTION "Map strip from $4D0B", ROMX[$4D0B], BANK[3]
; map_strip_from_4d0b.asm: not published here (it assembles data copied from the ROM)
MapStripFrom4D0B:
    INCBIN "roms/magination.gbc", $CD0B, $19

MapStripFrom4D0BEnd:

SECTION "Map strip from $4D24", ROMX[$4D24], BANK[3]
; map_strip_from_4d24.asm: not published here (it assembles data copied from the ROM)
MapStripFrom4D24:
    INCBIN "roms/magination.gbc", $CD24, $40

MapStripFrom4D24End:

SECTION "Map strip from $4D64", ROMX[$4D64], BANK[3]
; map_strip_from_4d64.asm: not published here (it assembles data copied from the ROM)
MapStripFrom4D64:
    INCBIN "roms/magination.gbc", $CD64, $3C

MapStripFrom4D64End:

SECTION "Map strip from $4DA0", ROMX[$4DA0], BANK[3]
; map_strip_from_4da0.asm: not published here (it assembles data copied from the ROM)
MapStripFrom4DA0:
    INCBIN "roms/magination.gbc", $CDA0, $3C

MapStripFrom4DA0End:

SECTION "Map strip from $4DDC", ROMX[$4DDC], BANK[3]
; map_strip_from_4ddc.asm: not published here (it assembles data copied from the ROM)
MapStripFrom4DDC:
    INCBIN "roms/magination.gbc", $CDDC, $40

MapStripFrom4DDCEnd:

SECTION "Map strip from $4E1C", ROMX[$4E1C], BANK[3]
; map_strip_from_4e1c.asm: not published here (it assembles data copied from the ROM)
MapStripFrom4E1C:
    INCBIN "roms/magination.gbc", $CE1C, $40

MapStripFrom4E1CEnd:

SECTION "Map strip from $4E5C", ROMX[$4E5C], BANK[3]
; map_strip_from_4e5c.asm: not published here (it assembles data copied from the ROM)
MapStripFrom4E5C:
    INCBIN "roms/magination.gbc", $CE5C, $40

MapStripFrom4E5CEnd:

SECTION "Map strip from $4E9C", ROMX[$4E9C], BANK[3]
; map_strip_from_4e9c.asm: not published here (it assembles data copied from the ROM)
MapStripFrom4E9C:
    INCBIN "roms/magination.gbc", $CE9C, $40

MapStripFrom4E9CEnd:

SECTION "Map strip from $4EDC", ROMX[$4EDC], BANK[3]
; map_strip_from_4edc.asm: not published here (it assembles data copied from the ROM)
MapStripFrom4EDC:
    INCBIN "roms/magination.gbc", $CEDC, $40

MapStripFrom4EDCEnd:

SECTION "Map strip from $4F1C", ROMX[$4F1C], BANK[3]
; map_strip_from_4f1c.asm: not published here (it assembles data copied from the ROM)
MapStripFrom4F1C:
    INCBIN "roms/magination.gbc", $CF1C, $40

MapStripFrom4F1CEnd:

SECTION "Map strip from $4F5C", ROMX[$4F5C], BANK[3]
; map_strip_from_4f5c.asm: not published here (it assembles data copied from the ROM)
MapStripFrom4F5C:
    INCBIN "roms/magination.gbc", $CF5C, $27

MapStripFrom4F5CEnd:

SECTION "Dispatch armed choice", ROMX[$4F83], BANK[3]
INCLUDE "src/dispatch_armed_choice.asm"

DispatchArmedChoiceEnd:

SECTION "Step choice 0B by CCC8", ROMX[$4FBE], BANK[3]
INCLUDE "src/step_choice_0b_by_ccc8.asm"

StepChoice0BByCcc8End:

SECTION "Step choice 0C by CCC8", ROMX[$503E], BANK[3]
INCLUDE "src/step_choice_0c_by_ccc8.asm"

StepChoice0CByCcc8End:

SECTION "Stage tiles and arm slot", ROMX[$50D0], BANK[3]
INCLUDE "src/stage_tiles_arm_slot.asm"

SECTION "Prepare choice 012", ROMX[$5158], BANK[3]
INCLUDE "src/prepare_choice_012.asm"

SECTION "Copy other choice byte", ROMX[$521A], BANK[3]
INCLUDE "src/copy_other_choice_byte.asm"

SECTION "Step FE choice by CCE3", ROMX[$5238], BANK[3]
INCLUDE "src/step_fe_choice_by_cce3.asm"

SECTION "Dispatch copied block choice", ROMX[$52BC], BANK[3]
INCLUDE "src/dispatch_copied_block_choice.asm"

DispatchCopiedBlockChoiceEnd:

SECTION "Step copied block choice 0B", ROMX[$52ED], BANK[3]
INCLUDE "src/step_copied_block_choice_0b.asm"

StepCopiedBlockChoice0BEnd:

SECTION "Step copied block choice 0C", ROMX[$536D], BANK[3]
INCLUDE "src/step_copied_block_choice_0c.asm"

StepCopiedBlockChoice0CEnd:

SECTION "Stage copied block and arm slot", ROMX[$5400], BANK[3]
INCLUDE "src/stage_copied_block_arm_slot.asm"

SECTION "Fill choice table from records", ROMX[$54F2], BANK[3]
INCLUDE "src/fill_choice_table_from_records.asm"

FillChoiceTableFromRecordsEnd:

SECTION "Copy choice record tiles", ROMX[$555E], BANK[3]
INCLUDE "src/copy_choice_record_tiles.asm"

CopyChoiceRecordTilesEnd:

SECTION "Commit copied block choice", ROMX[$55E3], BANK[3]
INCLUDE "src/commit_copied_block_choice.asm"

CommitCopiedBlockChoiceEnd:

SECTION "Paint copied block map strips", ROMX[$5627], BANK[3]
INCLUDE "src/paint_copied_block_map_strips.asm"

SECTION "Refresh frame blank saved choice rows", ROMX[$565B], BANK[3]
INCLUDE "src/refresh_frame_blank_saved_choice_rows.asm"

RefreshFrameBlankSavedChoiceRowsEnd:

SECTION "Leave window choice reload tiles", ROMX[$567B], BANK[3]
INCLUDE "src/leave_window_choice_reload_tiles.asm"

LeaveWindowChoiceReloadTilesEnd:

SECTION "Slide out keyed SRAM record", ROMX[$56BD], BANK[3]
INCLUDE "src/slide_out_keyed_sram_record.asm"

SlideOutKeyedSRAMRecordEnd:

SECTION "Paint window tilemap", ROMX[$56FA], BANK[3]
INCLUDE "src/paint_window_tilemap.asm"

PaintWindowTilemapEnd:

SECTION "Paint window indexed rows", ROMX[$5744], BANK[3]
INCLUDE "src/paint_window_indexed_rows.asm"

PaintWindowIndexedRowsEnd:

SECTION "Service window choice", ROMX[$58CB], BANK[3]
INCLUDE "src/service_window_choice.asm"

ServiceWindowChoiceEnd:

SECTION "Stage window tiles and arm slot", ROMX[$5AAE], BANK[3]
INCLUDE "src/stage_window_tiles_arm_slot.asm"

StageWindowTilesArmSlotEnd:

SECTION "Refresh then join arm slot", ROMX[$5BBA], BANK[3]
INCLUDE "src/refresh_then_join_arm_slot.asm"

RefreshThenJoinArmSlotEnd:

SECTION "Resolve armed list choice", ROMX[$5BC3], BANK[3]
INCLUDE "src/resolve_armed_list_choice.asm"

ResolveArmedListChoiceEnd:

SECTION "Resolve short list choice", ROMX[$5EE1], BANK[3]
INCLUDE "src/resolve_short_list_choice.asm"

ResolveShortListChoiceEnd:

SECTION "Choose short list slot", ROMX[$6213], BANK[3]
INCLUDE "src/choose_short_list_slot.asm"

ChooseShortListSlotEnd:

SECTION "Load paged SRAM choice pairs", ROMX[$6400], BANK[3]
INCLUDE "src/load_paged_sram_choice_pairs.asm"

LoadPagedSRAMChoicePairsEnd:

SECTION "Mark window choice cells", ROMX[$64B1], BANK[3]
INCLUDE "src/mark_window_choice_cells.asm"

MarkWindowChoiceCellsEnd:

SECTION "Blank saved choice window rows", ROMX[$653A], BANK[3]
INCLUDE "src/blank_saved_choice_rows_a.asm"

BlankSavedChoiceWindowRowsEnd:

SECTION "Blank later saved choice window rows", ROMX[$6575], BANK[3]
INCLUDE "src/blank_saved_choice_rows_b.asm"

BlankSavedChoiceWindowRowsBEnd:

SECTION "Paint choice mark cells", ROMX[$65AF], BANK[3]
INCLUDE "src/paint_choice_mark_cells.asm"

PaintChoiceMarkCellsEnd:

SECTION "Write ascending tiles", ROMX[$65D2], BANK[3]
INCLUDE "src/write_ascending_tiles.asm"

WriteAscendingTilesEnd:

SECTION "Dispatch prefixed block choice", ROMX[$65D9], BANK[3]
INCLUDE "src/dispatch_prefixed_block_choice.asm"

DispatchPrefixedBlockChoiceEnd:

SECTION "Step prefixed block choice 0B", ROMX[$6653], BANK[3]
INCLUDE "src/step_prefixed_block_choice_0b.asm"

StepPrefixedBlockChoice0BEnd:

SECTION "Step prefixed block choice 0C", ROMX[$667E], BANK[3]
INCLUDE "src/step_prefixed_block_choice_0c.asm"

StepPrefixedBlockChoice0CEnd:

SECTION "Setup prefixed block choice", ROMX[$66BE], BANK[3]
INCLUDE "src/setup_prefixed_block_choice.asm"

SECTION "Refresh prefixed block list", ROMX[$6784], BANK[3]
INCLUDE "src/refresh_prefixed_block_list.asm"

SECTION "Repaint prefixed block window", ROMX[$6796], BANK[3]
INCLUDE "src/repaint_prefixed_block_window.asm"

RepaintPrefixedBlockWindowEnd:

SECTION "Paint prefixed choice rows", ROMX[$6801], BANK[3]
INCLUDE "src/paint_prefixed_choice_rows.asm"

SECTION "Fill choice bytes forward", ROMX[$6880], BANK[3]
INCLUDE "src/fill_choice_bytes_forward.asm"

FillChoiceBytesForwardEnd:

SECTION "Refill choice bytes backward", ROMX[$68E8], BANK[3]
INCLUDE "src/refill_choice_bytes_backward.asm"

RefillChoiceBytesBackwardEnd:

SECTION "Add prefixed choice word", ROMX[$6930], BANK[3]
INCLUDE "src/add_prefixed_choice_word.asm"

AddPrefixedChoiceWordEnd:

SECTION "Clear latched slot resume choice", ROMX[$6A41], BANK[3]
INCLUDE "src/clear_latched_slot_resume_choice.asm"

ClearLatchedSlotResumeChoiceEnd:

SECTION "Spend prefixed block record", ROMX[$6A4D], BANK[3]
INCLUDE "src/spend_prefixed_block_record.asm"

SpendPrefixedBlockRecordEnd:

SECTION "Refresh frame planted map list", ROMX[$6AE6], BANK[3]
INCLUDE "src/refresh_frame_planted_map_list.asm"

SECTION "Reject prefixed record cost", ROMX[$6B03], BANK[3]
INCLUDE "src/reject_prefixed_record_cost.asm"

RejectPrefixedRecordCostEnd:

SECTION "Append EE digit places", ROMX[$6B0C], BANK[3]
INCLUDE "src/append_ee_digit_places.asm"

AppendEeDigitPlacesEnd:

SECTION "Refresh record length from mode", ROMX[$6B25], BANK[3]
INCLUDE "src/refresh_record_len_from_mode.asm"

SECTION "Plant one map list entry", ROMX[$6B43], BANK[3]
INCLUDE "src/plant_one_map_list_entry.asm"

SECTION "Jump to reload choice frame", ROMX[$6B77], BANK[3]
INCLUDE "src/jump_to_reload_choice_frame.asm"

SECTION "Prefixed block choice 00 or 01", ROMX[$6B7A], BANK[3]
INCLUDE "src/step_prefixed_block_choice_00.asm"

StepPrefixedBlockChoice00End:

SECTION "Walk planted map list", ROMX[$6C1A], BANK[3]
INCLUDE "src/walk_planted_map_list.asm"

SECTION "Plant latched slot digits", ROMX[$6C5C], BANK[3]
INCLUDE "src/plant_latched_slot_digits.asm"

PlantLatchedSlotDigitsEnd:

SECTION "Blank out of range slot map", ROMX[$6C9E], BANK[3]
INCLUDE "src/blank_out_of_range_slot_map.asm"

BlankOutOfRangeSlotMapEnd:

SECTION "Step prefixed block choice FE", ROMX[$6CA8], BANK[3]
INCLUDE "src/step_prefixed_block_choice_fe.asm"

StepPrefixedBlockChoiceFEEnd:

SECTION "Sync row end marks then scan", ROMX[$6D1F], BANK[3]
INCLUDE "src/sync_row_end_marks_then_scan.asm"

SECTION "Copy choice record word", ROMX[$6D72], BANK[3]
INCLUDE "src/copy_choice_record_word.asm"

SECTION "Dispatch SRAM list choice", ROMX[$6DA1], BANK[3]
INCLUDE "src/dispatch_sram_list_choice.asm"

DispatchSramListChoiceEnd:

SECTION "Step SRAM list choice 0B", ROMX[$6DDC], BANK[3]
INCLUDE "src/step_sram_list_choice_0b.asm"

StepSramListChoice0BEnd:

SECTION "Step SRAM list choice 0C", ROMX[$6E56], BANK[3]
INCLUDE "src/step_sram_list_choice_0c.asm"

StepSramListChoice0CEnd:

SECTION "Append three digit places", ROMX[$6ED7], BANK[3]
INCLUDE "src/append_three_digit_places.asm"

AppendThreeDigitPlacesEnd:

SECTION "Blank absent SRAM list slot", ROMX[$6EF0], BANK[3]
INCLUDE "src/blank_absent_sram_list_slot.asm"

BlankAbsentSramListSlotEnd:

SECTION "Sync SRAM list slot digits", ROMX[$6F39], BANK[3]
INCLUDE "src/sync_sram_list_slot_digits.asm"

SyncSramListSlotDigitsEnd:

SECTION "Paint SRAM list digit cells", ROMX[$6FE8], BANK[3]
INCLUDE "src/paint_sram_list_digit_cells.asm"

PaintSramListDigitCellsEnd:

SECTION "Stage SRAM list and arm slot", ROMX[$7025], BANK[3]
INCLUDE "src/stage_sram_list_arm_slot.asm"

StageSramListArmSlotEnd:

SECTION "Stage SRAM list names", ROMX[$70D4], BANK[3]
INCLUDE "src/stage_sram_list_names.asm"

StageSramListNamesEnd:

SECTION "Stage SRAM name tiles", ROMX[$7103], BANK[3]
INCLUDE "src/stage_sram_name_tiles.asm"

StageSramNameTilesEnd:

SECTION "Fill SRAM list ids", ROMX[$71AA], BANK[3]
INCLUDE "src/fill_sram_list_ids.asm"

FillSramListIdsEnd:

SECTION "Fill SRAM list prices", ROMX[$7213], BANK[3]
INCLUDE "src/fill_sram_list_prices.asm"

FillSramListPricesEnd:

SECTION "Spend SRAM list choice", ROMX[$729A], BANK[3]
INCLUDE "src/spend_sram_list_choice.asm"

SpendSramListChoiceEnd:

SECTION "Commit bought SRAM record", ROMX[$731C], BANK[3]
INCLUDE "src/commit_bought_sram_record.asm"

CommitBoughtSramRecordEnd:

SECTION "Paint SRAM list record bytes", ROMX[$7393], BANK[3]
INCLUDE "src/paint_sram_list_record_bytes.asm"

PaintSramListRecordBytesEnd:

SECTION "Paint SRAM record byte", ROMX[$73E3], BANK[3]
INCLUDE "src/paint_sram_record_byte.asm"

PaintSramRecordByteEnd:

SECTION "Paint SRAM list marks", ROMX[$7415], BANK[3]
INCLUDE "src/paint_sram_list_marks.asm"

PaintSramListMarksEnd:

SECTION "Paint map attrs and seed slot", ROMX[$7463], BANK[3]
INCLUDE "src/paint_map_attrs_seed_slot.asm"

PaintMapAttrsSeedSlotEnd:

SECTION "Count nonzero choice bytes", ROMX[$74EF], BANK[3]
INCLUDE "src/count_nonzero_choice_bytes.asm"

CountNonzeroChoiceBytesEnd:

SECTION "Collect choice indices backward", ROMX[$7512], BANK[3]
INCLUDE "src/collect_choice_indices_backward.asm"

CollectChoiceIndicesBackwardEnd:

SECTION "Collect choice indices forward", ROMX[$7550], BANK[3]
INCLUDE "src/collect_choice_indices_forward.asm"

CollectChoiceIndicesForwardEnd:

SECTION "Stage indexed choice tiles", ROMX[$7596], BANK[3]
INCLUDE "src/stage_indexed_choice_tiles.asm"

StageIndexedChoiceTilesEnd:

SECTION "Reload choice frame", ROMX[$7637], BANK[3]
INCLUDE "src/reload_choice_frame.asm"

ReloadChoiceFrameEnd:

SECTION "Refresh frame choice cell", ROMX[$7679], BANK[3]
INCLUDE "src/refresh_frame_choice_cell.asm"

RefreshFrameChoiceCellEnd:

SECTION "Paint choice tile 82", ROMX[$7696], BANK[3]
INCLUDE "src/paint_choice_tile_82.asm"

PaintChoiceTile82End:

SECTION "Refresh frame with blank choice cells", ROMX[$76B1], BANK[3]
INCLUDE "src/refresh_frame_blank_choice_cells.asm"

RefreshFrameBlankChoiceCellsEnd:

SECTION "Paint blank choice cells", ROMX[$76CE], BANK[3]
INCLUDE "src/paint_blank_choice_cells.asm"

PaintBlankChoiceCellsBodyEnd:

SECTION "Scan armed slot marks", ROMX[$76E0], BANK[3]
INCLUDE "src/scan_armed_slot_marks.asm"

ScanArmedSlotMarksEnd:

SECTION "Place window and copy map", ROMX[$76FA], BANK[3]
INCLUDE "src/place_window_copy_map.asm"

PlaceWindowCopyMapEnd:

SECTION "Copy repeated tile index", ROMX[$772F], BANK[3]
INCLUDE "src/copy_repeated_tile_index.asm"

SECTION "Refresh frame with mark pair", ROMX[$7751], BANK[3]
INCLUDE "src/refresh_frame_mark_pair.asm"

RefreshFrameMarkPairEnd:

SECTION "Paint mark pair cells", ROMX[$776E], BANK[3]
INCLUDE "src/paint_mark_pair_cells.asm"

PaintMarkPairCellsEnd:

SECTION "Refresh frame with mark window pair", ROMX[$7777], BANK[3]
INCLUDE "src/refresh_frame_mark_window_pair.asm"

RefreshFrameMarkWindowPairEnd:

SECTION "Paint mark window pair cells", ROMX[$7794], BANK[3]
INCLUDE "src/paint_mark_window_pair_cells.asm"

PaintMarkWindowPairCellsEnd:

SECTION "Refresh frame with blank mark pair", ROMX[$779D], BANK[3]
INCLUDE "src/refresh_frame_blank_mark_pair.asm"

RefreshFrameBlankMarkPairEnd:

SECTION "Paint blank mark pair cells", ROMX[$77BA], BANK[3]
INCLUDE "src/paint_blank_mark_pair_cells.asm"

PaintBlankMarkPairCellsEnd:

SECTION "Refresh frame with window pair", ROMX[$77C2], BANK[3]
INCLUDE "src/refresh_frame_window_pair.asm"

RefreshFrameWindowPairEnd:

SECTION "Paint window pair cells", ROMX[$77DF], BANK[3]
INCLUDE "src/paint_window_pair_cells.asm"

PaintWindowPairCellsEnd:

SECTION "Add A to E and store at HL", ROMX[$77E7], BANK[3]
INCLUDE "src/add_a_to_e_store_at_hl.asm"

SECTION "Copy fixed then caller tiles", ROMX[$77F3], BANK[3]
INCLUDE "src/copy_fixed_then_caller_tiles.asm"

SECTION "Nop pad from $782C", ROMX[$782C], BANK[3]
INCLUDE "src/nop_pad_782c.asm"

NopPad782CEnd:

SECTION "Nop pad from $7C2C", ROMX[$7C2C], BANK[3]
INCLUDE "src/nop_pad_7c2c.asm"

NopPad7C2CEnd:

SECTION "ROM Bank 004", ROMX[$4000], BANK[4]
; bank4_open_palettes.asm: not published here (it assembles data copied from the ROM)
Bank4OpenPalettes:
    INCBIN "roms/magination.gbc", $10000, $38

Bank4OpenPalettesEnd:

SECTION "Erased bytes after bank 4 palettes", ROMX[$4038], BANK[4]
INCLUDE "src/bank4_erased_after_palettes.asm"

Bank4ErasedAfterPalettesEnd:

SECTION "Nop pad from $4078", ROMX[$4078], BANK[4]
INCLUDE "src/nop_pad_4078.asm"

NopPad4078End:

SECTION "Repeated palettes after bank 4 nops", ROMX[$40B9], BANK[4]
; bank4_repeated_palettes.asm: not published here (it assembles data copied from the ROM)
Bank4RepeatedPalettes:
    INCBIN "roms/magination.gbc", $100B9, $37

SECTION "Copy entry record prefix", ROMX[$40F0], BANK[4]
INCLUDE "src/copy_entry_record_prefix.asm"

CopyEntryRecordPrefixEnd:

SECTION "Copy whole entry record", ROMX[$4105], BANK[4]
INCLUDE "src/copy_whole_entry_record.asm"

SECTION "Expand D391 record", ROMX[$411A], BANK[4]
INCLUDE "src/expand_d391_record.asm"

ExpandD391RecordEnd:

SECTION "Entry record 0", ROMX[$415B], BANK[4]
; entry_record_0.asm: not published here (it assembles data copied from the ROM)
EntryRecord0:
    INCBIN "roms/magination.gbc", $1015B, $2D

EntryRecord0End:

SECTION "Entry record 1", ROMX[$4188], BANK[4]
; entry_record_1.asm: not published here (it assembles data copied from the ROM)
EntryRecord1:
    INCBIN "roms/magination.gbc", $10188, $2D

EntryRecord1End:

SECTION "Entry record 2", ROMX[$41B5], BANK[4]
; entry_record_2.asm: not published here (it assembles data copied from the ROM)
EntryRecord2:
    INCBIN "roms/magination.gbc", $101B5, $2D

EntryRecord2End:

SECTION "Entry record 3", ROMX[$41E2], BANK[4]
; entry_record_3.asm: not published here (it assembles data copied from the ROM)
EntryRecord3:
    INCBIN "roms/magination.gbc", $101E2, $2D

EntryRecord3End:

SECTION "Entry record 4", ROMX[$420F], BANK[4]
; entry_record_4.asm: not published here (it assembles data copied from the ROM)
EntryRecord4:
    INCBIN "roms/magination.gbc", $1020F, $2D

EntryRecord4End:

SECTION "Entry record 5", ROMX[$423C], BANK[4]
; entry_record_5.asm: not published here (it assembles data copied from the ROM)
EntryRecord5:
    INCBIN "roms/magination.gbc", $1023C, $2D

EntryRecord5End:

SECTION "Entry record 6", ROMX[$4269], BANK[4]
; entry_record_6.asm: not published here (it assembles data copied from the ROM)
EntryRecord6:
    INCBIN "roms/magination.gbc", $10269, $2D

EntryRecord6End:

SECTION "Entry record 7", ROMX[$4296], BANK[4]
; entry_record_7.asm: not published here (it assembles data copied from the ROM)
EntryRecord7:
    INCBIN "roms/magination.gbc", $10296, $2D

EntryRecord7End:

SECTION "Entry record 8", ROMX[$42C3], BANK[4]
; entry_record_8.asm: not published here (it assembles data copied from the ROM)
EntryRecord8:
    INCBIN "roms/magination.gbc", $102C3, $2D

EntryRecord8End:

SECTION "Entry record 9", ROMX[$42F0], BANK[4]
; entry_record_9.asm: not published here (it assembles data copied from the ROM)
EntryRecord9:
    INCBIN "roms/magination.gbc", $102F0, $2D

EntryRecord9End:

SECTION "Entry record 10", ROMX[$431D], BANK[4]
; entry_record_10.asm: not published here (it assembles data copied from the ROM)
EntryRecord10:
    INCBIN "roms/magination.gbc", $1031D, $2D

EntryRecord10End:

SECTION "Entry record 11", ROMX[$434A], BANK[4]
; entry_record_11.asm: not published here (it assembles data copied from the ROM)
EntryRecord11:
    INCBIN "roms/magination.gbc", $1034A, $2D

EntryRecord11End:

SECTION "Entry record 12", ROMX[$4377], BANK[4]
; entry_record_12.asm: not published here (it assembles data copied from the ROM)
EntryRecord12:
    INCBIN "roms/magination.gbc", $10377, $2D

EntryRecord12End:

SECTION "Entry record 13", ROMX[$43A4], BANK[4]
; entry_record_13.asm: not published here (it assembles data copied from the ROM)
EntryRecord13:
    INCBIN "roms/magination.gbc", $103A4, $2D

EntryRecord13End:

SECTION "Entry record 14", ROMX[$43D1], BANK[4]
; entry_record_14.asm: not published here (it assembles data copied from the ROM)
EntryRecord14:
    INCBIN "roms/magination.gbc", $103D1, $2D

EntryRecord14End:

SECTION "Entry record 15", ROMX[$43FE], BANK[4]
; entry_record_15.asm: not published here (it assembles data copied from the ROM)
EntryRecord15:
    INCBIN "roms/magination.gbc", $103FE, $2D

EntryRecord15End:

SECTION "Entry record 16", ROMX[$442B], BANK[4]
; entry_record_16.asm: not published here (it assembles data copied from the ROM)
EntryRecord16:
    INCBIN "roms/magination.gbc", $1042B, $2D

EntryRecord16End:

SECTION "Entry record 17", ROMX[$4458], BANK[4]
; entry_record_17.asm: not published here (it assembles data copied from the ROM)
EntryRecord17:
    INCBIN "roms/magination.gbc", $10458, $2D

EntryRecord17End:

SECTION "Entry record 18", ROMX[$4485], BANK[4]
; entry_record_18.asm: not published here (it assembles data copied from the ROM)
EntryRecord18:
    INCBIN "roms/magination.gbc", $10485, $2D

EntryRecord18End:

SECTION "Entry record 19", ROMX[$44B2], BANK[4]
; entry_record_19.asm: not published here (it assembles data copied from the ROM)
EntryRecord19:
    INCBIN "roms/magination.gbc", $104B2, $2D

EntryRecord19End:

SECTION "Entry record 20", ROMX[$44DF], BANK[4]
; entry_record_20.asm: not published here (it assembles data copied from the ROM)
EntryRecord20:
    INCBIN "roms/magination.gbc", $104DF, $2D

EntryRecord20End:

SECTION "Entry record 21", ROMX[$450C], BANK[4]
; entry_record_21.asm: not published here (it assembles data copied from the ROM)
EntryRecord21:
    INCBIN "roms/magination.gbc", $1050C, $2D

EntryRecord21End:

SECTION "Entry record 22", ROMX[$4539], BANK[4]
; entry_record_22.asm: not published here (it assembles data copied from the ROM)
EntryRecord22:
    INCBIN "roms/magination.gbc", $10539, $22

EntryRecord22End:

SECTION "Entry record 22 field tail", ROMX[$455B], BANK[4]
; entry_record_22_field_tail.asm: not published here (it assembles data copied from the ROM)
EntryRecord22FieldTail:
    INCBIN "roms/magination.gbc", $1055B, $B

EntryRecord22FieldTailEnd:

SECTION "Entry record 23", ROMX[$4566], BANK[4]
; entry_record_23.asm: not published here (it assembles data copied from the ROM)
EntryRecord23:
    INCBIN "roms/magination.gbc", $10566, $2D

EntryRecord23End:

SECTION "Entry record 24", ROMX[$4593], BANK[4]
; entry_record_24.asm: not published here (it assembles data copied from the ROM)
EntryRecord24:
    INCBIN "roms/magination.gbc", $10593, $2D

EntryRecord24End:

SECTION "Entry record 25", ROMX[$45C0], BANK[4]
; entry_record_25.asm: not published here (it assembles data copied from the ROM)
EntryRecord25:
    INCBIN "roms/magination.gbc", $105C0, $2D

EntryRecord25End:

SECTION "Entry record 26", ROMX[$45ED], BANK[4]
; entry_record_26.asm: not published here (it assembles data copied from the ROM)
EntryRecord26:
    INCBIN "roms/magination.gbc", $105ED, $2D

EntryRecord26End:

SECTION "Entry record 27", ROMX[$461A], BANK[4]
; entry_record_27.asm: not published here (it assembles data copied from the ROM)
EntryRecord27:
    INCBIN "roms/magination.gbc", $1061A, $2D

EntryRecord27End:

SECTION "Entry record 28", ROMX[$4647], BANK[4]
; entry_record_28.asm: not published here (it assembles data copied from the ROM)
EntryRecord28:
    INCBIN "roms/magination.gbc", $10647, $2D

EntryRecord28End:

SECTION "Entry record 29", ROMX[$4674], BANK[4]
; entry_record_29.asm: not published here (it assembles data copied from the ROM)
EntryRecord29:
    INCBIN "roms/magination.gbc", $10674, $2D

EntryRecord29End:

SECTION "Entry record 30", ROMX[$46A1], BANK[4]
; entry_record_30.asm: not published here (it assembles data copied from the ROM)
EntryRecord30:
    INCBIN "roms/magination.gbc", $106A1, $2D

EntryRecord30End:

SECTION "Entry record 31", ROMX[$46CE], BANK[4]
; entry_record_31.asm: not published here (it assembles data copied from the ROM)
EntryRecord31:
    INCBIN "roms/magination.gbc", $106CE, $2D

EntryRecord31End:

SECTION "Entry record 32", ROMX[$46FB], BANK[4]
; entry_record_32.asm: not published here (it assembles data copied from the ROM)
EntryRecord32:
    INCBIN "roms/magination.gbc", $106FB, $2D

EntryRecord32End:

SECTION "Entry record 33", ROMX[$4728], BANK[4]
; entry_record_33.asm: not published here (it assembles data copied from the ROM)
EntryRecord33:
    INCBIN "roms/magination.gbc", $10728, $2D

EntryRecord33End:

SECTION "Entry record 34", ROMX[$4755], BANK[4]
; entry_record_34.asm: not published here (it assembles data copied from the ROM)
EntryRecord34:
    INCBIN "roms/magination.gbc", $10755, $2D

EntryRecord34End:

SECTION "Entry record 35", ROMX[$4782], BANK[4]
; entry_record_35.asm: not published here (it assembles data copied from the ROM)
EntryRecord35:
    INCBIN "roms/magination.gbc", $10782, $2D

EntryRecord35End:

SECTION "Entry record 36", ROMX[$47AF], BANK[4]
; entry_record_36.asm: not published here (it assembles data copied from the ROM)
EntryRecord36:
    INCBIN "roms/magination.gbc", $107AF, $2D

EntryRecord36End:

SECTION "Entry record 37", ROMX[$47DC], BANK[4]
; entry_record_37.asm: not published here (it assembles data copied from the ROM)
EntryRecord37:
    INCBIN "roms/magination.gbc", $107DC, $2D

EntryRecord37End:

SECTION "Entry record 38", ROMX[$4809], BANK[4]
; entry_record_38.asm: not published here (it assembles data copied from the ROM)
EntryRecord38:
    INCBIN "roms/magination.gbc", $10809, $2D

EntryRecord38End:

SECTION "Entry record 39", ROMX[$4836], BANK[4]
; entry_record_39.asm: not published here (it assembles data copied from the ROM)
EntryRecord39:
    INCBIN "roms/magination.gbc", $10836, $2D

EntryRecord39End:

SECTION "Entry record 40", ROMX[$4863], BANK[4]
; entry_record_40.asm: not published here (it assembles data copied from the ROM)
EntryRecord40:
    INCBIN "roms/magination.gbc", $10863, $2D

EntryRecord40End:

SECTION "Entry record 41", ROMX[$4890], BANK[4]
; entry_record_41.asm: not published here (it assembles data copied from the ROM)
EntryRecord41:
    INCBIN "roms/magination.gbc", $10890, $2D

EntryRecord41End:

SECTION "Entry record 42", ROMX[$48BD], BANK[4]
; entry_record_42.asm: not published here (it assembles data copied from the ROM)
EntryRecord42:
    INCBIN "roms/magination.gbc", $108BD, $2D

EntryRecord42End:

SECTION "Entry record 43", ROMX[$48EA], BANK[4]
; entry_record_43.asm: not published here (it assembles data copied from the ROM)
EntryRecord43:
    INCBIN "roms/magination.gbc", $108EA, $2D

EntryRecord43End:

SECTION "Entry record 44", ROMX[$4917], BANK[4]
; entry_record_44.asm: not published here (it assembles data copied from the ROM)
EntryRecord44:
    INCBIN "roms/magination.gbc", $10917, $2D

EntryRecord44End:

SECTION "Entry record 45", ROMX[$4944], BANK[4]
; entry_record_45.asm: not published here (it assembles data copied from the ROM)
EntryRecord45:
    INCBIN "roms/magination.gbc", $10944, $22

EntryRecord45End:

SECTION "Entry record 45 field tail", ROMX[$4966], BANK[4]
; entry_record_45_field_tail.asm: not published here (it assembles data copied from the ROM)
EntryRecord45FieldTail:
    INCBIN "roms/magination.gbc", $10966, $B

EntryRecord45FieldTailEnd:

SECTION "Entry record 46", ROMX[$4971], BANK[4]
; entry_record_46.asm: not published here (it assembles data copied from the ROM)
EntryRecord46:
    INCBIN "roms/magination.gbc", $10971, $2D

EntryRecord46End:

SECTION "Entry record 47", ROMX[$499E], BANK[4]
; entry_record_47.asm: not published here (it assembles data copied from the ROM)
EntryRecord47:
    INCBIN "roms/magination.gbc", $1099E, $2D

EntryRecord47End:

SECTION "Entry record 48", ROMX[$49CB], BANK[4]
; entry_record_48.asm: not published here (it assembles data copied from the ROM)
EntryRecord48:
    INCBIN "roms/magination.gbc", $109CB, $2D

EntryRecord48End:

SECTION "Entry record 49", ROMX[$49F8], BANK[4]
; entry_record_49.asm: not published here (it assembles data copied from the ROM)
EntryRecord49:
    INCBIN "roms/magination.gbc", $109F8, $2D

EntryRecord49End:

SECTION "Entry record 50", ROMX[$4A25], BANK[4]
; entry_record_50.asm: not published here (it assembles data copied from the ROM)
EntryRecord50:
    INCBIN "roms/magination.gbc", $10A25, $2D

EntryRecord50End:

SECTION "Entry record 51", ROMX[$4A52], BANK[4]
; entry_record_51.asm: not published here (it assembles data copied from the ROM)
EntryRecord51:
    INCBIN "roms/magination.gbc", $10A52, $2D

EntryRecord51End:

SECTION "Entry record 52", ROMX[$4A7F], BANK[4]
; entry_record_52.asm: not published here (it assembles data copied from the ROM)
EntryRecord52:
    INCBIN "roms/magination.gbc", $10A7F, $2D

EntryRecord52End:

SECTION "Entry record 53", ROMX[$4AAC], BANK[4]
; entry_record_53.asm: not published here (it assembles data copied from the ROM)
EntryRecord53:
    INCBIN "roms/magination.gbc", $10AAC, $2D

EntryRecord53End:

SECTION "Entry record 54", ROMX[$4AD9], BANK[4]
; entry_record_54.asm: not published here (it assembles data copied from the ROM)
EntryRecord54:
    INCBIN "roms/magination.gbc", $10AD9, $2D

EntryRecord54End:

SECTION "Entry record 55", ROMX[$4B06], BANK[4]
; entry_record_55.asm: not published here (it assembles data copied from the ROM)
EntryRecord55:
    INCBIN "roms/magination.gbc", $10B06, $2D

EntryRecord55End:

SECTION "Entry record 56", ROMX[$4B33], BANK[4]
; entry_record_56.asm: not published here (it assembles data copied from the ROM)
EntryRecord56:
    INCBIN "roms/magination.gbc", $10B33, $2D

EntryRecord56End:

SECTION "Entry record 57", ROMX[$4B60], BANK[4]
; entry_record_57.asm: not published here (it assembles data copied from the ROM)
EntryRecord57:
    INCBIN "roms/magination.gbc", $10B60, $2D

EntryRecord57End:

SECTION "Entry record 58", ROMX[$4B8D], BANK[4]
; entry_record_58.asm: not published here (it assembles data copied from the ROM)
EntryRecord58:
    INCBIN "roms/magination.gbc", $10B8D, $2D

EntryRecord58End:

SECTION "Entry record 59", ROMX[$4BBA], BANK[4]
; entry_record_59.asm: not published here (it assembles data copied from the ROM)
EntryRecord59:
    INCBIN "roms/magination.gbc", $10BBA, $2D

EntryRecord59End:

SECTION "Entry record 60", ROMX[$4BE7], BANK[4]
; entry_record_60.asm: not published here (it assembles data copied from the ROM)
EntryRecord60:
    INCBIN "roms/magination.gbc", $10BE7, $2D

EntryRecord60End:

SECTION "Entry record 61", ROMX[$4C14], BANK[4]
; entry_record_61.asm: not published here (it assembles data copied from the ROM)
EntryRecord61:
    INCBIN "roms/magination.gbc", $10C14, $2D

EntryRecord61End:

SECTION "Entry record 62", ROMX[$4C41], BANK[4]
; entry_record_62.asm: not published here (it assembles data copied from the ROM)
EntryRecord62:
    INCBIN "roms/magination.gbc", $10C41, $2D

EntryRecord62End:

SECTION "Entry record 63", ROMX[$4C6E], BANK[4]
; entry_record_63.asm: not published here (it assembles data copied from the ROM)
EntryRecord63:
    INCBIN "roms/magination.gbc", $10C6E, $2D

EntryRecord63End:

SECTION "Entry record 64", ROMX[$4C9B], BANK[4]
; entry_record_64.asm: not published here (it assembles data copied from the ROM)
EntryRecord64:
    INCBIN "roms/magination.gbc", $10C9B, $2D

EntryRecord64End:

SECTION "Entry record 65", ROMX[$4CC8], BANK[4]
; entry_record_65.asm: not published here (it assembles data copied from the ROM)
EntryRecord65:
    INCBIN "roms/magination.gbc", $10CC8, $2D

EntryRecord65End:

SECTION "Entry record 66", ROMX[$4CF5], BANK[4]
; entry_record_66.asm: not published here (it assembles data copied from the ROM)
EntryRecord66:
    INCBIN "roms/magination.gbc", $10CF5, $2D

EntryRecord66End:

SECTION "Entry record 67", ROMX[$4D22], BANK[4]
; entry_record_67.asm: not published here (it assembles data copied from the ROM)
EntryRecord67:
    INCBIN "roms/magination.gbc", $10D22, $2D

EntryRecord67End:

SECTION "Entry record 68", ROMX[$4D4F], BANK[4]
; entry_record_68.asm: not published here (it assembles data copied from the ROM)
EntryRecord68:
    INCBIN "roms/magination.gbc", $10D4F, $17

EntryRecord68End:

SECTION "Entry record 68 field tail", ROMX[$4D66], BANK[4]
; entry_record_68_field_tail.asm: not published here (it assembles data copied from the ROM)
EntryRecord68FieldTail:
    INCBIN "roms/magination.gbc", $10D66, $16

EntryRecord68FieldTailEnd:

SECTION "Entry record 69", ROMX[$4D7C], BANK[4]
; entry_record_69.asm: not published here (it assembles data copied from the ROM)
EntryRecord69:
    INCBIN "roms/magination.gbc", $10D7C, $2D

EntryRecord69End:

SECTION "Entry record 70", ROMX[$4DA9], BANK[4]
; entry_record_70.asm: not published here (it assembles data copied from the ROM)
EntryRecord70:
    INCBIN "roms/magination.gbc", $10DA9, $2D

EntryRecord70End:

SECTION "Entry record 71", ROMX[$4DD6], BANK[4]
; entry_record_71.asm: not published here (it assembles data copied from the ROM)
EntryRecord71:
    INCBIN "roms/magination.gbc", $10DD6, $2D

EntryRecord71End:

SECTION "Entry record 72", ROMX[$4E03], BANK[4]
; entry_record_72.asm: not published here (it assembles data copied from the ROM)
EntryRecord72:
    INCBIN "roms/magination.gbc", $10E03, $2D

EntryRecord72End:

SECTION "Entry record 73", ROMX[$4E30], BANK[4]
; entry_record_73.asm: not published here (it assembles data copied from the ROM)
EntryRecord73:
    INCBIN "roms/magination.gbc", $10E30, $2D

EntryRecord73End:

SECTION "Entry record 74", ROMX[$4E5D], BANK[4]
; entry_record_74.asm: not published here (it assembles data copied from the ROM)
EntryRecord74:
    INCBIN "roms/magination.gbc", $10E5D, $2D

EntryRecord74End:

SECTION "Entry record 75", ROMX[$4E8A], BANK[4]
; entry_record_75.asm: not published here (it assembles data copied from the ROM)
EntryRecord75:
    INCBIN "roms/magination.gbc", $10E8A, $2D

EntryRecord75End:

SECTION "Entry record 76", ROMX[$4EB7], BANK[4]
; entry_record_76.asm: not published here (it assembles data copied from the ROM)
EntryRecord76:
    INCBIN "roms/magination.gbc", $10EB7, $2D

EntryRecord76End:

SECTION "Entry record 77", ROMX[$4EE4], BANK[4]
; entry_record_77.asm: not published here (it assembles data copied from the ROM)
EntryRecord77:
    INCBIN "roms/magination.gbc", $10EE4, $2D

EntryRecord77End:

SECTION "Entry record 78", ROMX[$4F11], BANK[4]
; entry_record_78.asm: not published here (it assembles data copied from the ROM)
EntryRecord78:
    INCBIN "roms/magination.gbc", $10F11, $2D

EntryRecord78End:

SECTION "Entry record 79", ROMX[$4F3E], BANK[4]
; entry_record_79.asm: not published here (it assembles data copied from the ROM)
EntryRecord79:
    INCBIN "roms/magination.gbc", $10F3E, $2D

EntryRecord79End:

SECTION "Entry record 80", ROMX[$4F6B], BANK[4]
; entry_record_80.asm: not published here (it assembles data copied from the ROM)
EntryRecord80:
    INCBIN "roms/magination.gbc", $10F6B, $2D

EntryRecord80End:

SECTION "Entry record 81", ROMX[$4F98], BANK[4]
; entry_record_81.asm: not published here (it assembles data copied from the ROM)
EntryRecord81:
    INCBIN "roms/magination.gbc", $10F98, $2D

EntryRecord81End:

SECTION "Entry record 82", ROMX[$4FC5], BANK[4]
; entry_record_82.asm: not published here (it assembles data copied from the ROM)
EntryRecord82:
    INCBIN "roms/magination.gbc", $10FC5, $2D

EntryRecord82End:

SECTION "Entry record 83", ROMX[$4FF2], BANK[4]
; entry_record_83.asm: not published here (it assembles data copied from the ROM)
EntryRecord83:
    INCBIN "roms/magination.gbc", $10FF2, $2D

EntryRecord83End:

SECTION "Entry record 84", ROMX[$501F], BANK[4]
; entry_record_84.asm: not published here (it assembles data copied from the ROM)
EntryRecord84:
    INCBIN "roms/magination.gbc", $1101F, $2D

EntryRecord84End:

SECTION "Entry record 85", ROMX[$504C], BANK[4]
; entry_record_85.asm: not published here (it assembles data copied from the ROM)
EntryRecord85:
    INCBIN "roms/magination.gbc", $1104C, $2D

EntryRecord85End:

SECTION "Entry record 86", ROMX[$5079], BANK[4]
; entry_record_86.asm: not published here (it assembles data copied from the ROM)
EntryRecord86:
    INCBIN "roms/magination.gbc", $11079, $2D

EntryRecord86End:

SECTION "Entry record 87", ROMX[$50A6], BANK[4]
; entry_record_87.asm: not published here (it assembles data copied from the ROM)
EntryRecord87:
    INCBIN "roms/magination.gbc", $110A6, $2D

EntryRecord87End:

SECTION "Entry record 88", ROMX[$50D3], BANK[4]
; entry_record_88.asm: not published here (it assembles data copied from the ROM)
EntryRecord88:
    INCBIN "roms/magination.gbc", $110D3, $2D

EntryRecord88End:

SECTION "Entry record 89", ROMX[$5100], BANK[4]
; entry_record_89.asm: not published here (it assembles data copied from the ROM)
EntryRecord89:
    INCBIN "roms/magination.gbc", $11100, $2D

EntryRecord89End:

SECTION "Entry record 90", ROMX[$512D], BANK[4]
; entry_record_90.asm: not published here (it assembles data copied from the ROM)
EntryRecord90:
    INCBIN "roms/magination.gbc", $1112D, $2D

EntryRecord90End:

SECTION "Entry record 91 prefix", ROMX[$515A], BANK[4]
; entry_record_91_prefix.asm: not published here (it assembles data copied from the ROM)
EntryRecord91Prefix:
    INCBIN "roms/magination.gbc", $1115A, $22

EntryRecord91PrefixEnd:

SECTION "Entry record 91 field tail", ROMX[$517C], BANK[4]
; entry_record_91_field_tail.asm: not published here (it assembles data copied from the ROM)
EntryRecord91FieldTail:
    INCBIN "roms/magination.gbc", $1117C, $B

EntryRecord91FieldTailEnd:

SECTION "Entry record 92", ROMX[$5187], BANK[4]
; entry_record_92.asm: not published here (it assembles data copied from the ROM)
EntryRecord92:
    INCBIN "roms/magination.gbc", $11187, $2D

EntryRecord92End:

SECTION "Entry record 93", ROMX[$51B4], BANK[4]
; entry_record_93.asm: not published here (it assembles data copied from the ROM)
EntryRecord93:
    INCBIN "roms/magination.gbc", $111B4, $2D

SECTION "Entry record 94", ROMX[$51E1], BANK[4]
; entry_record_94.asm: not published here (it assembles data copied from the ROM)
EntryRecord93End:
EntryRecord94:
    INCBIN "roms/magination.gbc", $111E1, $2D

SECTION "Entry record 95", ROMX[$520E], BANK[4]
; entry_record_95.asm: not published here (it assembles data copied from the ROM)
EntryRecord94End:
EntryRecord95:
    INCBIN "roms/magination.gbc", $1120E, $2D

SECTION "Entry record 96", ROMX[$523B], BANK[4]
; entry_record_96.asm: not published here (it assembles data copied from the ROM)
EntryRecord95End:
EntryRecord96:
    INCBIN "roms/magination.gbc", $1123B, $2D

SECTION "Entry record 97", ROMX[$5268], BANK[4]
; entry_record_97.asm: not published here (it assembles data copied from the ROM)
EntryRecord96End:
EntryRecord97:
    INCBIN "roms/magination.gbc", $11268, $2D

SECTION "Entry record 98", ROMX[$5295], BANK[4]
; entry_record_98.asm: not published here (it assembles data copied from the ROM)
EntryRecord97End:
EntryRecord98:
    INCBIN "roms/magination.gbc", $11295, $2D

SECTION "Entry record 99", ROMX[$52C2], BANK[4]
; entry_record_99.asm: not published here (it assembles data copied from the ROM)
EntryRecord98End:
EntryRecord99:
    INCBIN "roms/magination.gbc", $112C2, $2D

SECTION "Entry record 100", ROMX[$52EF], BANK[4]
; entry_record_100.asm: not published here (it assembles data copied from the ROM)
EntryRecord100:
EntryRecord99End:
    INCBIN "roms/magination.gbc", $112EF, $2D

SECTION "Entry record 101", ROMX[$531C], BANK[4]
; entry_record_101.asm: not published here (it assembles data copied from the ROM)
EntryRecord100End:
EntryRecord101:
    INCBIN "roms/magination.gbc", $1131C, $2D

SECTION "Entry record 102", ROMX[$5349], BANK[4]
; entry_record_102.asm: not published here (it assembles data copied from the ROM)
EntryRecord101End:
EntryRecord102:
    INCBIN "roms/magination.gbc", $11349, $2D

SECTION "Entry record 103", ROMX[$5376], BANK[4]
; entry_record_103.asm: not published here (it assembles data copied from the ROM)
EntryRecord102End:
EntryRecord103:
    INCBIN "roms/magination.gbc", $11376, $2D

SECTION "Entry record 104", ROMX[$53A3], BANK[4]
; entry_record_104.asm: not published here (it assembles data copied from the ROM)
EntryRecord103End:
EntryRecord104:
    INCBIN "roms/magination.gbc", $113A3, $2D

SECTION "Entry record 105", ROMX[$53D0], BANK[4]
; entry_record_105.asm: not published here (it assembles data copied from the ROM)
EntryRecord105:
    INCBIN "roms/magination.gbc", $113D0, $2D

SECTION "Entry record 106", ROMX[$53FD], BANK[4]
; entry_record_106.asm: not published here (it assembles data copied from the ROM)
EntryRecord105End:
EntryRecord106:
    INCBIN "roms/magination.gbc", $113FD, $2D

SECTION "Entry record 107", ROMX[$542A], BANK[4]
; entry_record_107.asm: not published here (it assembles data copied from the ROM)
EntryRecord106End:
EntryRecord107:
    INCBIN "roms/magination.gbc", $1142A, $2D

SECTION "Entry record 108", ROMX[$5457], BANK[4]
; entry_record_108.asm: not published here (it assembles data copied from the ROM)
EntryRecord107End:
EntryRecord108:
    INCBIN "roms/magination.gbc", $11457, $2D

SECTION "Write three digit tiles", ROMX[$5484], BANK[4]
INCLUDE "src/write_three_digit_tiles.asm"

WriteThreeDigitTilesEnd:

SECTION "Flag direct script from entry end", ROMX[$5494], BANK[4]
INCLUDE "src/flag_direct_script_from_entry_end.asm"

FlagDirectScriptFromEntryEndEnd:

SECTION "Write three ascending tile runs", ROMX[$54BA], BANK[4]
INCLUDE "src/write_three_ascending_runs.asm"

WriteThreeAscendingRunsFromAEnd:

SECTION "Reload window tiles", ROMX[$54D8], BANK[4]
INCLUDE "src/reload_window_tiles.asm"

ReloadWindowTilesEnd:

SECTION "Paint SRAM word digits", ROMX[$551A], BANK[4]
INCLUDE "src/paint_sram_word_digits.asm"

PaintSRAMWordDigitsEnd:

SECTION "Copy indexed name tiles", ROMX[$554E], BANK[4]
INCLUDE "src/copy_indexed_name_tiles.asm"

CopyIndexedNameTilesEnd:

SECTION "Paint window frame map", ROMX[$557A], BANK[4]
INCLUDE "src/paint_window_frame_map.asm"

PaintWindowFrameMapEnd:

SECTION "Stamp window choice marks", ROMX[$569E], BANK[4]
INCLUDE "src/stamp_window_choice_marks.asm"

StampWindowChoiceMarksEnd:

SECTION "Copied block window choice", ROMX[$582C], BANK[4]
INCLUDE "src/copied_block_window_choice.asm"

CopiedBlockWindowChoiceEnd:

SECTION "Stage copied block window", ROMX[$5926], BANK[4]
INCLUDE "src/stage_copied_block_window.asm"

StageCopiedBlockWindowEnd:

SECTION "Rejoin copied block at WRAM bank", ROMX[$5A52], BANK[4]
INCLUDE "src/rejoin_copied_block_at_wram_bank.asm"

RejoinCopiedBlockAtWRAMBankEnd:

SECTION "Try afford other choice", ROMX[$5A5B], BANK[4]
INCLUDE "src/try_afford_other_choice.asm"

TryAffordOtherChoiceEnd:

SECTION "Commit other choice five", ROMX[$5CB3], BANK[4]
INCLUDE "src/commit_other_choice_five.asm"

CommitOtherChoiceFiveEnd:

SECTION "Add SRAM entry for operand", ROMX[$5D19], BANK[4]
INCLUDE "src/add_sram_entry_for_operand.asm"

AddSRAMEntryForOperandEnd:

SECTION "Show unaffordable choice", ROMX[$5DF5], BANK[4]
INCLUDE "src/show_unaffordable_choice.asm"

ShowUnaffordableChoiceEnd:

SECTION "Load WRAM6 choice rows", ROMX[$5F1A], BANK[4]
INCLUDE "src/load_wram6_choice_rows.asm"

LoadWRAM6ChoiceRowsEnd:

SECTION "Refresh changed slot digits", ROMX[$6034], BANK[4]
INCLUDE "src/refresh_changed_slot_digits.asm"

RefreshChangedSlotDigitsEnd:

SECTION "Copy slot digits to window", ROMX[$60DF], BANK[4]
INCLUDE "src/copy_slot_digits_to_window.asm"

CopySlotDigitsToWindowEnd:

SECTION "Blank slot digit rows", ROMX[$6160], BANK[4]
INCLUDE "src/blank_slot_digit_rows.asm"

BlankSlotDigitRowsEnd:

SECTION "Blank choice window strips", ROMX[$618B], BANK[4]
INCLUDE "src/blank_choice_window_strips.asm"

BlankChoiceWindowStripsEnd:

SECTION "Opcode 25 map list table", ROMX[$61C3], BANK[4]
; opcode25_map_list_table.asm: not published here (it assembles data copied from the ROM)
Opcode25MapListTable:
    INCBIN "roms/magination.gbc", $121C3, $28

Opcode25MapListTableEnd:

SECTION "Countdown panel callbacks", ROMX[$61EB], BANK[4]
INCLUDE "src/countdown_panel_callbacks.asm"

CountdownPanelCallbacksEnd:

SECTION "Copy VRAM 9000 to WRAM 4", ROMX[$624E], BANK[4]
INCLUDE "src/copy_vram9000_to_wram4.asm"

CopyVRAM9000ToWRAM4End:

SECTION "Copy VRAM 8000 to WRAM 6", ROMX[$6277], BANK[4]
INCLUDE "src/copy_vram8000_to_wram6.asm"

CopyVRAM8000ToWRAM6End:

SECTION "Copy C7AB to CC02", ROMX[$628F], BANK[4]
INCLUDE "src/copy_c7ab_to_cc02.asm"

CopyC7ABToCC02End:

SECTION "Clear scroll and panel bytes", ROMX[$629C], BANK[4]
INCLUDE "src/clear_scroll_and_panel_bytes.asm"

ClearScrollAndPanelBytesEnd:

SECTION "Restore saved tiles", ROMX[$62BE], BANK[4]
INCLUDE "src/restore_saved_tiles.asm"

RestoreSavedTilesEnd:

SECTION "Wait until C9AE", ROMX[$632E], BANK[4]
INCLUDE "src/wait_until_c9ae.asm"

WaitUntilC9AEEnd:

SECTION "LCD off setup", ROMX[$6346], BANK[4]
INCLUDE "src/lcd_off_setup.asm"

LcdOffSetupEnd:

SECTION "Clear map scroll bytes", ROMX[$63D9], BANK[4]
INCLUDE "src/clear_map_scroll_bytes.asm"

ClearMapScrollBytesEnd:

SECTION "Opcode 25 bank 4", ROMX[$6416], BANK[4]
INCLUDE "src/opcode_25_bank4.asm"

Opcode25Bank4End:

SECTION "Setup cleared map view", ROMX[$6439], BANK[4]
INCLUDE "src/setup_cleared_map_view.asm"

SetupClearedMapViewEnd:

SECTION "Load entry glyph source", ROMX[$648D], BANK[4]
INCLUDE "src/load_entry_glyph.asm"

LoadEntryGlyphSourceEnd:

SECTION "Load selected entry bits", ROMX[$64C9], BANK[4]
INCLUDE "src/load_selected_entry_bits.asm"

LoadSelectedEntryBitsEnd:

SECTION "Load selected panel byte", ROMX[$64EB], BANK[4]
INCLUDE "src/load_selected_panel_byte.asm"

LoadSelectedPanelByteEnd:

SECTION "Stage panel glyph dest", ROMX[$6542], BANK[4]
INCLUDE "src/stage_panel_glyph_dest.asm"

StagePanelGlyphDestEnd:

SECTION "Paint lower map and window attrs", ROMX[$65CF], BANK[4]
INCLUDE "src/paint_lower_map_and_window_attrs.asm"

PaintLowerMapAndWindowAttrsEnd:

SECTION "Paint panel index 0 attrs", ROMX[$660B], BANK[4]
INCLUDE "src/paint_panel_index0_attrs.asm"

PaintPanelIndex0AttrsEnd:

SECTION "Paint panel index 1 attrs", ROMX[$6693], BANK[4]
INCLUDE "src/paint_panel_index1_attrs.asm"

PaintPanelIndex1AttrsEnd:

SECTION "Paint panel index 2 attrs", ROMX[$671B], BANK[4]
INCLUDE "src/paint_panel_index2_attrs.asm"

SECTION "Paint panel index 3 attrs", ROMX[$67A3], BANK[4]
INCLUDE "src/paint_panel_index3_attrs.asm"

SECTION "Paint panel index 4 attrs", ROMX[$682B], BANK[4]
INCLUDE "src/paint_panel_index4_attrs.asm"

SECTION "Paint panel index 5 attrs", ROMX[$68B3], BANK[4]
INCLUDE "src/paint_panel_index5_attrs.asm"

SECTION "Paint panel index 6 attrs", ROMX[$693B], BANK[4]
INCLUDE "src/paint_panel_index6_attrs.asm"

SECTION "Paint panel index 7 attrs", ROMX[$69C3], BANK[4]
INCLUDE "src/paint_panel_index7_attrs.asm"

SECTION "Apply offset mask to VRAM byte", ROMX[$6A4B], BANK[4]
INCLUDE "src/apply_offset_mask_to_vram_byte.asm"

ApplyOffsetMaskToVramByteEnd:

SECTION "Apply indexed row mask", ROMX[$6A5E], BANK[4]
INCLUDE "src/apply_indexed_row_mask.asm"

ApplyIndexedRowMaskEnd:

SECTION "Advance row mask sweep", ROMX[$6A82], BANK[4]
INCLUDE "src/advance_row_mask_sweep.asm"

AdvanceRowMaskSweepEnd:

SECTION "Step row mask VRAM", ROMX[$6ABF], BANK[4]
INCLUDE "src/step_row_mask_vram.asm"

StepRowMaskVramEnd:

SECTION "Return at 6AF9", ROMX[$6AF9], BANK[4]
INCLUDE "src/return_6af9.asm"

Return6AF9End:

SECTION "Seed row mask and record", ROMX[$6AFA], BANK[4]
INCLUDE "src/seed_row_mask_and_record.asm"

SeedRowMaskAndRecordEnd:

SECTION "Gap before record 6BDC", ROMX[$6B3C], BANK[4]
; gap_before_record_6bdc.asm: not published here (it assembles data copied from the ROM)
GapBeforeRecord6BDC:
    INCBIN "roms/magination.gbc", $12B3C, $40

GapBeforeRecord6BDCEnd:

SECTION "Run 3 pairs before record 6BDC", ROMX[$6B7C], BANK[4]
; run3_pairs_before_record_6bdc.asm: not published here (it assembles data copied from the ROM)
Run3PairsBeforeRecord6BDC:
    INCBIN "roms/magination.gbc", $12B7C, $40

Run3PairsBeforeRecord6BDCEnd:

SECTION "Run 3 tail before record 6BDC", ROMX[$6BBC], BANK[4]
; run3_tail_before_record_6bdc.asm: not published here (it assembles data copied from the ROM)
Run3TailBeforeRecord6BDC:
    INCBIN "roms/magination.gbc", $12BBC, $20

Run3TailBeforeRecord6BDCEnd:

SECTION "Record 30", ROMX[$6BDC], BANK[4]
; record_30.asm: not published here (it assembles data copied from the ROM)
Record30:
    INCBIN "roms/magination.gbc", $12BDC, $30

Record30End:

SECTION "Limit 30 record", ROMX[$6C0C], BANK[4]
; limit_30_record.asm: not published here (it assembles data copied from the ROM)
Limit30Record:
    INCBIN "roms/magination.gbc", $12C0C, $30

Limit30RecordEnd:

SECTION "Limit 24 record", ROMX[$6C3C], BANK[4]
; limit_24_record.asm: not published here (it assembles data copied from the ROM)
Limit24Record:
    INCBIN "roms/magination.gbc", $12C3C, $24

Limit24RecordEnd:

SECTION "Limit 54 record", ROMX[$6C60], BANK[4]
; limit_54_record.asm: not published here (it assembles data copied from the ROM)
Limit54Record:
    INCBIN "roms/magination.gbc", $12C60, $3F

Limit54RecordEnd:

SECTION "Limit 54 record tail", ROMX[$6C9F], BANK[4]
; limit_54_record_tail.asm: not published here (it assembles data copied from the ROM)
Limit54RecordTail:
    INCBIN "roms/magination.gbc", $12C9F, $15

Limit54RecordTailEnd:

SECTION "Limit A8 record", ROMX[$6CB4], BANK[4]
; limit_a8_record.asm: not published here (it assembles data copied from the ROM)
LimitA8Record:
    INCBIN "roms/magination.gbc", $12CB4, $3F

LimitA8RecordEnd:

SECTION "Limit A8 record mid", ROMX[$6CF3], BANK[4]
; limit_a8_record_mid.asm: not published here (it assembles data copied from the ROM)
LimitA8RecordMid:
    INCBIN "roms/magination.gbc", $12CF3, $3F

SECTION "Limit A8 record tail", ROMX[$6D32], BANK[4]
; limit_a8_record_tail.asm: not published here (it assembles data copied from the ROM)
LimitA8RecordMidEnd:
LimitA8RecordTail:
    INCBIN "roms/magination.gbc", $12D32, $2A

SECTION "Limit 1D record", ROMX[$6D5C], BANK[4]
; limit_1d_record.asm: not published here (it assembles data copied from the ROM)
Limit1DRecord:
LimitA8RecordTailEnd:
    INCBIN "roms/magination.gbc", $12D5C, $1D

SECTION "Nibble 33 CC pairs", ROMX[$6D79], BANK[4]
; nibble_33_cc_pairs.asm: not published here (it assembles data copied from the ROM)
Limit1DRecordEnd:
Nibble33CcPairs:
    INCBIN "roms/magination.gbc", $12D79, $40

SECTION "Row mask pairs at $6DB9", ROMX[$6DB9], BANK[4]
; row_mask_pairs_6db9.asm: not published here (it assembles data copied from the ROM)
Nibble33CcPairsEnd:
RowMaskPairs6DB9:
    INCBIN "roms/magination.gbc", $12DB9, $30

SECTION "Row mask pairs at $6DB9 @$012DE9", ROMX[$6DE9], BANK[4]
RowMaskZeroPtr6DE9:
    INCBIN "roms/magination.gbc", $12DE9, $10

RowMaskPairs6DB9End:

SECTION "Nibble 33 CC pair pointers", ROMX[$6DF9], BANK[4]
; nibble_33_cc_pair_ptrs.asm: not published here (it assembles data copied from the ROM)
Nibble33CcPairPtrs:
    INCBIN "roms/magination.gbc", $12DF9, $20

Nibble33CcPairPtrsEnd:

SECTION "Row mask first four pointers", ROMX[$6E19], BANK[4]
; row_mask_first_four_ptrs.asm: not published here (it assembles data copied from the ROM)
RowMaskFirstFourPtrs:
    INCBIN "roms/magination.gbc", $12E19, $8

RowMaskFirstFourPtrsEnd:

SECTION "Record triples at $6E21", ROMX[$6E21], BANK[4]
; record_triples_6e21.asm: not published here (it assembles data copied from the ROM)
RecordTripleId00:
RecordTriples6E21:
    INCBIN "roms/magination.gbc", $12E21, $13

SECTION "Record triples at $6E21 @$012E34", ROMX[$6E34], BANK[4]
RecordTripleId10:
    INCBIN "roms/magination.gbc", $12E34, $13

SECTION "Record triples at $6E21 @$012E47", ROMX[$6E47], BANK[4]
RecordTripleId20:
    INCBIN "roms/magination.gbc", $12E47, $13

RecordTriples6E21End:

SECTION "Record triples at $6E5A", ROMX[$6E5A], BANK[4]
; record_triples_6e5a.asm: not published here (it assembles data copied from the ROM)
RecordTripleId30:
RecordTriples6E5A:
    INCBIN "roms/magination.gbc", $12E5A, $13

SECTION "Record triples at $6E5A @$012E6D", ROMX[$6E6D], BANK[4]
RecordTripleId40:
    INCBIN "roms/magination.gbc", $12E6D, $13

SECTION "Record triples at $6E5A @$012E80", ROMX[$6E80], BANK[4]
RecordTripleId50:
    INCBIN "roms/magination.gbc", $12E80, $13

RecordTriples6E5AEnd:

SECTION "Record triples at $6E93", ROMX[$6E93], BANK[4]
; record_triples_6e93.asm: not published here (it assembles data copied from the ROM)
RecordTripleId60:
RecordTriples6E93:
    INCBIN "roms/magination.gbc", $12E93, $13

SECTION "Record triples at $6E93 @$012EA6", ROMX[$6EA6], BANK[4]
RecordTripleId70:
    INCBIN "roms/magination.gbc", $12EA6, $13

SECTION "Record triples at $6E93 @$012EB9", ROMX[$6EB9], BANK[4]
RecordTripleId80:
    INCBIN "roms/magination.gbc", $12EB9, $13

RecordTriples6E93End:

SECTION "Record triples at $6ECC", ROMX[$6ECC], BANK[4]
; record_triples_6ecc.asm: not published here (it assembles data copied from the ROM)
RecordTripleId90:
RecordTriples6ECC:
    INCBIN "roms/magination.gbc", $12ECC, $13

SECTION "Record triples at $6ECC @$012EDF", ROMX[$6EDF], BANK[4]
RecordTripleIdA0:
    INCBIN "roms/magination.gbc", $12EDF, $13

SECTION "Record triples at $6ECC @$012EF2", ROMX[$6EF2], BANK[4]
RecordTripleIdB0:
    INCBIN "roms/magination.gbc", $12EF2, $13

RecordTriples6ECCEnd:

SECTION "Record triples at $6F05", ROMX[$6F05], BANK[4]
; record_triples_6f05.asm: not published here (it assembles data copied from the ROM)
RecordTripleIdC0:
RecordTriples6F05:
    INCBIN "roms/magination.gbc", $12F05, $13

SECTION "Record triples at $6F05 @$012F18", ROMX[$6F18], BANK[4]
RecordTripleIdD0:
    INCBIN "roms/magination.gbc", $12F18, $13

SECTION "Record triples at $6F05 @$012F2B", ROMX[$6F2B], BANK[4]
RecordTripleSlotPtrs:
    INCBIN "roms/magination.gbc", $12F2B, $11

RecordTriples6F05End:

SECTION "Record triple pointer tail", ROMX[$6F3C], BANK[4]
; record_triple_ptr_tail.asm: not published here (it assembles data copied from the ROM)
RecordTriplePtrTail:
    INCBIN "roms/magination.gbc", $12F3C, $B

RecordTriplePtrTailEnd:

SECTION "Fill entry map tile 80", ROMX[$6F47], BANK[4]
INCLUDE "src/fill_entry_map_tile80_vram0.asm"

FillEntryMapTile80VRAM0End:

SECTION "Fill entry map attr 08", ROMX[$6F60], BANK[4]
INCLUDE "src/fill_entry_map_attr08_vram1.asm"

FillEntryMapAttr08VRAM1End:

SECTION "Fill entry map 9C00 attr", ROMX[$6F79], BANK[4]
INCLUDE "src/fill_entry_map_9c00_attr_vram1.asm"

FillEntryMap9C00AttrVRAM1End:

SECTION "Fill entry map 9C00 tile 80", ROMX[$6F9E], BANK[4]
INCLUDE "src/fill_entry_map_9c00_tile80_vram0.asm"

FillEntryMap9C00Tile80VRAM0End:

SECTION "Table word for C9E4", ROMX[$6FAB], BANK[4]
INCLUDE "src/table_word_for_c9e4.asm"

TableWordForC9E4End:

SECTION "Copy entry record field", ROMX[$6FC5], BANK[4]
INCLUDE "src/copy_entry_record_field.asm"

CopyEntryRecordFieldEnd:

SECTION "Store indexed ptr plus 11", ROMX[$7016], BANK[4]
INCLUDE "src/store_indexed_ptr_plus_11.asm"

StoreIndexedPtrPlus11End:

SECTION "Record pointer from id", ROMX[$7029], BANK[4]
INCLUDE "src/record_ptr_from_id.asm"

RecordPtrFromIdEnd:

SECTION "Apply C9E4 table entry", ROMX[$704B], BANK[4]
INCLUDE "src/apply_c9e4_table_entry.asm"

ApplyC9E4TableEntryEnd:

SECTION "Present entry record by panel slot", ROMX[$7055], BANK[4]
INCLUDE "src/present_entry_record_by_panel_slot.asm"

PresentEntryRecordByPanelSlotEnd:

SECTION "Copy entry record field eleven", ROMX[$7069], BANK[4]
INCLUDE "src/copy_entry_record_field_eleven.asm"

CopyEntryRecordFieldElevenEnd:

SECTION "Step planted record", ROMX[$709E], BANK[4]
INCLUDE "src/step_planted_record.asm"

StepPlantedRecordEnd:

SECTION "Step script pair countdown", ROMX[$711C], BANK[4]
INCLUDE "src/step_script_pair_countdown.asm"

StepScriptPairCountdownEnd:

SECTION "Step scroll by script pair", ROMX[$715B], BANK[4]
INCLUDE "src/step_scroll_by_script_pair.asm"

StepScrollByScriptPairEnd:

SECTION "XOR then clamp entry map $9C00", ROMX[$718B], BANK[4]
INCLUDE "src/xor_then_clamp_entry_map_9c00.asm"

XorThenClampEntryMap9C00End:

SECTION "Poll script loop buttons", ROMX[$71A6], BANK[4]
INCLUDE "src/poll_script_loop_buttons.asm"

PollScriptLoopButtonsEnd:

SECTION "Script loop B press", ROMX[$71CE], BANK[4]
INCLUDE "src/script_loop_b_press.asm"

HandleScriptLoopBEnd:

SECTION "Run staged pointer script", ROMX[$71ED], BANK[4]
INCLUDE "src/run_staged_pointer_script.asm"

RunStagedPointerScriptEnd:

SECTION "Present installed script entries", ROMX[$722E], BANK[4]
INCLUDE "src/present_installed_script_entries.asm"

PresentInstalledScriptEntriesEnd:

SECTION "Script loop B panel frames", ROMX[$72B4], BANK[4]
INCLUDE "src/script_loop_b_panel_frames.asm"

ScriptLoopBPanelFramesEnd:

SECTION "Seed script scroll and record", ROMX[$72ED], BANK[4]
INCLUDE "src/seed_script_scroll_and_record.asm"

SeedScriptScrollAndRecordEnd:

SECTION "Apply C9BC scroll then frame", ROMX[$734D], BANK[4]
INCLUDE "src/apply_c9bc_scroll_then_frame.asm"

ApplyC9BCScrollThenFrameEnd:

SECTION "Scale E by D into C9C0", ROMX[$73AA], BANK[4]
INCLUDE "src/scale_e_by_d_into_c9c0.asm"

SECTION "Plant 6C0C limit 30", ROMX[$73E7], BANK[4]
INCLUDE "src/plant_6c0c_limit_30.asm"

SECTION "Clear scroll scale and point vblank 37AA", ROMX[$73FE], BANK[4]
INCLUDE "src/clear_scroll_scale_and_point_vblank_37aa.asm"

ClearScrollScaleAndPointVBlank37AAEnd:

SECTION "Clear C9C8 and install default handlers", ROMX[$7413], BANK[4]
INCLUDE "src/clear_c9c8_and_install_default_handlers.asm"

SECTION "Opcode 60 counted VRAM lists", ROMX[$742C], BANK[4]
; opcode60_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode60CountedVramLists:
    INCBIN "roms/magination.gbc", $1342C, $1E

Opcode60CountedVramListsEnd:

SECTION "Opcode 63 counted VRAM lists", ROMX[$744A], BANK[4]
; opcode63_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode63CountedVramLists:
    INCBIN "roms/magination.gbc", $1344A, $1E

Opcode63CountedVramListsEnd:

SECTION "Opcode 64 counted VRAM lists", ROMX[$7468], BANK[4]
; opcode64_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode64CountedVramLists:
    INCBIN "roms/magination.gbc", $13468, $1E

Opcode64CountedVramListsEnd:

SECTION "Opcode 65 counted VRAM lists", ROMX[$7486], BANK[4]
; opcode65_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode65CountedVramLists:
    INCBIN "roms/magination.gbc", $13486, $1E

Opcode65CountedVramListsEnd:

SECTION "Opcode 66 counted VRAM lists", ROMX[$74A4], BANK[4]
; opcode66_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode66CountedVramLists:
    INCBIN "roms/magination.gbc", $134A4, $1E

Opcode66CountedVramListsEnd:

SECTION "Opcode 67 counted VRAM lists", ROMX[$74C2], BANK[4]
; opcode67_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode67CountedVramLists:
    INCBIN "roms/magination.gbc", $134C2, $1E

Opcode67CountedVramListsEnd:

SECTION "Opcode 68 counted VRAM lists", ROMX[$74E0], BANK[4]
; opcode68_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode68CountedVramLists:
    INCBIN "roms/magination.gbc", $134E0, $1E

Opcode68CountedVramListsEnd:

SECTION "Opcode 69 counted VRAM lists", ROMX[$74FE], BANK[4]
; opcode69_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode69CountedVramLists:
    INCBIN "roms/magination.gbc", $134FE, $1E

Opcode69CountedVramListsEnd:

SECTION "Opcode 6A counted VRAM lists", ROMX[$751C], BANK[4]
; opcode6a_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode6ACountedVramLists:
    INCBIN "roms/magination.gbc", $1351C, $1E

Opcode6ACountedVramListsEnd:

SECTION "Opcode 5D counted VRAM lists", ROMX[$753A], BANK[4]
; opcode5d_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode5DCountedVramLists:
    INCBIN "roms/magination.gbc", $1353A, $1E

Opcode5DCountedVramListsEnd:

SECTION "Opcode 5B counted VRAM lists", ROMX[$7558], BANK[4]
; opcode5b_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode5BCountedVramLists:
    INCBIN "roms/magination.gbc", $13558, $1E

Opcode5BCountedVramListsEnd:

SECTION "Opcode 5F counted VRAM lists", ROMX[$7576], BANK[4]
; opcode5f_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode5FCountedVramLists:
    INCBIN "roms/magination.gbc", $13576, $1E

Opcode5FCountedVramListsEnd:

SECTION "Opcode 5A counted VRAM lists", ROMX[$7594], BANK[4]
; opcode5a_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode5ACountedVramLists:
    INCBIN "roms/magination.gbc", $13594, $1E

Opcode5ACountedVramListsEnd:

SECTION "Opcode 6B counted VRAM lists", ROMX[$75B2], BANK[4]
; opcode6b_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode6BCountedVramLists:
    INCBIN "roms/magination.gbc", $135B2, $1E

Opcode6BCountedVramListsEnd:

SECTION "Opcode 59 counted VRAM lists", ROMX[$75D0], BANK[4]
; opcode59_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode59CountedVramLists:
    INCBIN "roms/magination.gbc", $135D0, $1E

Opcode59CountedVramListsEnd:

SECTION "Opcode 5C counted VRAM lists", ROMX[$75EE], BANK[4]
; opcode5c_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode5CCountedVramLists:
    INCBIN "roms/magination.gbc", $135EE, $1E

Opcode5CCountedVramListsEnd:

SECTION "Opcode 5E counted VRAM lists", ROMX[$760C], BANK[4]
; opcode5e_counted_vram_lists.asm: not published here (it assembles data copied from the ROM)
Opcode5ECountedVramLists:
    INCBIN "roms/magination.gbc", $1360C, $1E

Opcode5ECountedVramListsEnd:

SECTION "Bank 4 nop fill at 762A", ROMX[$762A], BANK[4]
INCLUDE "src/bank4_nop_fill_762a.asm"

Bank4NopFill762AEnd:

SECTION "Bank 4 nop fill at 78FE", ROMX[$78FE], BANK[4]
INCLUDE "src/bank4_nop_fill_78fe.asm"

Bank4NopFill78FEEnd:

SECTION "Bank 4 unused tail", ROMX[$7CFE], BANK[4]
INCLUDE "src/bank4_unused_tail.asm"

SECTION "D103 word table", ROMX[$4000], BANK[5]
; d103_word_table.asm: not published here (it assembles data copied from the ROM)
D103WordTable:
    INCBIN "roms/magination.gbc", $14000, $2A

SECTION "D0B0 word table", ROMX[$402A], BANK[5]
; d0b0_word_table.asm: not published here (it assembles data copied from the ROM)
D0B0WordTable:
    INCBIN "roms/magination.gbc", $1402A, $2A

SECTION "D104 word table", ROMX[$4054], BANK[5]
; d104_word_table.asm: not published here (it assembles data copied from the ROM)
D104WordTable:
    INCBIN "roms/magination.gbc", $14054, $8

SECTION "Mark D075 bit and D091", ROMX[$405C], BANK[5]
INCLUDE "src/mark_d075_bit_and_d091.asm"

SECTION "Step D074 ranges in bank 7", ROMX[$407C], BANK[5]
INCLUDE "src/step_d074_ranges_in_bank7.asm"

SECTION "Run pair id scripts", ROMX[$4109], BANK[5]
INCLUDE "src/run_pair_id_scripts.asm"

RunPairIdScriptsEnd:

SECTION "Flag D019 for low D018 slot", ROMX[$4159], BANK[5]
INCLUDE "src/flag_d019_for_low_d018_slot.asm"

FlagD019ForLowD018SlotEnd:

SECTION "Flag D019 for high D018 slot", ROMX[$41E7], BANK[5]
INCLUDE "src/flag_d019_for_high_d018_slot.asm"

FlagD019ForHighD018SlotEnd:

SECTION "Flag D019 when D074 hits nine", ROMX[$4275], BANK[5]
INCLUDE "src/flag_d019_when_d074_hits_nine.asm"

FlagD019WhenD074HitsNineEnd:

SECTION "Flag D019 for copied D0B0", ROMX[$42B9], BANK[5]
INCLUDE "src/flag_d019_for_copied_d0b0.asm"

SECTION "Apply half D06C then maybe scan", ROMX[$42F6], BANK[5]
INCLUDE "src/apply_half_d06c_then_maybe_scan.asm"

ApplyHalfD06CThenMaybeScanEnd:

SECTION "Dispatch if D0E0 above D102", ROMX[$43E6], BANK[5]
INCLUDE "src/dispatch_if_d0e0_above_d102.asm"

DispatchIfD0E0AboveD102End:

SECTION "Copy three place digit glyphs", ROMX[$4430], BANK[5]
INCLUDE "src/copy_three_place_digit_glyphs.asm"

CopyThreePlaceDigitGlyphsEnd:

SECTION "Select D091 mark after D0B5", ROMX[$44F4], BANK[5]
INCLUDE "src/select_d091_mark_after_d0b5.asm"

SelectD091MarkAfterD0B5End:

SECTION "Set D071 and plant C71B script 4299", ROMX[$4595], BANK[5]
INCLUDE "src/set_d071_plant_c71b_script_4299.asm"

SetD071PlantC71BScript4299End:

SECTION "Run D0B1 map strips", ROMX[$45B0], BANK[5]
INCLUDE "src/run_d0b1_map_strips.asm"

RunD0B1MapStripsEnd:

SECTION "Finish D0B1 map strips", ROMX[$4967], BANK[5]
INCLUDE "src/finish_d0b1_map_strips.asm"

FinishD0B1MapStripsEnd:

SECTION "Fill ASCII slot counts", ROMX[$4A9D], BANK[5]
INCLUDE "src/fill_ascii_slot_counts.asm"

FillAsciiSlotCountsEnd:

SECTION "Write D023 value colon cap", ROMX[$4B05], BANK[5]
INCLUDE "src/write_d023_value_colon_cap.asm"

WriteD023ValueColonCapEnd:

SECTION "Set D0B4 unless D113 is 0C", ROMX[$4B45], BANK[5]
INCLUDE "src/set_d0b4_unless_d113_is_0c.asm"

SetD0B4UnlessD113Is0CEnd:

SECTION "Prepare A3A7 group or ret", ROMX[$4B51], BANK[5]
INCLUDE "src/prepare_a3a7_group_or_ret.asm"

PrepareA3A7GroupOrRetEnd:

SECTION "Continue A3A7 group", ROMX[$4BAA], BANK[5]
INCLUDE "src/continue_a3a7_group.asm"

ContinueA3A7GroupEnd:

SECTION "Load five SRAM entry digits", ROMX[$4F54], BANK[5]
INCLUDE "src/load_five_sram_entry_digits.asm"

LoadFiveSramEntryDigitsEnd:

SECTION "Paint entry digits and choose", ROMX[$5243], BANK[5]
INCLUDE "src/paint_entry_digits_and_choose.asm"

PaintEntryDigitsAndChooseEnd:

SECTION "Setup D104 word 3 bases", ROMX[$5553], BANK[5]
INCLUDE "src/setup_d104_word3_bases.asm"

SetupD104Word3BasesEnd:

SECTION "Write indexed names and count", ROMX[$5575], BANK[5]
INCLUDE "src/write_indexed_names_and_count.asm"

WriteIndexedNamesAndCountEnd:

SECTION "Copy indexed name then other list", ROMX[$55E0], BANK[5]
INCLUDE "src/copy_indexed_name_then_other_list.asm"

CopyIndexedNameThenOtherListEnd:

SECTION "Plant marked name and count", ROMX[$560E], BANK[5]
INCLUDE "src/plant_marked_name_and_count.asm"

PlantMarkedNameAndCountEnd:

SECTION "Write name field and second name", ROMX[$5657], BANK[5]
INCLUDE "src/write_name_field_and_second_name.asm"

WriteNameFieldAndSecondNameEnd:

SECTION "Load selected record to D100", ROMX[$56AF], BANK[5]
INCLUDE "src/load_selected_record_to_d100.asm"

LoadSelectedRecordToD100End:

SECTION "Pick D0B8 entry or FF", ROMX[$5762], BANK[5]
INCLUDE "src/pick_d0b8_entry_or_ff.asm"

PickD0B8EntryOrFFEnd:

SECTION "Call word at 4054 for D104", ROMX[$578B], BANK[5]
INCLUDE "src/call_word_at_4054_for_d104.asm"

SECTION "Plant slot 11 when D0C0 is one", ROMX[$579D], BANK[5]
INCLUDE "src/plant_slot_11_when_d0c0_is_one.asm"

SECTION "Apply indexed id record", ROMX[$57BA], BANK[5]
INCLUDE "src/apply_indexed_id_record.asm"

ApplyIndexedIdRecordEnd:

SECTION "Apply fixed id record at 5E2D", ROMX[$57E5], BANK[5]
INCLUDE "src/apply_fixed_id_record_5e2d.asm"

ApplyFixedIdRecord5E2DEnd:

SECTION "Mask D092 halves for D0B0", ROMX[$57FE], BANK[5]
INCLUDE "src/mask_d092_halves_for_d0b0.asm"

MaskD092HalvesForD0B0End:

SECTION "Mark D09B then clear ten", ROMX[$58A6], BANK[5]
INCLUDE "src/mark_d09b_then_clear_ten.asm"

MarkD09BThenClearTenEnd:

SECTION "Copy D092 strip for D0B0", ROMX[$58BD], BANK[5]
INCLUDE "src/copy_d092_strip_for_d0b0.asm"

CopyD092StripForD0B0End:

SECTION "Spin word 0 of 4054", ROMX[$5909], BANK[5]
INCLUDE "src/spin_word0_of_4054.asm"

SECTION "Wait for CCA7 choice", ROMX[$590B], BANK[5]
INCLUDE "src/wait_cca7_choice.asm"

WaitForCca7ChoiceEnd:

SECTION "Fill D09B strip for D0B0", ROMX[$59B0], BANK[5]
INCLUDE "src/fill_d09b_strip_for_d0b0.asm"

FillD09BStripForD0B0End:

SECTION "Clear nine D09B then set D0A4", ROMX[$5A03], BANK[5]
INCLUDE "src/clear_nine_d09b_set_d0a4.asm"

ClearNineD09BSetD0A4End:

SECTION "Wait until C71D clears", ROMX[$5A1A], BANK[5]
INCLUDE "src/wait_c71d_clear.asm"

WaitUntilC71DClearsEnd:

SECTION "Mark one D09B byte for D0B1", ROMX[$5A24], BANK[5]
INCLUDE "src/mark_d09b_slot_for_d0b1.asm"

MarkD09BSlotForD0B1End:

SECTION "Expire D07E countdowns", ROMX[$5A45], BANK[5]
INCLUDE "src/expire_d07e_countdowns.asm"

ExpireD07ECountdownsEnd:

SECTION "Set D0AF for D103 $16 and $18", ROMX[$5B29], BANK[5]
INCLUDE "src/set_d0af_for_d103_16.asm"

SetD0AFForD103SixteenEnd:

SECTION "Set D0AF for D103 $14 and $15", ROMX[$5B91], BANK[5]
INCLUDE "src/set_d0af_for_d103_14.asm"

SetD0AFForD103FourteenEnd:

SECTION "Set D0AF for D103 $0F", ROMX[$5BCE], BANK[5]
INCLUDE "src/set_d0af_for_d103_0f.asm"

SetD0AFForD1030FEnd:

SECTION "Set D0AF for D103 $0E", ROMX[$5BE7], BANK[5]
INCLUDE "src/set_d0af_for_d103_0e.asm"

SetD0AFForD1030EEnd:

SECTION "Set D0AF for D103 $0A", ROMX[$5BFE], BANK[5]
INCLUDE "src/set_d0af_for_d103_0a.asm"

SetD0AFForD1030AEnd:

SECTION "Set D0AF for D103 $0C and $0D", ROMX[$5C04], BANK[5]
INCLUDE "src/set_d0af_for_d103_0c.asm"

SetD0AFForD1030CEnd:

SECTION "Set D0AF for D103 $10 and $11", ROMX[$5C44], BANK[5]
INCLUDE "src/set_d0af_for_d103_10.asm"

SetD0AFForD103TenEnd:

SECTION "Paint choice tile block", ROMX[$5C81], BANK[5]
INCLUDE "src/paint_choice_tile_block.asm"

PaintChoiceTileBlockEnd:

SECTION "Indexed id record bases", ROMX[$5CF1], BANK[5]
; indexed_id_record_bases.asm: not published here (it assembles data copied from the ROM)
IndexedIdRecordBaseTable:
    INCBIN "roms/magination.gbc", $15CF1, $28

IndexedIdRecordBaseTableEnd:

SECTION "Indexed id records for D0C2 $63", ROMX[$5D19], BANK[5]
; indexed_id_records_63.asm: not published here (it assembles data copied from the ROM)
IndexedIdRecords63:
    INCBIN "roms/magination.gbc", $15D19, $3C

IndexedIdRecords63End:

SECTION "Indexed id records for D0C2 $67", ROMX[$5D55], BANK[5]
; indexed_id_records_67.asm: not published here (it assembles data copied from the ROM)
IndexedIdRecords67:
    INCBIN "roms/magination.gbc", $15D55, $3C

IndexedIdRecords67End:

SECTION "Indexed id records for D0C2 $60", ROMX[$5D91], BANK[5]
; indexed_id_records_60.asm: not published here (it assembles data copied from the ROM)
IndexedIdRecords60:
    INCBIN "roms/magination.gbc", $15D91, $F

IndexedIdRecords60End:

SECTION "Indexed id records for D0C2 $5D", ROMX[$5DA0], BANK[5]
; indexed_id_records_5d.asm: not published here (it assembles data copied from the ROM)
IndexedIdRecords5D:
    INCBIN "roms/magination.gbc", $15DA0, $F

IndexedIdRecords5DEnd:

SECTION "Indexed id records for D0C2 $5B", ROMX[$5DAF], BANK[5]
; indexed_id_records_5b.asm: not published here (it assembles data copied from the ROM)
IndexedIdRecords5B:
    INCBIN "roms/magination.gbc", $15DAF, $F

IndexedIdRecords5BEnd:

SECTION "Indexed id records for D0C2 $5F", ROMX[$5DBE], BANK[5]
; indexed_id_records_5f.asm: not published here (it assembles data copied from the ROM)
IndexedIdRecords5F:
    INCBIN "roms/magination.gbc", $15DBE, $F

IndexedIdRecords5FEnd:

SECTION "Indexed id records for D0C2 $5A", ROMX[$5DCD], BANK[5]
; indexed_id_records_5a.asm: not published here (it assembles data copied from the ROM)
IndexedIdRecords5A:
    INCBIN "roms/magination.gbc", $15DCD, $F

IndexedIdRecords5AEnd:

SECTION "Indexed id records for D0C2 $59", ROMX[$5DDC], BANK[5]
; indexed_id_records_59.asm: not published here (it assembles data copied from the ROM)
IndexedIdRecords59:
    INCBIN "roms/magination.gbc", $15DDC, $F

IndexedIdRecords59End:

SECTION "Indexed id records for D0C2 $5C", ROMX[$5DEB], BANK[5]
; indexed_id_records_5c.asm: not published here (it assembles data copied from the ROM)
IndexedIdRecords5C:
    INCBIN "roms/magination.gbc", $15DEB, $F

IndexedIdRecords5CEnd:

SECTION "Indexed id records for D0C2 $5E", ROMX[$5DFA], BANK[5]
; indexed_id_records_5e.asm: not published here (it assembles data copied from the ROM)
IndexedIdRecords5E:
    INCBIN "roms/magination.gbc", $15DFA, $F

IndexedIdRecords5EEnd:

SECTION "Indexed id records for D0C2 $58", ROMX[$5E09], BANK[5]
; indexed_id_records_58.asm: not published here (it assembles data copied from the ROM)
IndexedIdRecords58:
    INCBIN "roms/magination.gbc", $15E09, $15

IndexedIdRecords58End:

SECTION "Indexed id records for D0C2 $6B", ROMX[$5E1E], BANK[5]
; indexed_id_records_6b.asm: not published here (it assembles data copied from the ROM)
IndexedIdRecords6B:
    INCBIN "roms/magination.gbc", $15E1E, $F

SECTION "Indexed id records for D0C2 $6B @$015E2D", ROMX[$5E2D], BANK[5]
FixedIdRecords5E2D:
    INCBIN "roms/magination.gbc", $15E2D, $18

IndexedIdRecords6BEnd:

SECTION "Load pointed byte to D", ROMX[$5E45], BANK[5]
INCLUDE "src/load_pointed_byte_to_d.asm"

LoadPointedByteToDEnd:

SECTION "Copy 16 from CD8D pointer", ROMX[$5E4D], BANK[5]
INCLUDE "src/copy_ptr16.asm"

CopyPtr16BytesEnd:

SECTION "Fill indexed slot", ROMX[$5E62], BANK[5]
INCLUDE "src/fill_indexed_slot.asm"

FillIndexedSlotEnd:

SECTION "Fight menu record", ROMX[$5EAE], BANK[5]
; fight_menu_record.asm: not published here (it assembles data copied from the ROM)
FightMenuRecord:
    INCBIN "roms/magination.gbc", $15EAE, $10

FightMenuRecordEnd:

SECTION "Summon through Run records", ROMX[$5EBE], BANK[5]
; summon_through_run_records.asm: not published here (it assembles data copied from the ROM)
SummonThroughRunRecords:
    INCBIN "roms/magination.gbc", $15EBE, $40

SummonThroughRunRecordsEnd:

SECTION "Spell through Beam records", ROMX[$5EFE], BANK[5]
; spell_through_beam_records.asm: not published here (it assembles data copied from the ROM)
SpellThroughBeamRecords:
    INCBIN "roms/magination.gbc", $15EFE, $40

SpellThroughBeamRecordsEnd:

SECTION "Bite through Boost records", ROMX[$5F3E], BANK[5]
; bite_through_boost_records.asm: not published here (it assembles data copied from the ROM)
BiteThroughBoostRecords:
    INCBIN "roms/magination.gbc", $15F3E, $40

BiteThroughBoostRecordsEnd:

SECTION "Bramble through Charge records", ROMX[$5F7E], BANK[5]
; bramble_through_charge_records.asm: not published here (it assembles data copied from the ROM)
BrambleThroughChargeRecords:
    INCBIN "roms/magination.gbc", $15F7E, $40

BrambleThroughChargeRecordsEnd:

SECTION "Choke through Consume records", ROMX[$5FBE], BANK[5]
; choke_through_consume_records.asm: not published here (it assembles data copied from the ROM)
ChokeThroughConsumeRecords:
    INCBIN "roms/magination.gbc", $15FBE, $40

ChokeThroughConsumeRecordsEnd:

SECTION "Crack through Crush records", ROMX[$5FFE], BANK[5]
; crack_through_crush_records.asm: not published here (it assembles data copied from the ROM)
CrackThroughCrushRecords:
    INCBIN "roms/magination.gbc", $15FFE, $40

CrackThroughCrushRecordsEnd:

SECTION "Curse through Devour records", ROMX[$603E], BANK[5]
; curse_through_devour_records.asm: not published here (it assembles data copied from the ROM)
CurseThroughDevourRecords:
    INCBIN "roms/magination.gbc", $1603E, $40

CurseThroughDevourRecordsEnd:

SECTION "Dream through Flame records", ROMX[$607E], BANK[5]
; dream_through_flame_records.asm: not published here (it assembles data copied from the ROM)
DreamThroughFlameRecords:
    INCBIN "roms/magination.gbc", $1607E, $40

DreamThroughFlameRecordsEnd:

SECTION "Flash through Frenzy records", ROMX[$60BE], BANK[5]
; flash_through_frenzy_records.asm: not published here (it assembles data copied from the ROM)
FlashThroughFrenzyRecords:
    INCBIN "roms/magination.gbc", $160BE, $40

FlashThroughFrenzyRecordsEnd:

SECTION "Gale through Gust records", ROMX[$60FE], BANK[5]
; gale_through_gust_records.asm: not published here (it assembles data copied from the ROM)
GaleThroughGustRecords:
    INCBIN "roms/magination.gbc", $160FE, $40

GaleThroughGustRecordsEnd:

SECTION "Haunt through Impale records", ROMX[$613E], BANK[5]
; haunt_through_impale_records.asm: not published here (it assembles data copied from the ROM)
HauntThroughImpaleRecords:
    INCBIN "roms/magination.gbc", $1613E, $40

HauntThroughImpaleRecordsEnd:

SECTION "Infect through Jiggle records", ROMX[$617E], BANK[5]
; infect_through_jiggle_records.asm: not published here (it assembles data copied from the ROM)
InfectThroughJiggleRecords:
    INCBIN "roms/magination.gbc", $1617E, $40

InfectThroughJiggleRecordsEnd:

SECTION "Jolt through Magma records", ROMX[$61BE], BANK[5]
; jolt_through_magma_records.asm: not published here (it assembles data copied from the ROM)
JoltThroughMagmaRecords:
    INCBIN "roms/magination.gbc", $161BE, $40

JoltThroughMagmaRecordsEnd:

SECTION "Maul through Mist records", ROMX[$61FE], BANK[5]
; maul_through_mist_records.asm: not published here (it assembles data copied from the ROM)
MaulThroughMistRecords:
    INCBIN "roms/magination.gbc", $161FE, $40

MaulThroughMistRecordsEnd:

SECTION "Munch through Pinch records", ROMX[$623E], BANK[5]
; munch_through_pinch_records.asm: not published here (it assembles data copied from the ROM)
MunchThroughPinchRecords:
    INCBIN "roms/magination.gbc", $1623E, $40

MunchThroughPinchRecordsEnd:

SECTION "Pollen through Pummel records", ROMX[$627E], BANK[5]
; pollen_through_pummel_records.asm: not published here (it assembles data copied from the ROM)
PollenThroughPummelRecords:
    INCBIN "roms/magination.gbc", $1627E, $30

PollenThroughPummelRecordsEnd:

SECTION "Punch through Roots records", ROMX[$62AE], BANK[5]
; punch_through_roots_records.asm: not published here (it assembles data copied from the ROM)
PunchThroughRootsRecords:
    INCBIN "roms/magination.gbc", $162AE, $40

PunchThroughRootsRecordsEnd:

SECTION "Scratch through Shake records", ROMX[$62EE], BANK[5]
; scratch_through_shake_records.asm: not published here (it assembles data copied from the ROM)
ScratchThroughShakeRecords:
    INCBIN "roms/magination.gbc", $162EE, $40

ScratchThroughShakeRecordsEnd:

SECTION "Shield through Slide records", ROMX[$632E], BANK[5]
; shield_through_slide_records.asm: not published here (it assembles data copied from the ROM)
ShieldThroughSlideRecords:
    INCBIN "roms/magination.gbc", $1632E, $40

ShieldThroughSlideRecordsEnd:

SECTION "Soar through Sponge records", ROMX[$636E], BANK[5]
; soar_through_sponge_records.asm: not published here (it assembles data copied from the ROM)
SoarThroughSpongeRecords:
    INCBIN "roms/magination.gbc", $1636E, $40

SoarThroughSpongeRecordsEnd:

SECTION "Spore through Storm records", ROMX[$63AE], BANK[5]
; spore_through_storm_records.asm: not published here (it assembles data copied from the ROM)
SporeThroughStormRecords:
    INCBIN "roms/magination.gbc", $163AE, $40

SporeThroughStormRecordsEnd:

SECTION "Swarm through Tackle records", ROMX[$63EE], BANK[5]
; swarm_through_tackle_records.asm: not published here (it assembles data copied from the ROM)
SwarmThroughTackleRecords:
    INCBIN "roms/magination.gbc", $163EE, $40

SwarmThroughTackleRecordsEnd:

SECTION "Tangle through Thorns records", ROMX[$642E], BANK[5]
; tangle_through_thorns_records.asm: not published here (it assembles data copied from the ROM)
TangleThroughThornsRecords:
    INCBIN "roms/magination.gbc", $1642E, $40

TangleThroughThornsRecordsEnd:

SECTION "Thrust through Tide records", ROMX[$646E], BANK[5]
; thrust_through_tide_records.asm: not published here (it assembles data copied from the ROM)
ThrustThroughTideRecords:
    INCBIN "roms/magination.gbc", $1646E, $40

ThrustThroughTideRecordsEnd:

SECTION "Timber through Vampire records", ROMX[$64AE], BANK[5]
; timber_through_vampire_records.asm: not published here (it assembles data copied from the ROM)
TimberThroughVampireRecords:
    INCBIN "roms/magination.gbc", $164AE, $40

TimberThroughVampireRecordsEnd:

SECTION "Vortex through Wreck records", ROMX[$64EE], BANK[5]
; vortex_through_wreck_records.asm: not published here (it assembles data copied from the ROM)
VortexThroughWreckRecords:
    INCBIN "roms/magination.gbc", $164EE, $30

VortexThroughWreckRecordsEnd:

SECTION "Step class probe table", ROMX[$651E], BANK[5]
; step_class_probe_table.asm: not published here (it assembles data copied from the ROM)
StepClassProbeTable:
    INCBIN "roms/magination.gbc", $1651E, $10

StepClassProbeTableEnd:

SECTION "Step class occupancy handlers", ROMX[$652E], BANK[5]
; step_class_occupancy_handlers.asm: not published here (it assembles data copied from the ROM)
StepClassOccupancyHandlers:
    INCBIN "roms/magination.gbc", $1652E, $40

StepClassOccupancyHandlersEnd:

SECTION "Step class occupancy handlers classes 4-7", ROMX[$656E], BANK[5]
; step_class_occupancy_handlers_4_to_7.asm: not published here (it assembles data copied from the ROM)
StepClassOccupancyHandlers4To7:
    INCBIN "roms/magination.gbc", $1656E, $40

StepClassOccupancyHandlers4To7End:

SECTION "Apply fine X then fine Y", ROMX[$65AE], BANK[5]
INCLUDE "src/apply_fine_x_then_fine_y.asm"

ApplyFineXThenFineYEnd:

SECTION "Apply fine X then Y step", ROMX[$65B5], BANK[5]
INCLUDE "src/apply_fine_x_then_y_step.asm"

ApplyFineXThenYStepEnd:

SECTION "Apply X snap then fine Y", ROMX[$65BC], BANK[5]
INCLUDE "src/apply_x_snap_then_fine_y.asm"

ApplyXSnapThenFineYEnd:

SECTION "Apply X snap then Y step", ROMX[$65C3], BANK[5]
INCLUDE "src/apply_x_snap_then_y_step.asm"

ApplyXSnapThenYStepEnd:

SECTION "Maybe store minus Y then apply", ROMX[$65CA], BANK[5]
INCLUDE "src/maybe_store_minus_y_then_apply.asm"

MaybeStoreMinusYThenApplyEnd:

SECTION "Maybe store plus Y then apply", ROMX[$65E4], BANK[5]
INCLUDE "src/maybe_store_plus_y_then_apply.asm"

MaybeStorePlusYThenApplyEnd:

SECTION "Maybe store either Y then apply", ROMX[$65FF], BANK[5]
INCLUDE "src/maybe_store_either_y_then_apply.asm"

MaybeStoreEitherYThenApplyEnd:

SECTION "Snap X then maybe seed Y", ROMX[$6625], BANK[5]
INCLUDE "src/snap_x_then_maybe_seed_y.asm"

SnapXThenMaybeSeedYEnd:

SECTION "Countdown or snap X then seed minus Y", ROMX[$6636], BANK[5]
INCLUDE "src/countdown_or_snap_x_then_seed_minus_y.asm"

CountdownOrSnapXThenSeedMinusYEnd:

SECTION "Countdown or snap X then seed plus Y", ROMX[$6653], BANK[5]
INCLUDE "src/countdown_or_snap_x_then_seed_plus_y.asm"

CountdownOrSnapXThenSeedPlusYEnd:

SECTION "Snap minus X or apply fine Y", ROMX[$6670], BANK[5]
INCLUDE "src/snap_minus_x_or_apply_fine_y.asm"

SnapMinusXOrApplyFineYEnd:

SECTION "Snap plus X or apply fine Y", ROMX[$668B], BANK[5]
INCLUDE "src/snap_plus_x_or_apply_fine_y.asm"

SnapPlusXOrApplyFineYEnd:

SECTION "Set X step from fine X", ROMX[$66A6], BANK[5]
INCLUDE "src/set_x_step_from_fine_x.asm"

SetXStepFromFineXEnd:

SECTION "Apply fine Y when fine X is eight", ROMX[$66C8], BANK[5]
INCLUDE "src/apply_fine_y_when_fine_x_is_eight.asm"

ApplyFineYWhenFineXIsEightEnd:

SECTION "Seed X step then apply X and Y", ROMX[$66CC], BANK[5]
INCLUDE "src/seed_x_step_then_apply_x_and_y.asm"

SeedXStepThenApplyXAndYEnd:

SECTION "Countdown then seed minus X", ROMX[$66DD], BANK[5]
INCLUDE "src/countdown_then_seed_minus_x.asm"

CountdownThenSeedMinusXEnd:

SECTION "Countdown then seed plus X", ROMX[$66FA], BANK[5]
INCLUDE "src/countdown_then_seed_plus_x.asm"

CountdownThenSeedPlusXEnd:

SECTION "Add X step or snap fine X to eight", ROMX[$6717], BANK[5]
INCLUDE "src/add_x_step_or_snap_fine_x_to_eight.asm"

AddXStepOrSnapFineXToEightEnd:

SECTION "Seed X step from fine X ends", ROMX[$673E], BANK[5]
INCLUDE "src/seed_x_step_from_fine_x_ends.asm"

SeedXStepFromFineXEndsEnd:

SECTION "Apply Y step into fine Y", ROMX[$675A], BANK[5]
INCLUDE "src/apply_y_step_into_fine_y.asm"

ApplyYStepIntoFineYEnd:

SECTION "Seed Y step from fine Y ends", ROMX[$6787], BANK[5]
INCLUDE "src/seed_y_step_from_fine_y_ends.asm"

SeedYStepFromFineYEndsEnd:

SECTION "Select WRAM 5 and adjust record head", ROMX[$67A3], BANK[5]
INCLUDE "src/select_wram5_adjust_record_head.asm"

SelectWRAM5AdjustRecordHeadEnd:

SECTION "Apply fine X delta", ROMX[$67B1], BANK[5]
INCLUDE "src/apply_fine_x_delta.asm"

ApplyFineXDeltaEnd:

SECTION "Apply fine Y delta", ROMX[$67E7], BANK[5]
INCLUDE "src/apply_fine_y_delta.asm"

ApplyFineYDeltaEnd:

SECTION "Save step then apply or dispatch", ROMX[$682D], BANK[5]
INCLUDE "src/save_step_then_apply_or_dispatch.asm"

SECTION "Classify step against fine 8", ROMX[$6884], BANK[5]
INCLUDE "src/classify_step_against_fine8.asm"

ClassifyStepAgainstFine8SectionEnd:

SECTION "Probe cells on up-left step", ROMX[$68DF], BANK[5]
INCLUDE "src/probe_cells_up_left.asm"

ProbeCellsUpLeftEnd:

SECTION "Probe cells on down-left step", ROMX[$6936], BANK[5]
INCLUDE "src/probe_cells_down_left.asm"

ProbeCellsDownLeftEnd:

SECTION "Probe cells on left step", ROMX[$6988], BANK[5]
INCLUDE "src/probe_cells_left.asm"

ProbeCellsLeftEnd:

SECTION "Probe cells on up-right step", ROMX[$6A08], BANK[5]
INCLUDE "src/probe_cells_up_right.asm"

ProbeCellsUpRightEnd:

SECTION "Probe cells on down-right step", ROMX[$6A60], BANK[5]
INCLUDE "src/probe_cells_down_right.asm"

ProbeCellsDownRightEnd:

SECTION "Probe cells on right step", ROMX[$6AB1], BANK[5]
INCLUDE "src/probe_cells_right.asm"

ProbeCellsRightEnd:

SECTION "Probe cells on up step", ROMX[$6B31], BANK[5]
INCLUDE "src/probe_cells_up.asm"

ProbeCellsUpEnd:

SECTION "Probe cells on down step", ROMX[$6B9E], BANK[5]
INCLUDE "src/probe_cells_down.asm"

ProbeCellsDownEnd:

SECTION "ROM Bank 005 C12A pattern", ROMX[$6C08], BANK[5]
INCLUDE "src/write_c12a_pattern.asm"

SECTION "Bank 5 nop fill at $6C18", ROMX[$6C18], BANK[5]
INCLUDE "src/bank5_nop_fill_6c18.asm"

Bank5NopFill6C18End:

SECTION "Bank 5 nop fill at $7018", ROMX[$7018], BANK[5]
INCLUDE "src/bank5_nop_fill_7018.asm"

Bank5NopFill7018End:

SECTION "Bank 5 nop fill at $7418", ROMX[$7418], BANK[5]
INCLUDE "src/bank5_nop_fill_7418.asm"

Bank5NopFill7418End:

SECTION "Bank 5 nop fill at $7818", ROMX[$7818], BANK[5]
INCLUDE "src/bank5_nop_fill_7818.asm"

Bank5NopFill7818End:

SECTION "Bank 5 nop fill at $7C18", ROMX[$7C18], BANK[5]
INCLUDE "src/bank5_nop_fill_7c18.asm"

Bank5NopFill7C18End:

SECTION "Palette run head", ROMX[$4000], BANK[6]
; bank6_palette_head.asm: not published here (it assembles data copied from the ROM)
PaletteRunHead:
    INCBIN "roms/magination.gbc", $18000, $5

SECTION "Palette tail at $4005", ROMX[$4005], BANK[6]
; palette_tail_at_4005.asm: not published here (it assembles data copied from the ROM)
PaletteTailAt4005:
    INCBIN "roms/magination.gbc", $18005, $40

PaletteTailAt4005End:

SECTION "Repeated palette at $4045", ROMX[$4045], BANK[6]
; repeated_palette_at_4045.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4045:
    INCBIN "roms/magination.gbc", $18045, $40

RepeatedPaletteAt4045End:

SECTION "Repeated palette at $4085", ROMX[$4085], BANK[6]
; repeated_palette_at_4085.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4085:
    INCBIN "roms/magination.gbc", $18085, $40

RepeatedPaletteAt4085End:

SECTION "Tile tail at $40C5", ROMX[$40C5], BANK[6]
; tile_tail_at_40c5.asm: not published here (it assembles data copied from the ROM)
TileTailAt40C5:
    INCBIN "roms/magination.gbc", $180C5, $40

TileTailAt40C5End:

SECTION "Tile tail at $4105", ROMX[$4105], BANK[6]
; tile_tail_at_4105.asm: not published here (it assembles data copied from the ROM)
TileTailAt4105:
    INCBIN "roms/magination.gbc", $18105, $40

TileTailAt4105End:

SECTION "Tile tail at $4145", ROMX[$4145], BANK[6]
; tile_tail_at_4145.asm: not published here (it assembles data copied from the ROM)
TileTailAt4145:
    INCBIN "roms/magination.gbc", $18145, $40

TileTailAt4145End:

SECTION "Tile tail at $4185", ROMX[$4185], BANK[6]
; tile_tail_at_4185.asm: not published here (it assembles data copied from the ROM)
TileTailAt4185:
    INCBIN "roms/magination.gbc", $18185, $40

TileTailAt4185End:

SECTION "Tile tail at $41C5", ROMX[$41C5], BANK[6]
; tile_tail_at_41c5.asm: not published here (it assembles data copied from the ROM)
TileTailAt41C5:
    INCBIN "roms/magination.gbc", $181C5, $40

TileTailAt41C5End:

SECTION "Tile tail at $4205", ROMX[$4205], BANK[6]
; tile_tail_at_4205.asm: not published here (it assembles data copied from the ROM)
TileTailAt4205:
    INCBIN "roms/magination.gbc", $18205, $40

TileTailAt4205End:

SECTION "Tile tail at $4245", ROMX[$4245], BANK[6]
; tile_tail_at_4245.asm: not published here (it assembles data copied from the ROM)
TileTailAt4245:
    INCBIN "roms/magination.gbc", $18245, $40

TileTailAt4245End:

SECTION "Tile tail at $4285", ROMX[$4285], BANK[6]
; tile_tail_at_4285.asm: not published here (it assembles data copied from the ROM)
TileTailAt4285:
    INCBIN "roms/magination.gbc", $18285, $40

TileTailAt4285End:

SECTION "Tile tail at $42C5", ROMX[$42C5], BANK[6]
; tile_tail_at_42c5.asm: not published here (it assembles data copied from the ROM)
TileTailAt42C5:
    INCBIN "roms/magination.gbc", $182C5, $40

TileTailAt42C5End:

SECTION "Glyph tail at $4305", ROMX[$4305], BANK[6]
; glyph_tail_at_4305.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4305:
    INCBIN "roms/magination.gbc", $18305, $40

GlyphTailAt4305End:

SECTION "Glyph tail at $4345", ROMX[$4345], BANK[6]
; glyph_tail_at_4345.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4345:
    INCBIN "roms/magination.gbc", $18345, $40

GlyphTailAt4345End:

SECTION "Glyph tail at $4385", ROMX[$4385], BANK[6]
; glyph_tail_at_4385.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4385:
    INCBIN "roms/magination.gbc", $18385, $40

GlyphTailAt4385End:

SECTION "Glyph tail at $43C5", ROMX[$43C5], BANK[6]
; glyph_tail_at_43c5.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt43C5:
    INCBIN "roms/magination.gbc", $183C5, $40

GlyphTailAt43C5End:

SECTION "Glyph tail at $4405", ROMX[$4405], BANK[6]
; glyph_tail_at_4405.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4405:
    INCBIN "roms/magination.gbc", $18405, $40

GlyphTailAt4405End:

SECTION "Glyph tail at $4445", ROMX[$4445], BANK[6]
; glyph_tail_at_4445.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4445:
    INCBIN "roms/magination.gbc", $18445, $40

GlyphTailAt4445End:

SECTION "Glyph tail at $4485", ROMX[$4485], BANK[6]
; glyph_tail_at_4485.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4485:
    INCBIN "roms/magination.gbc", $18485, $40

GlyphTailAt4485End:

SECTION "Glyph tail at $44C5", ROMX[$44C5], BANK[6]
; glyph_tail_at_44c5.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt44C5:
    INCBIN "roms/magination.gbc", $184C5, $40

GlyphTailAt44C5End:

SECTION "Glyph tail at $4505", ROMX[$4505], BANK[6]
; glyph_tail_at_4505.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4505:
    INCBIN "roms/magination.gbc", $18505, $40

GlyphTailAt4505End:

SECTION "Glyph tail at $4545", ROMX[$4545], BANK[6]
; glyph_tail_at_4545.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4545:
    INCBIN "roms/magination.gbc", $18545, $40

GlyphTailAt4545End:

SECTION "Glyph tail at $4585", ROMX[$4585], BANK[6]
; glyph_tail_at_4585.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4585:
    INCBIN "roms/magination.gbc", $18585, $40

GlyphTailAt4585End:

SECTION "Glyph tail at $45C5", ROMX[$45C5], BANK[6]
; glyph_tail_at_45c5.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt45C5:
    INCBIN "roms/magination.gbc", $185C5, $40

GlyphTailAt45C5End:

SECTION "Glyph tail at $4605", ROMX[$4605], BANK[6]
; glyph_tail_at_4605.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4605:
    INCBIN "roms/magination.gbc", $18605, $40

GlyphTailAt4605End:

SECTION "Glyph tail at $4645", ROMX[$4645], BANK[6]
; glyph_tail_at_4645.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4645:
    INCBIN "roms/magination.gbc", $18645, $40

GlyphTailAt4645End:

SECTION "Glyph tail at $4685", ROMX[$4685], BANK[6]
; glyph_tail_at_4685.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4685:
    INCBIN "roms/magination.gbc", $18685, $40

GlyphTailAt4685End:

SECTION "Glyph tail at $46C5", ROMX[$46C5], BANK[6]
; glyph_tail_at_46c5.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt46C5:
    INCBIN "roms/magination.gbc", $186C5, $40

GlyphTailAt46C5End:

SECTION "Glyph tail at $4705", ROMX[$4705], BANK[6]
; glyph_tail_at_4705.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4705:
    INCBIN "roms/magination.gbc", $18705, $40

GlyphTailAt4705End:

SECTION "Glyph tail at $4745", ROMX[$4745], BANK[6]
; glyph_tail_at_4745.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4745:
    INCBIN "roms/magination.gbc", $18745, $40

GlyphTailAt4745End:

SECTION "Glyph tail at $4785", ROMX[$4785], BANK[6]
; glyph_tail_at_4785.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt4785:
    INCBIN "roms/magination.gbc", $18785, $40

GlyphTailAt4785End:

SECTION "Glyph tail at $47C5", ROMX[$47C5], BANK[6]
; glyph_tail_at_47c5.asm: not published here (it assembles data copied from the ROM)
GlyphTailAt47C5:
    INCBIN "roms/magination.gbc", $187C5, $3E

GlyphTailAt47C5End:

SECTION "Repeated palette at $4803", ROMX[$4803], BANK[6]
; repeated_palette_at_4803.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4803:
    INCBIN "roms/magination.gbc", $18803, $40

RepeatedPaletteAt4803End:

SECTION "Repeated palette at $4843", ROMX[$4843], BANK[6]
; repeated_palette_at_4843.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4843:
    INCBIN "roms/magination.gbc", $18843, $40

RepeatedPaletteAt4843End:

SECTION "Repeated palette at $4883", ROMX[$4883], BANK[6]
; repeated_palette_at_4883.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4883:
    INCBIN "roms/magination.gbc", $18883, $40

SECTION "Repeated palette at $48C3", ROMX[$48C3], BANK[6]
; repeated_palette_at_48c3.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4883End:
RepeatedPaletteAt48C3:
    INCBIN "roms/magination.gbc", $188C3, $40

SECTION "Repeated palette at $4903", ROMX[$4903], BANK[6]
; repeated_palette_at_4903.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt48C3End:
RepeatedPaletteAt4903:
    INCBIN "roms/magination.gbc", $18903, $40

SECTION "Repeated palette at $4943", ROMX[$4943], BANK[6]
; repeated_palette_at_4943.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4903End:
RepeatedPaletteAt4943:
    INCBIN "roms/magination.gbc", $18943, $40

SECTION "Repeated palette at $4983", ROMX[$4983], BANK[6]
; repeated_palette_at_4983.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4943End:
RepeatedPaletteAt4983:
    INCBIN "roms/magination.gbc", $18983, $40

SECTION "Repeated palette at $49C3", ROMX[$49C3], BANK[6]
; repeated_palette_at_49c3.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4983End:
RepeatedPaletteAt49C3:
    INCBIN "roms/magination.gbc", $189C3, $40

SECTION "Repeated palette at $4A03", ROMX[$4A03], BANK[6]
; repeated_palette_at_4a03.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt49C3End:
RepeatedPaletteAt4A03:
    INCBIN "roms/magination.gbc", $18A03, $40

SECTION "Repeated palette at $4A43", ROMX[$4A43], BANK[6]
; repeated_palette_at_4a43.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4A03End:
RepeatedPaletteAt4A43:
    INCBIN "roms/magination.gbc", $18A43, $40

SECTION "Repeated palette at $4A83", ROMX[$4A83], BANK[6]
; repeated_palette_at_4a83.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4A43End:
RepeatedPaletteAt4A83:
    INCBIN "roms/magination.gbc", $18A83, $40

SECTION "Repeated palette at $4AC3", ROMX[$4AC3], BANK[6]
; repeated_palette_at_4ac3.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4A83End:
RepeatedPaletteAt4AC3:
    INCBIN "roms/magination.gbc", $18AC3, $40

SECTION "Repeated palette at $4B03", ROMX[$4B03], BANK[6]
; repeated_palette_at_4b03.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4AC3End:
RepeatedPaletteAt4B03:
    INCBIN "roms/magination.gbc", $18B03, $40

SECTION "Repeated palette at $4B43", ROMX[$4B43], BANK[6]
; repeated_palette_at_4b43.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4B03End:
RepeatedPaletteAt4B43:
    INCBIN "roms/magination.gbc", $18B43, $40

SECTION "Repeated palette at $4B83", ROMX[$4B83], BANK[6]
; repeated_palette_at_4b83.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4B43End:
RepeatedPaletteAt4B83:
    INCBIN "roms/magination.gbc", $18B83, $40

SECTION "Repeated palette at $4BC3", ROMX[$4BC3], BANK[6]
; repeated_palette_at_4bc3.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4B83End:
RepeatedPaletteAt4BC3:
    INCBIN "roms/magination.gbc", $18BC3, $40

SECTION "Repeated palette byte at $4C03", ROMX[$4C03], BANK[6]
; repeated_palette_byte_4c03.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4BC3End:
RepeatedPaletteColor1High:
    INCBIN "roms/magination.gbc", $18C03, $1

SECTION "Repeated palette at $4C04", ROMX[$4C04], BANK[6]
; repeated_palette_at_4c04.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4C04:
    INCBIN "roms/magination.gbc", $18C04, $40

SECTION "Repeated palette at $4C44", ROMX[$4C44], BANK[6]
; repeated_palette_at_4c44.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4C04End:
RepeatedPaletteAt4C44:
    INCBIN "roms/magination.gbc", $18C44, $40

SECTION "Repeated palette at $4C84", ROMX[$4C84], BANK[6]
; repeated_palette_at_4c84.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4C44End:
RepeatedPaletteAt4C84:
    INCBIN "roms/magination.gbc", $18C84, $3F

SECTION "Repeated palette at $4CC3", ROMX[$4CC3], BANK[6]
; repeated_palette_at_4cc3.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4C84End:
RepeatedPaletteAt4CC3:
    INCBIN "roms/magination.gbc", $18CC3, $40

SECTION "Repeated palette at $4D03", ROMX[$4D03], BANK[6]
; repeated_palette_at_4d03.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4CC3End:
RepeatedPaletteAt4D03:
    INCBIN "roms/magination.gbc", $18D03, $40

SECTION "Repeated palette at $4D43", ROMX[$4D43], BANK[6]
; repeated_palette_at_4d43.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4D03End:
RepeatedPaletteAt4D43:
    INCBIN "roms/magination.gbc", $18D43, $40

SECTION "Repeated palette at $4D83", ROMX[$4D83], BANK[6]
; repeated_palette_at_4d83.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4D43End:
RepeatedPaletteAt4D83:
    INCBIN "roms/magination.gbc", $18D83, $40

SECTION "Repeated palette at $4DC3", ROMX[$4DC3], BANK[6]
; repeated_palette_at_4dc3.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4D83End:
RepeatedPaletteAt4DC3:
    INCBIN "roms/magination.gbc", $18DC3, $40

SECTION "Repeated palette at $4E03", ROMX[$4E03], BANK[6]
; repeated_palette_at_4e03.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4DC3End:
RepeatedPaletteAt4E03:
    INCBIN "roms/magination.gbc", $18E03, $40

SECTION "Repeated palette at $4E43", ROMX[$4E43], BANK[6]
; repeated_palette_at_4e43.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4E03End:
RepeatedPaletteAt4E43:
    INCBIN "roms/magination.gbc", $18E43, $40

SECTION "Repeated palette at $4E83", ROMX[$4E83], BANK[6]
; repeated_palette_at_4e83.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4E43End:
RepeatedPaletteAt4E83:
    INCBIN "roms/magination.gbc", $18E83, $40

SECTION "Repeated palette at $4EC3", ROMX[$4EC3], BANK[6]
; repeated_palette_at_4ec3.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4E83End:
RepeatedPaletteAt4EC3:
    INCBIN "roms/magination.gbc", $18EC3, $40

SECTION "Repeated palette at $4F03", ROMX[$4F03], BANK[6]
; repeated_palette_at_4f03.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4EC3End:
RepeatedPaletteAt4F03:
    INCBIN "roms/magination.gbc", $18F03, $40

SECTION "Repeated palette at $4F43", ROMX[$4F43], BANK[6]
; repeated_palette_at_4f43.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4F03End:
RepeatedPaletteAt4F43:
    INCBIN "roms/magination.gbc", $18F43, $40

SECTION "Repeated palette at $4F83", ROMX[$4F83], BANK[6]
; repeated_palette_at_4f83.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4F43End:
RepeatedPaletteAt4F83:
    INCBIN "roms/magination.gbc", $18F83, $40

SECTION "Repeated palette at $4FC3", ROMX[$4FC3], BANK[6]
; repeated_palette_at_4fc3.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4F83End:
RepeatedPaletteAt4FC3:
    INCBIN "roms/magination.gbc", $18FC3, $3D

SECTION "Shaded digit tiles at $5000", ROMX[$5000], BANK[6]
; shaded_digit_tiles_at_5000.asm: not published here (it assembles data copied from the ROM)
RepeatedPaletteAt4FC3End:
ShadedDigitTilesAt5000:
    INCBIN "roms/magination.gbc", $19000, $40

SECTION "Shaded digit tiles at $5040", ROMX[$5040], BANK[6]
; shaded_digit_tiles_at_5040.asm: not published here (it assembles data copied from the ROM)
ShadedDigitTilesAt5000End:
ShadedDigitTilesAt5040:
    INCBIN "roms/magination.gbc", $19040, $40

SECTION "Shaded digit tiles at $5080", ROMX[$5080], BANK[6]
; shaded_digit_tiles_at_5080.asm: not published here (it assembles data copied from the ROM)
ShadedDigitTilesAt5040End:
ShadedDigitTilesAt5080:
    INCBIN "roms/magination.gbc", $19080, $40

SECTION "Window tiles at $50C0", ROMX[$50C0], BANK[6]
; window_tiles_at_50c0.asm: not published here (it assembles data copied from the ROM)
WindowTilesAt50C0:
    INCBIN "roms/magination.gbc", $190C0, $40

SECTION "Window corner tile at $5100", ROMX[$5100], BANK[6]
; window_corner_tile_at_5100.asm: not published here (it assembles data copied from the ROM)
WindowCornerTileAt5100:
    INCBIN "roms/magination.gbc", $19100, $10

SECTION "Copy index 9 VRAM tiles", ROMX[$5110], BANK[6]
INCLUDE "src/copy_index9_vram_tiles.asm"

CopyIndex9VRAMTilesEnd:

SECTION "Copy index 5 VRAM tiles", ROMX[$5122], BANK[6]
INCLUDE "src/copy_index5_vram_tiles.asm"

CopyIndex5VRAMTilesEnd:

SECTION "Copy index 7 VRAM tiles", ROMX[$5134], BANK[6]
INCLUDE "src/copy_index7_vram_tiles.asm"

CopyIndex7VRAMTilesEnd:

SECTION "Copy indexed map", ROMX[$5157], BANK[6]
INCLUDE "src/copy_indexed_map.asm"

SECTION "Copy indexed blocks", ROMX[$5182], BANK[6]
INCLUDE "src/copy_indexed_blocks.asm"

SECTION "Indexed screen tables", ROMX[$51C1], BANK[6]
; indexed_screen_tables.asm: not published here (it assembles data copied from the ROM)
IndexedMapSources:
    INCBIN "roms/magination.gbc", $191C1, $18

SECTION "Indexed screen tables @$0191D9", ROMX[$51D9], BANK[6]
IndexedSetupRecordTable:
    INCBIN "roms/magination.gbc", $191D9, $18

SECTION "Indexed setup records", ROMX[$51F1], BANK[6]
; indexed_setup_records.asm: not published here (it assembles data copied from the ROM)
IndexedScreenTablesEnd:
SetupRecordIndex0:
    INCBIN "roms/magination.gbc", $191F1, $1B

SECTION "Indexed setup records @$01920C", ROMX[$520C], BANK[6]
SetupRecordIndex1:
    INCBIN "roms/magination.gbc", $1920C, $6

SECTION "Indexed setup records @$019212", ROMX[$5212], BANK[6]
SetupRecordIndex2:
    INCBIN "roms/magination.gbc", $19212, $6

SECTION "Indexed setup records @$019218", ROMX[$5218], BANK[6]
SetupRecordIndex4:
    INCBIN "roms/magination.gbc", $19218, $6

SECTION "Indexed setup records @$01921E", ROMX[$521E], BANK[6]
SetupRecordIndex0B:
    INCBIN "roms/magination.gbc", $1921E, $6

SECTION "Indexed setup records @$019224", ROMX[$5224], BANK[6]
SetupRecordIndex5:
    INCBIN "roms/magination.gbc", $19224, $9

SECTION "Indexed setup records 6 to 9", ROMX[$522D], BANK[6]
; indexed_setup_records_6.asm: not published here (it assembles data copied from the ROM)
IndexedSetupRecordsEnd:
SetupRecordIndex6:
    INCBIN "roms/magination.gbc", $1922D, $6

SECTION "Indexed setup records 6 to 9 @$019233", ROMX[$5233], BANK[6]
SetupRecordIndex7:
    INCBIN "roms/magination.gbc", $19233, $F

SECTION "Indexed setup records 6 to 9 @$019242", ROMX[$5242], BANK[6]
SetupRecordIndex8:
    INCBIN "roms/magination.gbc", $19242, $6

SECTION "Indexed setup records 6 to 9 @$019248", ROMX[$5248], BANK[6]
SetupRecordIndex9:
    INCBIN "roms/magination.gbc", $19248, $6

SECTION "Default record indexes and menu labels", ROMX[$524E], BANK[6]
; menu_tile_labels_524e.asm: not published here (it assembles data copied from the ROM)
DefaultRecordIndexGlyphs:
SetupRecords6To9End:
    INCBIN "roms/magination.gbc", $1924E, $C

SECTION "Default record indexes and menu labels @$01925A", ROMX[$525A], BANK[6]
MenuLabelTony:
    INCBIN "roms/magination.gbc", $1925A, $5

SECTION "Default record indexes and menu labels @$01925F", ROMX[$525F], BANK[6]
MenuLabelSpell:
    INCBIN "roms/magination.gbc", $1925F, $5

SECTION "Default record indexes and menu labels @$019264", ROMX[$5264], BANK[6]
MenuLabelRings:
    INCBIN "roms/magination.gbc", $19264, $5

SECTION "Default record indexes and menu labels @$019269", ROMX[$5269], BANK[6]
MenuLabelItems:
    INCBIN "roms/magination.gbc", $19269, $5

SECTION "Default record indexes and menu labels @$01926E", ROMX[$526E], BANK[6]
MenuLabelGlyph:
    INCBIN "roms/magination.gbc", $1926E, $5

SECTION "Default record indexes and menu labels @$019273", ROMX[$5273], BANK[6]
MenuLabelIndex1C:
    INCBIN "roms/magination.gbc", $19273, $1

SECTION "Default record indexes and menu labels @$019274", ROMX[$5274], BANK[6]
MenuLabelIndex12:
    INCBIN "roms/magination.gbc", $19274, $1

SECTION "Default record indexes and menu labels @$019275", ROMX[$5275], BANK[6]
MenuLabelDigits:
    INCBIN "roms/magination.gbc", $19275, $A

SECTION "Default record indexes and menu labels @$01927F", ROMX[$527F], BANK[6]
StartPressListGlyphs:
    INCBIN "roms/magination.gbc", $1927F, $5

SECTION "Default record indexes and menu labels @$019284", ROMX[$5284], BANK[6]
StartPressSaveGlyphs:
    INCBIN "roms/magination.gbc", $19284, $4

SECTION "Default record indexes and menu labels @$019288", ROMX[$5288], BANK[6]
StartPressBlankGlyphs:
    INCBIN "roms/magination.gbc", $19288, $4

SECTION "Menu glyph lists at $528C", ROMX[$528C], BANK[6]
; menu_glyph_lists_528c.asm: not published here (it assembles data copied from the ROM)
MenuGlyphSpace528C:
    INCBIN "roms/magination.gbc", $1928C, $1

SECTION "Menu glyph lists at $528C @$01928D", ROMX[$528D], BANK[6]
MenuGlyphLvl:
    INCBIN "roms/magination.gbc", $1928D, $4

SECTION "Menu glyph lists at $528C @$019291", ROMX[$5291], BANK[6]
MenuGlyphExp:
    INCBIN "roms/magination.gbc", $19291, $3

SECTION "Menu glyph lists at $528C @$019294", ROMX[$5294], BANK[6]
MenuGlyphSpace5294:
    INCBIN "roms/magination.gbc", $19294, $1

SECTION "Menu glyph lists at $528C @$019295", ROMX[$5295], BANK[6]
MenuGlyphPellBook:
    INCBIN "roms/magination.gbc", $19295, $8

SECTION "Menu glyph lists at $528C @$01929D", ROMX[$529D], BANK[6]
MenuGlyphSpace529D:
    INCBIN "roms/magination.gbc", $1929D, $1

SECTION "Menu glyph lists at $528C @$01929E", ROMX[$529E], BANK[6]
MenuGlyphTemList:
    INCBIN "roms/magination.gbc", $1929E, $8

SECTION "Menu glyph lists at $528C @$0192A6", ROMX[$52A6], BANK[6]
MenuGlyphSpace52A6:
    INCBIN "roms/magination.gbc", $192A6, $1

SECTION "Menu glyph lists at $528C @$0192A7", ROMX[$52A7], BANK[6]
MenuGlyphTem:
    INCBIN "roms/magination.gbc", $192A7, $4

SECTION "Menu glyph lists at $528C @$0192AB", ROMX[$52AB], BANK[6]
MenuGlyphAbility:
    INCBIN "roms/magination.gbc", $192AB, $7

SECTION "Menu glyph lists at $528C @$0192B2", ROMX[$52B2], BANK[6]
MenuGlyphIndex1B:
    INCBIN "roms/magination.gbc", $192B2, $1

SECTION "Menu glyph lists at $528C @$0192B3", ROMX[$52B3], BANK[6]
MenuGlyphAbilitySpaced:
    INCBIN "roms/magination.gbc", $192B3, $9

SECTION "Menu glyph lists at $528C @$0192BC", ROMX[$52BC], BANK[6]
MenuGlyphBlat:
    INCBIN "roms/magination.gbc", $192BC, $4

SECTION "Menu glyph lists at $52C0", ROMX[$52C0], BANK[6]
; menu_glyph_lists_52c0.asm: not published here (it assembles data copied from the ROM)
MenuGlyphWhichRing:
    INCBIN "roms/magination.gbc", $192C0, $11

SECTION "Menu glyph lists at $52C0 @$0192D1", ROMX[$52D1], BANK[6]
MenuGlyphWantToAct:
    INCBIN "roms/magination.gbc", $192D1, $F

SECTION "Menu glyph lists at $52C0 @$0192E0", ROMX[$52E0], BANK[6]
MenuGlyphLvlEX:
    INCBIN "roms/magination.gbc", $192E0, $5

SECTION "Menu glyph lists at $52C0 @$0192E5", ROMX[$52E5], BANK[6]
MenuGlyphBuy:
    INCBIN "roms/magination.gbc", $192E5, $3

SECTION "Menu glyph lists at $52C0 @$0192E8", ROMX[$52E8], BANK[6]
MenuGlyphSel:
    INCBIN "roms/magination.gbc", $192E8, $3

SECTION "Menu glyph lists at $52C0 @$0192EB", ROMX[$52EB], BANK[6]
MenuGlyphIndex12:
    INCBIN "roms/magination.gbc", $192EB, $1

SECTION "Menu glyph lists at $52C0 @$0192EC", ROMX[$52EC], BANK[6]
MenuGlyphDone:
    INCBIN "roms/magination.gbc", $192EC, $4

SECTION "Menu glyph lists at $52C0 @$0192F0", ROMX[$52F0], BANK[6]
MenuGlyphX:
    INCBIN "roms/magination.gbc", $192F0, $1

SECTION "Menu glyph lists at $52C0 @$0192F1", ROMX[$52F1], BANK[6]
MenuGlyphIndex1D:
    INCBIN "roms/magination.gbc", $192F1, $1

SECTION "Menu glyph items at $52F2", ROMX[$52F2], BANK[6]
; menu_glyph_items_52f2.asm: not published here (it assembles data copied from the ROM)
MenuGlyphItems:
    INCBIN "roms/magination.gbc", $192F2, $5

SECTION "Menu glyph items at $52F2 @$0192F7", ROMX[$52F7], BANK[6]
MenuGlyphSpl:
    INCBIN "roms/magination.gbc", $192F7, $3

SECTION "Menu glyph items at $52F2 @$0192FA", ROMX[$52FA], BANK[6]
MenuGlyphRic:
    INCBIN "roms/magination.gbc", $192FA, $3

SECTION "Menu glyph items at $52F2 @$0192FD", ROMX[$52FD], BANK[6]
MenuGlyphIndex1D52FD:
    INCBIN "roms/magination.gbc", $192FD, $1

SECTION "Menu glyph items at $52F2 @$0192FE", ROMX[$52FE], BANK[6]
MenuGlyphDone52FE:
    INCBIN "roms/magination.gbc", $192FE, $4

SECTION "Menu glyph choose song at $5302", ROMX[$5302], BANK[6]
; menu_glyph_choose_song_5302.asm: not published here (it assembles data copied from the ROM)
MenuGlyphChooseASong:
    INCBIN "roms/magination.gbc", $19302, $D

SECTION "Menu glyph choose song at $5302 @$01930F", ROMX[$530F], BANK[6]
MenuGlyphASelects:
    INCBIN "roms/magination.gbc", $1930F, $9

SECTION "Menu glyph choose song at $5302 @$019318", ROMX[$5318], BANK[6]
MenuGlyphBExits:
    INCBIN "roms/magination.gbc", $19318, $7

SECTION "Menu glyph choose song at $5302 @$01931F", ROMX[$531F], BANK[6]
MenuGlyphIndex1D531F:
    INCBIN "roms/magination.gbc", $1931F, $1

SECTION "Menu glyph choose song at $5302 @$019320", ROMX[$5320], BANK[6]
MenuGlyphTony:
    INCBIN "roms/magination.gbc", $19320, $4

SECTION "Menu glyph choose song at $5302 @$019324", ROMX[$5324], BANK[6]
MenuGlyphCost:
    INCBIN "roms/magination.gbc", $19324, $4

SECTION "Menu glyph choose song at $5302 @$019328", ROMX[$5328], BANK[6]
MenuGlyphIndex101112:
    INCBIN "roms/magination.gbc", $19328, $3

SECTION "Menu glyph choose song at $5302 @$01932B", ROMX[$532B], BANK[6]
MenuGlyphIndex1D532B:
    INCBIN "roms/magination.gbc", $1932B, $1

SECTION "Menu glyph choose song at $5302 @$01932C", ROMX[$532C], BANK[6]
MenuGlyphLVEX:
    INCBIN "roms/magination.gbc", $1932C, $4

SECTION "Menu glyph digits at $5330", ROMX[$5330], BANK[6]
; menu_glyph_digits_5330.asm: not published here (it assembles data copied from the ROM)
MenuGlyphDigits5330:
    INCBIN "roms/magination.gbc", $19330, $16

SECTION "Menu glyph digits at $5330 @$019346", ROMX[$5346], BANK[6]
MenuGlyphIndexX5346:
    INCBIN "roms/magination.gbc", $19346, $1

SECTION "Menu glyph digits at $5330 @$019347", ROMX[$5347], BANK[6]
MenuGlyphDigits5347:
    INCBIN "roms/magination.gbc", $19347, $3

SECTION "Menu glyph digits at $5330 @$01934A", ROMX[$534A], BANK[6]
MenuGlyphDigits534A:
    INCBIN "roms/magination.gbc", $1934A, $26

SECTION "Menu glyph digits at $5370", ROMX[$5370], BANK[6]
; menu_glyph_digits_5370.asm: not published here (it assembles data copied from the ROM)
MenuGlyphDigits5370:
    INCBIN "roms/magination.gbc", $19370, $15

SECTION "Paint indexed entry names", ROMX[$5385], BANK[6]
INCLUDE "src/paint_indexed_entry_names.asm"

PaintIndexedEntryNamesEnd:

SECTION "Stage entry name mask column", ROMX[$559B], BANK[6]
INCLUDE "src/stage_entry_name_mask_column.asm"

StageEntryNameMaskColumnEnd:

SECTION "Pass entry name strip", ROMX[$5636], BANK[6]
INCLUDE "src/pass_entry_name_strip.asm"

PassEntryNameStripEnd:

SECTION "Entry name row 2 mask column", ROMX[$56F8], BANK[6]
INCLUDE "src/entry_name_row2_mask_column.asm"

EntryNameRow2MaskColumnEnd:

SECTION "Entry name pass after row 2", ROMX[$5793], BANK[6]
INCLUDE "src/entry_name_pass_after_row2.asm"

EntryNamePassAfterRow2End:

SECTION "Entry name row 3 mask column", ROMX[$5855], BANK[6]
INCLUDE "src/entry_name_row3_mask_column.asm"

EntryNameRow3MaskColumnEnd:

SECTION "Entry name pass after row 3", ROMX[$58F0], BANK[6]
INCLUDE "src/entry_name_pass_after_row3.asm"

EntryNamePassAfterRow3End:

SECTION "Entry name row 4 mask column", ROMX[$59B2], BANK[6]
INCLUDE "src/entry_name_row4_mask_column.asm"

EntryNameRow4MaskColumnEnd:

SECTION "Copy indexed name", ROMX[$5A60], BANK[6]
INCLUDE "src/copy_indexed_name.asm"

CopyIndexedNameEnd:

SECTION "Copy pointed 22 bytes", ROMX[$5A87], BANK[6]
INCLUDE "src/copy_pointed_22.asm"

CopyPointed22End:

SECTION "Indexed blank name", ROMX[$5A9C], BANK[6]
INCLUDE "src/indexed_blank_name.asm"

IndexedBlankNameEnd:

SECTION "Indexed names from Abaquist", ROMX[$5AA6], BANK[6]
; indexed_names_from_abaquist.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromAbaquist:
    INCBIN "roms/magination.gbc", $19AA6, $3C

IndexedNamesFromAbaquistEnd:

SECTION "Indexed names from Bhatar", ROMX[$5AE2], BANK[6]
; indexed_names_from_bhatar.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromBhatar:
    INCBIN "roms/magination.gbc", $19AE2, $3C

IndexedNamesFromBhatarEnd:

SECTION "Indexed names from Bwill", ROMX[$5B1E], BANK[6]
; indexed_names_from_bwill.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromBwill:
    INCBIN "roms/magination.gbc", $19B1E, $3C

IndexedNamesFromBwillEnd:

SECTION "Indexed names from Core Hyren", ROMX[$5B5A], BANK[6]
; indexed_names_from_core_hyren.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromCoreHyren:
    INCBIN "roms/magination.gbc", $19B5A, $3C

IndexedNamesFromCoreHyrenEnd:

SECTION "Indexed names from Dryte Fiend", ROMX[$5B96], BANK[6]
; indexed_names_from_dryte_fiend.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromDryteFiend:
    INCBIN "roms/magination.gbc", $19B96, $3C

IndexedNamesFromDryteFiendEnd:

SECTION "Indexed names from Giant Korit", ROMX[$5BD2], BANK[6]
; indexed_names_from_giant_korit.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromGiantKorit:
    INCBIN "roms/magination.gbc", $19BD2, $3C

IndexedNamesFromGiantKoritEnd:

SECTION "Indexed names from Karak", ROMX[$5C0E], BANK[6]
; indexed_names_from_karak.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromKarak:
    INCBIN "roms/magination.gbc", $19C0E, $3C

IndexedNamesFromKarakEnd:

SECTION "Indexed names from LavaArboll", ROMX[$5C4A], BANK[6]
; indexed_names_from_lava_arboll.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromLavaArboll:
    INCBIN "roms/magination.gbc", $19C4A, $3C

IndexedNamesFromLavaArbollEnd:

SECTION "Indexed names from Mush Hyren", ROMX[$5C86], BANK[6]
; indexed_names_from_mush_hyren.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromMushHyren:
    INCBIN "roms/magination.gbc", $19C86, $3C

IndexedNamesFromMushHyrenEnd:

SECTION "Indexed names from Parmalag", ROMX[$5CC2], BANK[6]
; indexed_names_from_parmalag.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromParmalag:
    INCBIN "roms/magination.gbc", $19CC2, $3C

IndexedNamesFromParmalagEnd:

SECTION "Indexed names from Raxis", ROMX[$5CFE], BANK[6]
; indexed_names_from_raxis.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromRaxis:
    INCBIN "roms/magination.gbc", $19CFE, $3C

IndexedNamesFromRaxisEnd:

SECTION "Indexed names from ShadwVinoc", ROMX[$5D3A], BANK[6]
; indexed_names_from_shadw_vinoc.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromShadwVinoc:
    INCBIN "roms/magination.gbc", $19D3A, $3C

IndexedNamesFromShadwVinocEnd:

SECTION "Indexed names from TimberHyrn", ROMX[$5D76], BANK[6]
; indexed_names_from_timber_hyrn.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromTimberHyrn:
    INCBIN "roms/magination.gbc", $19D76, $3C

IndexedNamesFromTimberHyrnEnd:

SECTION "Indexed names from Vile Yogu", ROMX[$5DB2], BANK[6]
; indexed_names_from_vile_yogu.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromVileYogu:
    INCBIN "roms/magination.gbc", $19DB2, $3C

IndexedNamesFromVileYoguEnd:

SECTION "Indexed names from Xyx", ROMX[$5DEE], BANK[6]
; indexed_names_from_xyx.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromXyx:
    INCBIN "roms/magination.gbc", $19DEE, $3C

IndexedNamesFromXyxEnd:

SECTION "Indexed names from Ogar", ROMX[$5E2A], BANK[6]
; indexed_names_from_ogar.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromOgar:
    INCBIN "roms/magination.gbc", $19E2A, $3C

IndexedNamesFromOgarEnd:

SECTION "Indexed names from Agram", ROMX[$5E66], BANK[6]
; indexed_names_from_agram.asm: not published here (it assembles data copied from the ROM)
IndexedNamesFromAgram:
    INCBIN "roms/magination.gbc", $19E66, $40

IndexedNamesFromAgramEnd:

SECTION "Indexed shadow magi names", ROMX[$5EA6], BANK[6]
; indexed_shadow_magi_tail.asm: not published here (it assembles data copied from the ROM)
IndexedShadowMagiTail:
    INCBIN "roms/magination.gbc", $19EA6, $38

IndexedShadowMagiTailEnd:

SECTION "Indexed name 108", ROMX[$5EDE], BANK[6]
INCLUDE "src/indexed_name_108.asm"

IndexedName108End:

SECTION "Write two decimal tiles", ROMX[$5EE8], BANK[6]
INCLUDE "src/write_two_decimal_tiles.asm"

WriteTwoDecimalTilesEnd:

SECTION "Copy VRAM bank 1 tiles", ROMX[$5EFB], BANK[6]
INCLUDE "src/copy_vram_bank1_tiles.asm"

CopyVRAMBank1TilesEnd:

SECTION "Stamp setup attributes", ROMX[$5F0A], BANK[6]
INCLUDE "src/stamp_setup_attributes.asm"

StampSetupAttributesEnd:

SECTION "Draw start screen map", ROMX[$5FC2], BANK[6]
INCLUDE "src/draw_start_screen_map.asm"

DrawStartScreenMapEnd:

SECTION "Stamp tile 80 block", ROMX[$615F], BANK[6]
INCLUDE "src/stamp_tile80_block.asm"

StampTile80BlockEnd:

SECTION "Copy rows 20 by 10", ROMX[$6170], BANK[6]
INCLUDE "src/copy_rows_20_by_10.asm"

CopyRows20By10End:

SECTION "Copy record byte blocks", ROMX[$617E], BANK[6]
INCLUDE "src/copy_record_byte_blocks.asm"

CopyRecordByteBlocksEnd:

SECTION "Restore VRAM bank 1 tiles", ROMX[$61D2], BANK[6]
INCLUDE "src/restore_vram_bank1_tiles.asm"

RestoreVRAMBank1TilesEnd:

SECTION "Write digit tiles", ROMX[$61E1], BANK[6]
INCLUDE "src/write_digit_tiles.asm"

WriteDigitTilesEnd:

SECTION "Indexed setup", ROMX[$61F1], BANK[6]
INCLUDE "src/indexed_setup.asm"

IndexedSetupEnd:

SECTION "Write group row digits", ROMX[$636A], BANK[6]
INCLUDE "src/write_group_row_digits.asm"

WriteGroupRowDigitsEnd:

SECTION "Scan group bytes", ROMX[$63D6], BANK[6]
INCLUDE "src/scan_group_bytes.asm"

ScanGroupBytesEnd:

SECTION "Mode 6 after command 4D", ROMX[$6530], BANK[6]
INCLUDE "src/mode6_after_command_4d.asm"

Mode6AfterCommand4DEnd:

SECTION "Draw index 9 map", ROMX[$659C], BANK[6]
INCLUDE "src/draw_index9_map.asm"

DrawIndex9MapEnd:

SECTION "Copy five map rows", ROMX[$65FD], BANK[6]
INCLUDE "src/copy_five_map_rows.asm"

CopyFiveMapRowsEnd:

SECTION "Draw index 5 tail", ROMX[$6649], BANK[6]
INCLUDE "src/draw_index5_tail.asm"

DrawIndex5TailEnd:

SECTION "After start loop", ROMX[$673B], BANK[6]
INCLUDE "src/after_start_loop.asm"

AfterStartLoopEnd:

SECTION "Start button hook", ROMX[$6783], BANK[6]
INCLUDE "src/handle_start_press.asm"

HandleStartPressEnd:

SECTION "Fill group pointers", ROMX[$6911], BANK[6]
INCLUDE "src/fill_group_pointers.asm"

FillGroupPointersEnd:

SECTION "Indexed tail 7", ROMX[$6A39], BANK[6]
INCLUDE "src/indexed_tail_07.asm"

DrawIndexedEntryEnd:

SECTION "Slot 24 script record", ROMX[$6C9D], BANK[6]
INCLUDE "src/slot24_script_record.asm"

Slot24ScriptRecordEnd:

SECTION "Return at 6CC9", ROMX[$6CC9], BANK[6]
INCLUDE "src/ret_at_6cc9.asm"

SECTION "Indexed tail 8", ROMX[$6CCA], BANK[6]
INCLUDE "src/indexed_tail_08.asm"

DrawIndexedSlotsEnd:

SECTION "Command $4D group setup", ROMX[$6DDF], BANK[6]
INCLUDE "src/setup_command_4d.asm"

SECTION "Stamp tile run", ROMX[$6EBB], BANK[6]
INCLUDE "src/stamp_tile_run.asm"

StampTileRunEnd:

SECTION "Select indexed setup 0A", ROMX[$6EC2], BANK[6]
INCLUDE "src/select_indexed_setup.asm"

SelectIndexedSetup0AEnd:

SECTION "Indexed map 9 at $6ECA", ROMX[$6ECA], BANK[6]
; indexed_map_09.asm: not published here (it assembles data copied from the ROM)
IndexedMap09:
    INCBIN "roms/magination.gbc", $1AECA, $40

IndexedMap09End:

SECTION "Indexed map 9 at $6F0A", ROMX[$6F0A], BANK[6]
; indexed_map_09_mid.asm: not published here (it assembles data copied from the ROM)
IndexedMap09Mid:
    INCBIN "roms/magination.gbc", $1AF0A, $40

IndexedMap09MidEnd:

SECTION "Indexed map 9 at $6F4A", ROMX[$6F4A], BANK[6]
; indexed_map_09_tail.asm: not published here (it assembles data copied from the ROM)
IndexedMap09Tail:
    INCBIN "roms/magination.gbc", $1AF4A, $40

IndexedMap09TailEnd:

SECTION "Indexed map 9 at $6F8A", ROMX[$6F8A], BANK[6]
INCLUDE "src/indexed_map_09_end.asm"

IndexedMap09EndRowEnd:

SECTION "Indexed map 9 strip at $6F92", ROMX[$6F92], BANK[6]
; indexed_map_09_strip.asm: not published here (it assembles data copied from the ROM)
Index9RowStrip:
    INCBIN "roms/magination.gbc", $1AF92, $14

Index9RowStripEnd:

SECTION "Index 9 stamp tiles at $6FA6", ROMX[$6FA6], BANK[6]
; index9_stamp_tiles.asm: not published here (it assembles data copied from the ROM)
Index9StampTiles:
    INCBIN "roms/magination.gbc", $1AFA6, $6

Index9StampTilesEnd:

SECTION "Index 9 attribute rows at $6FAC", ROMX[$6FAC], BANK[6]
; index9_attr_rows.asm: not published here (it assembles data copied from the ROM)
Index9AttrRows:
    INCBIN "roms/magination.gbc", $1AFAC, $3C

Index9AttrRowsEnd:

SECTION "Index 9 attribute tail at $6FE8", ROMX[$6FE8], BANK[6]
; index9_attr_rows_tail.asm: not published here (it assembles data copied from the ROM)
Index9AttrRowsTail:
    INCBIN "roms/magination.gbc", $1AFE8, $24

Index9AttrRowsTailEnd:

SECTION "Index 9 attribute strip at $700C", ROMX[$700C], BANK[6]
; index9_attr_strip.asm: not published here (it assembles data copied from the ROM)
Index9AttrStrip:
    INCBIN "roms/magination.gbc", $1B00C, $14

Index9AttrStripEnd:

SECTION "Index 5 map head at $7020", ROMX[$7020], BANK[6]
; indexed_map_05_head.asm: not published here (it assembles data copied from the ROM)
Index5MapGap:
    INCBIN "roms/magination.gbc", $1B020, $6

SECTION "Index 5 map head at $7020 @$01B026", ROMX[$7026], BANK[6]
IndexedMap05Head:
    INCBIN "roms/magination.gbc", $1B026, $3A

IndexedMap05HeadEnd:

SECTION "Index 5 map rows at $7060", ROMX[$7060], BANK[6]
; indexed_map_05_rows.asm: not published here (it assembles data copied from the ROM)
IndexedMap05Rows:
    INCBIN "roms/magination.gbc", $1B060, $3E

IndexedMap05RowsEnd:

SECTION "Index 5 map rows 6 at $709E", ROMX[$709E], BANK[6]
; indexed_map_05_rows6.asm: not published here (it assembles data copied from the ROM)
IndexedMap05Rows6:
    INCBIN "roms/magination.gbc", $1B09E, $3C

IndexedMap05Rows6End:

SECTION "Index 5 map row 9 at $70DA", ROMX[$70DA], BANK[6]
; indexed_map_05_row9.asm: not published here (it assembles data copied from the ROM)
IndexedMap05Row9:
    INCBIN "roms/magination.gbc", $1B0DA, $14

IndexedMap05Row9End:

SECTION "Index 7 map head at $70EE", ROMX[$70EE], BANK[6]
; indexed_map_07_head.asm: not published here (it assembles data copied from the ROM)
IndexedMap07Head:
    INCBIN "roms/magination.gbc", $1B0EE, $3C

IndexedMap07HeadEnd:

SECTION "Index 7 map rows 3 at $712A", ROMX[$712A], BANK[6]
; indexed_map_07_rows3.asm: not published here (it assembles data copied from the ROM)
IndexedMap07Rows3:
    INCBIN "roms/magination.gbc", $1B12A, $3C

IndexedMap07Rows3End:

SECTION "Index 7 map rows 6 at $7166", ROMX[$7166], BANK[6]
; indexed_map_07_rows6.asm: not published here (it assembles data copied from the ROM)
IndexedMap07Rows6:
    INCBIN "roms/magination.gbc", $1B166, $3C

IndexedMap07Rows6End:

SECTION "Index 7 map row 9 at $71A2", ROMX[$71A2], BANK[6]
; indexed_map_07_row9.asm: not published here (it assembles data copied from the ROM)
IndexedMap07Row9:
    INCBIN "roms/magination.gbc", $1B1A2, $14

IndexedMap07Row9End:

SECTION "Index 3 map head at $71B6", ROMX[$71B6], BANK[6]
; indexed_map_03_head.asm: not published here (it assembles data copied from the ROM)
IndexedMap03Head:
    INCBIN "roms/magination.gbc", $1B1B6, $3C

IndexedMap03HeadEnd:

SECTION "Index 3 map rows 3 at $71F2", ROMX[$71F2], BANK[6]
; indexed_map_03_rows3.asm: not published here (it assembles data copied from the ROM)
IndexedMap03Rows3:
    INCBIN "roms/magination.gbc", $1B1F2, $3C

IndexedMap03Rows3End:

SECTION "Index 3 map rows 6 at $722E", ROMX[$722E], BANK[6]
; indexed_map_03_rows6.asm: not published here (it assembles data copied from the ROM)
IndexedMap03Rows6:
    INCBIN "roms/magination.gbc", $1B22E, $3C

IndexedMap03Rows6End:

SECTION "Index 3 map row 9 at $726A", ROMX[$726A], BANK[6]
; indexed_map_03_row9.asm: not published here (it assembles data copied from the ROM)
IndexedMap03Row9:
    INCBIN "roms/magination.gbc", $1B26A, $14

IndexedMap03Row9End:

SECTION "Index 8 map rows 0 at $727E", ROMX[$727E], BANK[6]
; indexed_map_08_rows0.asm: not published here (it assembles data copied from the ROM)
IndexedMap08Rows0:
    INCBIN "roms/magination.gbc", $1B27E, $3C

IndexedMap08Rows0End:

SECTION "Index 8 map rows 3 at $72BA", ROMX[$72BA], BANK[6]
; indexed_map_08_rows3.asm: not published here (it assembles data copied from the ROM)
IndexedMap08Rows3:
    INCBIN "roms/magination.gbc", $1B2BA, $3C

IndexedMap08Rows3End:

SECTION "Index 8 map row 6 at $72F6", ROMX[$72F6], BANK[6]
; indexed_map_08_row6.asm: not published here (it assembles data copied from the ROM)
IndexedMap08Row6:
    INCBIN "roms/magination.gbc", $1B2F6, $14

IndexedMap08Row6End:

SECTION "Indexed map 8 tail at $730A", ROMX[$730A], BANK[6]
; indexed_map_08_tail.asm: not published here (it assembles data copied from the ROM)
IndexedMap08Tail:
    INCBIN "roms/magination.gbc", $1B30A, $3C

IndexedMap08TailEnd:

SECTION "Map at $7346", ROMX[$7346], BANK[6]
; map_at_7346.asm: not published here (it assembles data copied from the ROM)
MapAt7346:
    INCBIN "roms/magination.gbc", $1B346, $3C

MapAt7346End:

SECTION "Map at $7382", ROMX[$7382], BANK[6]
; map_at_7382.asm: not published here (it assembles data copied from the ROM)
MapAt7382:
    INCBIN "roms/magination.gbc", $1B382, $3C

MapAt7382End:

SECTION "Map at $73BE", ROMX[$73BE], BANK[6]
; map_at_73be.asm: not published here (it assembles data copied from the ROM)
MapAt73BE:
    INCBIN "roms/magination.gbc", $1B3BE, $3C

MapAt73BEEnd:

SECTION "Map at $73FA", ROMX[$73FA], BANK[6]
; map_at_73fa.asm: not published here (it assembles data copied from the ROM)
MapAt73FA:
    INCBIN "roms/magination.gbc", $1B3FA, $14

MapAt73FAEnd:

SECTION "Indexed map $0B at $740E", ROMX[$740E], BANK[6]
; indexed_map_0b.asm: not published here (it assembles data copied from the ROM)
IndexedMap0B:
    INCBIN "roms/magination.gbc", $1B40E, $3C

IndexedMap0BEnd:

SECTION "Indexed map $0B rows 3-5", ROMX[$744A], BANK[6]
; indexed_map_0b_rows3.asm: not published here (it assembles data copied from the ROM)
IndexedMap0BRows3:
    INCBIN "roms/magination.gbc", $1B44A, $3C

IndexedMap0BRows3End:

SECTION "Indexed map $0B rows 6-8", ROMX[$7486], BANK[6]
; indexed_map_0b_rows6.asm: not published here (it assembles data copied from the ROM)
IndexedMap0BRows6:
    INCBIN "roms/magination.gbc", $1B486, $3C

IndexedMap0BRows6End:

SECTION "Indexed map $0B row 9", ROMX[$74C2], BANK[6]
; indexed_map_0b_row9.asm: not published here (it assembles data copied from the ROM)
IndexedMap0BRow9:
    INCBIN "roms/magination.gbc", $1B4C2, $14

IndexedMap0BRow9End:

SECTION "Index 5 tiles at $74D6", ROMX[$74D6], BANK[6]
; index5_tiles_at_74d6.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt74D6:
    INCBIN "roms/magination.gbc", $1B4D6, $40

Index5TilesAt74D6End:

SECTION "Index 5 tiles at $7516", ROMX[$7516], BANK[6]
; index5_tiles_at_7516.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt7516:
    INCBIN "roms/magination.gbc", $1B516, $40

Index5TilesAt7516End:

SECTION "Index 5 tiles at $7556", ROMX[$7556], BANK[6]
; index5_tiles_at_7556.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt7556:
    INCBIN "roms/magination.gbc", $1B556, $40

Index5TilesAt7556End:

SECTION "Index 5 tiles at $7596", ROMX[$7596], BANK[6]
; index5_tiles_at_7596.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt7596:
    INCBIN "roms/magination.gbc", $1B596, $40

Index5TilesAt7596End:

SECTION "Index 5 tiles at $75D6", ROMX[$75D6], BANK[6]
; index5_tiles_at_75d6.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt75D6:
    INCBIN "roms/magination.gbc", $1B5D6, $40

Index5TilesAt75D6End:

SECTION "Index 5 tiles at $7616", ROMX[$7616], BANK[6]
; index5_tiles_at_7616.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt7616:
    INCBIN "roms/magination.gbc", $1B616, $40

Index5TilesAt7616End:

SECTION "Index 5 tiles at $7656", ROMX[$7656], BANK[6]
; index5_tiles_at_7656.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt7656:
    INCBIN "roms/magination.gbc", $1B656, $40

Index5TilesAt7656End:

SECTION "Index 5 tiles at $7696", ROMX[$7696], BANK[6]
; index5_tiles_at_7696.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt7696:
    INCBIN "roms/magination.gbc", $1B696, $40

Index5TilesAt7696End:

SECTION "Index 5 tiles at $76D6", ROMX[$76D6], BANK[6]
; index5_tiles_at_76d6.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt76D6:
    INCBIN "roms/magination.gbc", $1B6D6, $34

SECTION "Index 5 tiles at $770A", ROMX[$770A], BANK[6]
; index5_tiles_at_770a.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt76D6End:
Index5TilesAt770A:
    INCBIN "roms/magination.gbc", $1B70A, $40

Index5TilesAt770AEnd:

SECTION "Index 5 tiles at $774A", ROMX[$774A], BANK[6]
; index5_tiles_at_774a.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt774A:
    INCBIN "roms/magination.gbc", $1B74A, $40

Index5TilesAt774AEnd:

SECTION "Index 5 tiles at $778A", ROMX[$778A], BANK[6]
; index5_tiles_at_778a.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt778A:
    INCBIN "roms/magination.gbc", $1B78A, $40

Index5TilesAt778AEnd:

SECTION "Index 5 tiles at $77CA", ROMX[$77CA], BANK[6]
; index5_tiles_at_77ca.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt77CA:
    INCBIN "roms/magination.gbc", $1B7CA, $40

Index5TilesAt77CAEnd:

SECTION "Index 5 tiles at $780A", ROMX[$780A], BANK[6]
; index5_tiles_at_780a.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt780A:
    INCBIN "roms/magination.gbc", $1B80A, $40

Index5TilesAt780AEnd:

SECTION "Index 5 tiles at $784A", ROMX[$784A], BANK[6]
; index5_tiles_at_784a.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt784A:
    INCBIN "roms/magination.gbc", $1B84A, $40

Index5TilesAt784AEnd:

SECTION "Index 5 tiles at $788A", ROMX[$788A], BANK[6]
; index5_tiles_at_788a.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt788A:
    INCBIN "roms/magination.gbc", $1B88A, $40

Index5TilesAt788AEnd:

SECTION "Index 5 tiles at $78CA", ROMX[$78CA], BANK[6]
; index5_tiles_at_78ca.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt78CA:
    INCBIN "roms/magination.gbc", $1B8CA, $40

Index5TilesAt78CAEnd:

SECTION "Index 5 tiles at $790A", ROMX[$790A], BANK[6]
; index5_tiles_at_790a.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt790A:
    INCBIN "roms/magination.gbc", $1B90A, $40

Index5TilesAt790AEnd:

SECTION "Index 5 tiles at $794A", ROMX[$794A], BANK[6]
; index5_tiles_at_794a.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt794A:
    INCBIN "roms/magination.gbc", $1B94A, $40

Index5TilesAt794AEnd:

SECTION "Index 5 tiles at $798A", ROMX[$798A], BANK[6]
; index5_tiles_at_798a.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt798A:
    INCBIN "roms/magination.gbc", $1B98A, $40

Index5TilesAt798AEnd:

SECTION "Index 5 tiles at $79CA", ROMX[$79CA], BANK[6]
; index5_tiles_at_79ca.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt79CA:
    INCBIN "roms/magination.gbc", $1B9CA, $40

Index5TilesAt79CAEnd:

SECTION "Index 5 tiles at $7A0A", ROMX[$7A0A], BANK[6]
; index5_tiles_at_7a0a.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt7A0A:
    INCBIN "roms/magination.gbc", $1BA0A, $40

Index5TilesAt7A0AEnd:

SECTION "Index 5 tiles at $7A4A", ROMX[$7A4A], BANK[6]
; index5_tiles_at_7a4a.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt7A4A:
    INCBIN "roms/magination.gbc", $1BA4A, $40

Index5TilesAt7A4AEnd:

SECTION "Index 5 tiles at $7A8A", ROMX[$7A8A], BANK[6]
; index5_tiles_at_7a8a.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt7A8A:
    INCBIN "roms/magination.gbc", $1BA8A, $40

Index5TilesAt7A8AEnd:

SECTION "Index 5 tiles at $7ACA", ROMX[$7ACA], BANK[6]
; index5_tiles_at_7aca.asm: not published here (it assembles data copied from the ROM)
Index5TilesAt7ACA:
    INCBIN "roms/magination.gbc", $1BACA, $40

Index5TilesAt7ACAEnd:

SECTION "Index 9 tiles at $7B0A", ROMX[$7B0A], BANK[6]
; index9_tiles_at_7b0a.asm: not published here (it assembles data copied from the ROM)
Index9TilesAt7B0A:
    INCBIN "roms/magination.gbc", $1BB0A, $40

Index9TilesAt7B0AEnd:

SECTION "Index 9 tiles at $7B4A", ROMX[$7B4A], BANK[6]
; index9_tiles_at_7b4a.asm: not published here (it assembles data copied from the ROM)
Index9TilesAt7B4A:
    INCBIN "roms/magination.gbc", $1BB4A, $40

Index9TilesAt7B4AEnd:

SECTION "Index 9 tiles at $7B8A", ROMX[$7B8A], BANK[6]
; index9_tiles_at_7b8a.asm: not published here (it assembles data copied from the ROM)
Index9TilesAt7B8A:
    INCBIN "roms/magination.gbc", $1BB8A, $40

Index9TilesAt7B8AEnd:

SECTION "Index 9 tiles at $7BCA", ROMX[$7BCA], BANK[6]
; index9_tiles_at_7bca.asm: not published here (it assembles data copied from the ROM)
Index9TilesAt7BCA:
    INCBIN "roms/magination.gbc", $1BBCA, $40

Index9TilesAt7BCAEnd:

SECTION "Index 9 tiles at $7C0A", ROMX[$7C0A], BANK[6]
; index9_tiles_at_7c0a.asm: not published here (it assembles data copied from the ROM)
Index9TilesAt7C0A:
    INCBIN "roms/magination.gbc", $1BC0A, $40

Index9TilesAt7C0AEnd:

SECTION "Index 9 tiles at $7C4A", ROMX[$7C4A], BANK[6]
; index9_tiles_at_7c4a.asm: not published here (it assembles data copied from the ROM)
Index9TilesAt7C4A:
    INCBIN "roms/magination.gbc", $1BC4A, $40

Index9TilesAt7C4AEnd:

SECTION "Index 9 tiles at $7C8A", ROMX[$7C8A], BANK[6]
; index9_tiles_at_7c8a.asm: not published here (it assembles data copied from the ROM)
Index9TilesAt7C8A:
    INCBIN "roms/magination.gbc", $1BC8A, $40

Index9TilesAt7C8AEnd:

SECTION "Index 9 tiles at $7CCA", ROMX[$7CCA], BANK[6]
; index9_tiles_at_7cca.asm: not published here (it assembles data copied from the ROM)
Index9TilesAt7CCA:
    INCBIN "roms/magination.gbc", $1BCCA, $40

Index9TilesAt7CCAEnd:

SECTION "Index 9 tiles at $7D0A", ROMX[$7D0A], BANK[6]
; index9_tiles_at_7d0a.asm: not published here (it assembles data copied from the ROM)
Index9TilesAt7D0A:
    INCBIN "roms/magination.gbc", $1BD0A, $40

Index9TilesAt7D0AEnd:

SECTION "Index 9 tiles at $7D4A", ROMX[$7D4A], BANK[6]
; index9_tiles_at_7d4a.asm: not published here (it assembles data copied from the ROM)
Index9TilesAt7D4A:
    INCBIN "roms/magination.gbc", $1BD4A, $40

Index9TilesAt7D4AEnd:

SECTION "Index 9 tiles at $7D8A", ROMX[$7D8A], BANK[6]
; index9_tiles_at_7d8a.asm: not published here (it assembles data copied from the ROM)
Index9TilesAt7D8A:
    INCBIN "roms/magination.gbc", $1BD8A, $40

Index9TilesAt7D8AEnd:

SECTION "Index 9 tiles at $7DCA", ROMX[$7DCA], BANK[6]
; index9_tiles_at_7dca.asm: not published here (it assembles data copied from the ROM)
Index9TilesAt7DCA:
    INCBIN "roms/magination.gbc", $1BDCA, $40

Index9TilesAt7DCAEnd:

SECTION "Index 9 tiles at $7E0A", ROMX[$7E0A], BANK[6]
INCLUDE "src/index9_tiles_at_7e0a.asm"

Index9TilesAt7E0AEnd:

SECTION "Index 9 tiles at $7E4A", ROMX[$7E4A], BANK[6]
INCLUDE "src/index9_tiles_at_7e4a.asm"

Index9TilesAt7E4AEnd:

SECTION "Index 9 tiles at $7E8A", ROMX[$7E8A], BANK[6]
INCLUDE "src/index9_tiles_at_7e8a.asm"

Index9TilesAt7E8AEnd:

SECTION "Index 9 tiles at $7ECA", ROMX[$7ECA], BANK[6]
INCLUDE "src/index9_tiles_at_7eca.asm"

Index9TilesAt7ECAEnd:

SECTION "Index 9 tiles at $7F0A", ROMX[$7F0A], BANK[6]
INCLUDE "src/index9_tiles_at_7f0a.asm"

Index9TilesAt7F0AEnd:

SECTION "Index 9 tiles at $7F4A", ROMX[$7F4A], BANK[6]
INCLUDE "src/index9_tiles_at_7f4a.asm"

Index9TilesAt7F4AEnd:

SECTION "Bank 6 tail padding", ROMX[$7F8A], BANK[6]
INCLUDE "src/bank6_tail_padding.asm"

Bank6TailPaddingEnd:

SECTION "Bank 7 hexspeak", ROMX[$4000], BANK[7]
; bank7_hexspeak.asm: not published here (it assembles data copied from the ROM)
Bank7Hexspeak:
    INCBIN "roms/magination.gbc", $1C000, $10

Bank7HexspeakEnd:

SECTION "Mirror accepted save", ROMX[$4010], BANK[7]
INCLUDE "src/mirror_accepted_save.asm"

MirrorAcceptedSaveEnd:

SECTION "Copy save bank through WRAM", ROMX[$4048], BANK[7]
INCLUDE "src/copy_save_bank.asm"

CopySramBankOntoPairEnd:

SECTION "Check save signature", ROMX[$4087], BANK[7]
INCLUDE "src/check_save_signature.asm"

CheckSaveSignatureEnd:

SECTION "Increment SRAM script word", ROMX[$40B7], BANK[7]
INCLUDE "src/increment_sram_script_word.asm"

IncrementSramScriptWordEnd:

SECTION "Store SRAM bank as save flag", ROMX[$40D4], BANK[7]
INCLUDE "src/store_sram_bank_flag.asm"

StoreSramBankFlagThenMirrorEnd:

SECTION "Clear SRAM runs after script word", ROMX[$40E6], BANK[7]
INCLUDE "src/clear_sram_after_script_word.asm"

ClearSramAfterScriptWordEnd:

SECTION "Wipe save banks", ROMX[$410B], BANK[7]
INCLUDE "src/wipe_save_banks.asm"

WipeSaveBanksEnd:

SECTION "Store save stamp", ROMX[$4141], BANK[7]
INCLUDE "src/store_save_stamp.asm"

StoreSaveStampEnd:

SECTION "Cycle panel slot palette colors", ROMX[$416B], BANK[7]
INCLUDE "src/cycle_panel_slot_palette_colors.asm"

CyclePanelSlotPaletteColorsEnd:

SECTION "Dispatch panel slot blend", ROMX[$41BD], BANK[7]
INCLUDE "src/dispatch_panel_slot_blend.asm"

DispatchPanelSlotBlendEnd:

SECTION "Step slot palettes", ROMX[$41CB], BANK[7]
INCLUDE "src/step_slot_palettes.asm"

StepSlotPalettesEnd:

SECTION "Stage pair block from entry record", ROMX[$425F], BANK[7]
INCLUDE "src/stage_pair_block_from_entry_record.asm"

StagePairBlockFromEntryRecordEnd:

SECTION "Write C9DA word at panel color 1", ROMX[$42B1], BANK[7]
INCLUDE "src/write_c9da_word_at_panel_color1.asm"

WriteC9DAWordAtPanelColor1End:

SECTION "Permute panel palette channels", ROMX[$42E3], BANK[7]
INCLUDE "src/permute_panel_palette_channels.asm"

PermutePanelPaletteChannelsEnd:

SECTION "Complement panel slot palettes", ROMX[$4333], BANK[7]
INCLUDE "src/complement_panel_slot_palettes.asm"

ComplementPanelSlotPalettesEnd:

SECTION "Blend low slot palettes", ROMX[$43BD], BANK[7]
INCLUDE "src/blend_low_slot_palettes.asm"

BlendLowSlotPalettesEnd:

SECTION "Blend high slot palettes", ROMX[$440D], BANK[7]
INCLUDE "src/blend_high_slot_palettes.asm"

BlendHighSlotPalettesEnd:

SECTION "Copy C7AB to BG palettes", ROMX[$445F], BANK[7]
INCLUDE "src/copy_c7ab_to_bg_palettes.asm"

CopyC7ABToBGPalettesEnd:

SECTION "Copy C7EB to OBJ palettes", ROMX[$44EA], BANK[7]
INCLUDE "src/copy_c7eb_to_obj_palettes.asm"

CopyC7EBToOBJPalettesEnd:

SECTION "Refresh saved palettes", ROMX[$4575], BANK[7]
INCLUDE "src/refresh_saved_palettes.asm"

RefreshSavedPalettesEnd:

SECTION "Split RGB from color word", ROMX[$4586], BANK[7]
INCLUDE "src/split_color_word.asm"

SplitRgbFromColorWordEnd:

SECTION "Pack RGB into color word", ROMX[$459A], BANK[7]
INCLUDE "src/pack_rgb_into_color_word.asm"

PackRgbChannelsIntoColorWordEnd:

SECTION "Rotate palette colors", ROMX[$45B2], BANK[7]
INCLUDE "src/rotate_palette_colors.asm"

RotatePaletteColorsEnd:

SECTION "Step channels toward saved", ROMX[$4633], BANK[7]
INCLUDE "src/step_channels_toward_saved.asm"

StepChannelsTowardSavedBytesEnd:

SECTION "Decrement channels toward zero", ROMX[$467E], BANK[7]
INCLUDE "src/decrement_channels_toward_zero.asm"

DecrementChannelsTowardZeroEnd:

SECTION "Increment channels toward white", ROMX[$46A1], BANK[7]
INCLUDE "src/increment_channels_toward_white.asm"

IncrementChannelsTowardWhiteEnd:

SECTION "Step color word toward black", ROMX[$46C6], BANK[7]
INCLUDE "src/step_color_word_toward_black.asm"

StepColorWordTowardBlackEnd:

SECTION "Step color word toward saved", ROMX[$46D0], BANK[7]
INCLUDE "src/step_color_word_toward_saved.asm"

StepColorWordTowardSavedEnd:

SECTION "Step color word toward white", ROMX[$46DA], BANK[7]
INCLUDE "src/step_color_word_toward_white.asm"

StepColorWordTowardWhiteEnd:

SECTION "Step color words", ROMX[$46E4], BANK[7]
INCLUDE "src/step_color_words.asm"

StepColorWordsEnd:

SECTION "Arm panel callback", ROMX[$474F], BANK[7]
INCLUDE "src/arm_panel_callback.asm"

ArmPanelCallbackEnd:

SECTION "Write word at twice E stride 8", ROMX[$4774], BANK[7]
INCLUDE "src/write_word_at_twice_e_stride8.asm"

WriteWordAtTwiceEStride8End:

SECTION "Permute color channels", ROMX[$4787], BANK[7]
INCLUDE "src/permute_color_channels.asm"

PermuteColorChannelsEnd:

SECTION "Complement color words", ROMX[$47D1], BANK[7]
INCLUDE "src/complement_color_words.asm"

ComplementColorWordsEnd:

SECTION "Panel row from high nibble", ROMX[$47DD], BANK[7]
INCLUDE "src/panel_row_from_high_nibble.asm"

PanelRowFromHighNibbleEnd:

SECTION "Panel quad from low nibble", ROMX[$47F8], BANK[7]
INCLUDE "src/panel_quad_from_low_nibble.asm"

PanelQuadFromLowNibbleEnd:

SECTION "Stage panel row ptr and pair count", ROMX[$480C], BANK[7]
INCLUDE "src/stage_panel_row_ptr_and_pair_count.asm"

StagePanelRowPtrAndPairCountEnd:

SECTION "Run panel index through 2EB6", ROMX[$481E], BANK[7]
INCLUDE "src/run_panel_index_through_2eb6.asm"

RunPanelIndexThrough2EB6End:

SECTION "Fill panel words eighty past row", ROMX[$4837], BANK[7]
INCLUDE "src/fill_panel_words_eighty_past_row.asm"

FillPanelWordsEightyPastRowEnd:

SECTION "Fill panel words from C9DA", ROMX[$4850], BANK[7]
INCLUDE "src/fill_panel_words_from_c9da.asm"

FillPanelWordsFromC9DAEnd:

SECTION "Rotate palettes eighty past row", ROMX[$4870], BANK[7]
INCLUDE "src/rotate_palettes_eighty_past_row.asm"

RotatePalettesEightyPastRowEnd:

SECTION "Apply panel row words", ROMX[$489D], BANK[7]
INCLUDE "src/apply_panel_row_words.asm"

ApplyPanelRowWordsEnd:

SECTION "Return at 48DB", ROMX[$48DB], BANK[7]
INCLUDE "src/return_at_48db.asm"

ReturnAt48DBEnd:

SECTION "Complement colors eighty past row", ROMX[$48DC], BANK[7]
INCLUDE "src/complement_colors_eighty_past_row.asm"

ComplementColorsEightyPastRowEnd:

SECTION "Step staged color eighty past row", ROMX[$48FD], BANK[7]
INCLUDE "src/step_staged_color_eighty_past_row.asm"

StepStagedColorEightyPastRowEnd:

SECTION "Clamp map camera", ROMX[$491F], BANK[7]
INCLUDE "src/clamp_map_camera.asm"

ClampMapCameraEnd:

SECTION "Draw metatile window", ROMX[$4A55], BANK[7]
INCLUDE "src/draw_metatile_window.asm"

DrawMetatileWindowEnd:

SECTION "Queue script cell copy", ROMX[$4AA4], BANK[7]
INCLUDE "src/queue_script_cell_copy.asm"

QueueScriptCellCopyEnd:

SECTION "Copy stamped map cell", ROMX[$4ADF], BANK[7]
INCLUDE "src/copy_stamped_map_cell.asm"

CopyStampedMapCellEnd:

SECTION "Flush queued scroll", ROMX[$4B1D], BANK[7]
INCLUDE "src/flush_queued_scroll.asm"

FlushQueuedScrollEnd:

SECTION "Build metatile pointers", ROMX[$4C53], BANK[7]
INCLUDE "src/metatile_address.asm"

BuildMetatilePointersEnd:

SECTION "Queue cell copy from id", ROMX[$4C77], BANK[7]
INCLUDE "src/queue_cell_copy_from_id.asm"

QueueCellCopyFromIdEnd:

SECTION "Reload script cell copy", ROMX[$4CA1], BANK[7]
INCLUDE "src/reload_script_cell_copy.asm"

ReloadScriptCellCopyEnd:

SECTION "Copy metatile", ROMX[$4CBB], BANK[7]
INCLUDE "src/copy_metatile.asm"

CopyMetatileEnd:

SECTION "Step horizontal scroll", ROMX[$4CF5], BANK[7]
INCLUDE "src/step_horizontal_scroll.asm"

StepHorizontalScrollEnd:

SECTION "Copy queued column attrs", ROMX[$4E2B], BANK[7]
INCLUDE "src/copy_queued_column_attrs.asm"

CopyQueuedColumnAttrsEnd:

SECTION "Copy queued column", ROMX[$4F38], BANK[7]
INCLUDE "src/copy_queued_column.asm"

CopyQueuedColumnEnd:

SECTION "Step vertical scroll", ROMX[$5198], BANK[7]
INCLUDE "src/step_vertical_scroll.asm"

StepVerticalScrollEnd:

SECTION "Expand scrolled row", ROMX[$52FA], BANK[7]
INCLUDE "src/expand_scrolled_row.asm"

ExpandScrolledRowD400End:

SECTION "Load scrolled row", ROMX[$5415], BANK[7]
INCLUDE "src/load_scrolled_row.asm"

LoadScrolledRowEnd:

SECTION "Write staged bytes at four ptrs", ROMX[$55E5], BANK[7]
INCLUDE "src/write_staged_bytes_at_four_ptrs.asm"

WriteStagedBytesAtFourPtrsEnd:

SECTION "Step tilemap column", ROMX[$564F], BANK[7]
INCLUDE "src/step_tilemap_column.asm"

StepTilemapColumnEnd:

SECTION "Step tilemap row", ROMX[$565A], BANK[7]
INCLUDE "src/step_tilemap_row.asm"

StepTilemapRowEnd:

SECTION "Stage tilemap quad", ROMX[$566E], BANK[7]
INCLUDE "src/stage_tilemap_quad.asm"

StageTilemapQuadEnd:

SECTION "Stage tilemap quad right", ROMX[$56B1], BANK[7]
INCLUDE "src/stage_tilemap_quad_right.asm"

StageTilemapQuadRightEnd:

SECTION "Stage tilemap quad left", ROMX[$56C0], BANK[7]
INCLUDE "src/stage_tilemap_quad_left.asm"

StageTilemapQuadLeftEnd:

SECTION "Stage tilemap quad down", ROMX[$56CF], BANK[7]
INCLUDE "src/stage_tilemap_quad_down.asm"

StageTilemapQuadDownEnd:

SECTION "Stage tilemap quad up", ROMX[$56DE], BANK[7]
INCLUDE "src/stage_tilemap_quad_up.asm"

StageTilemapQuadUpEnd:

SECTION "Fill tilemap rect 22x20", ROMX[$56ED], BANK[7]
INCLUDE "src/fill_tilemap_rect_22x20.asm"

FillTilemapRect22x20End:

SECTION "Enter opcode 30 target", ROMX[$584A], BANK[7]
INCLUDE "src/enter_opcode30_target.asm"

EnterOpcode30TargetEnd:

SECTION "Init sound state", ROMX[$5854], BANK[7]
INCLUDE "src/init_sound_state.asm"

InitSoundStateEnd:

SECTION "Select sound command", ROMX[$5897], BANK[7]
INCLUDE "src/select_sound_command.asm"

SECTION "Advance sound index on A", ROMX[$5997], BANK[7]
INCLUDE "src/advance_sound_index_on_a.asm"

AdvanceSoundIndexOnAEnd:

SECTION "Sound index buttons after A", ROMX[$59CA], BANK[7]
INCLUDE "src/sound_index_buttons_after_a.asm"

SoundIndexButtonsAfterAEnd:

SECTION "Read joypad", ROMX[$59FF], BANK[7]
INCLUDE "src/read_joypad.asm"

ReadJoypadEnd:

SECTION "Switch to double speed", ROMX[$5A4F], BANK[7]
INCLUDE "src/switch_to_double_speed.asm"

SwitchCPUToDoubleSpeedEnd:

SECTION "Switch to normal speed", ROMX[$5A7C], BANK[7]
INCLUDE "src/switch_to_normal_speed.asm"

SwitchCPUToNormalSpeedEnd:

SECTION "Copy OAM DMA routine", ROMX[$5AA9], BANK[7]
INCLUDE "src/copy_oam_dma_routine.asm"

CopyOAMDMAToHRAMEnd:

SECTION "Copy three bytes from CD8D pointer", ROMX[$5AC1], BANK[7]
INCLUDE "src/copy_three_from_cd8d_ptr.asm"

CopyThreeFromCD8DEnd:

SECTION "SRAM list price table", ROMX[$5AD7], BANK[7]
; sram_list_price_table.asm: not published here (it assembles data copied from the ROM)
SramListPriceTable:
    INCBIN "roms/magination.gbc", $1DAD7, $3F

SramListPriceTableEnd:

SECTION "SRAM list prices from 105", ROMX[$5B16], BANK[7]
; sram_list_prices_105.asm: not published here (it assembles data copied from the ROM)
SramListPricesFrom105:
    INCBIN "roms/magination.gbc", $1DB16, $3F

SramListPricesFrom105End:

SECTION "SRAM list prices from 210", ROMX[$5B55], BANK[7]
; sram_list_prices_210.asm: not published here (it assembles data copied from the ROM)
SramListPricesFrom210:
    INCBIN "roms/magination.gbc", $1DB55, $3F

SramListPricesFrom210End:

SECTION "SRAM list prices from 315", ROMX[$5B94], BANK[7]
; sram_list_prices_315.asm: not published here (it assembles data copied from the ROM)
SramListPricesFrom315:
    INCBIN "roms/magination.gbc", $1DB94, $3F

SramListPricesFrom315End:

SECTION "SRAM list prices from 420", ROMX[$5BD3], BANK[7]
; sram_list_prices_420.asm: not published here (it assembles data copied from the ROM)
SramListPricesFrom420:
    INCBIN "roms/magination.gbc", $1DBD3, $2D

SramListPricesFrom420End:

SECTION "Step staged color and copy C7DB word", ROMX[$5C00], BANK[7]
INCLUDE "src/step_staged_color_and_copy_c7db.asm"

StepStagedColorAndCopyC7DBEnd:

SECTION "Apply panel row and copy C7DB word", ROMX[$5C29], BANK[7]
INCLUDE "src/apply_panel_row_and_copy_c7db.asm"

ApplyPanelRowAndCopyC7DBEnd:

SECTION "Write C9E5 word at slots 00 and 0C", ROMX[$5C52], BANK[7]
INCLUDE "src/write_c9e5_word_at_slots_00_and_0c.asm"

WriteC9E5WordAtSlots00And0CEnd:

SECTION "Write indexed word at slot 18", ROMX[$5C7E], BANK[7]
INCLUDE "src/write_indexed_word_at_slot18.asm"

WriteIndexedWordAtSlot18End:

SECTION "Write C9E5 word at C7AB slot 14", ROMX[$5C9D], BANK[7]
INCLUDE "src/write_c9e5_word_at_c7ab_slot14.asm"

WriteC9E5WordAtC7ABSlot14End:

SECTION "Write panel word then zero", ROMX[$5CB9], BANK[7]
INCLUDE "src/write_panel_word_then_zero.asm"

SECTION "Write C9E5 word at C7AB slots", ROMX[$5CE2], BANK[7]
INCLUDE "src/write_c9e5_word_at_c7ab_slots.asm"

WriteC9E5WordAtC7ABSlotsEnd:

SECTION "Replace 3DE0 at slots 08 and 14", ROMX[$5D32], BANK[7]
INCLUDE "src/replace_3de0_at_slots_08_and_14.asm"

Replace3DE0AtSlots08And14End:

SECTION "Bank 7 default arg table", ROMX[$5D7F], BANK[7]
; bank7_default_arg_table.asm: not published here (it assembles data copied from the ROM)
Bank7DefaultArgHandlers:
    INCBIN "roms/magination.gbc", $1DD7F, $1C

SECTION "Copy two bytes from CD8D pointer", ROMX[$5D9B], BANK[7]
INCLUDE "src/copy_two_from_cd8d_ptr.asm"

CopyTwoFromCD8DEnd:

SECTION "Copy group bytes", ROMX[$5DAE], BANK[7]
INCLUDE "src/copy_group_bytes.asm"

SECTION "Copy indexed group record", ROMX[$5DC3], BANK[7]
INCLUDE "src/copy_indexed_group_record.asm"

SECTION "Copy indexed group record from 6FF5", ROMX[$5DE1], BANK[7]
INCLUDE "src/copy_indexed_group_record_6ff5.asm"

SECTION "Blank group record at 5DFF", ROMX[$5DFF], BANK[7]
; blank_group_record_5dff.asm: not published here (it assembles data copied from the ROM)
BlankGroupRecord5DFF:
    INCBIN "roms/magination.gbc", $1DDFF, $22

BlankGroupRecord5DFFEnd:

SECTION "Baloo Leaf group record", ROMX[$5E21], BANK[7]
; baloo_leaf_group_record.asm: not published here (it assembles data copied from the ROM)
BalooLeafGroupRecord:
    INCBIN "roms/magination.gbc", $1DE21, $22

BalooLeafGroupRecordEnd:

SECTION "Baloo Sap group record", ROMX[$5E43], BANK[7]
; baloo_sap_group_record.asm: not published here (it assembles data copied from the ROM)
BalooSapGroupRecord:
    INCBIN "roms/magination.gbc", $1DE43, $22

BalooSapGroupRecordEnd:

SECTION "Baloo Root group record", ROMX[$5E65], BANK[7]
; baloo_root_group_record.asm: not published here (it assembles data copied from the ROM)
BalooRootGroupRecord:
    INCBIN "roms/magination.gbc", $1DE65, $22

BalooRootGroupRecordEnd:

SECTION "3-Headed Coin group record", ROMX[$5E87], BANK[7]
; three_headed_coin_group_record.asm: not published here (it assembles data copied from the ROM)
ThreeHeadedCoinGroupRecord:
    INCBIN "roms/magination.gbc", $1DE87, $22

ThreeHeadedCoinGroupRecordEnd:

SECTION "Balance Scale group record", ROMX[$5EA9], BANK[7]
; balance_scale_group_record.asm: not published here (it assembles data copied from the ROM)
BalanceScaleGroupRecord:
    INCBIN "roms/magination.gbc", $1DEA9, $22

BalanceScaleGroupRecordEnd:

SECTION "Bucket O'pink group record", ROMX[$5ECB], BANK[7]
; bucket_opink_group_record.asm: not published here (it assembles data copied from the ROM)
BucketOpinkGroupRecord:
    INCBIN "roms/magination.gbc", $1DECB, $22

BucketOpinkGroupRecordEnd:

SECTION "Plod Spnew group record", ROMX[$5EED], BANK[7]
; plod_spnew_group_record.asm: not published here (it assembles data copied from the ROM)
PlodSpnewGroupRecord:
    INCBIN "roms/magination.gbc", $1DEED, $22

PlodSpnewGroupRecordEnd:

SECTION "Haste Gem group record", ROMX[$5F0F], BANK[7]
; haste_gem_group_record.asm: not published here (it assembles data copied from the ROM)
HasteGemGroupRecord:
    INCBIN "roms/magination.gbc", $1DF0F, $22

HasteGemGroupRecordEnd:

SECTION "Guard Gem group record", ROMX[$5F31], BANK[7]
; guard_gem_group_record.asm: not published here (it assembles data copied from the ROM)
GuardGemGroupRecord:
    INCBIN "roms/magination.gbc", $1DF31, $22

GuardGemGroupRecordEnd:

SECTION "Power Gem group record", ROMX[$5F53], BANK[7]
; power_gem_group_record.asm: not published here (it assembles data copied from the ROM)
PowerGemGroupRecord:
    INCBIN "roms/magination.gbc", $1DF53, $22

PowerGemGroupRecordEnd:

SECTION "Strength Gem group record", ROMX[$5F75], BANK[7]
; strength_gem_group_record.asm: not published here (it assembles data copied from the ROM)
StrengthGemGroupRecord:
    INCBIN "roms/magination.gbc", $1DF75, $22

StrengthGemGroupRecordEnd:

SECTION "Deflect Gem group record", ROMX[$5F97], BANK[7]
; deflect_gem_group_record.asm: not published here (it assembles data copied from the ROM)
DeflectGemGroupRecord:
    INCBIN "roms/magination.gbc", $1DF97, $22

DeflectGemGroupRecordEnd:

SECTION "Remedy Drink group record", ROMX[$5FB9], BANK[7]
; remedy_drink_group_record.asm: not published here (it assembles data copied from the ROM)
RemedyDrinkGroupRecord:
    INCBIN "roms/magination.gbc", $1DFB9, $22

RemedyDrinkGroupRecordEnd:

SECTION "Crescent Gem group record", ROMX[$5FDB], BANK[7]
; crescent_gem_group_record.asm: not published here (it assembles data copied from the ROM)
CrescentGemGroupRecord:
    INCBIN "roms/magination.gbc", $1DFDB, $22

CrescentGemGroupRecordEnd:

SECTION "Gibbous Gem group record", ROMX[$5FFD], BANK[7]
; gibbous_gem_group_record.asm: not published here (it assembles data copied from the ROM)
GibbousGemGroupRecord:
    INCBIN "roms/magination.gbc", $1DFFD, $22

GibbousGemGroupRecordEnd:

SECTION "Rune of Might group record", ROMX[$601F], BANK[7]
; rune_of_might_group_record.asm: not published here (it assembles data copied from the ROM)
RuneOfMightGroupRecord:
    INCBIN "roms/magination.gbc", $1E01F, $22

RuneOfMightGroupRecordEnd:

SECTION "Rune of Hope group record", ROMX[$6041], BANK[7]
; rune_of_hope_group_record.asm: not published here (it assembles data copied from the ROM)
RuneOfHopeGroupRecord:
    INCBIN "roms/magination.gbc", $1E041, $22

RuneOfHopeGroupRecordEnd:

SECTION "Rune of Power group record", ROMX[$6063], BANK[7]
; rune_of_power_group_record.asm: not published here (it assembles data copied from the ROM)
RuneOfPowerGroupRecord:
    INCBIN "roms/magination.gbc", $1E063, $22

RuneOfPowerGroupRecordEnd:

SECTION "Rune of Will group record", ROMX[$6085], BANK[7]
; rune_of_will_group_record.asm: not published here (it assembles data copied from the ROM)
RuneOfWillGroupRecord:
    INCBIN "roms/magination.gbc", $1E085, $22

RuneOfWillGroupRecordEnd:

SECTION "Rune of Fury group record", ROMX[$60A7], BANK[7]
; rune_of_fury_group_record.asm: not published here (it assembles data copied from the ROM)
RuneOfFuryGroupRecord:
    INCBIN "roms/magination.gbc", $1E0A7, $22

RuneOfFuryGroupRecordEnd:

SECTION "Master Rune group record", ROMX[$60C9], BANK[7]
; master_rune_group_record.asm: not published here (it assembles data copied from the ROM)
MasterRuneGroupRecord:
    INCBIN "roms/magination.gbc", $1E0C9, $22

MasterRuneGroupRecordEnd:

SECTION "Karmic Might group record", ROMX[$60EB], BANK[7]
; karmic_might_group_record.asm: not published here (it assembles data copied from the ROM)
KarmicMightGroupRecord:
    INCBIN "roms/magination.gbc", $1E0EB, $22

KarmicMightGroupRecordEnd:

SECTION "Karmic Hope group record", ROMX[$610D], BANK[7]
; karmic_hope_group_record.asm: not published here (it assembles data copied from the ROM)
KarmicHopeGroupRecord:
    INCBIN "roms/magination.gbc", $1E10D, $22

KarmicHopeGroupRecordEnd:

SECTION "Karmic Power group record", ROMX[$612F], BANK[7]
; karmic_power_group_record.asm: not published here (it assembles data copied from the ROM)
KarmicPowerGroupRecord:
    INCBIN "roms/magination.gbc", $1E12F, $22

KarmicPowerGroupRecordEnd:

SECTION "Karmic Will group record", ROMX[$6151], BANK[7]
; karmic_will_group_record.asm: not published here (it assembles data copied from the ROM)
KarmicWillGroupRecord:
    INCBIN "roms/magination.gbc", $1E151, $22

KarmicWillGroupRecordEnd:

SECTION "Karmic Fury group record", ROMX[$6173], BANK[7]
; karmic_fury_group_record.asm: not published here (it assembles data copied from the ROM)
KarmicFuryGroupRecord:
    INCBIN "roms/magination.gbc", $1E173, $22

KarmicFuryGroupRecordEnd:

SECTION "Cloud Frond group record", ROMX[$6195], BANK[7]
; cloud_frond_group_record.asm: not published here (it assembles data copied from the ROM)
CloudFrondGroupRecord:
    INCBIN "roms/magination.gbc", $1E195, $22

CloudFrondGroupRecordEnd:

SECTION "Shadow Key record fields", ROMX[$61B7], BANK[7]
; shadow_key_record_fields.asm: not published here (it assembles data copied from the ROM)
ShadowKeyRecordFields:
    INCBIN "roms/magination.gbc", $1E1B7, $C

ShadowKeyRecordFieldsEnd:

SECTION "Shadow Key name", ROMX[$61C3], BANK[7]
; shadow_key_name.asm: not published here (it assembles data copied from the ROM)
ShadowKeyName:
    INCBIN "roms/magination.gbc", $1E1C3, $13

ShadowKeyNameEnd:

SECTION "Ashgar's Key record", ROMX[$61D6], BANK[7]
; ashgars_key_record.asm: not published here (it assembles data copied from the ROM)
AshgarsKeyRecord:
    INCBIN "roms/magination.gbc", $1E1D6, $22

AshgarsKeyRecordEnd:

SECTION "Blu's Horn record", ROMX[$61F8], BANK[7]
; blus_horn_record.asm: not published here (it assembles data copied from the ROM)
BlusHornRecord:
    INCBIN "roms/magination.gbc", $1E1F8, $22

BlusHornRecordEnd:

SECTION "Wence's Arrow record", ROMX[$621A], BANK[7]
; wences_arrow_record.asm: not published here (it assembles data copied from the ROM)
WencesArrowRecord:
    INCBIN "roms/magination.gbc", $1E21A, $22

WencesArrowRecordEnd:

SECTION "Feather record", ROMX[$623C], BANK[7]
; feather_record.asm: not published here (it assembles data copied from the ROM)
FeatherRecord:
    INCBIN "roms/magination.gbc", $1E23C, $22

FeatherRecordEnd:

SECTION "Star Key record", ROMX[$625E], BANK[7]
; star_key_record.asm: not published here (it assembles data copied from the ROM)
StarKeyRecord:
    INCBIN "roms/magination.gbc", $1E25E, $22

StarKeyRecordEnd:

SECTION "Blurry record", ROMX[$6280], BANK[7]
; blurry_record.asm: not published here (it assembles data copied from the ROM)
BlurryRecord:
    INCBIN "roms/magination.gbc", $1E280, $22

BlurryRecordEnd:

SECTION "Water of Life record", ROMX[$62A2], BANK[7]
; water_of_life_record.asm: not published here (it assembles data copied from the ROM)
WaterOfLifeRecord:
    INCBIN "roms/magination.gbc", $1E2A2, $22

WaterOfLifeRecordEnd:

SECTION "Screwdriver record", ROMX[$62C4], BANK[7]
; screwdriver_record.asm: not published here (it assembles data copied from the ROM)
ScrewdriverRecord:
    INCBIN "roms/magination.gbc", $1E2C4, $22

ScrewdriverRecordEnd:

SECTION "Specimen Jar record", ROMX[$62E6], BANK[7]
; specimen_jar_record.asm: not published here (it assembles data copied from the ROM)
SpecimenJarRecord:
    INCBIN "roms/magination.gbc", $1E2E6, $22

SpecimenJarRecordEnd:

SECTION "Jar of Fungus record", ROMX[$6308], BANK[7]
; jar_of_fungus_record.asm: not published here (it assembles data copied from the ROM)
JarOfFungusRecord:
    INCBIN "roms/magination.gbc", $1E308, $22

JarOfFungusRecordEnd:

SECTION "Algae record", ROMX[$632A], BANK[7]
; algae_record.asm: not published here (it assembles data copied from the ROM)
AlgaeRecord:
    INCBIN "roms/magination.gbc", $1E32A, $22

AlgaeRecordEnd:

SECTION "Fungicide record", ROMX[$634C], BANK[7]
; fungicide_record.asm: not published here (it assembles data copied from the ROM)
FungicideRecord:
    INCBIN "roms/magination.gbc", $1E34C, $22

FungicideRecordEnd:

SECTION "Hollow Stool record", ROMX[$636E], BANK[7]
; hollow_stool_record.asm: not published here (it assembles data copied from the ROM)
HollowStoolRecord:
    INCBIN "roms/magination.gbc", $1E36E, $22

HollowStoolRecordEnd:

SECTION "Blast Urn record", ROMX[$6390], BANK[7]
; blast_urn_record.asm: not published here (it assembles data copied from the ROM)
BlastUrnRecord:
    INCBIN "roms/magination.gbc", $1E390, $22

BlastUrnRecordEnd:

SECTION "Ticket record", ROMX[$63B2], BANK[7]
; ticket_record.asm: not published here (it assembles data copied from the ROM)
TicketRecord:
    INCBIN "roms/magination.gbc", $1E3B2, $22

TicketRecordEnd:

SECTION "Bird Seed record", ROMX[$63D4], BANK[7]
; bird_seed_record.asm: not published here (it assembles data copied from the ROM)
BirdSeedRecord:
    INCBIN "roms/magination.gbc", $1E3D4, $22

BirdSeedRecordEnd:

SECTION "Eldritch Awl record", ROMX[$63F6], BANK[7]
; eldritch_awl_record.asm: not published here (it assembles data copied from the ROM)
EldritchAwlRecord:
    INCBIN "roms/magination.gbc", $1E3F6, $22

EldritchAwlRecordEnd:

SECTION "Ornate Awl record", ROMX[$6418], BANK[7]
; ornate_awl_record.asm: not published here (it assembles data copied from the ROM)
OrnateAwlRecord:
    INCBIN "roms/magination.gbc", $1E418, $22

OrnateAwlRecordEnd:

SECTION "Eight-byte stat names", ROMX[$643A], BANK[7]
; eight_byte_stat_names.asm: not published here (it assembles data copied from the ROM)
EightByteStatNames:
    INCBIN "roms/magination.gbc", $1E43A, $3B

EightByteStatNamesEnd:

SECTION "Nine-byte status names", ROMX[$6475], BANK[7]
; sub_cd93_from_d110_plus_ten_or_name_count.asm: not published here (it assembles data copied from the ROM)
NineByteStatusNames:
    INCBIN "roms/magination.gbc", $1E475, $40

SECTION "Nine-byte status names @$01E4B5", ROMX[$64B5], BANK[7]
SubCd93FromD110PlusTenOrNameCount:
    INCBIN "roms/magination.gbc", $1E4B5, $5A

SubCd93FromD110PlusTenOrNameCountEnd:

SECTION "Subtract CD93 from indexed SRAM below five", ROMX[$650F], BANK[7]
INCLUDE "src/sub_cd93_from_indexed_sram_below_five.asm"

SECTION "Add CD93 into D110 plus ten or set name count", ROMX[$6551], BANK[7]
INCLUDE "src/add_cd93_into_d110_plus_ten_or_name_count.asm"

SECTION "Add CD93 into indexed SRAM below five", ROMX[$65AF], BANK[7]
INCLUDE "src/add_cd93_into_indexed_sram_below_five.asm"

SECTION "Add CD93 into next SRAM byte", ROMX[$65C3], BANK[7]
INCLUDE "src/add_cd93_into_next_sram_byte.asm"

SECTION "Zero name count script 416D or mark D125", ROMX[$65F1], BANK[7]
INCLUDE "src/zero_name_count_script_416d_or_mark_d125.asm"

SECTION "Zero name count script from CDAA and complement D124", ROMX[$6648], BANK[7]
INCLUDE "src/zero_name_count_script_from_cdaa_complement_d124.asm"

SECTION "Zero name count script 4184 or mark D125", ROMX[$667B], BANK[7]
INCLUDE "src/zero_name_count_script_4184_or_mark_d125.asm"

SECTION "Zero name count and script 4A4E", ROMX[$66D2], BANK[7]
INCLUDE "src/count_zero_names_script_4a4e.asm"

CountZeroNamesAndPlantScript4A4EEnd:

SECTION "Copy D119 word, zero count, plant CDAA script", ROMX[$6701], BANK[7]
INCLUDE "src/copy_d119_word_zero_count_plant_cdaa_script.asm"

CopyD119WordZeroCountThenPlantCdaaScriptEnd:

SECTION "Floor remainder SRAM and copy eight", ROMX[$6739], BANK[7]
INCLUDE "src/floor_remainder_sram_and_copy_eight.asm"

FloorRemainderSramAndCopyEightEnd:

SECTION "Add two to five next SRAM bytes then plant CDAA script", ROMX[$6791], BANK[7]
INCLUDE "src/add_two_to_five_next_sram_then_plant_cdaa.asm"

AddTwoToFiveNextSramThenPlantCdaaEnd:

SECTION "Rotate D125, mask with not D124, plant CDAA script", ROMX[$67E3], BANK[7]
INCLUDE "src/rotate_d125_or_d126_mask_not_d124_plant_cdaa.asm"

SECTION "RRC D125, mask with not D124, plant CDAA script", ROMX[$6824], BANK[7]
INCLUDE "src/rrc_d125_or_d126_mask_not_d124_plant_cdaa.asm"

SECTION "Clamp group SRAM byte", ROMX[$6865], BANK[7]
INCLUDE "src/clamp_group_sram.asm"

SECTION "Copy record for lowest set bit", ROMX[$68B4], BANK[7]
INCLUDE "src/copy_record_for_lowest_set_bit.asm"

CopyRecordForLowestSetBitEnd:

SECTION "Floor group SRAM byte", ROMX[$68DA], BANK[7]
INCLUDE "src/floor_group_sram_byte.asm"

SECTION "Copy scaled group bytes", ROMX[$68E1], BANK[7]
INCLUDE "src/copy_scaled_group_bytes.asm"

SECTION "Copy indexed record", ROMX[$68F8], BANK[7]
INCLUDE "src/copy_indexed_record.asm"

CopyIndexedRecordEnd:

SECTION "Indexed name records", ROMX[$6916], BANK[7]
; indexed_name_records.asm: not published here (it assembles data copied from the ROM)
BlankIndexedNameRecord:
    INCBIN "roms/magination.gbc", $1E916, $13

SECTION "Indexed name records @$01E929", ROMX[$6929], BANK[7]
ArchaicLeafIndexedRecord:
    INCBIN "roms/magination.gbc", $1E929, $13

SECTION "Indexed name records @$01E93C", ROMX[$693C], BANK[7]
ArmorOrbIndexedRecord:
    INCBIN "roms/magination.gbc", $1E93C, $13

IndexedNameRecordsEnd:

SECTION "Indexed name records at $694F", ROMX[$694F], BANK[7]
; indexed_name_records_694f.asm: not published here (it assembles data copied from the ROM)
BagOfBonesIndexedRecord:
    INCBIN "roms/magination.gbc", $1E94F, $13

SECTION "Indexed name records at $694F @$01E962", ROMX[$6962], BANK[7]
BarkThimbleIndexedRecord:
    INCBIN "roms/magination.gbc", $1E962, $13

SECTION "Indexed name records at $694F @$01E975", ROMX[$6975], BANK[7]
ChanneledGemIndexedRecord:
    INCBIN "roms/magination.gbc", $1E975, $13

IndexedNameRecords694FEnd:

SECTION "Indexed name records at $6988", ROMX[$6988], BANK[7]
; indexed_name_records_6988.asm: not published here (it assembles data copied from the ROM)
CorfPearlIndexedRecord:
    INCBIN "roms/magination.gbc", $1E988, $13

SECTION "Indexed name records at $6988 @$01E99B", ROMX[$699B], BANK[7]
CrimsonVoidIndexedRecord:
    INCBIN "roms/magination.gbc", $1E99B, $13

SECTION "Indexed name records at $6988 @$01E9AE", ROMX[$69AE], BANK[7]
EarthsAuraIndexedRecord:
    INCBIN "roms/magination.gbc", $1E9AE, $13

IndexedNameRecords6988End:

SECTION "Indexed name records at $69C1", ROMX[$69C1], BANK[7]
; indexed_name_records_69c1.asm: not published here (it assembles data copied from the ROM)
EndBringerIndexedRecord:
    INCBIN "roms/magination.gbc", $1E9C1, $13

SECTION "Indexed name records at $69C1 @$01E9D4", ROMX[$69D4], BANK[7]
EnergyGemIndexedRecord:
    INCBIN "roms/magination.gbc", $1E9D4, $13

SECTION "Indexed name records at $69C1 @$01E9E7", ROMX[$69E7], BANK[7]
FlameAuraIndexedRecord:
    INCBIN "roms/magination.gbc", $1E9E7, $13

IndexedNameRecords69C1End:

SECTION "Indexed name records at $69FA", ROMX[$69FA], BANK[7]
; indexed_name_records_69fa.asm: not published here (it assembles data copied from the ROM)
FlameEssenceIndexedRecord:
    INCBIN "roms/magination.gbc", $1E9FA, $13

SECTION "Indexed name records at $69FA @$01EA0D", ROMX[$6A0D], BANK[7]
GemOfNaroomIndexedRecord:
    INCBIN "roms/magination.gbc", $1EA0D, $13

SECTION "Indexed name records at $69FA @$01EA20", ROMX[$6A20], BANK[7]
GoldenCloverIndexedRecord:
    INCBIN "roms/magination.gbc", $1EA20, $13

IndexedNameRecords69FAEnd:

SECTION "Indexed name records at $6A33", ROMX[$6A33], BANK[7]
; indexed_name_records_6a33.asm: not published here (it assembles data copied from the ROM)
GrailOfLifeIndexedRecord:
    INCBIN "roms/magination.gbc", $1EA33, $13

SECTION "Indexed name records at $6A33 @$01EA46", ROMX[$6A46], BANK[7]
HyrensClawIndexedRecord:
    INCBIN "roms/magination.gbc", $1EA46, $13

SECTION "Indexed name records at $6A33 @$01EA59", ROMX[$6A59], BANK[7]
LeafEssenceIndexedRecord:
    INCBIN "roms/magination.gbc", $1EA59, $13

IndexedNameRecords6A33End:

SECTION "Indexed name records at $6A6C", ROMX[$6A6C], BANK[7]
; indexed_name_records_6a6c.asm: not published here (it assembles data copied from the ROM)
LucentBeltIndexedRecord:
    INCBIN "roms/magination.gbc", $1EA6C, $13

SECTION "Indexed name records at $6A6C @$01EA7F", ROMX[$6A7F], BANK[7]
MaelstromIndexedRecord:
    INCBIN "roms/magination.gbc", $1EA7F, $13

SECTION "Indexed name records at $6A6C @$01EA92", ROMX[$6A92], BANK[7]
OmborsAmuletIndexedRecord:
    INCBIN "roms/magination.gbc", $1EA92, $13

IndexedNameRecords6A6CEnd:

SECTION "Indexed name records at $6AA5", ROMX[$6AA5], BANK[7]
; indexed_name_records_6aa5.asm: not published here (it assembles data copied from the ROM)
PhantomWindIndexedRecord:
    INCBIN "roms/magination.gbc", $1EAA5, $13

SECTION "Indexed name records at $6AA5 @$01EAB8", ROMX[$6AB8], BANK[7]
PinchOfLifeIndexedRecord:
    INCBIN "roms/magination.gbc", $1EAB8, $13

SECTION "Indexed name records at $6AA5 @$01EACB", ROMX[$6ACB], BANK[7]
RabbageFootIndexedRecord:
    INCBIN "roms/magination.gbc", $1EACB, $13

IndexedNameRecords6AA5End:

SECTION "Indexed name records at $6ADE", ROMX[$6ADE], BANK[7]
; indexed_name_records_6ade.asm: not published here (it assembles data copied from the ROM)
RageStoneIndexedRecord:
    INCBIN "roms/magination.gbc", $1EADE, $13

SECTION "Indexed name records at $6ADE @$01EAF1", ROMX[$6AF1], BANK[7]
ShadowVeilIndexedRecord:
    INCBIN "roms/magination.gbc", $1EAF1, $13

SECTION "Indexed name records at $6ADE @$01EB04", ROMX[$6B04], BANK[7]
ShieldOrbIndexedRecord:
    INCBIN "roms/magination.gbc", $1EB04, $13

IndexedNameRecords6ADEEnd:

SECTION "Indexed name records at $6B17", ROMX[$6B17], BANK[7]
; indexed_name_records_6b17.asm: not published here (it assembles data copied from the ROM)
SkyEssenceIndexedRecord:
    INCBIN "roms/magination.gbc", $1EB17, $13

SECTION "Indexed name records at $6B17 @$01EB2A", ROMX[$6B2A], BANK[7]
SpiceOfLifeIndexedRecord:
    INCBIN "roms/magination.gbc", $1EB2A, $13

SECTION "Indexed name records at $6B17 @$01EB3D", ROMX[$6B3D], BANK[7]
StoneEssenceIndexedRecord:
    INCBIN "roms/magination.gbc", $1EB3D, $13

IndexedNameRecords6B17End:

SECTION "Indexed name records at $6B50", ROMX[$6B50], BANK[7]
; indexed_name_records_6b50.asm: not published here (it assembles data copied from the ROM)
StoneOfDoomIndexedRecord:
    INCBIN "roms/magination.gbc", $1EB50, $13

SECTION "Indexed name records at $6B50 @$01EB63", ROMX[$6B63], BANK[7]
StoneOfLifeIndexedRecord:
    INCBIN "roms/magination.gbc", $1EB63, $13

SECTION "Indexed name records at $6B50 @$01EB76", ROMX[$6B76], BANK[7]
SwordOfWindIndexedRecord:
    INCBIN "roms/magination.gbc", $1EB76, $13

IndexedNameRecords6B50End:

SECTION "Indexed name records at $6B89", ROMX[$6B89], BANK[7]
; indexed_name_records_6b89.asm: not published here (it assembles data copied from the ROM)
TideEssenceIndexedRecord:
    INCBIN "roms/magination.gbc", $1EB89, $13

SECTION "Indexed name records at $6B89 @$01EB9C", ROMX[$6B9C], BANK[7]
TitanRingIndexedRecord:
    INCBIN "roms/magination.gbc", $1EB9C, $13

SECTION "Indexed name records at $6B89 @$01EBAF", ROMX[$6BAF], BANK[7]
WaterOrbIndexedRecord:
    INCBIN "roms/magination.gbc", $1EBAF, $13

IndexedNameRecords6B89End:

SECTION "Indexed name record at $6BC2", ROMX[$6BC2], BANK[7]
; indexed_name_records_6bc2.asm: not published here (it assembles data copied from the ROM)
WishboneIndexedRecord:
    INCBIN "roms/magination.gbc", $1EBC2, $13

IndexedNameRecords6BC2End:

SECTION "Indexed name shared return", ROMX[$6BD5], BANK[7]
INCLUDE "src/indexed_name_shared_return.asm"

SECTION "Archaic Leaf cap D11C", ROMX[$6BD6], BANK[7]
INCLUDE "src/archaic_leaf_cap_d11c.asm"

ArchaicLeafCapD11CEnd:

SECTION "Armor Orb cap D11E", ROMX[$6BE4], BANK[7]
INCLUDE "src/armor_orb_cap_d11e.asm"

ArmorOrbCapD11EEnd:

SECTION "Bag of Bones cap D11B", ROMX[$6BF2], BANK[7]
INCLUDE "src/bag_of_bones_cap_d11b.asm"

BagOfBonesCapD11BEnd:

SECTION "Bark Thimble cap D11E", ROMX[$6C00], BANK[7]
INCLUDE "src/bark_thimble_cap_d11e.asm"

BarkThimbleCapD11EEnd:

SECTION "Channeled Gem cap D11C", ROMX[$6C0E], BANK[7]
INCLUDE "src/channeled_gem_cap_d11c.asm"

ChanneledGemCapD11CEnd:

SECTION "Corf Pearl adjust D110", ROMX[$6C1C], BANK[7]
INCLUDE "src/corf_pearl_adjust_d110.asm"

CorfPearlAdjustD110End:

SECTION "Crimson Void adjust D110", ROMX[$6C42], BANK[7]
INCLUDE "src/crimson_void_adjust_d110.asm"

CrimsonVoidAdjustD110End:

SECTION "Earth's Aura adjust D110", ROMX[$6C80], BANK[7]
INCLUDE "src/earths_aura_adjust_d110.asm"

EarthsAuraAdjustD110End:

SECTION "End Bringer adjust D110", ROMX[$6CAD], BANK[7]
INCLUDE "src/end_bringer_adjust_d110.asm"

EndBringerAdjustD110End:

SECTION "Energy Gem adjust D110", ROMX[$6D1F], BANK[7]
INCLUDE "src/energy_gem_adjust_d110.asm"

EnergyGemAdjustD110End:

SECTION "Flame Aura adjust D110", ROMX[$6D3B], BANK[7]
INCLUDE "src/flame_aura_adjust_d110.asm"

FlameAuraAdjustD110End:

SECTION "Flame Essence adjust D122", ROMX[$6D73], BANK[7]
INCLUDE "src/flame_essence_adjust_d122.asm"

FlameEssenceAdjustD122End:

SECTION "Flame Essence adjust D106", ROMX[$6D82], BANK[7]
INCLUDE "src/flame_essence_adjust_d106.asm"

FlameEssenceAdjustD106End:

SECTION "Gem of Naroom adjust D11E", ROMX[$6D8A], BANK[7]
INCLUDE "src/gem_of_naroom_adjust_d11e.asm"

GemOfNaroomAdjustD11EEnd:

SECTION "Golden Clover adjust D120", ROMX[$6D98], BANK[7]
INCLUDE "src/golden_clover_adjust_d120.asm"

GoldenCloverAdjustD120End:

SECTION "Grail of Life adjust D119", ROMX[$6DA6], BANK[7]
INCLUDE "src/grail_of_life_adjust_d119.asm"

GrailOfLifeAdjustD119End:

SECTION "Hyren's Claw adjust D11B", ROMX[$6DC2], BANK[7]
INCLUDE "src/hyrens_claw_adjust_d11b.asm"

HyrensClawAdjustD11BEnd:

SECTION "Leaf Essence adjust D122", ROMX[$6DD0], BANK[7]
INCLUDE "src/leaf_essence_adjust_d122.asm"

LeafEssenceAdjustD122End:

SECTION "Leaf Essence adjust D106", ROMX[$6DDF], BANK[7]
INCLUDE "src/leaf_essence_adjust_d106.asm"

LeafEssenceAdjustD106End:

SECTION "Lucent Belt adjust D11C", ROMX[$6DE7], BANK[7]
INCLUDE "src/lucent_belt_adjust_d11c.asm"

LucentBeltAdjustD11CEnd:

SECTION "Maelstrom adjust D11B", ROMX[$6DF5], BANK[7]
INCLUDE "src/maelstrom_adjust_d11b.asm"

MaelstromAdjustD11BEnd:

SECTION "Ombors Amulet adjust D11F", ROMX[$6E03], BANK[7]
INCLUDE "src/ombors_amulet_adjust_d11f.asm"

OmborsAmuletAdjustD11FEnd:

SECTION "Phantom Wind adjust D110", ROMX[$6E11], BANK[7]
INCLUDE "src/phantom_wind_adjust_d110.asm"

PhantomWindAdjustD110End:

SECTION "Pinch of Life adjust D110", ROMX[$6E40], BANK[7]
INCLUDE "src/pinch_of_life_adjust_d110.asm"

PinchOfLifeAdjustD110End:

SECTION "Rabbage Foot clear D120", ROMX[$6E7B], BANK[7]
INCLUDE "src/rabbage_foot_clear_d120.asm"

RabbageFootClearD120End:

SECTION "Rage Stone adjust D110", ROMX[$6E80], BANK[7]
INCLUDE "src/rage_stone_adjust_d110.asm"

RageStoneAdjustD110End:

SECTION "Shadow Veil adjust D110", ROMX[$6E9B], BANK[7]
INCLUDE "src/shadow_veil_adjust_d110.asm"

ShadowVeilAdjustD110End:

SECTION "Shield Orb adjust D110", ROMX[$6EBD], BANK[7]
INCLUDE "src/shield_orb_adjust_d110.asm"

ShieldOrbAdjustD110End:

SECTION "Sky Essence OR D122", ROMX[$6ECB], BANK[7]
INCLUDE "src/sky_essence_or_d122.asm"

SkyEssenceOrD122End:

SECTION "Sky Essence adjust D106", ROMX[$6EDA], BANK[7]
INCLUDE "src/sky_essence_adjust_d106.asm"

SkyEssenceAdjustD106End:

SECTION "Spice of Life adjust D119", ROMX[$6EE2], BANK[7]
INCLUDE "src/spice_of_life_adjust_d119.asm"

SpiceOfLifeAdjustD119End:

SECTION "Stone of Doom OR D126", ROMX[$6EFE], BANK[7]
INCLUDE "src/stone_of_doom_or_d126.asm"

StoneOfDoomOrD126End:

SECTION "Stone Essence OR D122", ROMX[$6F06], BANK[7]
INCLUDE "src/stone_essence_or_d122.asm"

StoneEssenceOrD122End:

SECTION "Stone Essence adjust D106", ROMX[$6F15], BANK[7]
INCLUDE "src/stone_essence_adjust_d106.asm"

StoneEssenceAdjustD106End:

SECTION "Stone of Life adjust D119", ROMX[$6F1D], BANK[7]
INCLUDE "src/stone_of_life_adjust_d119.asm"

StoneOfLifeAdjustD119End:

SECTION "Sword of Wind adjust D11B", ROMX[$6F40], BANK[7]
INCLUDE "src/sword_of_wind_adjust_d11b.asm"

SwordOfWindAdjustD11BEnd:

SECTION "Tide Essence OR D122", ROMX[$6F4E], BANK[7]
INCLUDE "src/tide_essence_or_d122.asm"

TideEssenceOrD122End:

SECTION "Tide Essence adjust D106", ROMX[$6F5D], BANK[7]
INCLUDE "src/tide_essence_adjust_d106.asm"

TideEssenceAdjustD106End:

SECTION "Titan Ring adjust D11B", ROMX[$6F65], BANK[7]
INCLUDE "src/titan_ring_adjust_d11b.asm"

TitanRingAdjustD11BEnd:

SECTION "Water Orb adjust D110", ROMX[$6F73], BANK[7]
INCLUDE "src/water_orb_adjust_d110.asm"

WaterOrbAdjustD110End:

SECTION "Wishbone adjust D120", ROMX[$6FC1], BANK[7]
INCLUDE "src/wishbone_adjust_d120.asm"

WishboneAdjustD120End:

SECTION "Bank 7 copy indexed name", ROMX[$6FCF], BANK[7]
INCLUDE "src/bank7_copy_indexed_name.asm"

SECTION "Floor entry scan byte", ROMX[$6FEE], BANK[7]
INCLUDE "src/bank7_floor_entry_scan.asm"

Bank7FloorEntryScanEnd:

SECTION "Blank group record at 6FF5", ROMX[$6FF5], BANK[7]
; blank_group_record_6ff5.asm: not published here (it assembles data copied from the ROM)
BlankGroupRecord6FF5:
    INCBIN "roms/magination.gbc", $1EFF5, $22

BlankGroupRecord6FF5End:

SECTION "Leaf Cut group record", ROMX[$7017], BANK[7]
; leaf_cut_group_record.asm: not published here (it assembles data copied from the ROM)
LeafCutGroupRecord:
    INCBIN "roms/magination.gbc", $1F017, $22

LeafCutGroupRecordEnd:

SECTION "Grow group record", ROMX[$7039], BANK[7]
; grow_group_record.asm: not published here (it assembles data copied from the ROM)
GrowGroupRecord:
    INCBIN "roms/magination.gbc", $1F039, $22

GrowGroupRecordEnd:

SECTION "Burrow group record", ROMX[$705B], BANK[7]
; burrow_group_record.asm: not published here (it assembles data copied from the ROM)
BurrowGroupRecord:
    INCBIN "roms/magination.gbc", $1F05B, $22

BurrowGroupRecordEnd:

SECTION "Cave In group record", ROMX[$707D], BANK[7]
; cave_in_group_record.asm: not published here (it assembles data copied from the ROM)
CaveInGroupRecord:
    INCBIN "roms/magination.gbc", $1F07D, $22

CaveInGroupRecordEnd:

SECTION "Thunderquake group record", ROMX[$709F], BANK[7]
; thunderquake_group_record.asm: not published here (it assembles data copied from the ROM)
ThunderquakeGroupRecord:
    INCBIN "roms/magination.gbc", $1F09F, $22

ThunderquakeGroupRecordEnd:

SECTION "Fireball group record", ROMX[$70C1], BANK[7]
; fireball_group_record.asm: not published here (it assembles data copied from the ROM)
FireballGroupRecord:
    INCBIN "roms/magination.gbc", $1F0C1, $22

FireballGroupRecordEnd:

SECTION "Flame Geyser group record", ROMX[$70E3], BANK[7]
; flame_geyser_group_record.asm: not published here (it assembles data copied from the ROM)
FlameGeyserGroupRecord:
    INCBIN "roms/magination.gbc", $1F0E3, $22

FlameGeyserGroupRecordEnd:

SECTION "Entangle group record", ROMX[$7105], BANK[7]
; entangle_group_record.asm: not published here (it assembles data copied from the ROM)
EntangleGroupRecord:
    INCBIN "roms/magination.gbc", $1F105, $22

EntangleGroupRecordEnd:

SECTION "Tidal Wave group record", ROMX[$7127], BANK[7]
; tidal_wave_group_record.asm: not published here (it assembles data copied from the ROM)
TidalWaveGroupRecord:
    INCBIN "roms/magination.gbc", $1F127, $22

TidalWaveGroupRecordEnd:

SECTION "Dispel X group record", ROMX[$7149], BANK[7]
; dispel_x_group_record.asm: not published here (it assembles data copied from the ROM)
DispelXGroupRecord:
    INCBIN "roms/magination.gbc", $1F149, $22

DispelXGroupRecordEnd:

SECTION "Updraft group record", ROMX[$716B], BANK[7]
; updraft_group_record.asm: not published here (it assembles data copied from the ROM)
UpdraftGroupRecord:
    INCBIN "roms/magination.gbc", $1F16B, $22

UpdraftGroupRecordEnd:

SECTION "Lightning group record", ROMX[$718D], BANK[7]
; lightning_group_record.asm: not published here (it assembles data copied from the ROM)
LightningGroupRecord:
    INCBIN "roms/magination.gbc", $1F18D, $22

LightningGroupRecordEnd:

SECTION "Condemn group record", ROMX[$71AF], BANK[7]
; condemn_group_record.asm: not published here (it assembles data copied from the ROM)
CondemnGroupRecord:
    INCBIN "roms/magination.gbc", $1F1AF, $22

CondemnGroupRecordEnd:

SECTION "Singularity group record", ROMX[$71D1], BANK[7]
; singularity_group_record.asm: not published here (it assembles data copied from the ROM)
SingularityGroupRecord:
    INCBIN "roms/magination.gbc", $1F1D1, $22

SingularityGroupRecordEnd:

SECTION "Judge group record", ROMX[$71F3], BANK[7]
; judge_group_record.asm: not published here (it assembles data copied from the ROM)
JudgeGroupRecord:
    INCBIN "roms/magination.gbc", $1F1F3, $22

JudgeGroupRecordEnd:

SECTION "Jury group record", ROMX[$7215], BANK[7]
; jury_group_record.asm: not published here (it assembles data copied from the ROM)
JuryGroupRecord:
    INCBIN "roms/magination.gbc", $1F215, $22

JuryGroupRecordEnd:

SECTION "Executioner group record", ROMX[$7237], BANK[7]
; executioner_group_record.asm: not published here (it assembles data copied from the ROM)
ExecutionerGroupRecord:
    INCBIN "roms/magination.gbc", $1F237, $22

ExecutionerGroupRecordEnd:

SECTION "Flood group record", ROMX[$7259], BANK[7]
; flood_group_record.asm: not published here (it assembles data copied from the ROM)
FloodGroupRecord:
    INCBIN "roms/magination.gbc", $1F259, $22

FloodGroupRecordEnd:

SECTION "Cunning Blow group record", ROMX[$727B], BANK[7]
; cunning_blow_group_record.asm: not published here (it assembles data copied from the ROM)
CunningBlowGroupRecord:
    INCBIN "roms/magination.gbc", $1F27B, $22

CunningBlowGroupRecordEnd:

SECTION "Stage CD93 as name count", ROMX[$729D], BANK[7]
INCLUDE "src/stage_cd93_as_name_count.asm"

SECTION "Stage divider remainder plus ten", ROMX[$72B1], BANK[7]
INCLUDE "src/stage_divider_remainder_plus_ten.asm"

SECTION "Call SetD0B4 then divider cp E6", ROMX[$72F0], BANK[7]
INCLUDE "src/call_set_d0b4_then_divider_cp_e6.asm"

SECTION "Store index-3 record byte", ROMX[$72FF], BANK[7]
INCLUDE "src/store_index3_record_byte.asm"

SECTION "Clear index-3 SRAM byte", ROMX[$7338], BANK[7]
INCLUDE "src/clear_index3_sram_byte.asm"

SECTION "Dispatch bank 7 arg", ROMX[$7350], BANK[7]
INCLUDE "src/dispatch_bank7_arg.asm"

SECTION "Bank 7 arg return", ROMX[$7367], BANK[7]
INCLUDE "src/bank7_arg_return.asm"

SECTION "Add C9FE to map word 0", ROMX[$7368], BANK[7]
INCLUDE "src/add_c9fe_to_map_word0.asm"

SECTION "Add C9FE clamp map word 1", ROMX[$73A8], BANK[7]
INCLUDE "src/add_c9fe_clamp_map_word1.asm"

AddC9FEClampMapWord1End:

SECTION "Add C9FE clamp map word 2", ROMX[$73E7], BANK[7]
INCLUDE "src/add_c9fe_clamp_map_word2.asm"

SECTION "Copy name and add scan C", ROMX[$7419], BANK[7]
INCLUDE "src/copy_name_add_scan_c.asm"

CopyNameAndAddScanCEnd:

SECTION "Dispatch bank 7 arg from index 7", ROMX[$7465], BANK[7]
INCLUDE "src/dispatch_bank7_arg_from_index7.asm"

SECTION "Sub C9FE clear or wrap map word 0", ROMX[$746B], BANK[7]
INCLUDE "src/sub_c9fe_clear_or_wrap_map_word0.asm"

SECTION "Floor scan C", ROMX[$74A2], BANK[7]
INCLUDE "src/bank7_floor_scan_c.asm"

SECTION "Floor SRAM byte", ROMX[$74A6], BANK[7]
INCLUDE "src/floor_sram_byte.asm"

FloorSRAMByteEnd:

SECTION "Floor A minus C disable SRAM", ROMX[$74C2], BANK[7]
INCLUDE "src/floor_a_minus_c_disable_sram.asm"

FloorAMinusCDisableSRAMEnd:

SECTION "Bank 7 unused at 74CC", ROMX[$74CC], BANK[7]
INCLUDE "src/bank7_unused_at_74cc.asm"

SECTION "Bank 7 unused at 750C", ROMX[$750C], BANK[7]
INCLUDE "src/bank7_unused_at_750c.asm"

SECTION "Bank 7 unused nop pad at 754C", ROMX[$754C], BANK[7]
INCLUDE "src/bank7_unused_nop_pad_754c.asm"

SECTION "Bank 7 unused tail at 78C2", ROMX[$78C2], BANK[7]
INCLUDE "src/bank7_unused_tail_78c2.asm"

SECTION "Bank 7 unused nop pad at 7902", ROMX[$7902], BANK[7]
INCLUDE "src/bank7_unused_nop_pad_7902.asm"

SECTION "Bank 7 tail nop pad", ROMX[$7CC2], BANK[7]
INCLUDE "src/bank7_tail_nop_pad.asm"

Bank7TailNopPadEnd:

SECTION "ROM Bank 008", ROMX[$4000], BANK[8]
    INCBIN "roms/magination.gbc", $20000, $0280

SECTION "ROM from $020280", ROMX[$4280], BANK[8]
; bank8_tiles_at_4280.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4280:
    INCBIN "roms/magination.gbc", $20280, $40

SECTION "ROM from $0202C0", ROMX[$42C0], BANK[8]
; bank8_tiles_at_42c0.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4280End:
Bank8TilesAt42C0:
    INCBIN "roms/magination.gbc", $202C0, $40

SECTION "ROM from $020300", ROMX[$4300], BANK[8]
; bank8_tiles_at_4300.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt42C0End:
Bank8TilesAt4300:
    INCBIN "roms/magination.gbc", $20300, $40

SECTION "ROM from $020340", ROMX[$4340], BANK[8]
; bank8_tiles_at_4340.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4300End:
Bank8TilesAt4340:
    INCBIN "roms/magination.gbc", $20340, $40

SECTION "ROM from $020380", ROMX[$4380], BANK[8]
; bank8_tiles_at_4380.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4340End:
Bank8TilesAt4380:
    INCBIN "roms/magination.gbc", $20380, $40

SECTION "ROM from $0203C0", ROMX[$43C0], BANK[8]
; bank8_tiles_at_43c0.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4380End:
Bank8TilesAt43C0:
    INCBIN "roms/magination.gbc", $203C0, $40

SECTION "ROM from $020400", ROMX[$4400], BANK[8]
; bank8_tiles_at_4400.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt43C0End:
Bank8TilesAt4400:
    INCBIN "roms/magination.gbc", $20400, $3E

SECTION "Bank 8 at 443E", ROMX[$443E], BANK[8]
    INCBIN "roms/magination.gbc", $2043E, $06D2

SECTION "ROM from $020B10", ROMX[$4B10], BANK[8]
; bank8_tiles_at_4b10.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4B10:
    INCBIN "roms/magination.gbc", $20B10, $40

SECTION "ROM from $020B50", ROMX[$4B50], BANK[8]
    INCBIN "roms/magination.gbc", $20B50, $022B

SECTION "ROM from $020D7B", ROMX[$4D7B], BANK[8]
; bank8_tiles_at_4d7b.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4D7B:
    INCBIN "roms/magination.gbc", $20D7B, $40

SECTION "ROM from $020DBB", ROMX[$4DBB], BANK[8]
; bank8_tiles_at_4dbb.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4D7BEnd:
Bank8TilesAt4DBB:
    INCBIN "roms/magination.gbc", $20DBB, $40

SECTION "ROM from $020DFB", ROMX[$4DFB], BANK[8]
; bank8_tiles_at_4dfb.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4DBBEnd:
Bank8TilesAt4DFB:
    INCBIN "roms/magination.gbc", $20DFB, $40

SECTION "ROM from $020E3B", ROMX[$4E3B], BANK[8]
; bank8_tiles_at_4e3b.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4E3B:
    INCBIN "roms/magination.gbc", $20E3B, $40

SECTION "ROM from $020E7B", ROMX[$4E7B], BANK[8]
; bank8_tiles_at_4e7b.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4E7B:
    INCBIN "roms/magination.gbc", $20E7B, $40

SECTION "ROM from $020EBB", ROMX[$4EBB], BANK[8]
; bank8_tiles_at_4ebb.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4EBB:
    INCBIN "roms/magination.gbc", $20EBB, $40

SECTION "ROM from $020EFB", ROMX[$4EFB], BANK[8]
; bank8_tiles_at_4efb.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4EFB:
    INCBIN "roms/magination.gbc", $20EFB, $40

SECTION "ROM from $020F3B", ROMX[$4F3B], BANK[8]
; bank8_tiles_at_4f3b.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4F3B:
    INCBIN "roms/magination.gbc", $20F3B, $40

SECTION "ROM from $020F7B", ROMX[$4F7B], BANK[8]
; bank8_tiles_at_4f7b.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4F7B:
    INCBIN "roms/magination.gbc", $20F7B, $40

SECTION "ROM from $020FBB", ROMX[$4FBB], BANK[8]
; bank8_tiles_at_4fbb.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4FBB:
    INCBIN "roms/magination.gbc", $20FBB, $40

SECTION "ROM from $020FFB", ROMX[$4FFB], BANK[8]
; bank8_tiles_at_4ffb.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt4FFB:
    INCBIN "roms/magination.gbc", $20FFB, $30

SECTION "ROM from $02102B", ROMX[$502B], BANK[8]
; bank8_tiles_at_502b.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt502B:
    INCBIN "roms/magination.gbc", $2102B, $2

SECTION "ROM at $02102D", ROMX[$502D], BANK[8]
    INCBIN "roms/magination.gbc", $2102D, $0510

SECTION "ROM at $02153D", ROMX[$553D], BANK[8]
; bank8_tiles_at_553d.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt553D:
    INCBIN "roms/magination.gbc", $2153D, $40

SECTION "ROM at $02157D", ROMX[$557D], BANK[8]
; bank8_tiles_at_557d.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt557D:
    INCBIN "roms/magination.gbc", $2157D, $40

SECTION "ROM at $0215BD", ROMX[$55BD], BANK[8]
; bank8_tiles_at_55bd.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt55BD:
    INCBIN "roms/magination.gbc", $215BD, $40

SECTION "ROM at $0215FD", ROMX[$55FD], BANK[8]
; bank8_tiles_at_55fd.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt55FD:
    INCBIN "roms/magination.gbc", $215FD, $40

SECTION "ROM at $02163D", ROMX[$563D], BANK[8]
; bank8_tiles_at_563d.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt563D:
    INCBIN "roms/magination.gbc", $2163D, $40

SECTION "ROM at $02167D", ROMX[$567D], BANK[8]
; bank8_tiles_at_567d.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt567D:
    INCBIN "roms/magination.gbc", $2167D, $40

SECTION "ROM at $0216BD", ROMX[$56BD], BANK[8]
; bank8_tiles_at_56bd.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt56BD:
    INCBIN "roms/magination.gbc", $216BD, $40

SECTION "ROM at $0216FD", ROMX[$56FD], BANK[8]
; bank8_tiles_at_56fd.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt56FD:
    INCBIN "roms/magination.gbc", $216FD, $40

SECTION "ROM at $02173D", ROMX[$573D], BANK[8]
; bank8_tiles_at_573d.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt573D:
    INCBIN "roms/magination.gbc", $2173D, $40

SECTION "ROM at $02177D", ROMX[$577D], BANK[8]
; bank8_tiles_at_577d.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt577D:
    INCBIN "roms/magination.gbc", $2177D, $40

SECTION "ROM at $0217BD", ROMX[$57BD], BANK[8]
; bank8_tiles_at_57bd.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt57BD:
    INCBIN "roms/magination.gbc", $217BD, $11

SECTION "ROM at $0217CE", ROMX[$57CE], BANK[8]
; bank8_tiles_at_57ce.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt57CE:
    INCBIN "roms/magination.gbc", $217CE, $40

SECTION "ROM at $02180E", ROMX[$580E], BANK[8]
; bank8_tiles_at_580e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt57CEEnd:
Bank8TilesAt580E:
    INCBIN "roms/magination.gbc", $2180E, $40

SECTION "ROM at $02184E", ROMX[$584E], BANK[8]
; bank8_tiles_at_584e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt580EEnd:
Bank8TilesAt584E:
    INCBIN "roms/magination.gbc", $2184E, $40

SECTION "ROM at $02188E", ROMX[$588E], BANK[8]
; bank8_tiles_at_588e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt584EEnd:
Bank8TilesAt588E:
    INCBIN "roms/magination.gbc", $2188E, $40

SECTION "ROM at $0218CE", ROMX[$58CE], BANK[8]
; bank8_tiles_at_58ce.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt588EEnd:
Bank8TilesAt58CE:
    INCBIN "roms/magination.gbc", $218CE, $40

SECTION "ROM at $02190E", ROMX[$590E], BANK[8]
; bank8_tiles_at_590e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt58CEEnd:
Bank8TilesAt590E:
    INCBIN "roms/magination.gbc", $2190E, $40

SECTION "ROM at $02194E", ROMX[$594E], BANK[8]
; bank8_tiles_at_594e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt590EEnd:
Bank8TilesAt594E:
    INCBIN "roms/magination.gbc", $2194E, $40

SECTION "ROM at $02198E", ROMX[$598E], BANK[8]
; bank8_tiles_at_598e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt594EEnd:
Bank8TilesAt598E:
    INCBIN "roms/magination.gbc", $2198E, $40

SECTION "ROM at $0219CE", ROMX[$59CE], BANK[8]
; bank8_tiles_at_59ce.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt598EEnd:
Bank8TilesAt59CE:
    INCBIN "roms/magination.gbc", $219CE, $40

SECTION "ROM at $021A0E", ROMX[$5A0E], BANK[8]
; bank8_tiles_at_5a0e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt59CEEnd:
Bank8TilesAt5A0E:
    INCBIN "roms/magination.gbc", $21A0E, $40

SECTION "ROM at $021A4E", ROMX[$5A4E], BANK[8]
; bank8_tiles_at_5a4e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5A0EEnd:
Bank8TilesAt5A4E:
    INCBIN "roms/magination.gbc", $21A4E, $40

SECTION "ROM at $021A8E", ROMX[$5A8E], BANK[8]
; bank8_tiles_at_5a8e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5A4EEnd:
Bank8TilesAt5A8E:
    INCBIN "roms/magination.gbc", $21A8E, $40

SECTION "ROM at $021ACE", ROMX[$5ACE], BANK[8]
; bank8_tiles_at_5ace.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5A8EEnd:
Bank8TilesAt5ACE:
    INCBIN "roms/magination.gbc", $21ACE, $40

SECTION "ROM at $021B0E", ROMX[$5B0E], BANK[8]
; bank8_tiles_at_5b0e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5ACEEnd:
Bank8TilesAt5B0E:
    INCBIN "roms/magination.gbc", $21B0E, $40

SECTION "ROM at $021B4E", ROMX[$5B4E], BANK[8]
; bank8_tiles_at_5b4e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5B0EEnd:
Bank8TilesAt5B4E:
    INCBIN "roms/magination.gbc", $21B4E, $40

SECTION "ROM at $021B8E", ROMX[$5B8E], BANK[8]
; bank8_tiles_at_5b8e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5B4EEnd:
Bank8TilesAt5B8E:
    INCBIN "roms/magination.gbc", $21B8E, $40

SECTION "ROM at $021BCE", ROMX[$5BCE], BANK[8]
; bank8_tiles_at_5bce.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5B8EEnd:
Bank8TilesAt5BCE:
    INCBIN "roms/magination.gbc", $21BCE, $40

SECTION "ROM at $021C0E", ROMX[$5C0E], BANK[8]
; bank8_tiles_at_5c0e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5C0E:
    INCBIN "roms/magination.gbc", $21C0E, $40

SECTION "ROM at $021C4E", ROMX[$5C4E], BANK[8]
; bank8_tiles_at_5c4e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5C4E:
    INCBIN "roms/magination.gbc", $21C4E, $40

SECTION "ROM at $021C8E", ROMX[$5C8E], BANK[8]
; bank8_tiles_at_5c8e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5C8E:
    INCBIN "roms/magination.gbc", $21C8E, $40

SECTION "ROM at $021CCE", ROMX[$5CCE], BANK[8]
; bank8_tiles_at_5cce.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5CCE:
    INCBIN "roms/magination.gbc", $21CCE, $40

SECTION "ROM at $021D0E", ROMX[$5D0E], BANK[8]
; bank8_tiles_at_5d0e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5D0E:
    INCBIN "roms/magination.gbc", $21D0E, $40

SECTION "ROM at $021D4E", ROMX[$5D4E], BANK[8]
; bank8_tiles_at_5d4e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5D4E:
    INCBIN "roms/magination.gbc", $21D4E, $40

SECTION "ROM at $021D8E", ROMX[$5D8E], BANK[8]
; bank8_tiles_at_5d8e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5D8E:
    INCBIN "roms/magination.gbc", $21D8E, $40

SECTION "ROM at $021DCE", ROMX[$5DCE], BANK[8]
; bank8_tiles_at_5dce.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5DCE:
    INCBIN "roms/magination.gbc", $21DCE, $40

SECTION "ROM at $021E0E", ROMX[$5E0E], BANK[8]
; bank8_tiles_at_5e0e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5E0E:
    INCBIN "roms/magination.gbc", $21E0E, $40

SECTION "ROM at $021E4E", ROMX[$5E4E], BANK[8]
; bank8_tiles_at_5e4e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5E4E:
    INCBIN "roms/magination.gbc", $21E4E, $40

SECTION "ROM at $021E8E", ROMX[$5E8E], BANK[8]
; bank8_tiles_at_5e8e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5E8E:
    INCBIN "roms/magination.gbc", $21E8E, $40

SECTION "ROM at $021ECE", ROMX[$5ECE], BANK[8]
; bank8_tiles_at_5ece.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5ECE:
    INCBIN "roms/magination.gbc", $21ECE, $40

SECTION "ROM at $021F0E", ROMX[$5F0E], BANK[8]
; bank8_tiles_at_5f0e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5F0E:
    INCBIN "roms/magination.gbc", $21F0E, $40

SECTION "ROM at $021F4E", ROMX[$5F4E], BANK[8]
; bank8_tiles_at_5f4e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5F4E:
    INCBIN "roms/magination.gbc", $21F4E, $40

SECTION "ROM at $021F8E", ROMX[$5F8E], BANK[8]
; bank8_tiles_at_5f8e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5F8E:
    INCBIN "roms/magination.gbc", $21F8E, $40

SECTION "ROM at $021FCE", ROMX[$5FCE], BANK[8]
; bank8_tiles_at_5fce.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt5FCE:
    INCBIN "roms/magination.gbc", $21FCE, $40

SECTION "ROM at $02200E", ROMX[$600E], BANK[8]
; bank8_tiles_at_600e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt600E:
    INCBIN "roms/magination.gbc", $2200E, $40

SECTION "ROM at $02204E", ROMX[$604E], BANK[8]
; bank8_tiles_at_604e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt604E:
    INCBIN "roms/magination.gbc", $2204E, $40

SECTION "ROM at $02208E", ROMX[$608E], BANK[8]
; bank8_tiles_at_608e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt608E:
    INCBIN "roms/magination.gbc", $2208E, $40

SECTION "ROM at $0220CE", ROMX[$60CE], BANK[8]
; bank8_tiles_at_60ce.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt60CE:
    INCBIN "roms/magination.gbc", $220CE, $32

SECTION "ROM from $022100", ROMX[$6100], BANK[8]
    INCBIN "roms/magination.gbc", $22100, $007F

SECTION "ROM at $02217F", ROMX[$617F], BANK[8]
; bank8_tiles_at_617f.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt617F:
    INCBIN "roms/magination.gbc", $2217F, $11

SECTION "ROM at $022190", ROMX[$6190], BANK[8]
; bank8_tiles_at_6190.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6190:
    INCBIN "roms/magination.gbc", $22190, $40

SECTION "ROM at $0221D0", ROMX[$61D0], BANK[8]
; bank8_tiles_at_61d0.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt61D0:
    INCBIN "roms/magination.gbc", $221D0, $40

SECTION "ROM at $022210", ROMX[$6210], BANK[8]
; bank8_tiles_at_6210.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6210:
    INCBIN "roms/magination.gbc", $22210, $40

SECTION "ROM at $022250", ROMX[$6250], BANK[8]
; bank8_tiles_at_6250.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6250:
    INCBIN "roms/magination.gbc", $22250, $3F

SECTION "ROM at $02228F", ROMX[$628F], BANK[8]
    INCBIN "roms/magination.gbc", $2228F, $0034

SECTION "ROM at $0222C3", ROMX[$62C3], BANK[8]
; bank8_tiles_at_62c3.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt62C3:
    INCBIN "roms/magination.gbc", $222C3, $40

SECTION "ROM at $022303", ROMX[$6303], BANK[8]
; bank8_tiles_at_6303.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6303:
    INCBIN "roms/magination.gbc", $22303, $7

SECTION "ROM at $02230A", ROMX[$630A], BANK[8]
    INCBIN "roms/magination.gbc", $2230A, $01F6

SECTION "ROM at $022500", ROMX[$6500], BANK[8]
; bank8_tiles_at_6500.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6500:
    INCBIN "roms/magination.gbc", $22500, $40

SECTION "ROM at $022540", ROMX[$6540], BANK[8]
    INCBIN "roms/magination.gbc", $22540, $008E

SECTION "ROM at $0225CE", ROMX[$65CE], BANK[8]
; bank8_tiles_at_65ce.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt65CE:
    INCBIN "roms/magination.gbc", $225CE, $40

SECTION "ROM at $02260E", ROMX[$660E], BANK[8]
; bank8_tiles_at_660e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt65CEEnd:
Bank8TilesAt660E:
    INCBIN "roms/magination.gbc", $2260E, $40

SECTION "ROM at $02264E", ROMX[$664E], BANK[8]
; bank8_tiles_at_664e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt660EEnd:
Bank8TilesAt664E:
    INCBIN "roms/magination.gbc", $2264E, $40

SECTION "ROM at $02268E", ROMX[$668E], BANK[8]
; bank8_tiles_at_668e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt664EEnd:
Bank8TilesAt668E:
    INCBIN "roms/magination.gbc", $2268E, $40

SECTION "ROM at $0226CE", ROMX[$66CE], BANK[8]
; bank8_tiles_at_66ce.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt668EEnd:
Bank8TilesAt66CE:
    INCBIN "roms/magination.gbc", $226CE, $40

SECTION "ROM at $02270E", ROMX[$670E], BANK[8]
; bank8_tiles_at_670e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt66CEEnd:
Bank8TilesAt670E:
    INCBIN "roms/magination.gbc", $2270E, $40

SECTION "ROM at $02274E", ROMX[$674E], BANK[8]
; bank8_tiles_at_674e.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt670EEnd:
Bank8TilesAt674E:
    INCBIN "roms/magination.gbc", $2274E, $3C

SECTION "ROM at $02278A", ROMX[$678A], BANK[8]
    INCBIN "roms/magination.gbc", $2278A, $03AA

SECTION "ROM at $022B34", ROMX[$6B34], BANK[8]
; bank8_tiles_at_6b34.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6B34:
    INCBIN "roms/magination.gbc", $22B34, $40

SECTION "ROM from $022B74", ROMX[$6B74], BANK[8]
; bank8_tiles_at_6b74.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6B74:
    INCBIN "roms/magination.gbc", $22B74, $28

SECTION "ROM at $022B9C", ROMX[$6B9C], BANK[8]
; bank8_tiles_at_6b9c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6B9C:
    INCBIN "roms/magination.gbc", $22B9C, $40

SECTION "ROM from $022BDC", ROMX[$6BDC], BANK[8]
; bank8_tiles_at_6bdc.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6B9CEnd:
Bank8TilesAt6BDC:
    INCBIN "roms/magination.gbc", $22BDC, $40

SECTION "ROM at $022C1C", ROMX[$6C1C], BANK[8]
; bank8_tiles_at_6c1c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6BDCEnd:
Bank8TilesAt6C1C:
    INCBIN "roms/magination.gbc", $22C1C, $40

SECTION "ROM at $022C5C", ROMX[$6C5C], BANK[8]
; bank8_tiles_at_6c5c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6C1CEnd:
Bank8TilesAt6C5C:
    INCBIN "roms/magination.gbc", $22C5C, $40

SECTION "ROM at $022C9C", ROMX[$6C9C], BANK[8]
; bank8_tiles_at_6c9c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6C5CEnd:
Bank8TilesAt6C9C:
    INCBIN "roms/magination.gbc", $22C9C, $40

SECTION "ROM from $022CDC", ROMX[$6CDC], BANK[8]
; bank8_tiles_at_6cdc.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6C9CEnd:
Bank8TilesAt6CDC:
    INCBIN "roms/magination.gbc", $22CDC, $40

SECTION "ROM from $022D1C", ROMX[$6D1C], BANK[8]
; bank8_tiles_at_6d1c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6CDCEnd:
Bank8TilesAt6D1C:
    INCBIN "roms/magination.gbc", $22D1C, $40

SECTION "ROM from $022D5C", ROMX[$6D5C], BANK[8]
; bank8_tiles_at_6d5c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6D1CEnd:
Bank8TilesAt6D5C:
    INCBIN "roms/magination.gbc", $22D5C, $40

SECTION "ROM from $022D9C", ROMX[$6D9C], BANK[8]
; bank8_tiles_at_6d9c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6D5CEnd:
Bank8TilesAt6D9C:
    INCBIN "roms/magination.gbc", $22D9C, $40

SECTION "ROM from $022DDC", ROMX[$6DDC], BANK[8]
; bank8_tiles_at_6ddc.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6D9CEnd:
Bank8TilesAt6DDC:
    INCBIN "roms/magination.gbc", $22DDC, $40

SECTION "ROM from $022E1C", ROMX[$6E1C], BANK[8]
; bank8_tiles_at_6e1c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6DDCEnd:
Bank8TilesAt6E1C:
    INCBIN "roms/magination.gbc", $22E1C, $40

SECTION "ROM from $022E5C", ROMX[$6E5C], BANK[8]
; bank8_tiles_at_6e5c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6E1CEnd:
Bank8TilesAt6E5C:
    INCBIN "roms/magination.gbc", $22E5C, $40

SECTION "ROM from $022E9C", ROMX[$6E9C], BANK[8]
; bank8_tiles_at_6e9c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6E5CEnd:
Bank8TilesAt6E9C:
    INCBIN "roms/magination.gbc", $22E9C, $40

SECTION "ROM from $022EDC", ROMX[$6EDC], BANK[8]
; bank8_tiles_at_6edc.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6E9CEnd:
Bank8TilesAt6EDC:
    INCBIN "roms/magination.gbc", $22EDC, $40

SECTION "ROM from $022F1C", ROMX[$6F1C], BANK[8]
; bank8_tiles_at_6f1c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6EDCEnd:
Bank8TilesAt6F1C:
    INCBIN "roms/magination.gbc", $22F1C, $40

SECTION "ROM from $022F5C", ROMX[$6F5C], BANK[8]
; bank8_tiles_at_6f5c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6F1CEnd:
Bank8TilesAt6F5C:
    INCBIN "roms/magination.gbc", $22F5C, $9

SECTION "ROM at $022F65", ROMX[$6F65], BANK[8]
; bank8_tiles_at_6f65.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt6F5CEnd:
Bank8TilesAt6F65:
    INCBIN "roms/magination.gbc", $22F65, $37

SECTION "ROM at $022F9C", ROMX[$6F9C], BANK[8]
    INCBIN "roms/magination.gbc", $22F9C, $00BF

SECTION "ROM from $02305B", ROMX[$705B], BANK[8]
; bank8_tiles_at_705b.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt705B:
    INCBIN "roms/magination.gbc", $2305B, $39

SECTION "ROM at $023094", ROMX[$7094], BANK[8]
    INCBIN "roms/magination.gbc", $23094, $00A8

SECTION "ROM from $02313C", ROMX[$713C], BANK[8]
; bank8_tiles_at_713c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt713C:
    INCBIN "roms/magination.gbc", $2313C, $40

SECTION "ROM from $02317C", ROMX[$717C], BANK[8]
; bank8_tiles_at_717c.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt713CEnd:
Bank8TilesAt717C:
    INCBIN "roms/magination.gbc", $2317C, $40

SECTION "ROM from $0231BC", ROMX[$71BC], BANK[8]
; bank8_tiles_at_71bc.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt717CEnd:
Bank8TilesAt71BC:
    INCBIN "roms/magination.gbc", $231BC, $40

SECTION "ROM from $0231FC", ROMX[$71FC], BANK[8]
; bank8_tiles_at_71fc.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt71BCEnd:
Bank8TilesAt71FC:
    INCBIN "roms/magination.gbc", $231FC, $25

SECTION "ROM at $023221", ROMX[$7221], BANK[8]
; bank8_tiles_at_7221.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt71FCEnd:
Bank8TilesAt7221:
    INCBIN "roms/magination.gbc", $23221, $40

SECTION "ROM from $023261", ROMX[$7261], BANK[8]
; bank8_tiles_at_7261.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7221End:
Bank8TilesAt7261:
    INCBIN "roms/magination.gbc", $23261, $40

SECTION "ROM from $0232A1", ROMX[$72A1], BANK[8]
; bank8_tiles_at_72a1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7261End:
Bank8TilesAt72A1:
    INCBIN "roms/magination.gbc", $232A1, $40

SECTION "ROM from $0232E1", ROMX[$72E1], BANK[8]
; bank8_tiles_at_72e1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt72A1End:
Bank8TilesAt72E1:
    INCBIN "roms/magination.gbc", $232E1, $40

SECTION "ROM from $023321", ROMX[$7321], BANK[8]
; bank8_tiles_at_7321.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt72E1End:
Bank8TilesAt7321:
    INCBIN "roms/magination.gbc", $23321, $40

SECTION "ROM from $023361", ROMX[$7361], BANK[8]
; bank8_tiles_at_7361.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7321End:
Bank8TilesAt7361:
    INCBIN "roms/magination.gbc", $23361, $40

SECTION "ROM from $0233A1", ROMX[$73A1], BANK[8]
; bank8_tiles_at_73a1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7361End:
Bank8TilesAt73A1:
    INCBIN "roms/magination.gbc", $233A1, $40

SECTION "ROM from $0233E1", ROMX[$73E1], BANK[8]
; bank8_tiles_at_73e1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt73A1End:
Bank8TilesAt73E1:
    INCBIN "roms/magination.gbc", $233E1, $40

SECTION "ROM from $023421", ROMX[$7421], BANK[8]
; bank8_tiles_at_7421.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt73E1End:
Bank8TilesAt7421:
    INCBIN "roms/magination.gbc", $23421, $40

SECTION "ROM from $023461", ROMX[$7461], BANK[8]
; bank8_tiles_at_7461.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7421End:
Bank8TilesAt7461:
    INCBIN "roms/magination.gbc", $23461, $40

SECTION "ROM from $0234A1", ROMX[$74A1], BANK[8]
; bank8_tiles_at_74a1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7461End:
Bank8TilesAt74A1:
    INCBIN "roms/magination.gbc", $234A1, $40

SECTION "ROM from $0234E1", ROMX[$74E1], BANK[8]
; bank8_tiles_at_74e1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt74A1End:
Bank8TilesAt74E1:
    INCBIN "roms/magination.gbc", $234E1, $40

SECTION "ROM from $023521", ROMX[$7521], BANK[8]
; bank8_tiles_at_7521.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt74E1End:
Bank8TilesAt7521:
    INCBIN "roms/magination.gbc", $23521, $40

SECTION "ROM from $023561", ROMX[$7561], BANK[8]
; bank8_tiles_at_7561.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7521End:
Bank8TilesAt7561:
    INCBIN "roms/magination.gbc", $23561, $40

SECTION "ROM from $0235A1", ROMX[$75A1], BANK[8]
; bank8_tiles_at_75a1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7561End:
Bank8TilesAt75A1:
    INCBIN "roms/magination.gbc", $235A1, $40

SECTION "ROM from $0235E1", ROMX[$75E1], BANK[8]
; bank8_tiles_at_75e1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt75A1End:
Bank8TilesAt75E1:
    INCBIN "roms/magination.gbc", $235E1, $40

SECTION "ROM from $023621", ROMX[$7621], BANK[8]
; bank8_tiles_at_7621.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt75E1End:
Bank8TilesAt7621:
    INCBIN "roms/magination.gbc", $23621, $40

SECTION "ROM at $023661", ROMX[$7661], BANK[8]
; bank8_tiles_at_7661.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7621End:
Bank8TilesAt7661:
    INCBIN "roms/magination.gbc", $23661, $40

SECTION "ROM at $0236A1", ROMX[$76A1], BANK[8]
; bank8_tiles_at_76a1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7661End:
Bank8TilesAt76A1:
    INCBIN "roms/magination.gbc", $236A1, $40

SECTION "ROM from $0236E1", ROMX[$76E1], BANK[8]
; bank8_tiles_at_76e1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt76A1End:
Bank8TilesAt76E1:
    INCBIN "roms/magination.gbc", $236E1, $40

SECTION "ROM from $023721", ROMX[$7721], BANK[8]
; bank8_tiles_at_7721.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt76E1End:
Bank8TilesAt7721:
    INCBIN "roms/magination.gbc", $23721, $40

SECTION "ROM from $023761", ROMX[$7761], BANK[8]
; bank8_tiles_at_7761.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7721End:
Bank8TilesAt7761:
    INCBIN "roms/magination.gbc", $23761, $40

SECTION "ROM from $0237A1", ROMX[$77A1], BANK[8]
; bank8_tiles_at_77a1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7761End:
Bank8TilesAt77A1:
    INCBIN "roms/magination.gbc", $237A1, $40

SECTION "ROM from $0237E1", ROMX[$77E1], BANK[8]
; bank8_tiles_at_77e1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt77A1End:
Bank8TilesAt77E1:
    INCBIN "roms/magination.gbc", $237E1, $40

SECTION "ROM from $023821", ROMX[$7821], BANK[8]
; bank8_tiles_at_7821.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt77E1End:
Bank8TilesAt7821:
    INCBIN "roms/magination.gbc", $23821, $40

SECTION "ROM from $023861", ROMX[$7861], BANK[8]
; bank8_tiles_at_7861.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7821End:
Bank8TilesAt7861:
    INCBIN "roms/magination.gbc", $23861, $40

SECTION "ROM from $0238A1", ROMX[$78A1], BANK[8]
; bank8_tiles_at_78a1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7861End:
Bank8TilesAt78A1:
    INCBIN "roms/magination.gbc", $238A1, $40

SECTION "ROM from $0238E1", ROMX[$78E1], BANK[8]
; bank8_tiles_at_78e1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt78A1End:
Bank8TilesAt78E1:
    INCBIN "roms/magination.gbc", $238E1, $40

SECTION "ROM from $023921", ROMX[$7921], BANK[8]
; bank8_tiles_at_7921.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt78E1End:
Bank8TilesAt7921:
    INCBIN "roms/magination.gbc", $23921, $40

SECTION "ROM from $023961", ROMX[$7961], BANK[8]
; bank8_tiles_at_7961.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7921End:
Bank8TilesAt7961:
    INCBIN "roms/magination.gbc", $23961, $40

SECTION "ROM from $0239A1", ROMX[$79A1], BANK[8]
; bank8_tiles_at_79a1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7961End:
Bank8TilesAt79A1:
    INCBIN "roms/magination.gbc", $239A1, $40

SECTION "ROM from $0239E1", ROMX[$79E1], BANK[8]
; bank8_tiles_at_79e1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt79A1End:
Bank8TilesAt79E1:
    INCBIN "roms/magination.gbc", $239E1, $40

SECTION "ROM from $023A21", ROMX[$7A21], BANK[8]
; bank8_tiles_at_7a21.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt79E1End:
Bank8TilesAt7A21:
    INCBIN "roms/magination.gbc", $23A21, $40

SECTION "ROM from $023A61", ROMX[$7A61], BANK[8]
; bank8_tiles_at_7a61.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7A21End:
Bank8TilesAt7A61:
    INCBIN "roms/magination.gbc", $23A61, $40

SECTION "ROM from $023AA1", ROMX[$7AA1], BANK[8]
; bank8_tiles_at_7aa1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7A61End:
Bank8TilesAt7AA1:
    INCBIN "roms/magination.gbc", $23AA1, $40

SECTION "ROM from $023AE1", ROMX[$7AE1], BANK[8]
; bank8_tiles_at_7ae1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7AA1End:
Bank8TilesAt7AE1:
    INCBIN "roms/magination.gbc", $23AE1, $40

SECTION "ROM from $023B21", ROMX[$7B21], BANK[8]
; bank8_tiles_at_7b21.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7AE1End:
Bank8TilesAt7B21:
    INCBIN "roms/magination.gbc", $23B21, $40

SECTION "ROM from $023B61", ROMX[$7B61], BANK[8]
; bank8_tiles_at_7b61.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7B21End:
Bank8TilesAt7B61:
    INCBIN "roms/magination.gbc", $23B61, $40

SECTION "ROM from $023BA1", ROMX[$7BA1], BANK[8]
; bank8_tiles_at_7ba1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7B61End:
Bank8TilesAt7BA1:
    INCBIN "roms/magination.gbc", $23BA1, $40

SECTION "ROM from $023BE1", ROMX[$7BE1], BANK[8]
; bank8_tiles_at_7be1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7BA1End:
Bank8TilesAt7BE1:
    INCBIN "roms/magination.gbc", $23BE1, $40

SECTION "ROM from $023C21", ROMX[$7C21], BANK[8]
; bank8_tiles_at_7c21.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7BE1End:
Bank8TilesAt7C21:
    INCBIN "roms/magination.gbc", $23C21, $40

SECTION "ROM from $023C61", ROMX[$7C61], BANK[8]
; bank8_tiles_at_7c61.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7C21End:
Bank8TilesAt7C61:
    INCBIN "roms/magination.gbc", $23C61, $40

SECTION "ROM from $023CA1", ROMX[$7CA1], BANK[8]
; bank8_tiles_at_7ca1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7C61End:
Bank8TilesAt7CA1:
    INCBIN "roms/magination.gbc", $23CA1, $40

SECTION "ROM from $023CE1", ROMX[$7CE1], BANK[8]
; bank8_tiles_at_7ce1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7CA1End:
Bank8TilesAt7CE1:
    INCBIN "roms/magination.gbc", $23CE1, $40

SECTION "ROM from $023D21", ROMX[$7D21], BANK[8]
; bank8_tiles_at_7d21.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7CE1End:
Bank8TilesAt7D21:
    INCBIN "roms/magination.gbc", $23D21, $40

SECTION "ROM from $023D61", ROMX[$7D61], BANK[8]
; bank8_tiles_at_7d61.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7D21End:
Bank8TilesAt7D61:
    INCBIN "roms/magination.gbc", $23D61, $40

SECTION "ROM from $023DA1", ROMX[$7DA1], BANK[8]
; bank8_tiles_at_7da1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7D61End:
Bank8TilesAt7DA1:
    INCBIN "roms/magination.gbc", $23DA1, $40

SECTION "ROM from $023DE1", ROMX[$7DE1], BANK[8]
; bank8_tiles_at_7de1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7DA1End:
Bank8TilesAt7DE1:
    INCBIN "roms/magination.gbc", $23DE1, $40

SECTION "ROM from $023E21", ROMX[$7E21], BANK[8]
; bank8_tiles_at_7e21.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7DE1End:
Bank8TilesAt7E21:
    INCBIN "roms/magination.gbc", $23E21, $40

SECTION "ROM from $023E61", ROMX[$7E61], BANK[8]
; bank8_tiles_at_7e61.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7E21End:
Bank8TilesAt7E61:
    INCBIN "roms/magination.gbc", $23E61, $40

SECTION "ROM from $023EA1", ROMX[$7EA1], BANK[8]
; bank8_tiles_at_7ea1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7EA1:
    INCBIN "roms/magination.gbc", $23EA1, $40

SECTION "ROM from $023EE1", ROMX[$7EE1], BANK[8]
; bank8_tiles_at_7ee1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7EE1:
    INCBIN "roms/magination.gbc", $23EE1, $40

SECTION "ROM from $023F21", ROMX[$7F21], BANK[8]
; bank8_tiles_at_7f21.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7F21:
    INCBIN "roms/magination.gbc", $23F21, $40

SECTION "ROM from $023F61", ROMX[$7F61], BANK[8]
; bank8_tiles_at_7f61.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7F61:
    INCBIN "roms/magination.gbc", $23F61, $40

SECTION "ROM from $023FA1", ROMX[$7FA1], BANK[8]
; bank8_tiles_at_7fa1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7FA1:
    INCBIN "roms/magination.gbc", $23FA1, $40

SECTION "ROM from $023FE1", ROMX[$7FE1], BANK[8]
; bank8_tiles_at_7fe1.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7FE1:
    INCBIN "roms/magination.gbc", $23FE1, $1F

SECTION "ROM Bank 009", ROMX[$4000], BANK[9]
; bank9_tiles_at_4000.asm: not published here (it assembles data copied from the ROM)
Bank8TilesAt7FE1End:
Bank9TilesAt4000:
    INCBIN "roms/magination.gbc", $24000, $40

SECTION "ROM from $024040", ROMX[$4040], BANK[9]
; bank9_tiles_at_4040.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4000End:
Bank9TilesAt4040:
    INCBIN "roms/magination.gbc", $24040, $40

SECTION "ROM from $024080", ROMX[$4080], BANK[9]
; bank9_tiles_at_4080.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4040End:
Bank9TilesAt4080:
    INCBIN "roms/magination.gbc", $24080, $40

SECTION "ROM from $0240C0", ROMX[$40C0], BANK[9]
; bank9_tiles_at_40c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4080End:
Bank9TilesAt40C0:
    INCBIN "roms/magination.gbc", $240C0, $40

SECTION "ROM from $024100", ROMX[$4100], BANK[9]
; bank9_tiles_at_4100.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt40C0End:
Bank9TilesAt4100:
    INCBIN "roms/magination.gbc", $24100, $40

SECTION "ROM from $024140", ROMX[$4140], BANK[9]
; bank9_tiles_at_4140.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4100End:
Bank9TilesAt4140:
    INCBIN "roms/magination.gbc", $24140, $40

SECTION "ROM from $024180", ROMX[$4180], BANK[9]
; bank9_tiles_at_4180.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4140End:
Bank9TilesAt4180:
    INCBIN "roms/magination.gbc", $24180, $40

SECTION "ROM from $0241C0", ROMX[$41C0], BANK[9]
; bank9_tiles_at_41c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4180End:
Bank9TilesAt41C0:
    INCBIN "roms/magination.gbc", $241C0, $40

SECTION "ROM from $024200", ROMX[$4200], BANK[9]
; bank9_tiles_at_4200.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt41C0End:
Bank9TilesAt4200:
    INCBIN "roms/magination.gbc", $24200, $40

SECTION "ROM from $024240", ROMX[$4240], BANK[9]
; bank9_tiles_at_4240.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4200End:
Bank9TilesAt4240:
    INCBIN "roms/magination.gbc", $24240, $40

SECTION "ROM from $024280", ROMX[$4280], BANK[9]
; bank9_tiles_at_4280.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4240End:
Bank9TilesAt4280:
    INCBIN "roms/magination.gbc", $24280, $40

SECTION "ROM from $0242C0", ROMX[$42C0], BANK[9]
; bank9_tiles_at_42c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4280End:
Bank9TilesAt42C0:
    INCBIN "roms/magination.gbc", $242C0, $40

SECTION "ROM from $024300", ROMX[$4300], BANK[9]
; bank9_tiles_at_4300.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt42C0End:
Bank9TilesAt4300:
    INCBIN "roms/magination.gbc", $24300, $40

SECTION "ROM from $024340", ROMX[$4340], BANK[9]
; bank9_tiles_at_4340.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4300End:
Bank9TilesAt4340:
    INCBIN "roms/magination.gbc", $24340, $40

SECTION "ROM from $024380", ROMX[$4380], BANK[9]
; bank9_tiles_at_4380.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4340End:
Bank9TilesAt4380:
    INCBIN "roms/magination.gbc", $24380, $40

SECTION "ROM from $0243C0", ROMX[$43C0], BANK[9]
; bank9_tiles_at_43c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4380End:
Bank9TilesAt43C0:
    INCBIN "roms/magination.gbc", $243C0, $40

SECTION "ROM from $024400", ROMX[$4400], BANK[9]
; bank9_tiles_at_4400.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt43C0End:
Bank9TilesAt4400:
    INCBIN "roms/magination.gbc", $24400, $40

SECTION "ROM from $024440", ROMX[$4440], BANK[9]
; bank9_tiles_at_4440.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4400End:
Bank9TilesAt4440:
    INCBIN "roms/magination.gbc", $24440, $40

SECTION "ROM from $024480", ROMX[$4480], BANK[9]
; bank9_tiles_at_4480.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4440End:
Bank9TilesAt4480:
    INCBIN "roms/magination.gbc", $24480, $40

SECTION "ROM from $0244C0", ROMX[$44C0], BANK[9]
; bank9_tiles_at_44c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4480End:
Bank9TilesAt44C0:
    INCBIN "roms/magination.gbc", $244C0, $40

SECTION "ROM from $024500", ROMX[$4500], BANK[9]
; bank9_tiles_at_4500.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt44C0End:
Bank9TilesAt4500:
    INCBIN "roms/magination.gbc", $24500, $40

SECTION "ROM from $024540", ROMX[$4540], BANK[9]
; bank9_tiles_at_4540.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4500End:
Bank9TilesAt4540:
    INCBIN "roms/magination.gbc", $24540, $40

SECTION "ROM from $024580", ROMX[$4580], BANK[9]
; bank9_tiles_at_4580.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4540End:
Bank9TilesAt4580:
    INCBIN "roms/magination.gbc", $24580, $40

SECTION "ROM from $0245C0", ROMX[$45C0], BANK[9]
; bank9_tiles_at_45c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4580End:
Bank9TilesAt45C0:
    INCBIN "roms/magination.gbc", $245C0, $40

SECTION "ROM from $024600", ROMX[$4600], BANK[9]
; bank9_tiles_at_4600.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt45C0End:
Bank9TilesAt4600:
    INCBIN "roms/magination.gbc", $24600, $40

SECTION "ROM from $024640", ROMX[$4640], BANK[9]
; bank9_tiles_at_4640.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4600End:
Bank9TilesAt4640:
    INCBIN "roms/magination.gbc", $24640, $40

SECTION "ROM from $024680", ROMX[$4680], BANK[9]
; bank9_tiles_at_4680.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4640End:
Bank9TilesAt4680:
    INCBIN "roms/magination.gbc", $24680, $40

SECTION "ROM from $0246C0", ROMX[$46C0], BANK[9]
; bank9_tiles_at_46c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4680End:
Bank9TilesAt46C0:
    INCBIN "roms/magination.gbc", $246C0, $40

SECTION "ROM from $024700", ROMX[$4700], BANK[9]
; bank9_tiles_at_4700.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt46C0End:
Bank9TilesAt4700:
    INCBIN "roms/magination.gbc", $24700, $40

SECTION "ROM from $024740", ROMX[$4740], BANK[9]
; bank9_tiles_at_4740.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4700End:
Bank9TilesAt4740:
    INCBIN "roms/magination.gbc", $24740, $40

SECTION "ROM from $024780", ROMX[$4780], BANK[9]
; bank9_tiles_at_4780.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4740End:
Bank9TilesAt4780:
    INCBIN "roms/magination.gbc", $24780, $40

SECTION "ROM from $0247C0", ROMX[$47C0], BANK[9]
; bank9_tiles_at_47c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4780End:
Bank9TilesAt47C0:
    INCBIN "roms/magination.gbc", $247C0, $40

SECTION "ROM from $024800", ROMX[$4800], BANK[9]
; bank9_tiles_at_4800.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt47C0End:
Bank9TilesAt4800:
    INCBIN "roms/magination.gbc", $24800, $40

SECTION "ROM from $024840", ROMX[$4840], BANK[9]
; bank9_tiles_at_4840.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4800End:
Bank9TilesAt4840:
    INCBIN "roms/magination.gbc", $24840, $40

SECTION "ROM from $024880", ROMX[$4880], BANK[9]
; bank9_tiles_at_4880.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4840End:
Bank9TilesAt4880:
    INCBIN "roms/magination.gbc", $24880, $40

SECTION "ROM from $0248C0", ROMX[$48C0], BANK[9]
; bank9_tiles_at_48c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4880End:
Bank9TilesAt48C0:
    INCBIN "roms/magination.gbc", $248C0, $40

SECTION "ROM from $024900", ROMX[$4900], BANK[9]
; bank9_tiles_at_4900.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt48C0End:
Bank9TilesAt4900:
    INCBIN "roms/magination.gbc", $24900, $40

SECTION "ROM from $024940", ROMX[$4940], BANK[9]
; bank9_tiles_at_4940.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4900End:
Bank9TilesAt4940:
    INCBIN "roms/magination.gbc", $24940, $40

SECTION "ROM from $024980", ROMX[$4980], BANK[9]
; bank9_tiles_at_4980.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4940End:
Bank9TilesAt4980:
    INCBIN "roms/magination.gbc", $24980, $40

SECTION "ROM from $0249C0", ROMX[$49C0], BANK[9]
; bank9_tiles_at_49c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4980End:
Bank9TilesAt49C0:
    INCBIN "roms/magination.gbc", $249C0, $40

SECTION "ROM from $024A00", ROMX[$4A00], BANK[9]
; bank9_tiles_at_4a00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt49C0End:
Bank9TilesAt4A00:
    INCBIN "roms/magination.gbc", $24A00, $40

SECTION "ROM from $024A40", ROMX[$4A40], BANK[9]
; bank9_tiles_at_4a40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4A00End:
Bank9TilesAt4A40:
    INCBIN "roms/magination.gbc", $24A40, $40

SECTION "ROM from $024A80", ROMX[$4A80], BANK[9]
; bank9_tiles_at_4a80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4A40End:
Bank9TilesAt4A80:
    INCBIN "roms/magination.gbc", $24A80, $40

SECTION "ROM from $024AC0", ROMX[$4AC0], BANK[9]
; bank9_tiles_at_4ac0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4A80End:
Bank9TilesAt4AC0:
    INCBIN "roms/magination.gbc", $24AC0, $40

SECTION "ROM from $024B00", ROMX[$4B00], BANK[9]
; bank9_tiles_at_4b00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4AC0End:
Bank9TilesAt4B00:
    INCBIN "roms/magination.gbc", $24B00, $40

SECTION "ROM from $024B40", ROMX[$4B40], BANK[9]
; bank9_tiles_at_4b40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4B00End:
Bank9TilesAt4B40:
    INCBIN "roms/magination.gbc", $24B40, $40

SECTION "ROM from $024B80", ROMX[$4B80], BANK[9]
; bank9_tiles_at_4b80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4B40End:
Bank9TilesAt4B80:
    INCBIN "roms/magination.gbc", $24B80, $40

SECTION "ROM from $024BC0", ROMX[$4BC0], BANK[9]
; bank9_tiles_at_4bc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4B80End:
Bank9TilesAt4BC0:
    INCBIN "roms/magination.gbc", $24BC0, $40

SECTION "ROM from $024C00", ROMX[$4C00], BANK[9]
; bank9_tiles_at_4c00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4BC0End:
Bank9TilesAt4C00:
    INCBIN "roms/magination.gbc", $24C00, $40

SECTION "ROM from $024C40", ROMX[$4C40], BANK[9]
; bank9_tiles_at_4c40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4C00End:
Bank9TilesAt4C40:
    INCBIN "roms/magination.gbc", $24C40, $40

SECTION "ROM from $024C80", ROMX[$4C80], BANK[9]
; bank9_tiles_at_4c80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4C40End:
Bank9TilesAt4C80:
    INCBIN "roms/magination.gbc", $24C80, $40

SECTION "ROM from $024CC0", ROMX[$4CC0], BANK[9]
; bank9_tiles_at_4cc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4C80End:
Bank9TilesAt4CC0:
    INCBIN "roms/magination.gbc", $24CC0, $40

SECTION "ROM from $024D00", ROMX[$4D00], BANK[9]
; bank9_tiles_at_4d00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4CC0End:
Bank9TilesAt4D00:
    INCBIN "roms/magination.gbc", $24D00, $40

SECTION "ROM from $024D40", ROMX[$4D40], BANK[9]
; bank9_tiles_at_4d40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4D00End:
Bank9TilesAt4D40:
    INCBIN "roms/magination.gbc", $24D40, $40

SECTION "ROM from $024D80", ROMX[$4D80], BANK[9]
; bank9_tiles_at_4d80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4D40End:
Bank9TilesAt4D80:
    INCBIN "roms/magination.gbc", $24D80, $40

SECTION "ROM from $024DC0", ROMX[$4DC0], BANK[9]
; bank9_tiles_at_4dc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4D80End:
Bank9TilesAt4DC0:
    INCBIN "roms/magination.gbc", $24DC0, $40

SECTION "ROM from $024E00", ROMX[$4E00], BANK[9]
; bank9_tiles_at_4e00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4DC0End:
Bank9TilesAt4E00:
    INCBIN "roms/magination.gbc", $24E00, $40

SECTION "ROM from $024E40", ROMX[$4E40], BANK[9]
; bank9_tiles_at_4e40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4E00End:
Bank9TilesAt4E40:
    INCBIN "roms/magination.gbc", $24E40, $40

SECTION "ROM from $024E80", ROMX[$4E80], BANK[9]
; bank9_tiles_at_4e80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4E40End:
Bank9TilesAt4E80:
    INCBIN "roms/magination.gbc", $24E80, $40

SECTION "ROM from $024EC0", ROMX[$4EC0], BANK[9]
; bank9_tiles_at_4ec0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4E80End:
Bank9TilesAt4EC0:
    INCBIN "roms/magination.gbc", $24EC0, $40

SECTION "ROM from $024F00", ROMX[$4F00], BANK[9]
; bank9_tiles_at_4f00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4EC0End:
Bank9TilesAt4F00:
    INCBIN "roms/magination.gbc", $24F00, $40

SECTION "ROM from $024F40", ROMX[$4F40], BANK[9]
; bank9_tiles_at_4f40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4F00End:
Bank9TilesAt4F40:
    INCBIN "roms/magination.gbc", $24F40, $40

SECTION "ROM from $024F80", ROMX[$4F80], BANK[9]
; bank9_tiles_at_4f80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4F40End:
Bank9TilesAt4F80:
    INCBIN "roms/magination.gbc", $24F80, $40

SECTION "ROM from $024FC0", ROMX[$4FC0], BANK[9]
; bank9_tiles_at_4fc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4F80End:
Bank9TilesAt4FC0:
    INCBIN "roms/magination.gbc", $24FC0, $40

SECTION "ROM from $025000", ROMX[$5000], BANK[9]
; bank9_tiles_at_5000.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt4FC0End:
Bank9TilesAt5000:
    INCBIN "roms/magination.gbc", $25000, $40

SECTION "ROM from $025040", ROMX[$5040], BANK[9]
; bank9_tiles_at_5040.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5000End:
Bank9TilesAt5040:
    INCBIN "roms/magination.gbc", $25040, $40

SECTION "ROM from $025080", ROMX[$5080], BANK[9]
; bank9_tiles_at_5080.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5040End:
Bank9TilesAt5080:
    INCBIN "roms/magination.gbc", $25080, $40

SECTION "ROM from $0250C0", ROMX[$50C0], BANK[9]
; bank9_tiles_at_50c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5080End:
Bank9TilesAt50C0:
    INCBIN "roms/magination.gbc", $250C0, $40

SECTION "ROM from $025100", ROMX[$5100], BANK[9]
; bank9_tiles_at_5100.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt50C0End:
Bank9TilesAt5100:
    INCBIN "roms/magination.gbc", $25100, $40

SECTION "ROM from $025140", ROMX[$5140], BANK[9]
; bank9_tiles_at_5140.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5100End:
Bank9TilesAt5140:
    INCBIN "roms/magination.gbc", $25140, $40

SECTION "ROM from $025180", ROMX[$5180], BANK[9]
; bank9_tiles_at_5180.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5140End:
Bank9TilesAt5180:
    INCBIN "roms/magination.gbc", $25180, $40

SECTION "ROM from $0251C0", ROMX[$51C0], BANK[9]
; bank9_tiles_at_51c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5180End:
Bank9TilesAt51C0:
    INCBIN "roms/magination.gbc", $251C0, $40

SECTION "ROM from $025200", ROMX[$5200], BANK[9]
; bank9_tiles_at_5200.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt51C0End:
Bank9TilesAt5200:
    INCBIN "roms/magination.gbc", $25200, $40

SECTION "ROM from $025240", ROMX[$5240], BANK[9]
; bank9_tiles_at_5240.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5240:
    INCBIN "roms/magination.gbc", $25240, $40

SECTION "ROM from $025280", ROMX[$5280], BANK[9]
; bank9_tiles_at_5280.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5280:
    INCBIN "roms/magination.gbc", $25280, $40

SECTION "ROM from $0252C0", ROMX[$52C0], BANK[9]
; bank9_tiles_at_52c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt52C0:
    INCBIN "roms/magination.gbc", $252C0, $40

SECTION "ROM from $025300", ROMX[$5300], BANK[9]
; bank9_tiles_at_5300.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5300:
    INCBIN "roms/magination.gbc", $25300, $40

SECTION "ROM from $025340", ROMX[$5340], BANK[9]
; bank9_tiles_at_5340.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5340:
    INCBIN "roms/magination.gbc", $25340, $40

SECTION "ROM from $025380", ROMX[$5380], BANK[9]
; bank9_tiles_at_5380.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5380:
    INCBIN "roms/magination.gbc", $25380, $40

SECTION "ROM from $0253C0", ROMX[$53C0], BANK[9]
; bank9_tiles_at_53c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt53C0:
    INCBIN "roms/magination.gbc", $253C0, $40

SECTION "ROM from $025400", ROMX[$5400], BANK[9]
; bank9_tiles_at_5400.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5400:
    INCBIN "roms/magination.gbc", $25400, $40

SECTION "ROM from $025440", ROMX[$5440], BANK[9]
; bank9_tiles_at_5440.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5440:
    INCBIN "roms/magination.gbc", $25440, $40

SECTION "ROM from $025480", ROMX[$5480], BANK[9]
; bank9_tiles_at_5480.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5480:
    INCBIN "roms/magination.gbc", $25480, $40

SECTION "ROM from $0254C0", ROMX[$54C0], BANK[9]
; bank9_tiles_at_54c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt54C0:
    INCBIN "roms/magination.gbc", $254C0, $40

SECTION "ROM from $025500", ROMX[$5500], BANK[9]
; bank9_tiles_at_5500.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5500:
    INCBIN "roms/magination.gbc", $25500, $40

SECTION "ROM from $025540", ROMX[$5540], BANK[9]
; bank9_tiles_at_5540.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5540:
    INCBIN "roms/magination.gbc", $25540, $40

SECTION "ROM from $025580", ROMX[$5580], BANK[9]
; bank9_tiles_at_5580.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5580:
    INCBIN "roms/magination.gbc", $25580, $40

SECTION "ROM from $0255C0", ROMX[$55C0], BANK[9]
; bank9_tiles_at_55c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt55C0:
    INCBIN "roms/magination.gbc", $255C0, $40

SECTION "ROM from $025600", ROMX[$5600], BANK[9]
; bank9_tiles_at_5600.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5600:
    INCBIN "roms/magination.gbc", $25600, $40

SECTION "ROM from $025640", ROMX[$5640], BANK[9]
; bank9_tiles_at_5640.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5640:
    INCBIN "roms/magination.gbc", $25640, $40

SECTION "ROM from $025680", ROMX[$5680], BANK[9]
; bank9_tiles_at_5680.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5680:
    INCBIN "roms/magination.gbc", $25680, $40

SECTION "ROM from $0256C0", ROMX[$56C0], BANK[9]
; bank9_tiles_at_56c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt56C0:
    INCBIN "roms/magination.gbc", $256C0, $40

SECTION "ROM from $025700", ROMX[$5700], BANK[9]
; bank9_tiles_at_5700.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5700:
    INCBIN "roms/magination.gbc", $25700, $40

SECTION "ROM from $025740", ROMX[$5740], BANK[9]
; bank9_tiles_at_5740.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5740:
    INCBIN "roms/magination.gbc", $25740, $40

SECTION "ROM from $025780", ROMX[$5780], BANK[9]
; bank9_tiles_at_5780.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5780:
    INCBIN "roms/magination.gbc", $25780, $40

SECTION "ROM from $0257C0", ROMX[$57C0], BANK[9]
; bank9_tiles_at_57c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt57C0:
    INCBIN "roms/magination.gbc", $257C0, $40

SECTION "ROM from $025800", ROMX[$5800], BANK[9]
; bank9_tiles_at_5800.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5800:
    INCBIN "roms/magination.gbc", $25800, $40

SECTION "ROM from $025840", ROMX[$5840], BANK[9]
; bank9_tiles_at_5840.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5840:
    INCBIN "roms/magination.gbc", $25840, $40

SECTION "ROM from $025880", ROMX[$5880], BANK[9]
; bank9_tiles_at_5880.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5880:
    INCBIN "roms/magination.gbc", $25880, $40

SECTION "ROM from $0258C0", ROMX[$58C0], BANK[9]
; bank9_tiles_at_58c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt58C0:
    INCBIN "roms/magination.gbc", $258C0, $40

SECTION "ROM from $025900", ROMX[$5900], BANK[9]
; bank9_tiles_at_5900.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5900:
    INCBIN "roms/magination.gbc", $25900, $40

SECTION "ROM from $025940", ROMX[$5940], BANK[9]
; bank9_tiles_at_5940.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5940:
    INCBIN "roms/magination.gbc", $25940, $40

SECTION "ROM from $025980", ROMX[$5980], BANK[9]
; bank9_tiles_at_5980.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5980:
    INCBIN "roms/magination.gbc", $25980, $40

SECTION "ROM from $0259C0", ROMX[$59C0], BANK[9]
; bank9_tiles_at_59c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt59C0:
    INCBIN "roms/magination.gbc", $259C0, $40

SECTION "ROM from $025A00", ROMX[$5A00], BANK[9]
; bank9_tiles_at_5a00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5A00:
    INCBIN "roms/magination.gbc", $25A00, $40

SECTION "ROM from $025A40", ROMX[$5A40], BANK[9]
; bank9_tiles_at_5a40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5A40:
    INCBIN "roms/magination.gbc", $25A40, $40

SECTION "ROM from $025A80", ROMX[$5A80], BANK[9]
; bank9_tiles_at_5a80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5A80:
    INCBIN "roms/magination.gbc", $25A80, $40

SECTION "ROM from $025AC0", ROMX[$5AC0], BANK[9]
; bank9_tiles_at_5ac0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5AC0:
    INCBIN "roms/magination.gbc", $25AC0, $40

SECTION "ROM from $025B00", ROMX[$5B00], BANK[9]
; bank9_tiles_at_5b00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5B00:
    INCBIN "roms/magination.gbc", $25B00, $40

SECTION "ROM from $025B40", ROMX[$5B40], BANK[9]
; bank9_tiles_at_5b40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5B40:
    INCBIN "roms/magination.gbc", $25B40, $40

SECTION "ROM from $025B80", ROMX[$5B80], BANK[9]
; bank9_tiles_at_5b80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5B80:
    INCBIN "roms/magination.gbc", $25B80, $40

SECTION "ROM from $025BC0", ROMX[$5BC0], BANK[9]
; bank9_tiles_at_5bc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5BC0:
    INCBIN "roms/magination.gbc", $25BC0, $40

SECTION "ROM from $025C00", ROMX[$5C00], BANK[9]
; bank9_tiles_at_5c00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5C00:
    INCBIN "roms/magination.gbc", $25C00, $40

SECTION "ROM from $025C40", ROMX[$5C40], BANK[9]
; bank9_tiles_at_5c40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5C40:
    INCBIN "roms/magination.gbc", $25C40, $40

SECTION "ROM from $025C80", ROMX[$5C80], BANK[9]
; bank9_tiles_at_5c80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5C80:
    INCBIN "roms/magination.gbc", $25C80, $40

SECTION "ROM from $025CC0", ROMX[$5CC0], BANK[9]
; bank9_tiles_at_5cc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5CC0:
    INCBIN "roms/magination.gbc", $25CC0, $40

SECTION "ROM from $025D00", ROMX[$5D00], BANK[9]
; bank9_tiles_at_5d00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5D00:
    INCBIN "roms/magination.gbc", $25D00, $40

SECTION "ROM from $025D40", ROMX[$5D40], BANK[9]
; bank9_tiles_at_5d40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5D40:
    INCBIN "roms/magination.gbc", $25D40, $40

SECTION "ROM from $025D80", ROMX[$5D80], BANK[9]
; bank9_tiles_at_5d80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5D80:
    INCBIN "roms/magination.gbc", $25D80, $40

SECTION "ROM from $025DC0", ROMX[$5DC0], BANK[9]
; bank9_tiles_at_5dc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5DC0:
    INCBIN "roms/magination.gbc", $25DC0, $40

SECTION "ROM from $025E00", ROMX[$5E00], BANK[9]
; bank9_tiles_at_5e00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5E00:
    INCBIN "roms/magination.gbc", $25E00, $40

SECTION "ROM from $025E40", ROMX[$5E40], BANK[9]
; bank9_tiles_at_5e40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5E40:
    INCBIN "roms/magination.gbc", $25E40, $40

SECTION "ROM from $025E80", ROMX[$5E80], BANK[9]
; bank9_tiles_at_5e80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5E80:
    INCBIN "roms/magination.gbc", $25E80, $40

SECTION "ROM from $025EC0", ROMX[$5EC0], BANK[9]
; bank9_tiles_at_5ec0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5EC0:
    INCBIN "roms/magination.gbc", $25EC0, $40

SECTION "ROM from $025F00", ROMX[$5F00], BANK[9]
; bank9_tiles_at_5f00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5F00:
    INCBIN "roms/magination.gbc", $25F00, $40

SECTION "ROM from $025F40", ROMX[$5F40], BANK[9]
; bank9_tiles_at_5f40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5F40:
    INCBIN "roms/magination.gbc", $25F40, $40

SECTION "ROM from $025F80", ROMX[$5F80], BANK[9]
; bank9_tiles_at_5f80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5F80:
    INCBIN "roms/magination.gbc", $25F80, $40

SECTION "ROM from $025FC0", ROMX[$5FC0], BANK[9]
; bank9_tiles_at_5fc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt5FC0:
    INCBIN "roms/magination.gbc", $25FC0, $40

SECTION "ROM from $026000", ROMX[$6000], BANK[9]
; bank9_tiles_at_6000.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6000:
    INCBIN "roms/magination.gbc", $26000, $40

SECTION "ROM from $026040", ROMX[$6040], BANK[9]
; bank9_tiles_at_6040.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6040:
    INCBIN "roms/magination.gbc", $26040, $40

SECTION "ROM from $026080", ROMX[$6080], BANK[9]
; bank9_tiles_at_6080.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6080:
    INCBIN "roms/magination.gbc", $26080, $40

SECTION "ROM from $0260C0", ROMX[$60C0], BANK[9]
; bank9_tiles_at_60c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt60C0:
    INCBIN "roms/magination.gbc", $260C0, $40

SECTION "ROM from $026100", ROMX[$6100], BANK[9]
; bank9_tiles_at_6100.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6100:
    INCBIN "roms/magination.gbc", $26100, $40

SECTION "ROM from $026140", ROMX[$6140], BANK[9]
; bank9_tiles_at_6140.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6140:
    INCBIN "roms/magination.gbc", $26140, $40

SECTION "ROM from $026180", ROMX[$6180], BANK[9]
; bank9_tiles_at_6180.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6180:
    INCBIN "roms/magination.gbc", $26180, $40

SECTION "ROM from $0261C0", ROMX[$61C0], BANK[9]
; bank9_tiles_at_61c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt61C0:
    INCBIN "roms/magination.gbc", $261C0, $40

SECTION "ROM from $026200", ROMX[$6200], BANK[9]
; bank9_tiles_at_6200.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6200:
    INCBIN "roms/magination.gbc", $26200, $40

SECTION "ROM from $026240", ROMX[$6240], BANK[9]
; bank9_tiles_at_6240.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6240:
    INCBIN "roms/magination.gbc", $26240, $40

SECTION "ROM from $026280", ROMX[$6280], BANK[9]
; bank9_tiles_at_6280.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6280:
    INCBIN "roms/magination.gbc", $26280, $40

SECTION "ROM from $0262C0", ROMX[$62C0], BANK[9]
; bank9_tiles_at_62c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt62C0:
    INCBIN "roms/magination.gbc", $262C0, $40

SECTION "ROM from $026300", ROMX[$6300], BANK[9]
; bank9_tiles_at_6300.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6300:
    INCBIN "roms/magination.gbc", $26300, $40

SECTION "ROM from $026340", ROMX[$6340], BANK[9]
; bank9_tiles_at_6340.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6340:
    INCBIN "roms/magination.gbc", $26340, $40

SECTION "ROM from $026380", ROMX[$6380], BANK[9]
; bank9_tiles_at_6380.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6380:
    INCBIN "roms/magination.gbc", $26380, $40

SECTION "ROM from $0263C0", ROMX[$63C0], BANK[9]
; bank9_tiles_at_63c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt63C0:
    INCBIN "roms/magination.gbc", $263C0, $40

SECTION "ROM from $026400", ROMX[$6400], BANK[9]
; bank9_tiles_at_6400.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6400:
    INCBIN "roms/magination.gbc", $26400, $40

SECTION "ROM from $026440", ROMX[$6440], BANK[9]
; bank9_tiles_at_6440.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6440:
    INCBIN "roms/magination.gbc", $26440, $40

SECTION "ROM from $026480", ROMX[$6480], BANK[9]
; bank9_tiles_at_6480.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6480:
    INCBIN "roms/magination.gbc", $26480, $40

SECTION "ROM from $0264C0", ROMX[$64C0], BANK[9]
; bank9_tiles_at_64c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt64C0:
    INCBIN "roms/magination.gbc", $264C0, $40

SECTION "ROM from $026500", ROMX[$6500], BANK[9]
; bank9_tiles_at_6500.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6500:
    INCBIN "roms/magination.gbc", $26500, $40

SECTION "ROM from $026540", ROMX[$6540], BANK[9]
; bank9_tiles_at_6540.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6540:
    INCBIN "roms/magination.gbc", $26540, $40

SECTION "ROM from $026580", ROMX[$6580], BANK[9]
; bank9_tiles_at_6580.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6580:
    INCBIN "roms/magination.gbc", $26580, $40

SECTION "ROM from $0265C0", ROMX[$65C0], BANK[9]
; bank9_tiles_at_65c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt65C0:
    INCBIN "roms/magination.gbc", $265C0, $40

SECTION "ROM from $026600", ROMX[$6600], BANK[9]
; bank9_tiles_at_6600.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6600:
    INCBIN "roms/magination.gbc", $26600, $40

SECTION "ROM from $026640", ROMX[$6640], BANK[9]
; bank9_tiles_at_6640.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6640:
    INCBIN "roms/magination.gbc", $26640, $40

SECTION "ROM from $026680", ROMX[$6680], BANK[9]
; bank9_tiles_at_6680.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6680:
    INCBIN "roms/magination.gbc", $26680, $40

SECTION "ROM from $0266C0", ROMX[$66C0], BANK[9]
; bank9_tiles_at_66c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt66C0:
    INCBIN "roms/magination.gbc", $266C0, $40

SECTION "ROM from $026700", ROMX[$6700], BANK[9]
; bank9_tiles_at_6700.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6700:
    INCBIN "roms/magination.gbc", $26700, $40

SECTION "ROM from $026740", ROMX[$6740], BANK[9]
; bank9_tiles_at_6740.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6740:
    INCBIN "roms/magination.gbc", $26740, $40

SECTION "ROM from $026780", ROMX[$6780], BANK[9]
; bank9_tiles_at_6780.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6780:
    INCBIN "roms/magination.gbc", $26780, $40

SECTION "ROM from $0267C0", ROMX[$67C0], BANK[9]
; bank9_tiles_at_67c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt67C0:
    INCBIN "roms/magination.gbc", $267C0, $40

SECTION "ROM from $026800", ROMX[$6800], BANK[9]
; bank9_tiles_at_6800.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6800:
    INCBIN "roms/magination.gbc", $26800, $40

SECTION "ROM from $026840", ROMX[$6840], BANK[9]
; bank9_tiles_at_6840.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6840:
    INCBIN "roms/magination.gbc", $26840, $40

SECTION "ROM from $026880", ROMX[$6880], BANK[9]
; bank9_tiles_at_6880.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6880:
    INCBIN "roms/magination.gbc", $26880, $40

SECTION "ROM from $0268C0", ROMX[$68C0], BANK[9]
; bank9_tiles_at_68c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt68C0:
    INCBIN "roms/magination.gbc", $268C0, $40

SECTION "ROM from $026900", ROMX[$6900], BANK[9]
; bank9_tiles_at_6900.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6900:
    INCBIN "roms/magination.gbc", $26900, $40

SECTION "ROM from $026940", ROMX[$6940], BANK[9]
; bank9_tiles_at_6940.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6940:
    INCBIN "roms/magination.gbc", $26940, $40

SECTION "ROM from $026980", ROMX[$6980], BANK[9]
; bank9_tiles_at_6980.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6980:
    INCBIN "roms/magination.gbc", $26980, $40

SECTION "ROM from $0269C0", ROMX[$69C0], BANK[9]
; bank9_tiles_at_69c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt69C0:
    INCBIN "roms/magination.gbc", $269C0, $40

SECTION "ROM from $026A00", ROMX[$6A00], BANK[9]
; bank9_tiles_at_6a00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6A00:
    INCBIN "roms/magination.gbc", $26A00, $40

SECTION "ROM from $026A40", ROMX[$6A40], BANK[9]
; bank9_tiles_at_6a40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6A40:
    INCBIN "roms/magination.gbc", $26A40, $40

SECTION "ROM from $026A80", ROMX[$6A80], BANK[9]
; bank9_tiles_at_6a80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6A80:
    INCBIN "roms/magination.gbc", $26A80, $40

SECTION "ROM from $026AC0", ROMX[$6AC0], BANK[9]
; bank9_tiles_at_6ac0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6AC0:
    INCBIN "roms/magination.gbc", $26AC0, $40

SECTION "ROM from $026B00", ROMX[$6B00], BANK[9]
; bank9_tiles_at_6b00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6B00:
    INCBIN "roms/magination.gbc", $26B00, $40

SECTION "ROM from $026B40", ROMX[$6B40], BANK[9]
; bank9_tiles_at_6b40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6B40:
    INCBIN "roms/magination.gbc", $26B40, $40

SECTION "ROM from $026B80", ROMX[$6B80], BANK[9]
; bank9_tiles_at_6b80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6B80:
    INCBIN "roms/magination.gbc", $26B80, $40

SECTION "ROM from $026BC0", ROMX[$6BC0], BANK[9]
; bank9_tiles_at_6bc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6BC0:
    INCBIN "roms/magination.gbc", $26BC0, $40

SECTION "ROM from $026C00", ROMX[$6C00], BANK[9]
; bank9_tiles_at_6c00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6C00:
    INCBIN "roms/magination.gbc", $26C00, $40

SECTION "ROM from $026C40", ROMX[$6C40], BANK[9]
; bank9_tiles_at_6c40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6C40:
    INCBIN "roms/magination.gbc", $26C40, $40

SECTION "ROM from $026C80", ROMX[$6C80], BANK[9]
; bank9_tiles_at_6c80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6C80:
    INCBIN "roms/magination.gbc", $26C80, $40

SECTION "ROM from $026CC0", ROMX[$6CC0], BANK[9]
; bank9_tiles_at_6cc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6CC0:
    INCBIN "roms/magination.gbc", $26CC0, $40

SECTION "ROM from $026D00", ROMX[$6D00], BANK[9]
; bank9_tiles_at_6d00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6D00:
    INCBIN "roms/magination.gbc", $26D00, $40

SECTION "ROM from $026D40", ROMX[$6D40], BANK[9]
; bank9_tiles_at_6d40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6D40:
    INCBIN "roms/magination.gbc", $26D40, $40

SECTION "ROM from $026D80", ROMX[$6D80], BANK[9]
; bank9_tiles_at_6d80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6D80:
    INCBIN "roms/magination.gbc", $26D80, $40

SECTION "ROM from $026DC0", ROMX[$6DC0], BANK[9]
; bank9_tiles_at_6dc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6DC0:
    INCBIN "roms/magination.gbc", $26DC0, $40

SECTION "ROM from $026E00", ROMX[$6E00], BANK[9]
; bank9_tiles_at_6e00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6E00:
    INCBIN "roms/magination.gbc", $26E00, $40

SECTION "ROM from $026E40", ROMX[$6E40], BANK[9]
; bank9_tiles_at_6e40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6E40:
    INCBIN "roms/magination.gbc", $26E40, $40

SECTION "ROM from $026E80", ROMX[$6E80], BANK[9]
; bank9_tiles_at_6e80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6E80:
    INCBIN "roms/magination.gbc", $26E80, $40

SECTION "ROM from $026EC0", ROMX[$6EC0], BANK[9]
; bank9_tiles_at_6ec0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6EC0:
    INCBIN "roms/magination.gbc", $26EC0, $40

SECTION "ROM from $026F00", ROMX[$6F00], BANK[9]
; bank9_tiles_at_6f00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6F00:
    INCBIN "roms/magination.gbc", $26F00, $40

SECTION "ROM from $026F40", ROMX[$6F40], BANK[9]
; bank9_tiles_at_6f40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6F40:
    INCBIN "roms/magination.gbc", $26F40, $40

SECTION "ROM from $026F80", ROMX[$6F80], BANK[9]
; bank9_tiles_at_6f80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6F80:
    INCBIN "roms/magination.gbc", $26F80, $40

SECTION "ROM from $026FC0", ROMX[$6FC0], BANK[9]
; bank9_tiles_at_6fc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt6FC0:
    INCBIN "roms/magination.gbc", $26FC0, $40

SECTION "ROM from $027000", ROMX[$7000], BANK[9]
; bank9_tiles_at_7000.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7000:
    INCBIN "roms/magination.gbc", $27000, $40

SECTION "ROM from $027040", ROMX[$7040], BANK[9]
; bank9_tiles_at_7040.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7040:
    INCBIN "roms/magination.gbc", $27040, $40

SECTION "ROM from $027080", ROMX[$7080], BANK[9]
; bank9_tiles_at_7080.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7080:
    INCBIN "roms/magination.gbc", $27080, $40

SECTION "ROM from $0270C0", ROMX[$70C0], BANK[9]
; bank9_tiles_at_70c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt70C0:
    INCBIN "roms/magination.gbc", $270C0, $40

SECTION "ROM from $027100", ROMX[$7100], BANK[9]
; bank9_tiles_at_7100.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7100:
    INCBIN "roms/magination.gbc", $27100, $40

SECTION "ROM from $027140", ROMX[$7140], BANK[9]
; bank9_tiles_at_7140.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7140:
    INCBIN "roms/magination.gbc", $27140, $40

SECTION "ROM from $027180", ROMX[$7180], BANK[9]
; bank9_tiles_at_7180.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7180:
    INCBIN "roms/magination.gbc", $27180, $40

SECTION "ROM from $0271C0", ROMX[$71C0], BANK[9]
; bank9_tiles_at_71c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt71C0:
    INCBIN "roms/magination.gbc", $271C0, $40

SECTION "ROM from $027200", ROMX[$7200], BANK[9]
; bank9_tiles_at_7200.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7200:
    INCBIN "roms/magination.gbc", $27200, $40

SECTION "ROM from $027240", ROMX[$7240], BANK[9]
; bank9_tiles_at_7240.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7240:
    INCBIN "roms/magination.gbc", $27240, $40

SECTION "ROM from $027280", ROMX[$7280], BANK[9]
; bank9_tiles_at_7280.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7280:
    INCBIN "roms/magination.gbc", $27280, $40

SECTION "ROM from $0272C0", ROMX[$72C0], BANK[9]
; bank9_tiles_at_72c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt72C0:
    INCBIN "roms/magination.gbc", $272C0, $40

SECTION "ROM from $027300", ROMX[$7300], BANK[9]
; bank9_tiles_at_7300.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7300:
    INCBIN "roms/magination.gbc", $27300, $40

SECTION "ROM from $027340", ROMX[$7340], BANK[9]
; bank9_tiles_at_7340.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7340:
    INCBIN "roms/magination.gbc", $27340, $40

SECTION "ROM from $027380", ROMX[$7380], BANK[9]
; bank9_tiles_at_7380.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7380:
    INCBIN "roms/magination.gbc", $27380, $40

SECTION "ROM from $0273C0", ROMX[$73C0], BANK[9]
; bank9_tiles_at_73c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt73C0:
    INCBIN "roms/magination.gbc", $273C0, $40

SECTION "ROM from $027400", ROMX[$7400], BANK[9]
; bank9_tiles_at_7400.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7400:
    INCBIN "roms/magination.gbc", $27400, $40

SECTION "ROM from $027440", ROMX[$7440], BANK[9]
; bank9_tiles_at_7440.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7440:
    INCBIN "roms/magination.gbc", $27440, $40

SECTION "ROM from $027480", ROMX[$7480], BANK[9]
; bank9_tiles_at_7480.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7480:
    INCBIN "roms/magination.gbc", $27480, $40

SECTION "ROM from $0274C0", ROMX[$74C0], BANK[9]
; bank9_tiles_at_74c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt74C0:
    INCBIN "roms/magination.gbc", $274C0, $40

SECTION "ROM from $027500", ROMX[$7500], BANK[9]
; bank9_tiles_at_7500.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7500:
    INCBIN "roms/magination.gbc", $27500, $40

SECTION "ROM from $027540", ROMX[$7540], BANK[9]
; bank9_tiles_at_7540.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7540:
    INCBIN "roms/magination.gbc", $27540, $40

SECTION "ROM from $027580", ROMX[$7580], BANK[9]
; bank9_tiles_at_7580.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7580:
    INCBIN "roms/magination.gbc", $27580, $40

SECTION "ROM from $0275C0", ROMX[$75C0], BANK[9]
; bank9_tiles_at_75c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt75C0:
    INCBIN "roms/magination.gbc", $275C0, $40

SECTION "ROM from $027600", ROMX[$7600], BANK[9]
; bank9_tiles_at_7600.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7600:
    INCBIN "roms/magination.gbc", $27600, $40

SECTION "ROM from $027640", ROMX[$7640], BANK[9]
; bank9_tiles_at_7640.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7640:
    INCBIN "roms/magination.gbc", $27640, $40

SECTION "ROM from $027680", ROMX[$7680], BANK[9]
; bank9_tiles_at_7680.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7680:
    INCBIN "roms/magination.gbc", $27680, $40

SECTION "ROM from $0276C0", ROMX[$76C0], BANK[9]
; bank9_tiles_at_76c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt76C0:
    INCBIN "roms/magination.gbc", $276C0, $40

SECTION "ROM from $027700", ROMX[$7700], BANK[9]
; bank9_tiles_at_7700.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7700:
    INCBIN "roms/magination.gbc", $27700, $40

SECTION "ROM from $027740", ROMX[$7740], BANK[9]
; bank9_tiles_at_7740.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7740:
    INCBIN "roms/magination.gbc", $27740, $40

SECTION "ROM from $027780", ROMX[$7780], BANK[9]
; bank9_tiles_at_7780.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7780:
    INCBIN "roms/magination.gbc", $27780, $40

SECTION "ROM from $0277C0", ROMX[$77C0], BANK[9]
; bank9_tiles_at_77c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt77C0:
    INCBIN "roms/magination.gbc", $277C0, $40

SECTION "ROM from $027800", ROMX[$7800], BANK[9]
; bank9_tiles_at_7800.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7800:
    INCBIN "roms/magination.gbc", $27800, $40

SECTION "ROM from $027840", ROMX[$7840], BANK[9]
; bank9_tiles_at_7840.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7840:
    INCBIN "roms/magination.gbc", $27840, $40

SECTION "ROM from $027880", ROMX[$7880], BANK[9]
; bank9_tiles_at_7880.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7880:
    INCBIN "roms/magination.gbc", $27880, $40

SECTION "ROM from $0278C0", ROMX[$78C0], BANK[9]
; bank9_tiles_at_78c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt78C0:
    INCBIN "roms/magination.gbc", $278C0, $40

SECTION "ROM from $027900", ROMX[$7900], BANK[9]
; bank9_tiles_at_7900.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7900:
    INCBIN "roms/magination.gbc", $27900, $40

SECTION "ROM from $027940", ROMX[$7940], BANK[9]
; bank9_tiles_at_7940.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7940:
    INCBIN "roms/magination.gbc", $27940, $40

SECTION "ROM from $027980", ROMX[$7980], BANK[9]
; bank9_tiles_at_7980.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7980:
    INCBIN "roms/magination.gbc", $27980, $40

SECTION "ROM from $0279C0", ROMX[$79C0], BANK[9]
; bank9_tiles_at_79c0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt79C0:
    INCBIN "roms/magination.gbc", $279C0, $40

SECTION "ROM from $027A00", ROMX[$7A00], BANK[9]
; bank9_tiles_at_7a00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7A00:
    INCBIN "roms/magination.gbc", $27A00, $40

SECTION "ROM from $027A40", ROMX[$7A40], BANK[9]
; bank9_tiles_at_7a40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7A40:
    INCBIN "roms/magination.gbc", $27A40, $40

SECTION "ROM from $027A80", ROMX[$7A80], BANK[9]
; bank9_tiles_at_7a80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7A80:
    INCBIN "roms/magination.gbc", $27A80, $40

SECTION "ROM from $027AC0", ROMX[$7AC0], BANK[9]
; bank9_tiles_at_7ac0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7AC0:
    INCBIN "roms/magination.gbc", $27AC0, $40

SECTION "ROM from $027B00", ROMX[$7B00], BANK[9]
; bank9_tiles_at_7b00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7B00:
    INCBIN "roms/magination.gbc", $27B00, $40

SECTION "ROM from $027B40", ROMX[$7B40], BANK[9]
; bank9_tiles_at_7b40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7B40:
    INCBIN "roms/magination.gbc", $27B40, $40

SECTION "ROM from $027B80", ROMX[$7B80], BANK[9]
; bank9_tiles_at_7b80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7B80:
    INCBIN "roms/magination.gbc", $27B80, $40

SECTION "ROM from $027BC0", ROMX[$7BC0], BANK[9]
; bank9_tiles_at_7bc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7BC0:
    INCBIN "roms/magination.gbc", $27BC0, $40

SECTION "ROM from $027C00", ROMX[$7C00], BANK[9]
; bank9_tiles_at_7c00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7C00:
    INCBIN "roms/magination.gbc", $27C00, $40

SECTION "ROM from $027C40", ROMX[$7C40], BANK[9]
; bank9_tiles_at_7c40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7C40:
    INCBIN "roms/magination.gbc", $27C40, $40

SECTION "ROM from $027C80", ROMX[$7C80], BANK[9]
; bank9_tiles_at_7c80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7C80:
    INCBIN "roms/magination.gbc", $27C80, $40

SECTION "ROM from $027CC0", ROMX[$7CC0], BANK[9]
; bank9_tiles_at_7cc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7CC0:
    INCBIN "roms/magination.gbc", $27CC0, $40

SECTION "ROM from $027D00", ROMX[$7D00], BANK[9]
; bank9_tiles_at_7d00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7D00:
    INCBIN "roms/magination.gbc", $27D00, $40

SECTION "ROM from $027D40", ROMX[$7D40], BANK[9]
; bank9_tiles_at_7d40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7D40:
    INCBIN "roms/magination.gbc", $27D40, $40

SECTION "ROM from $027D80", ROMX[$7D80], BANK[9]
; bank9_tiles_at_7d80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7D80:
    INCBIN "roms/magination.gbc", $27D80, $40

SECTION "ROM from $027DC0", ROMX[$7DC0], BANK[9]
; bank9_tiles_at_7dc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7DC0:
    INCBIN "roms/magination.gbc", $27DC0, $40

SECTION "ROM from $027E00", ROMX[$7E00], BANK[9]
; bank9_tiles_at_7e00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7E00:
    INCBIN "roms/magination.gbc", $27E00, $40

SECTION "ROM from $027E40", ROMX[$7E40], BANK[9]
; bank9_tiles_at_7e40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7E40:
    INCBIN "roms/magination.gbc", $27E40, $40

SECTION "ROM from $027E80", ROMX[$7E80], BANK[9]
; bank9_tiles_at_7e80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7E80:
    INCBIN "roms/magination.gbc", $27E80, $40

SECTION "ROM from $027EC0", ROMX[$7EC0], BANK[9]
; bank9_tiles_at_7ec0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7EC0:
    INCBIN "roms/magination.gbc", $27EC0, $40

SECTION "ROM from $027F00", ROMX[$7F00], BANK[9]
; bank9_tiles_at_7f00.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7F00:
    INCBIN "roms/magination.gbc", $27F00, $40

SECTION "ROM from $027F40", ROMX[$7F40], BANK[9]
; bank9_tiles_at_7f40.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7F40:
    INCBIN "roms/magination.gbc", $27F40, $40

SECTION "ROM from $027F80", ROMX[$7F80], BANK[9]
; bank9_tiles_at_7f80.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7F80:
    INCBIN "roms/magination.gbc", $27F80, $40

SECTION "ROM from $027FC0", ROMX[$7FC0], BANK[9]
; bank9_tiles_at_7fc0.asm: not published here (it assembles data copied from the ROM)
Bank9TilesAt7FC0:
    INCBIN "roms/magination.gbc", $27FC0, $40

SECTION "ROM Bank 010", ROMX[$4000], BANK[10]
; bank10_tiles_at_4000.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4000:
    INCBIN "roms/magination.gbc", $28000, $40

SECTION "ROM from $028040", ROMX[$4040], BANK[10]
; bank10_tiles_at_4040.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4040:
    INCBIN "roms/magination.gbc", $28040, $40

SECTION "ROM from $028080", ROMX[$4080], BANK[10]
; bank10_tiles_at_4080.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4080:
    INCBIN "roms/magination.gbc", $28080, $40

SECTION "ROM from $0280C0", ROMX[$40C0], BANK[10]
; bank10_tiles_at_40c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt40C0:
    INCBIN "roms/magination.gbc", $280C0, $40

SECTION "ROM from $028100", ROMX[$4100], BANK[10]
; bank10_tiles_at_4100.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4100:
    INCBIN "roms/magination.gbc", $28100, $40

SECTION "ROM from $028140", ROMX[$4140], BANK[10]
; bank10_tiles_at_4140.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4140:
    INCBIN "roms/magination.gbc", $28140, $40

SECTION "ROM from $028180", ROMX[$4180], BANK[10]
; bank10_tiles_at_4180.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4180:
    INCBIN "roms/magination.gbc", $28180, $40

SECTION "ROM from $0281C0", ROMX[$41C0], BANK[10]
; bank10_tiles_at_41c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt41C0:
    INCBIN "roms/magination.gbc", $281C0, $40

SECTION "ROM from $028200", ROMX[$4200], BANK[10]
; bank10_tiles_at_4200.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4200:
    INCBIN "roms/magination.gbc", $28200, $40

SECTION "ROM from $028240", ROMX[$4240], BANK[10]
; bank10_tiles_at_4240.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4240:
    INCBIN "roms/magination.gbc", $28240, $40

SECTION "ROM from $028280", ROMX[$4280], BANK[10]
; bank10_tiles_at_4280.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4280:
    INCBIN "roms/magination.gbc", $28280, $40

SECTION "ROM from $0282C0", ROMX[$42C0], BANK[10]
; bank10_tiles_at_42c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt42C0:
    INCBIN "roms/magination.gbc", $282C0, $40

SECTION "ROM from $028300", ROMX[$4300], BANK[10]
; bank10_tiles_at_4300.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4300:
    INCBIN "roms/magination.gbc", $28300, $40

SECTION "ROM from $028340", ROMX[$4340], BANK[10]
; bank10_tiles_at_4340.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4340:
    INCBIN "roms/magination.gbc", $28340, $40

SECTION "ROM from $028380", ROMX[$4380], BANK[10]
; bank10_tiles_at_4380.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4380:
    INCBIN "roms/magination.gbc", $28380, $40

SECTION "ROM from $0283C0", ROMX[$43C0], BANK[10]
; bank10_tiles_at_43c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt43C0:
    INCBIN "roms/magination.gbc", $283C0, $40

SECTION "ROM from $028400", ROMX[$4400], BANK[10]
; bank10_tiles_at_4400.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4400:
    INCBIN "roms/magination.gbc", $28400, $40

SECTION "ROM from $028440", ROMX[$4440], BANK[10]
; bank10_tiles_at_4440.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4440:
    INCBIN "roms/magination.gbc", $28440, $40

SECTION "ROM from $028480", ROMX[$4480], BANK[10]
; bank10_tiles_at_4480.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4480:
    INCBIN "roms/magination.gbc", $28480, $40

SECTION "ROM from $0284C0", ROMX[$44C0], BANK[10]
; bank10_tiles_at_44c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt44C0:
    INCBIN "roms/magination.gbc", $284C0, $40

SECTION "ROM from $028500", ROMX[$4500], BANK[10]
; bank10_tiles_at_4500.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4500:
    INCBIN "roms/magination.gbc", $28500, $40

SECTION "ROM from $028540", ROMX[$4540], BANK[10]
; bank10_tiles_at_4540.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4540:
    INCBIN "roms/magination.gbc", $28540, $40

SECTION "ROM from $028580", ROMX[$4580], BANK[10]
; bank10_tiles_at_4580.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4580:
    INCBIN "roms/magination.gbc", $28580, $40

SECTION "ROM from $0285C0", ROMX[$45C0], BANK[10]
; bank10_tiles_at_45c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt45C0:
    INCBIN "roms/magination.gbc", $285C0, $40

SECTION "ROM from $028600", ROMX[$4600], BANK[10]
; bank10_tiles_at_4600.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt45C0End:
Bank10TilesAt4600:
    INCBIN "roms/magination.gbc", $28600, $40

SECTION "ROM from $028640", ROMX[$4640], BANK[10]
; bank10_tiles_at_4640.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4600End:
Bank10TilesAt4640:
    INCBIN "roms/magination.gbc", $28640, $40

SECTION "ROM from $028680", ROMX[$4680], BANK[10]
; bank10_tiles_at_4680.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4640End:
Bank10TilesAt4680:
    INCBIN "roms/magination.gbc", $28680, $40

SECTION "ROM from $0286C0", ROMX[$46C0], BANK[10]
; bank10_tiles_at_46c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4680End:
Bank10TilesAt46C0:
    INCBIN "roms/magination.gbc", $286C0, $40

SECTION "ROM from $028700", ROMX[$4700], BANK[10]
; bank10_tiles_at_4700.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt46C0End:
Bank10TilesAt4700:
    INCBIN "roms/magination.gbc", $28700, $40

SECTION "ROM from $028740", ROMX[$4740], BANK[10]
; bank10_tiles_at_4740.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4700End:
Bank10TilesAt4740:
    INCBIN "roms/magination.gbc", $28740, $40

SECTION "ROM from $028780", ROMX[$4780], BANK[10]
; bank10_tiles_at_4780.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4740End:
Bank10TilesAt4780:
    INCBIN "roms/magination.gbc", $28780, $40

SECTION "ROM from $0287C0", ROMX[$47C0], BANK[10]
; bank10_tiles_at_47c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4780End:
Bank10TilesAt47C0:
    INCBIN "roms/magination.gbc", $287C0, $40

SECTION "ROM from $028800", ROMX[$4800], BANK[10]
; bank10_tiles_at_4800.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt47C0End:
Bank10TilesAt4800:
    INCBIN "roms/magination.gbc", $28800, $40

SECTION "ROM from $028840", ROMX[$4840], BANK[10]
; bank10_tiles_at_4840.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4800End:
Bank10TilesAt4840:
    INCBIN "roms/magination.gbc", $28840, $40

SECTION "ROM from $028880", ROMX[$4880], BANK[10]
; bank10_tiles_at_4880.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4840End:
Bank10TilesAt4880:
    INCBIN "roms/magination.gbc", $28880, $40

SECTION "ROM from $0288C0", ROMX[$48C0], BANK[10]
; bank10_tiles_at_48c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4880End:
Bank10TilesAt48C0:
    INCBIN "roms/magination.gbc", $288C0, $40

SECTION "ROM from $028900", ROMX[$4900], BANK[10]
; bank10_tiles_at_4900.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt48C0End:
Bank10TilesAt4900:
    INCBIN "roms/magination.gbc", $28900, $40

SECTION "ROM from $028940", ROMX[$4940], BANK[10]
; bank10_tiles_at_4940.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4900End:
Bank10TilesAt4940:
    INCBIN "roms/magination.gbc", $28940, $40

SECTION "ROM from $028980", ROMX[$4980], BANK[10]
; bank10_tiles_at_4980.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4940End:
Bank10TilesAt4980:
    INCBIN "roms/magination.gbc", $28980, $40

SECTION "ROM from $0289C0", ROMX[$49C0], BANK[10]
; bank10_tiles_at_49c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4980End:
Bank10TilesAt49C0:
    INCBIN "roms/magination.gbc", $289C0, $40

SECTION "ROM from $028A00", ROMX[$4A00], BANK[10]
; bank10_tiles_at_4a00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt49C0End:
Bank10TilesAt4A00:
    INCBIN "roms/magination.gbc", $28A00, $40

SECTION "ROM from $028A40", ROMX[$4A40], BANK[10]
; bank10_tiles_at_4a40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4A00End:
Bank10TilesAt4A40:
    INCBIN "roms/magination.gbc", $28A40, $40

SECTION "ROM from $028A80", ROMX[$4A80], BANK[10]
; bank10_tiles_at_4a80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4A40End:
Bank10TilesAt4A80:
    INCBIN "roms/magination.gbc", $28A80, $40

SECTION "ROM from $028AC0", ROMX[$4AC0], BANK[10]
; bank10_tiles_at_4ac0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4A80End:
Bank10TilesAt4AC0:
    INCBIN "roms/magination.gbc", $28AC0, $40

SECTION "ROM from $028B00", ROMX[$4B00], BANK[10]
; bank10_tiles_at_4b00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4AC0End:
Bank10TilesAt4B00:
    INCBIN "roms/magination.gbc", $28B00, $40

SECTION "ROM from $028B40", ROMX[$4B40], BANK[10]
; bank10_tiles_at_4b40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4B00End:
Bank10TilesAt4B40:
    INCBIN "roms/magination.gbc", $28B40, $40

SECTION "ROM from $028B80", ROMX[$4B80], BANK[10]
; bank10_tiles_at_4b80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4B40End:
Bank10TilesAt4B80:
    INCBIN "roms/magination.gbc", $28B80, $40

SECTION "ROM from $028BC0", ROMX[$4BC0], BANK[10]
; bank10_tiles_at_4bc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4B80End:
Bank10TilesAt4BC0:
    INCBIN "roms/magination.gbc", $28BC0, $40

SECTION "ROM from $028C00", ROMX[$4C00], BANK[10]
; bank10_tiles_at_4c00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4BC0End:
Bank10TilesAt4C00:
    INCBIN "roms/magination.gbc", $28C00, $40

SECTION "ROM from $028C40", ROMX[$4C40], BANK[10]
; bank10_tiles_at_4c40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4C00End:
Bank10TilesAt4C40:
    INCBIN "roms/magination.gbc", $28C40, $40

SECTION "ROM from $028C80", ROMX[$4C80], BANK[10]
; bank10_tiles_at_4c80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4C40End:
Bank10TilesAt4C80:
    INCBIN "roms/magination.gbc", $28C80, $40

SECTION "ROM from $028CC0", ROMX[$4CC0], BANK[10]
; bank10_tiles_at_4cc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4C80End:
Bank10TilesAt4CC0:
    INCBIN "roms/magination.gbc", $28CC0, $40

SECTION "ROM from $028D00", ROMX[$4D00], BANK[10]
; bank10_tiles_at_4d00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4CC0End:
Bank10TilesAt4D00:
    INCBIN "roms/magination.gbc", $28D00, $40

SECTION "ROM from $028D40", ROMX[$4D40], BANK[10]
; bank10_tiles_at_4d40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4D00End:
Bank10TilesAt4D40:
    INCBIN "roms/magination.gbc", $28D40, $40

SECTION "ROM from $028D80", ROMX[$4D80], BANK[10]
; bank10_tiles_at_4d80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4D40End:
Bank10TilesAt4D80:
    INCBIN "roms/magination.gbc", $28D80, $40

SECTION "ROM from $028DC0", ROMX[$4DC0], BANK[10]
; bank10_tiles_at_4dc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4D80End:
Bank10TilesAt4DC0:
    INCBIN "roms/magination.gbc", $28DC0, $40

SECTION "ROM from $028E00", ROMX[$4E00], BANK[10]
; bank10_tiles_at_4e00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4DC0End:
Bank10TilesAt4E00:
    INCBIN "roms/magination.gbc", $28E00, $40

SECTION "ROM from $028E40", ROMX[$4E40], BANK[10]
; bank10_tiles_at_4e40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4E00End:
Bank10TilesAt4E40:
    INCBIN "roms/magination.gbc", $28E40, $40

SECTION "ROM from $028E80", ROMX[$4E80], BANK[10]
; bank10_tiles_at_4e80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4E40End:
Bank10TilesAt4E80:
    INCBIN "roms/magination.gbc", $28E80, $40

SECTION "ROM from $028EC0", ROMX[$4EC0], BANK[10]
; bank10_tiles_at_4ec0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4E80End:
Bank10TilesAt4EC0:
    INCBIN "roms/magination.gbc", $28EC0, $40

SECTION "ROM from $028F00", ROMX[$4F00], BANK[10]
; bank10_tiles_at_4f00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4EC0End:
Bank10TilesAt4F00:
    INCBIN "roms/magination.gbc", $28F00, $40

SECTION "ROM from $028F40", ROMX[$4F40], BANK[10]
; bank10_tiles_at_4f40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4F00End:
Bank10TilesAt4F40:
    INCBIN "roms/magination.gbc", $28F40, $40

SECTION "ROM from $028F80", ROMX[$4F80], BANK[10]
; bank10_tiles_at_4f80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4F40End:
Bank10TilesAt4F80:
    INCBIN "roms/magination.gbc", $28F80, $40

SECTION "ROM from $028FC0", ROMX[$4FC0], BANK[10]
; bank10_tiles_at_4fc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4F80End:
Bank10TilesAt4FC0:
    INCBIN "roms/magination.gbc", $28FC0, $40

SECTION "ROM from $029000", ROMX[$5000], BANK[10]
; bank10_tiles_at_5000.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt4FC0End:
Bank10TilesAt5000:
    INCBIN "roms/magination.gbc", $29000, $40

SECTION "ROM from $029040", ROMX[$5040], BANK[10]
; bank10_tiles_at_5040.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5000End:
Bank10TilesAt5040:
    INCBIN "roms/magination.gbc", $29040, $40

SECTION "ROM from $029080", ROMX[$5080], BANK[10]
; bank10_tiles_at_5080.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5040End:
Bank10TilesAt5080:
    INCBIN "roms/magination.gbc", $29080, $40

SECTION "ROM from $0290C0", ROMX[$50C0], BANK[10]
; bank10_tiles_at_50c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5080End:
Bank10TilesAt50C0:
    INCBIN "roms/magination.gbc", $290C0, $40

SECTION "ROM from $029100", ROMX[$5100], BANK[10]
; bank10_tiles_at_5100.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt50C0End:
Bank10TilesAt5100:
    INCBIN "roms/magination.gbc", $29100, $40

SECTION "ROM from $029140", ROMX[$5140], BANK[10]
; bank10_tiles_at_5140.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5100End:
Bank10TilesAt5140:
    INCBIN "roms/magination.gbc", $29140, $40

SECTION "ROM from $029180", ROMX[$5180], BANK[10]
; bank10_tiles_at_5180.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5140End:
Bank10TilesAt5180:
    INCBIN "roms/magination.gbc", $29180, $40

SECTION "ROM from $0291C0", ROMX[$51C0], BANK[10]
; bank10_tiles_at_51c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5180End:
Bank10TilesAt51C0:
    INCBIN "roms/magination.gbc", $291C0, $40

SECTION "ROM from $029200", ROMX[$5200], BANK[10]
; bank10_tiles_at_5200.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt51C0End:
Bank10TilesAt5200:
    INCBIN "roms/magination.gbc", $29200, $40

SECTION "ROM from $029240", ROMX[$5240], BANK[10]
; bank10_tiles_at_5240.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5200End:
Bank10TilesAt5240:
    INCBIN "roms/magination.gbc", $29240, $40

SECTION "ROM from $029280", ROMX[$5280], BANK[10]
; bank10_tiles_at_5280.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5240End:
Bank10TilesAt5280:
    INCBIN "roms/magination.gbc", $29280, $40

SECTION "ROM from $0292C0", ROMX[$52C0], BANK[10]
; bank10_tiles_at_52c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5280End:
Bank10TilesAt52C0:
    INCBIN "roms/magination.gbc", $292C0, $40

SECTION "ROM from $029300", ROMX[$5300], BANK[10]
; bank10_tiles_at_5300.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt52C0End:
Bank10TilesAt5300:
    INCBIN "roms/magination.gbc", $29300, $40

SECTION "ROM from $029340", ROMX[$5340], BANK[10]
; bank10_tiles_at_5340.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5300End:
Bank10TilesAt5340:
    INCBIN "roms/magination.gbc", $29340, $40

SECTION "ROM from $029380", ROMX[$5380], BANK[10]
; bank10_tiles_at_5380.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5340End:
Bank10TilesAt5380:
    INCBIN "roms/magination.gbc", $29380, $40

SECTION "ROM from $0293C0", ROMX[$53C0], BANK[10]
; bank10_tiles_at_53c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5380End:
Bank10TilesAt53C0:
    INCBIN "roms/magination.gbc", $293C0, $40

SECTION "ROM from $029400", ROMX[$5400], BANK[10]
; bank10_tiles_at_5400.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt53C0End:
Bank10TilesAt5400:
    INCBIN "roms/magination.gbc", $29400, $40

SECTION "ROM from $029440", ROMX[$5440], BANK[10]
; bank10_tiles_at_5440.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5440:
    INCBIN "roms/magination.gbc", $29440, $40

SECTION "ROM from $029480", ROMX[$5480], BANK[10]
; bank10_tiles_at_5480.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5480:
    INCBIN "roms/magination.gbc", $29480, $40

SECTION "ROM from $0294C0", ROMX[$54C0], BANK[10]
; bank10_tiles_at_54c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt54C0:
    INCBIN "roms/magination.gbc", $294C0, $40

SECTION "ROM from $029500", ROMX[$5500], BANK[10]
; bank10_tiles_at_5500.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5500:
    INCBIN "roms/magination.gbc", $29500, $40

SECTION "ROM from $029540", ROMX[$5540], BANK[10]
; bank10_tiles_at_5540.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5540:
    INCBIN "roms/magination.gbc", $29540, $40

SECTION "ROM from $029580", ROMX[$5580], BANK[10]
; bank10_tiles_at_5580.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5580:
    INCBIN "roms/magination.gbc", $29580, $40

SECTION "ROM from $0295C0", ROMX[$55C0], BANK[10]
; bank10_tiles_at_55c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt55C0:
    INCBIN "roms/magination.gbc", $295C0, $40

SECTION "ROM from $029600", ROMX[$5600], BANK[10]
; bank10_tiles_at_5600.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5600:
    INCBIN "roms/magination.gbc", $29600, $40

SECTION "ROM from $029640", ROMX[$5640], BANK[10]
; bank10_tiles_at_5640.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5640:
    INCBIN "roms/magination.gbc", $29640, $40

SECTION "ROM from $029680", ROMX[$5680], BANK[10]
; bank10_tiles_at_5680.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5640End:
Bank10TilesAt5680:
    INCBIN "roms/magination.gbc", $29680, $40

SECTION "ROM from $0296C0", ROMX[$56C0], BANK[10]
; bank10_tiles_at_56c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5680End:
Bank10TilesAt56C0:
    INCBIN "roms/magination.gbc", $296C0, $40

SECTION "ROM from $029700", ROMX[$5700], BANK[10]
; bank10_tiles_at_5700.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt56C0End:
Bank10TilesAt5700:
    INCBIN "roms/magination.gbc", $29700, $40

SECTION "ROM from $029740", ROMX[$5740], BANK[10]
; bank10_tiles_at_5740.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5700End:
Bank10TilesAt5740:
    INCBIN "roms/magination.gbc", $29740, $40

SECTION "ROM from $029780", ROMX[$5780], BANK[10]
; bank10_tiles_at_5780.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5740End:
Bank10TilesAt5780:
    INCBIN "roms/magination.gbc", $29780, $40

SECTION "ROM from $0297C0", ROMX[$57C0], BANK[10]
; bank10_tiles_at_57c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5780End:
Bank10TilesAt57C0:
    INCBIN "roms/magination.gbc", $297C0, $40

SECTION "ROM from $029800", ROMX[$5800], BANK[10]
; bank10_tiles_at_5800.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt57C0End:
Bank10TilesAt5800:
    INCBIN "roms/magination.gbc", $29800, $40

SECTION "ROM from $029840", ROMX[$5840], BANK[10]
; bank10_tiles_at_5840.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5800End:
Bank10TilesAt5840:
    INCBIN "roms/magination.gbc", $29840, $40

SECTION "ROM from $029880", ROMX[$5880], BANK[10]
; bank10_tiles_at_5880.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5840End:
Bank10TilesAt5880:
    INCBIN "roms/magination.gbc", $29880, $40

SECTION "ROM from $0298C0", ROMX[$58C0], BANK[10]
; bank10_tiles_at_58c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5880End:
Bank10TilesAt58C0:
    INCBIN "roms/magination.gbc", $298C0, $40

SECTION "ROM from $029900", ROMX[$5900], BANK[10]
; bank10_tiles_at_5900.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt58C0End:
Bank10TilesAt5900:
    INCBIN "roms/magination.gbc", $29900, $40

SECTION "ROM from $029940", ROMX[$5940], BANK[10]
; bank10_tiles_at_5940.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5900End:
Bank10TilesAt5940:
    INCBIN "roms/magination.gbc", $29940, $40

SECTION "ROM from $029980", ROMX[$5980], BANK[10]
; bank10_tiles_at_5980.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5940End:
Bank10TilesAt5980:
    INCBIN "roms/magination.gbc", $29980, $40

SECTION "ROM from $0299C0", ROMX[$59C0], BANK[10]
; bank10_tiles_at_59c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5980End:
Bank10TilesAt59C0:
    INCBIN "roms/magination.gbc", $299C0, $40

SECTION "ROM from $029A00", ROMX[$5A00], BANK[10]
; bank10_tiles_at_5a00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt59C0End:
Bank10TilesAt5A00:
    INCBIN "roms/magination.gbc", $29A00, $40

SECTION "ROM from $029A40", ROMX[$5A40], BANK[10]
; bank10_tiles_at_5a40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5A00End:
Bank10TilesAt5A40:
    INCBIN "roms/magination.gbc", $29A40, $40

SECTION "ROM from $029A80", ROMX[$5A80], BANK[10]
; bank10_tiles_at_5a80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5A40End:
Bank10TilesAt5A80:
    INCBIN "roms/magination.gbc", $29A80, $40

SECTION "ROM from $029AC0", ROMX[$5AC0], BANK[10]
; bank10_tiles_at_5ac0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5A80End:
Bank10TilesAt5AC0:
    INCBIN "roms/magination.gbc", $29AC0, $40

SECTION "ROM from $029B00", ROMX[$5B00], BANK[10]
; bank10_tiles_at_5b00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5AC0End:
Bank10TilesAt5B00:
    INCBIN "roms/magination.gbc", $29B00, $40

SECTION "ROM from $029B40", ROMX[$5B40], BANK[10]
; bank10_tiles_at_5b40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5B00End:
Bank10TilesAt5B40:
    INCBIN "roms/magination.gbc", $29B40, $40

SECTION "ROM from $029B80", ROMX[$5B80], BANK[10]
; bank10_tiles_at_5b80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5B40End:
Bank10TilesAt5B80:
    INCBIN "roms/magination.gbc", $29B80, $40

SECTION "ROM from $029BC0", ROMX[$5BC0], BANK[10]
; bank10_tiles_at_5bc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5B80End:
Bank10TilesAt5BC0:
    INCBIN "roms/magination.gbc", $29BC0, $40

SECTION "ROM from $029C00", ROMX[$5C00], BANK[10]
; bank10_tiles_at_5c00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5BC0End:
Bank10TilesAt5C00:
    INCBIN "roms/magination.gbc", $29C00, $40

SECTION "ROM from $029C40", ROMX[$5C40], BANK[10]
; bank10_tiles_at_5c40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5C00End:
Bank10TilesAt5C40:
    INCBIN "roms/magination.gbc", $29C40, $40

SECTION "ROM from $029C80", ROMX[$5C80], BANK[10]
; bank10_tiles_at_5c80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5C40End:
Bank10TilesAt5C80:
    INCBIN "roms/magination.gbc", $29C80, $40

SECTION "ROM from $029CC0", ROMX[$5CC0], BANK[10]
; bank10_tiles_at_5cc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5C80End:
Bank10TilesAt5CC0:
    INCBIN "roms/magination.gbc", $29CC0, $40

SECTION "ROM from $029D00", ROMX[$5D00], BANK[10]
; bank10_tiles_at_5d00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5CC0End:
Bank10TilesAt5D00:
    INCBIN "roms/magination.gbc", $29D00, $40

SECTION "ROM from $029D40", ROMX[$5D40], BANK[10]
; bank10_tiles_at_5d40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5D00End:
Bank10TilesAt5D40:
    INCBIN "roms/magination.gbc", $29D40, $40

SECTION "ROM from $029D80", ROMX[$5D80], BANK[10]
; bank10_tiles_at_5d80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5D40End:
Bank10TilesAt5D80:
    INCBIN "roms/magination.gbc", $29D80, $40

SECTION "ROM from $029DC0", ROMX[$5DC0], BANK[10]
; bank10_tiles_at_5dc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5D80End:
Bank10TilesAt5DC0:
    INCBIN "roms/magination.gbc", $29DC0, $40

SECTION "ROM from $029E00", ROMX[$5E00], BANK[10]
; bank10_tiles_at_5e00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5DC0End:
Bank10TilesAt5E00:
    INCBIN "roms/magination.gbc", $29E00, $40

SECTION "ROM from $029E40", ROMX[$5E40], BANK[10]
; bank10_tiles_at_5e40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5E00End:
Bank10TilesAt5E40:
    INCBIN "roms/magination.gbc", $29E40, $40

SECTION "ROM from $029E80", ROMX[$5E80], BANK[10]
; bank10_tiles_at_5e80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5E40End:
Bank10TilesAt5E80:
    INCBIN "roms/magination.gbc", $29E80, $40

SECTION "ROM from $029EC0", ROMX[$5EC0], BANK[10]
; bank10_tiles_at_5ec0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5E80End:
Bank10TilesAt5EC0:
    INCBIN "roms/magination.gbc", $29EC0, $40

SECTION "ROM from $029F00", ROMX[$5F00], BANK[10]
; bank10_tiles_at_5f00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5EC0End:
Bank10TilesAt5F00:
    INCBIN "roms/magination.gbc", $29F00, $40

SECTION "ROM from $029F40", ROMX[$5F40], BANK[10]
; bank10_tiles_at_5f40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5F00End:
Bank10TilesAt5F40:
    INCBIN "roms/magination.gbc", $29F40, $40

SECTION "ROM from $029F80", ROMX[$5F80], BANK[10]
; bank10_tiles_at_5f80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5F40End:
Bank10TilesAt5F80:
    INCBIN "roms/magination.gbc", $29F80, $40

SECTION "ROM from $029FC0", ROMX[$5FC0], BANK[10]
; bank10_tiles_at_5fc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5F80End:
Bank10TilesAt5FC0:
    INCBIN "roms/magination.gbc", $29FC0, $40

SECTION "ROM from $02A000", ROMX[$6000], BANK[10]
; bank10_tiles_at_6000.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt5FC0End:
Bank10TilesAt6000:
    INCBIN "roms/magination.gbc", $2A000, $40

SECTION "ROM from $02A040", ROMX[$6040], BANK[10]
; bank10_tiles_at_6040.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6000End:
Bank10TilesAt6040:
    INCBIN "roms/magination.gbc", $2A040, $40

SECTION "ROM from $02A080", ROMX[$6080], BANK[10]
; bank10_tiles_at_6080.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6040End:
Bank10TilesAt6080:
    INCBIN "roms/magination.gbc", $2A080, $40

SECTION "ROM from $02A0C0", ROMX[$60C0], BANK[10]
; bank10_tiles_at_60c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6080End:
Bank10TilesAt60C0:
    INCBIN "roms/magination.gbc", $2A0C0, $40

SECTION "ROM from $02A100", ROMX[$6100], BANK[10]
; bank10_tiles_at_6100.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt60C0End:
Bank10TilesAt6100:
    INCBIN "roms/magination.gbc", $2A100, $40

SECTION "ROM from $02A140", ROMX[$6140], BANK[10]
; bank10_tiles_at_6140.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6100End:
Bank10TilesAt6140:
    INCBIN "roms/magination.gbc", $2A140, $40

SECTION "ROM from $02A180", ROMX[$6180], BANK[10]
; bank10_tiles_at_6180.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6140End:
Bank10TilesAt6180:
    INCBIN "roms/magination.gbc", $2A180, $40

SECTION "ROM from $02A1C0", ROMX[$61C0], BANK[10]
; bank10_tiles_at_61c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6180End:
Bank10TilesAt61C0:
    INCBIN "roms/magination.gbc", $2A1C0, $40

SECTION "ROM from $02A200", ROMX[$6200], BANK[10]
; bank10_tiles_at_6200.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt61C0End:
Bank10TilesAt6200:
    INCBIN "roms/magination.gbc", $2A200, $40

SECTION "ROM from $02A240", ROMX[$6240], BANK[10]
; bank10_tiles_at_6240.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6200End:
Bank10TilesAt6240:
    INCBIN "roms/magination.gbc", $2A240, $40

SECTION "ROM from $02A280", ROMX[$6280], BANK[10]
; bank10_tiles_at_6280.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6240End:
Bank10TilesAt6280:
    INCBIN "roms/magination.gbc", $2A280, $40

SECTION "ROM from $02A2C0", ROMX[$62C0], BANK[10]
; bank10_tiles_at_62c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6280End:
Bank10TilesAt62C0:
    INCBIN "roms/magination.gbc", $2A2C0, $40

SECTION "ROM from $02A300", ROMX[$6300], BANK[10]
; bank10_tiles_at_6300.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt62C0End:
Bank10TilesAt6300:
    INCBIN "roms/magination.gbc", $2A300, $40

SECTION "ROM from $02A340", ROMX[$6340], BANK[10]
; bank10_tiles_at_6340.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6340:
    INCBIN "roms/magination.gbc", $2A340, $40

SECTION "ROM from $02A380", ROMX[$6380], BANK[10]
; bank10_tiles_at_6380.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6380:
    INCBIN "roms/magination.gbc", $2A380, $40

SECTION "ROM from $02A3C0", ROMX[$63C0], BANK[10]
; bank10_tiles_at_63c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt63C0:
    INCBIN "roms/magination.gbc", $2A3C0, $40

SECTION "ROM from $02A400", ROMX[$6400], BANK[10]
; bank10_tiles_at_6400.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6400:
    INCBIN "roms/magination.gbc", $2A400, $40

SECTION "ROM from $02A440", ROMX[$6440], BANK[10]
; bank10_tiles_at_6440.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6440:
    INCBIN "roms/magination.gbc", $2A440, $40

SECTION "ROM from $02A480", ROMX[$6480], BANK[10]
; bank10_tiles_at_6480.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6480:
    INCBIN "roms/magination.gbc", $2A480, $40

SECTION "ROM from $02A4C0", ROMX[$64C0], BANK[10]
; bank10_tiles_at_64c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt64C0:
    INCBIN "roms/magination.gbc", $2A4C0, $40

SECTION "ROM from $02A500", ROMX[$6500], BANK[10]
; bank10_tiles_at_6500.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6500:
    INCBIN "roms/magination.gbc", $2A500, $40

SECTION "ROM from $02A540", ROMX[$6540], BANK[10]
; bank10_tiles_at_6540.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6540:
    INCBIN "roms/magination.gbc", $2A540, $40

SECTION "ROM from $02A580", ROMX[$6580], BANK[10]
; bank10_tiles_at_6580.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6580:
    INCBIN "roms/magination.gbc", $2A580, $40

SECTION "ROM from $02A5C0", ROMX[$65C0], BANK[10]
; bank10_tiles_at_65c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt65C0:
    INCBIN "roms/magination.gbc", $2A5C0, $40

SECTION "ROM from $02A600", ROMX[$6600], BANK[10]
; bank10_tiles_at_6600.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6600:
    INCBIN "roms/magination.gbc", $2A600, $40

SECTION "ROM from $02A640", ROMX[$6640], BANK[10]
; bank10_tiles_at_6640.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6640:
    INCBIN "roms/magination.gbc", $2A640, $40

SECTION "ROM from $02A680", ROMX[$6680], BANK[10]
; bank10_tiles_at_6680.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6680:
    INCBIN "roms/magination.gbc", $2A680, $40

SECTION "ROM from $02A6C0", ROMX[$66C0], BANK[10]
; bank10_tiles_at_66c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt66C0:
    INCBIN "roms/magination.gbc", $2A6C0, $40

SECTION "ROM from $02A700", ROMX[$6700], BANK[10]
; bank10_tiles_at_6700.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6700:
    INCBIN "roms/magination.gbc", $2A700, $40

SECTION "ROM from $02A740", ROMX[$6740], BANK[10]
; bank10_tiles_at_6740.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6740:
    INCBIN "roms/magination.gbc", $2A740, $40

SECTION "ROM from $02A780", ROMX[$6780], BANK[10]
; bank10_tiles_at_6780.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6780:
    INCBIN "roms/magination.gbc", $2A780, $40

SECTION "ROM from $02A7C0", ROMX[$67C0], BANK[10]
; bank10_tiles_at_67c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt67C0:
    INCBIN "roms/magination.gbc", $2A7C0, $40

SECTION "ROM from $02A800", ROMX[$6800], BANK[10]
; bank10_tiles_at_6800.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6800:
    INCBIN "roms/magination.gbc", $2A800, $40

SECTION "ROM from $02A840", ROMX[$6840], BANK[10]
; bank10_tiles_at_6840.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6840:
    INCBIN "roms/magination.gbc", $2A840, $40

SECTION "ROM from $02A880", ROMX[$6880], BANK[10]
; bank10_tiles_at_6880.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6880:
    INCBIN "roms/magination.gbc", $2A880, $40

SECTION "ROM from $02A8C0", ROMX[$68C0], BANK[10]
; bank10_tiles_at_68c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt68C0:
    INCBIN "roms/magination.gbc", $2A8C0, $40

SECTION "ROM from $02A900", ROMX[$6900], BANK[10]
; bank10_tiles_at_6900.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6900:
    INCBIN "roms/magination.gbc", $2A900, $40

SECTION "ROM from $02A940", ROMX[$6940], BANK[10]
; bank10_tiles_at_6940.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6940:
    INCBIN "roms/magination.gbc", $2A940, $40

SECTION "ROM from $02A980", ROMX[$6980], BANK[10]
; bank10_tiles_at_6980.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6980:
    INCBIN "roms/magination.gbc", $2A980, $40

SECTION "ROM from $02A9C0", ROMX[$69C0], BANK[10]
; bank10_tiles_at_69c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt69C0:
    INCBIN "roms/magination.gbc", $2A9C0, $40

SECTION "ROM from $02AA00", ROMX[$6A00], BANK[10]
; bank10_tiles_at_6a00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6A00:
    INCBIN "roms/magination.gbc", $2AA00, $40

SECTION "ROM from $02AA40", ROMX[$6A40], BANK[10]
; bank10_tiles_at_6a40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6A40:
    INCBIN "roms/magination.gbc", $2AA40, $40

SECTION "ROM from $02AA80", ROMX[$6A80], BANK[10]
; bank10_tiles_at_6a80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6A80:
    INCBIN "roms/magination.gbc", $2AA80, $40

SECTION "ROM from $02AAC0", ROMX[$6AC0], BANK[10]
; bank10_tiles_at_6ac0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6AC0:
    INCBIN "roms/magination.gbc", $2AAC0, $40

SECTION "ROM from $02AB00", ROMX[$6B00], BANK[10]
; bank10_tiles_at_6b00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6B00:
    INCBIN "roms/magination.gbc", $2AB00, $40

SECTION "ROM from $02AB40", ROMX[$6B40], BANK[10]
; bank10_tiles_at_6b40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6B40:
    INCBIN "roms/magination.gbc", $2AB40, $40

SECTION "ROM from $02AB80", ROMX[$6B80], BANK[10]
; bank10_tiles_at_6b80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6B80:
    INCBIN "roms/magination.gbc", $2AB80, $40

SECTION "ROM from $02ABC0", ROMX[$6BC0], BANK[10]
; bank10_tiles_at_6bc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6BC0:
    INCBIN "roms/magination.gbc", $2ABC0, $40

SECTION "ROM from $02AC00", ROMX[$6C00], BANK[10]
; bank10_tiles_at_6c00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6C00:
    INCBIN "roms/magination.gbc", $2AC00, $40

SECTION "ROM from $02AC40", ROMX[$6C40], BANK[10]
; bank10_tiles_at_6c40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6C40:
    INCBIN "roms/magination.gbc", $2AC40, $40

SECTION "ROM from $02AC80", ROMX[$6C80], BANK[10]
; bank10_tiles_at_6c80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6C80:
    INCBIN "roms/magination.gbc", $2AC80, $40

SECTION "ROM from $02ACC0", ROMX[$6CC0], BANK[10]
; bank10_tiles_at_6cc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6CC0:
    INCBIN "roms/magination.gbc", $2ACC0, $40

SECTION "ROM from $02AD00", ROMX[$6D00], BANK[10]
; bank10_tiles_at_6d00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6D00:
    INCBIN "roms/magination.gbc", $2AD00, $40

SECTION "ROM from $02AD40", ROMX[$6D40], BANK[10]
; bank10_tiles_at_6d40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6D40:
    INCBIN "roms/magination.gbc", $2AD40, $40

SECTION "ROM from $02AD80", ROMX[$6D80], BANK[10]
; bank10_tiles_at_6d80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6D80:
    INCBIN "roms/magination.gbc", $2AD80, $40

SECTION "ROM from $02ADC0", ROMX[$6DC0], BANK[10]
; bank10_tiles_at_6dc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6DC0:
    INCBIN "roms/magination.gbc", $2ADC0, $40

SECTION "ROM from $02AE00", ROMX[$6E00], BANK[10]
; bank10_tiles_at_6e00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6E00:
    INCBIN "roms/magination.gbc", $2AE00, $40

SECTION "ROM from $02AE40", ROMX[$6E40], BANK[10]
; bank10_tiles_at_6e40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6E40:
    INCBIN "roms/magination.gbc", $2AE40, $40

SECTION "ROM from $02AE80", ROMX[$6E80], BANK[10]
; bank10_tiles_at_6e80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6E80:
    INCBIN "roms/magination.gbc", $2AE80, $40

SECTION "ROM from $02AEC0", ROMX[$6EC0], BANK[10]
; bank10_tiles_at_6ec0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6EC0:
    INCBIN "roms/magination.gbc", $2AEC0, $40

SECTION "ROM from $02AF00", ROMX[$6F00], BANK[10]
; bank10_tiles_at_6f00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6F00:
    INCBIN "roms/magination.gbc", $2AF00, $40

SECTION "ROM from $02AF40", ROMX[$6F40], BANK[10]
; bank10_tiles_at_6f40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6F40:
    INCBIN "roms/magination.gbc", $2AF40, $40

SECTION "ROM from $02AF80", ROMX[$6F80], BANK[10]
; bank10_tiles_at_6f80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6F80:
    INCBIN "roms/magination.gbc", $2AF80, $40

SECTION "ROM from $02AFC0", ROMX[$6FC0], BANK[10]
; bank10_tiles_at_6fc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt6FC0:
    INCBIN "roms/magination.gbc", $2AFC0, $40

SECTION "ROM from $02B000", ROMX[$7000], BANK[10]
; bank10_tiles_at_7000.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7000:
    INCBIN "roms/magination.gbc", $2B000, $40

SECTION "ROM from $02B040", ROMX[$7040], BANK[10]
; bank10_tiles_at_7040.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7040:
    INCBIN "roms/magination.gbc", $2B040, $40

SECTION "ROM from $02B080", ROMX[$7080], BANK[10]
; bank10_tiles_at_7080.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7080:
    INCBIN "roms/magination.gbc", $2B080, $40

SECTION "ROM from $02B0C0", ROMX[$70C0], BANK[10]
; bank10_tiles_at_70c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt70C0:
    INCBIN "roms/magination.gbc", $2B0C0, $40

SECTION "ROM from $02B100", ROMX[$7100], BANK[10]
; bank10_tiles_at_7100.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7100:
    INCBIN "roms/magination.gbc", $2B100, $40

SECTION "ROM from $02B140", ROMX[$7140], BANK[10]
; bank10_tiles_at_7140.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7140:
    INCBIN "roms/magination.gbc", $2B140, $40

SECTION "ROM from $02B180", ROMX[$7180], BANK[10]
; bank10_tiles_at_7180.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7180:
    INCBIN "roms/magination.gbc", $2B180, $40

SECTION "ROM from $02B1C0", ROMX[$71C0], BANK[10]
; bank10_tiles_at_71c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt71C0:
    INCBIN "roms/magination.gbc", $2B1C0, $40

SECTION "ROM from $02B200", ROMX[$7200], BANK[10]
; bank10_tiles_at_7200.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7200:
    INCBIN "roms/magination.gbc", $2B200, $40

SECTION "ROM from $02B240", ROMX[$7240], BANK[10]
; bank10_tiles_at_7240.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7240:
    INCBIN "roms/magination.gbc", $2B240, $40

SECTION "ROM from $02B280", ROMX[$7280], BANK[10]
; bank10_tiles_at_7280.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7280:
    INCBIN "roms/magination.gbc", $2B280, $40

SECTION "ROM from $02B2C0", ROMX[$72C0], BANK[10]
; bank10_tiles_at_72c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt72C0:
    INCBIN "roms/magination.gbc", $2B2C0, $40

SECTION "ROM from $02B300", ROMX[$7300], BANK[10]
; bank10_tiles_at_7300.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7300:
    INCBIN "roms/magination.gbc", $2B300, $40

SECTION "ROM from $02B340", ROMX[$7340], BANK[10]
; bank10_tiles_at_7340.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7340:
    INCBIN "roms/magination.gbc", $2B340, $40

SECTION "ROM from $02B380", ROMX[$7380], BANK[10]
; bank10_tiles_at_7380.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7380:
    INCBIN "roms/magination.gbc", $2B380, $40

SECTION "ROM from $02B3C0", ROMX[$73C0], BANK[10]
; bank10_tiles_at_73c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt73C0:
    INCBIN "roms/magination.gbc", $2B3C0, $40

SECTION "ROM from $02B400", ROMX[$7400], BANK[10]
; bank10_tiles_at_7400.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7400:
    INCBIN "roms/magination.gbc", $2B400, $40

SECTION "ROM from $02B440", ROMX[$7440], BANK[10]
; bank10_tiles_at_7440.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7440:
    INCBIN "roms/magination.gbc", $2B440, $40

SECTION "ROM from $02B480", ROMX[$7480], BANK[10]
; bank10_tiles_at_7480.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7480:
    INCBIN "roms/magination.gbc", $2B480, $40

SECTION "ROM from $02B4C0", ROMX[$74C0], BANK[10]
; bank10_tiles_at_74c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt74C0:
    INCBIN "roms/magination.gbc", $2B4C0, $40

SECTION "ROM from $02B500", ROMX[$7500], BANK[10]
; bank10_tiles_at_7500.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7500:
    INCBIN "roms/magination.gbc", $2B500, $40

SECTION "ROM from $02B540", ROMX[$7540], BANK[10]
; bank10_tiles_at_7540.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7540:
    INCBIN "roms/magination.gbc", $2B540, $40

SECTION "ROM from $02B580", ROMX[$7580], BANK[10]
; bank10_tiles_at_7580.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7580:
    INCBIN "roms/magination.gbc", $2B580, $40

SECTION "ROM from $02B5C0", ROMX[$75C0], BANK[10]
; bank10_tiles_at_75c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt75C0:
    INCBIN "roms/magination.gbc", $2B5C0, $40

SECTION "ROM from $02B600", ROMX[$7600], BANK[10]
; bank10_tiles_at_7600.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7600:
    INCBIN "roms/magination.gbc", $2B600, $40

SECTION "ROM from $02B640", ROMX[$7640], BANK[10]
; bank10_tiles_at_7640.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7640:
    INCBIN "roms/magination.gbc", $2B640, $40

SECTION "ROM from $02B680", ROMX[$7680], BANK[10]
; bank10_tiles_at_7680.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7680:
    INCBIN "roms/magination.gbc", $2B680, $40

SECTION "ROM from $02B6C0", ROMX[$76C0], BANK[10]
; bank10_tiles_at_76c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt76C0:
    INCBIN "roms/magination.gbc", $2B6C0, $40

SECTION "ROM from $02B700", ROMX[$7700], BANK[10]
; bank10_tiles_at_7700.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7700:
    INCBIN "roms/magination.gbc", $2B700, $40

SECTION "ROM from $02B740", ROMX[$7740], BANK[10]
; bank10_tiles_at_7740.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7740:
    INCBIN "roms/magination.gbc", $2B740, $40

SECTION "ROM from $02B780", ROMX[$7780], BANK[10]
; bank10_tiles_at_7780.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7780:
    INCBIN "roms/magination.gbc", $2B780, $40

SECTION "ROM from $02B7C0", ROMX[$77C0], BANK[10]
; bank10_tiles_at_77c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt77C0:
    INCBIN "roms/magination.gbc", $2B7C0, $40

SECTION "ROM from $02B800", ROMX[$7800], BANK[10]
; bank10_tiles_at_7800.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7800:
    INCBIN "roms/magination.gbc", $2B800, $40

SECTION "ROM from $02B840", ROMX[$7840], BANK[10]
; bank10_tiles_at_7840.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7840:
    INCBIN "roms/magination.gbc", $2B840, $40

SECTION "ROM from $02B880", ROMX[$7880], BANK[10]
; bank10_tiles_at_7880.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7880:
    INCBIN "roms/magination.gbc", $2B880, $40

SECTION "ROM from $02B8C0", ROMX[$78C0], BANK[10]
; bank10_tiles_at_78c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt78C0:
    INCBIN "roms/magination.gbc", $2B8C0, $40

SECTION "ROM from $02B900", ROMX[$7900], BANK[10]
; bank10_tiles_at_7900.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7900:
    INCBIN "roms/magination.gbc", $2B900, $40

SECTION "ROM from $02B940", ROMX[$7940], BANK[10]
; bank10_tiles_at_7940.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7940:
    INCBIN "roms/magination.gbc", $2B940, $40

SECTION "ROM from $02B980", ROMX[$7980], BANK[10]
; bank10_tiles_at_7980.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7980:
    INCBIN "roms/magination.gbc", $2B980, $40

SECTION "ROM from $02B9C0", ROMX[$79C0], BANK[10]
; bank10_tiles_at_79c0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt79C0:
    INCBIN "roms/magination.gbc", $2B9C0, $40

SECTION "ROM from $02BA00", ROMX[$7A00], BANK[10]
; bank10_tiles_at_7a00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7A00:
    INCBIN "roms/magination.gbc", $2BA00, $40

SECTION "ROM from $02BA40", ROMX[$7A40], BANK[10]
; bank10_tiles_at_7a40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7A40:
    INCBIN "roms/magination.gbc", $2BA40, $40

SECTION "ROM from $02BA80", ROMX[$7A80], BANK[10]
; bank10_tiles_at_7a80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7A80:
    INCBIN "roms/magination.gbc", $2BA80, $40

SECTION "ROM from $02BAC0", ROMX[$7AC0], BANK[10]
; bank10_tiles_at_7ac0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7AC0:
    INCBIN "roms/magination.gbc", $2BAC0, $40

SECTION "ROM from $02BB00", ROMX[$7B00], BANK[10]
; bank10_tiles_at_7b00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7B00:
    INCBIN "roms/magination.gbc", $2BB00, $40

SECTION "ROM from $02BB40", ROMX[$7B40], BANK[10]
; bank10_tiles_at_7b40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7B40:
    INCBIN "roms/magination.gbc", $2BB40, $40

SECTION "ROM from $02BB80", ROMX[$7B80], BANK[10]
; bank10_tiles_at_7b80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7B80:
    INCBIN "roms/magination.gbc", $2BB80, $40

SECTION "ROM from $02BBC0", ROMX[$7BC0], BANK[10]
; bank10_tiles_at_7bc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7BC0:
    INCBIN "roms/magination.gbc", $2BBC0, $40

SECTION "ROM from $02BC00", ROMX[$7C00], BANK[10]
; bank10_tiles_at_7c00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7C00:
    INCBIN "roms/magination.gbc", $2BC00, $40

SECTION "ROM from $02BC40", ROMX[$7C40], BANK[10]
; bank10_tiles_at_7c40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7C40:
    INCBIN "roms/magination.gbc", $2BC40, $40

SECTION "ROM from $02BC80", ROMX[$7C80], BANK[10]
; bank10_tiles_at_7c80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7C80:
    INCBIN "roms/magination.gbc", $2BC80, $40

SECTION "ROM from $02BCC0", ROMX[$7CC0], BANK[10]
; bank10_tiles_at_7cc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7CC0:
    INCBIN "roms/magination.gbc", $2BCC0, $40

SECTION "ROM from $02BD00", ROMX[$7D00], BANK[10]
; bank10_tiles_at_7d00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7D00:
    INCBIN "roms/magination.gbc", $2BD00, $40

SECTION "ROM from $02BD40", ROMX[$7D40], BANK[10]
; bank10_tiles_at_7d40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7D40:
    INCBIN "roms/magination.gbc", $2BD40, $40

SECTION "ROM from $02BD80", ROMX[$7D80], BANK[10]
; bank10_tiles_at_7d80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7D80:
    INCBIN "roms/magination.gbc", $2BD80, $40

SECTION "ROM from $02BDC0", ROMX[$7DC0], BANK[10]
; bank10_tiles_at_7dc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7DC0:
    INCBIN "roms/magination.gbc", $2BDC0, $40

SECTION "ROM from $02BE00", ROMX[$7E00], BANK[10]
; bank10_tiles_at_7e00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7E00:
    INCBIN "roms/magination.gbc", $2BE00, $40

SECTION "ROM from $02BE40", ROMX[$7E40], BANK[10]
; bank10_tiles_at_7e40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7E40:
    INCBIN "roms/magination.gbc", $2BE40, $40

SECTION "ROM from $02BE80", ROMX[$7E80], BANK[10]
; bank10_tiles_at_7e80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7E80:
    INCBIN "roms/magination.gbc", $2BE80, $40

SECTION "ROM from $02BEC0", ROMX[$7EC0], BANK[10]
; bank10_tiles_at_7ec0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7EC0:
    INCBIN "roms/magination.gbc", $2BEC0, $40

SECTION "ROM from $02BF00", ROMX[$7F00], BANK[10]
; bank10_tiles_at_7f00.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7F00:
    INCBIN "roms/magination.gbc", $2BF00, $40

SECTION "ROM from $02BF40", ROMX[$7F40], BANK[10]
; bank10_tiles_at_7f40.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7F40:
    INCBIN "roms/magination.gbc", $2BF40, $40

SECTION "ROM from $02BF80", ROMX[$7F80], BANK[10]
; bank10_tiles_at_7f80.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7F80:
    INCBIN "roms/magination.gbc", $2BF80, $40

SECTION "ROM from $02BFC0", ROMX[$7FC0], BANK[10]
; bank10_tiles_at_7fc0.asm: not published here (it assembles data copied from the ROM)
Bank10TilesAt7FC0:
    INCBIN "roms/magination.gbc", $2BFC0, $40

SECTION "ROM Bank 011", ROMX[$4000], BANK[11]
; bank11_tiles_at_4000.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4000:
    INCBIN "roms/magination.gbc", $2C000, $40

SECTION "ROM from $02C040", ROMX[$4040], BANK[11]
; bank11_tiles_at_4040.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4040:
    INCBIN "roms/magination.gbc", $2C040, $40

SECTION "ROM from $02C080", ROMX[$4080], BANK[11]
; bank11_tiles_at_4080.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4080:
    INCBIN "roms/magination.gbc", $2C080, $40

SECTION "ROM from $02C0C0", ROMX[$40C0], BANK[11]
; bank11_tiles_at_40c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt40C0:
    INCBIN "roms/magination.gbc", $2C0C0, $40

SECTION "ROM from $02C100", ROMX[$4100], BANK[11]
; bank11_tiles_at_4100.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4100:
    INCBIN "roms/magination.gbc", $2C100, $40

SECTION "ROM from $02C140", ROMX[$4140], BANK[11]
; bank11_tiles_at_4140.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4140:
    INCBIN "roms/magination.gbc", $2C140, $40

SECTION "ROM from $02C180", ROMX[$4180], BANK[11]
; bank11_tiles_at_4180.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4180:
    INCBIN "roms/magination.gbc", $2C180, $40

SECTION "ROM from $02C1C0", ROMX[$41C0], BANK[11]
; bank11_tiles_at_41c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt41C0:
    INCBIN "roms/magination.gbc", $2C1C0, $40

SECTION "ROM from $02C200", ROMX[$4200], BANK[11]
; bank11_tiles_at_4200.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4200:
    INCBIN "roms/magination.gbc", $2C200, $40

SECTION "ROM from $02C240", ROMX[$4240], BANK[11]
; bank11_tiles_at_4240.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4240:
    INCBIN "roms/magination.gbc", $2C240, $40

SECTION "ROM from $02C280", ROMX[$4280], BANK[11]
; bank11_tiles_at_4280.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4280:
    INCBIN "roms/magination.gbc", $2C280, $40

SECTION "ROM from $02C2C0", ROMX[$42C0], BANK[11]
; bank11_tiles_at_42c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt42C0:
    INCBIN "roms/magination.gbc", $2C2C0, $40

SECTION "ROM from $02C300", ROMX[$4300], BANK[11]
; bank11_tiles_at_4300.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4300:
    INCBIN "roms/magination.gbc", $2C300, $40

SECTION "ROM from $02C340", ROMX[$4340], BANK[11]
; bank11_tiles_at_4340.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4340:
    INCBIN "roms/magination.gbc", $2C340, $40

SECTION "ROM from $02C380", ROMX[$4380], BANK[11]
; bank11_tiles_at_4380.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4380:
    INCBIN "roms/magination.gbc", $2C380, $40

SECTION "ROM from $02C3C0", ROMX[$43C0], BANK[11]
; bank11_tiles_at_43c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt43C0:
    INCBIN "roms/magination.gbc", $2C3C0, $40

SECTION "ROM from $02C400", ROMX[$4400], BANK[11]
; bank11_tiles_at_4400.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4400:
    INCBIN "roms/magination.gbc", $2C400, $40

SECTION "ROM from $02C440", ROMX[$4440], BANK[11]
; bank11_tiles_at_4440.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4440:
    INCBIN "roms/magination.gbc", $2C440, $40

SECTION "ROM from $02C480", ROMX[$4480], BANK[11]
; bank11_tiles_at_4480.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4480:
    INCBIN "roms/magination.gbc", $2C480, $40

SECTION "ROM from $02C4C0", ROMX[$44C0], BANK[11]
; bank11_tiles_at_44c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt44C0:
    INCBIN "roms/magination.gbc", $2C4C0, $40

SECTION "ROM from $02C500", ROMX[$4500], BANK[11]
; bank11_tiles_at_4500.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt44C0End:
Bank11TilesAt4500:
    INCBIN "roms/magination.gbc", $2C500, $40

SECTION "ROM from $02C540", ROMX[$4540], BANK[11]
; bank11_tiles_at_4540.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4500End:
Bank11TilesAt4540:
    INCBIN "roms/magination.gbc", $2C540, $40

SECTION "ROM from $02C580", ROMX[$4580], BANK[11]
; bank11_tiles_at_4580.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4540End:
Bank11TilesAt4580:
    INCBIN "roms/magination.gbc", $2C580, $40

SECTION "ROM from $02C5C0", ROMX[$45C0], BANK[11]
; bank11_tiles_at_45c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4580End:
Bank11TilesAt45C0:
    INCBIN "roms/magination.gbc", $2C5C0, $40

SECTION "ROM from $02C600", ROMX[$4600], BANK[11]
; bank11_tiles_at_4600.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt45C0End:
Bank11TilesAt4600:
    INCBIN "roms/magination.gbc", $2C600, $40

SECTION "ROM from $02C640", ROMX[$4640], BANK[11]
; bank11_tiles_at_4640.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4600End:
Bank11TilesAt4640:
    INCBIN "roms/magination.gbc", $2C640, $40

SECTION "ROM from $02C680", ROMX[$4680], BANK[11]
; bank11_tiles_at_4680.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4640End:
Bank11TilesAt4680:
    INCBIN "roms/magination.gbc", $2C680, $40

SECTION "ROM from $02C6C0", ROMX[$46C0], BANK[11]
; bank11_tiles_at_46c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4680End:
Bank11TilesAt46C0:
    INCBIN "roms/magination.gbc", $2C6C0, $40

SECTION "ROM from $02C700", ROMX[$4700], BANK[11]
; bank11_tiles_at_4700.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4700:
    INCBIN "roms/magination.gbc", $2C700, $40

SECTION "ROM from $02C740", ROMX[$4740], BANK[11]
; bank11_tiles_at_4740.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4740:
    INCBIN "roms/magination.gbc", $2C740, $40

SECTION "ROM from $02C780", ROMX[$4780], BANK[11]
; bank11_tiles_at_4780.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4780:
    INCBIN "roms/magination.gbc", $2C780, $40

SECTION "ROM from $02C7C0", ROMX[$47C0], BANK[11]
; bank11_tiles_at_47c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4780End:
Bank11TilesAt47C0:
    INCBIN "roms/magination.gbc", $2C7C0, $40

SECTION "ROM from $02C800", ROMX[$4800], BANK[11]
; bank11_tiles_at_4800.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt47C0End:
Bank11TilesAt4800:
    INCBIN "roms/magination.gbc", $2C800, $40

SECTION "ROM from $02C840", ROMX[$4840], BANK[11]
; bank11_tiles_at_4840.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4800End:
Bank11TilesAt4840:
    INCBIN "roms/magination.gbc", $2C840, $40

SECTION "ROM from $02C880", ROMX[$4880], BANK[11]
; bank11_tiles_at_4880.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4840End:
Bank11TilesAt4880:
    INCBIN "roms/magination.gbc", $2C880, $40

SECTION "ROM from $02C8C0", ROMX[$48C0], BANK[11]
; bank11_tiles_at_48c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4880End:
Bank11TilesAt48C0:
    INCBIN "roms/magination.gbc", $2C8C0, $40

SECTION "ROM from $02C900", ROMX[$4900], BANK[11]
; bank11_tiles_at_4900.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt48C0End:
Bank11TilesAt4900:
    INCBIN "roms/magination.gbc", $2C900, $40

SECTION "ROM from $02C940", ROMX[$4940], BANK[11]
; bank11_tiles_at_4940.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4900End:
Bank11TilesAt4940:
    INCBIN "roms/magination.gbc", $2C940, $40

SECTION "ROM from $02C980", ROMX[$4980], BANK[11]
; bank11_tiles_at_4980.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4940End:
Bank11TilesAt4980:
    INCBIN "roms/magination.gbc", $2C980, $40

SECTION "ROM from $02C9C0", ROMX[$49C0], BANK[11]
; bank11_tiles_at_49c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4980End:
Bank11TilesAt49C0:
    INCBIN "roms/magination.gbc", $2C9C0, $40

SECTION "ROM from $02CA00", ROMX[$4A00], BANK[11]
; bank11_tiles_at_4a00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt49C0End:
Bank11TilesAt4A00:
    INCBIN "roms/magination.gbc", $2CA00, $40

SECTION "ROM from $02CA40", ROMX[$4A40], BANK[11]
; bank11_tiles_at_4a40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4A00End:
Bank11TilesAt4A40:
    INCBIN "roms/magination.gbc", $2CA40, $40

SECTION "ROM from $02CA80", ROMX[$4A80], BANK[11]
; bank11_tiles_at_4a80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4A40End:
Bank11TilesAt4A80:
    INCBIN "roms/magination.gbc", $2CA80, $40

SECTION "ROM from $02CAC0", ROMX[$4AC0], BANK[11]
; bank11_tiles_at_4ac0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4A80End:
Bank11TilesAt4AC0:
    INCBIN "roms/magination.gbc", $2CAC0, $40

SECTION "ROM from $02CB00", ROMX[$4B00], BANK[11]
; bank11_tiles_at_4b00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4B00:
    INCBIN "roms/magination.gbc", $2CB00, $40

SECTION "ROM from $02CB40", ROMX[$4B40], BANK[11]
; bank11_tiles_at_4b40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4B00End:
Bank11TilesAt4B40:
    INCBIN "roms/magination.gbc", $2CB40, $40

SECTION "ROM from $02CB80", ROMX[$4B80], BANK[11]
; bank11_tiles_at_4b80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4B40End:
Bank11TilesAt4B80:
    INCBIN "roms/magination.gbc", $2CB80, $40

SECTION "ROM from $02CBC0", ROMX[$4BC0], BANK[11]
; bank11_tiles_at_4bc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4B80End:
Bank11TilesAt4BC0:
    INCBIN "roms/magination.gbc", $2CBC0, $40

SECTION "ROM from $02CC00", ROMX[$4C00], BANK[11]
; bank11_tiles_at_4c00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4BC0End:
Bank11TilesAt4C00:
    INCBIN "roms/magination.gbc", $2CC00, $40

SECTION "ROM from $02CC40", ROMX[$4C40], BANK[11]
; bank11_tiles_at_4c40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4C00End:
Bank11TilesAt4C40:
    INCBIN "roms/magination.gbc", $2CC40, $40

SECTION "ROM from $02CC80", ROMX[$4C80], BANK[11]
; bank11_tiles_at_4c80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4C40End:
Bank11TilesAt4C80:
    INCBIN "roms/magination.gbc", $2CC80, $40

SECTION "ROM from $02CCC0", ROMX[$4CC0], BANK[11]
; bank11_tiles_at_4cc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4C80End:
Bank11TilesAt4CC0:
    INCBIN "roms/magination.gbc", $2CCC0, $40

SECTION "ROM from $02CD00", ROMX[$4D00], BANK[11]
; bank11_tiles_at_4d00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4CC0End:
Bank11TilesAt4D00:
    INCBIN "roms/magination.gbc", $2CD00, $40

SECTION "ROM from $02CD40", ROMX[$4D40], BANK[11]
; bank11_tiles_at_4d40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4D00End:
Bank11TilesAt4D40:
    INCBIN "roms/magination.gbc", $2CD40, $40

SECTION "ROM from $02CD80", ROMX[$4D80], BANK[11]
; bank11_tiles_at_4d80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4D40End:
Bank11TilesAt4D80:
    INCBIN "roms/magination.gbc", $2CD80, $40

SECTION "ROM from $02CDC0", ROMX[$4DC0], BANK[11]
; bank11_tiles_at_4dc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4D80End:
Bank11TilesAt4DC0:
    INCBIN "roms/magination.gbc", $2CDC0, $40

SECTION "ROM from $02CE00", ROMX[$4E00], BANK[11]
; bank11_tiles_at_4e00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4DC0End:
Bank11TilesAt4E00:
    INCBIN "roms/magination.gbc", $2CE00, $40

SECTION "ROM from $02CE40", ROMX[$4E40], BANK[11]
; bank11_tiles_at_4e40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4E00End:
Bank11TilesAt4E40:
    INCBIN "roms/magination.gbc", $2CE40, $40

SECTION "ROM from $02CE80", ROMX[$4E80], BANK[11]
; bank11_tiles_at_4e80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4E40End:
Bank11TilesAt4E80:
    INCBIN "roms/magination.gbc", $2CE80, $40

SECTION "ROM from $02CEC0", ROMX[$4EC0], BANK[11]
; bank11_tiles_at_4ec0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4E80End:
Bank11TilesAt4EC0:
    INCBIN "roms/magination.gbc", $2CEC0, $40

SECTION "ROM from $02CF00", ROMX[$4F00], BANK[11]
; bank11_tiles_at_4f00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4F00:
    INCBIN "roms/magination.gbc", $2CF00, $40

SECTION "ROM from $02CF40", ROMX[$4F40], BANK[11]
; bank11_tiles_at_4f40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4F40:
    INCBIN "roms/magination.gbc", $2CF40, $40

SECTION "ROM from $02CF80", ROMX[$4F80], BANK[11]
; bank11_tiles_at_4f80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4F80:
    INCBIN "roms/magination.gbc", $2CF80, $40

SECTION "ROM from $02CFC0", ROMX[$4FC0], BANK[11]
; bank11_tiles_at_4fc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt4FC0:
    INCBIN "roms/magination.gbc", $2CFC0, $40

SECTION "ROM from $02D000", ROMX[$5000], BANK[11]
; bank11_tiles_at_5000.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5000:
    INCBIN "roms/magination.gbc", $2D000, $40

SECTION "ROM from $02D040", ROMX[$5040], BANK[11]
; bank11_tiles_at_5040.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5040:
    INCBIN "roms/magination.gbc", $2D040, $40

SECTION "ROM from $02D080", ROMX[$5080], BANK[11]
; bank11_tiles_at_5080.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5040End:
Bank11TilesAt5080:
    INCBIN "roms/magination.gbc", $2D080, $40

SECTION "ROM from $02D0C0", ROMX[$50C0], BANK[11]
; bank11_tiles_at_50c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5080End:
Bank11TilesAt50C0:
    INCBIN "roms/magination.gbc", $2D0C0, $40

SECTION "ROM from $02D100", ROMX[$5100], BANK[11]
; bank11_tiles_at_5100.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt50C0End:
Bank11TilesAt5100:
    INCBIN "roms/magination.gbc", $2D100, $40

SECTION "ROM from $02D140", ROMX[$5140], BANK[11]
; bank11_tiles_at_5140.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5100End:
Bank11TilesAt5140:
    INCBIN "roms/magination.gbc", $2D140, $40

SECTION "ROM from $02D180", ROMX[$5180], BANK[11]
; bank11_tiles_at_5180.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5140End:
Bank11TilesAt5180:
    INCBIN "roms/magination.gbc", $2D180, $40

SECTION "ROM from $02D1C0", ROMX[$51C0], BANK[11]
; bank11_tiles_at_51c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5180End:
Bank11TilesAt51C0:
    INCBIN "roms/magination.gbc", $2D1C0, $40

SECTION "ROM from $02D200", ROMX[$5200], BANK[11]
; bank11_tiles_at_5200.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt51C0End:
Bank11TilesAt5200:
    INCBIN "roms/magination.gbc", $2D200, $40

SECTION "ROM from $02D240", ROMX[$5240], BANK[11]
; bank11_tiles_at_5240.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5200End:
Bank11TilesAt5240:
    INCBIN "roms/magination.gbc", $2D240, $40

SECTION "ROM from $02D280", ROMX[$5280], BANK[11]
; bank11_tiles_at_5280.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5240End:
Bank11TilesAt5280:
    INCBIN "roms/magination.gbc", $2D280, $40

SECTION "ROM from $02D2C0", ROMX[$52C0], BANK[11]
; bank11_tiles_at_52c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5280End:
Bank11TilesAt52C0:
    INCBIN "roms/magination.gbc", $2D2C0, $40

SECTION "ROM from $02D300", ROMX[$5300], BANK[11]
; bank11_tiles_at_5300.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5300:
    INCBIN "roms/magination.gbc", $2D300, $40

SECTION "ROM from $02D340", ROMX[$5340], BANK[11]
; bank11_tiles_at_5340.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5300End:
Bank11TilesAt5340:
    INCBIN "roms/magination.gbc", $2D340, $40

SECTION "ROM from $02D380", ROMX[$5380], BANK[11]
; bank11_tiles_at_5380.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5340End:
Bank11TilesAt5380:
    INCBIN "roms/magination.gbc", $2D380, $40

SECTION "ROM from $02D3C0", ROMX[$53C0], BANK[11]
; bank11_tiles_at_53c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5380End:
Bank11TilesAt53C0:
    INCBIN "roms/magination.gbc", $2D3C0, $40

SECTION "ROM from $02D400", ROMX[$5400], BANK[11]
; bank11_tiles_at_5400.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt53C0End:
Bank11TilesAt5400:
    INCBIN "roms/magination.gbc", $2D400, $40

SECTION "ROM from $02D440", ROMX[$5440], BANK[11]
; bank11_tiles_at_5440.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5400End:
Bank11TilesAt5440:
    INCBIN "roms/magination.gbc", $2D440, $40

SECTION "ROM from $02D480", ROMX[$5480], BANK[11]
; bank11_tiles_at_5480.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5440End:
Bank11TilesAt5480:
    INCBIN "roms/magination.gbc", $2D480, $40

SECTION "ROM from $02D4C0", ROMX[$54C0], BANK[11]
; bank11_tiles_at_54c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5480End:
Bank11TilesAt54C0:
    INCBIN "roms/magination.gbc", $2D4C0, $40

SECTION "ROM from $02D500", ROMX[$5500], BANK[11]
; bank11_tiles_at_5500.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt54C0End:
Bank11TilesAt5500:
    INCBIN "roms/magination.gbc", $2D500, $40

SECTION "ROM from $02D540", ROMX[$5540], BANK[11]
; bank11_tiles_at_5540.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5500End:
Bank11TilesAt5540:
    INCBIN "roms/magination.gbc", $2D540, $40

SECTION "ROM from $02D580", ROMX[$5580], BANK[11]
; bank11_tiles_at_5580.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5540End:
Bank11TilesAt5580:
    INCBIN "roms/magination.gbc", $2D580, $40

SECTION "ROM from $02D5C0", ROMX[$55C0], BANK[11]
; bank11_tiles_at_55c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5580End:
Bank11TilesAt55C0:
    INCBIN "roms/magination.gbc", $2D5C0, $40

SECTION "ROM from $02D600", ROMX[$5600], BANK[11]
; bank11_tiles_at_5600.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt55C0End:
Bank11TilesAt5600:
    INCBIN "roms/magination.gbc", $2D600, $40

SECTION "ROM from $02D640", ROMX[$5640], BANK[11]
; bank11_tiles_at_5640.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5600End:
Bank11TilesAt5640:
    INCBIN "roms/magination.gbc", $2D640, $40

SECTION "ROM from $02D680", ROMX[$5680], BANK[11]
; bank11_tiles_at_5680.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5640End:
Bank11TilesAt5680:
    INCBIN "roms/magination.gbc", $2D680, $40

SECTION "ROM from $02D6C0", ROMX[$56C0], BANK[11]
; bank11_tiles_at_56c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5680End:
Bank11TilesAt56C0:
    INCBIN "roms/magination.gbc", $2D6C0, $40

SECTION "ROM from $02D700", ROMX[$5700], BANK[11]
; bank11_tiles_at_5700.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5700:
    INCBIN "roms/magination.gbc", $2D700, $40

SECTION "ROM from $02D740", ROMX[$5740], BANK[11]
; bank11_tiles_at_5740.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5740:
    INCBIN "roms/magination.gbc", $2D740, $40

SECTION "ROM from $02D780", ROMX[$5780], BANK[11]
; bank11_tiles_at_5780.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5780:
    INCBIN "roms/magination.gbc", $2D780, $40

SECTION "ROM from $02D7C0", ROMX[$57C0], BANK[11]
; bank11_tiles_at_57c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5780End:
Bank11TilesAt57C0:
    INCBIN "roms/magination.gbc", $2D7C0, $40

SECTION "ROM from $02D800", ROMX[$5800], BANK[11]
; bank11_tiles_at_5800.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt57C0End:
Bank11TilesAt5800:
    INCBIN "roms/magination.gbc", $2D800, $40

SECTION "ROM from $02D840", ROMX[$5840], BANK[11]
; bank11_tiles_at_5840.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5800End:
Bank11TilesAt5840:
    INCBIN "roms/magination.gbc", $2D840, $40

SECTION "ROM from $02D880", ROMX[$5880], BANK[11]
; bank11_tiles_at_5880.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5840End:
Bank11TilesAt5880:
    INCBIN "roms/magination.gbc", $2D880, $40

SECTION "ROM from $02D8C0", ROMX[$58C0], BANK[11]
; bank11_tiles_at_58c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5880End:
Bank11TilesAt58C0:
    INCBIN "roms/magination.gbc", $2D8C0, $40

SECTION "ROM from $02D900", ROMX[$5900], BANK[11]
; bank11_tiles_at_5900.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt58C0End:
Bank11TilesAt5900:
    INCBIN "roms/magination.gbc", $2D900, $40

SECTION "ROM from $02D940", ROMX[$5940], BANK[11]
; bank11_tiles_at_5940.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5900End:
Bank11TilesAt5940:
    INCBIN "roms/magination.gbc", $2D940, $40

SECTION "ROM from $02D980", ROMX[$5980], BANK[11]
; bank11_tiles_at_5980.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5940End:
Bank11TilesAt5980:
    INCBIN "roms/magination.gbc", $2D980, $40

SECTION "ROM from $02D9C0", ROMX[$59C0], BANK[11]
; bank11_tiles_at_59c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5980End:
Bank11TilesAt59C0:
    INCBIN "roms/magination.gbc", $2D9C0, $40

SECTION "ROM from $02DA00", ROMX[$5A00], BANK[11]
; bank11_tiles_at_5a00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt59C0End:
Bank11TilesAt5A00:
    INCBIN "roms/magination.gbc", $2DA00, $40

SECTION "ROM from $02DA40", ROMX[$5A40], BANK[11]
; bank11_tiles_at_5a40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5A00End:
Bank11TilesAt5A40:
    INCBIN "roms/magination.gbc", $2DA40, $40

SECTION "ROM from $02DA80", ROMX[$5A80], BANK[11]
; bank11_tiles_at_5a80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5A40End:
Bank11TilesAt5A80:
    INCBIN "roms/magination.gbc", $2DA80, $40

SECTION "ROM from $02DAC0", ROMX[$5AC0], BANK[11]
; bank11_tiles_at_5ac0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5A80End:
Bank11TilesAt5AC0:
    INCBIN "roms/magination.gbc", $2DAC0, $40

SECTION "ROM from $02DB00", ROMX[$5B00], BANK[11]
; bank11_tiles_at_5b00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5AC0End:
Bank11TilesAt5B00:
    INCBIN "roms/magination.gbc", $2DB00, $40

SECTION "ROM from $02DB40", ROMX[$5B40], BANK[11]
; bank11_tiles_at_5b40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5B00End:
Bank11TilesAt5B40:
    INCBIN "roms/magination.gbc", $2DB40, $40

SECTION "ROM from $02DB80", ROMX[$5B80], BANK[11]
; bank11_tiles_at_5b80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5B80:
    INCBIN "roms/magination.gbc", $2DB80, $40

SECTION "ROM from $02DBC0", ROMX[$5BC0], BANK[11]
; bank11_tiles_at_5bc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5B80End:
Bank11TilesAt5BC0:
    INCBIN "roms/magination.gbc", $2DBC0, $40

SECTION "ROM from $02DC00", ROMX[$5C00], BANK[11]
; bank11_tiles_at_5c00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5BC0End:
Bank11TilesAt5C00:
    INCBIN "roms/magination.gbc", $2DC00, $40

SECTION "ROM from $02DC40", ROMX[$5C40], BANK[11]
; bank11_tiles_at_5c40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5C00End:
Bank11TilesAt5C40:
    INCBIN "roms/magination.gbc", $2DC40, $40

SECTION "ROM from $02DC80", ROMX[$5C80], BANK[11]
; bank11_tiles_at_5c80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5C40End:
Bank11TilesAt5C80:
    INCBIN "roms/magination.gbc", $2DC80, $40

SECTION "ROM from $02DCC0", ROMX[$5CC0], BANK[11]
; bank11_tiles_at_5cc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5C80End:
Bank11TilesAt5CC0:
    INCBIN "roms/magination.gbc", $2DCC0, $40

SECTION "ROM from $02DD00", ROMX[$5D00], BANK[11]
; bank11_tiles_at_5d00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5CC0End:
Bank11TilesAt5D00:
    INCBIN "roms/magination.gbc", $2DD00, $40

SECTION "ROM from $02DD40", ROMX[$5D40], BANK[11]
; bank11_tiles_at_5d40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5D00End:
Bank11TilesAt5D40:
    INCBIN "roms/magination.gbc", $2DD40, $40

SECTION "ROM from $02DD80", ROMX[$5D80], BANK[11]
; bank11_tiles_at_5d80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5D40End:
Bank11TilesAt5D80:
    INCBIN "roms/magination.gbc", $2DD80, $40

SECTION "ROM from $02DDC0", ROMX[$5DC0], BANK[11]
; bank11_tiles_at_5dc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5D80End:
Bank11TilesAt5DC0:
    INCBIN "roms/magination.gbc", $2DDC0, $40

SECTION "ROM from $02DE00", ROMX[$5E00], BANK[11]
; bank11_tiles_at_5e00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5DC0End:
Bank11TilesAt5E00:
    INCBIN "roms/magination.gbc", $2DE00, $40

SECTION "ROM from $02DE40", ROMX[$5E40], BANK[11]
; bank11_tiles_at_5e40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5E00End:
Bank11TilesAt5E40:
    INCBIN "roms/magination.gbc", $2DE40, $40

SECTION "ROM from $02DE80", ROMX[$5E80], BANK[11]
; bank11_tiles_at_5e80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5E40End:
Bank11TilesAt5E80:
    INCBIN "roms/magination.gbc", $2DE80, $40

SECTION "ROM from $02DEC0", ROMX[$5EC0], BANK[11]
; bank11_tiles_at_5ec0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5E80End:
Bank11TilesAt5EC0:
    INCBIN "roms/magination.gbc", $2DEC0, $40

SECTION "ROM from $02DF00", ROMX[$5F00], BANK[11]
; bank11_tiles_at_5f00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5EC0End:
Bank11TilesAt5F00:
    INCBIN "roms/magination.gbc", $2DF00, $40

SECTION "ROM from $02DF40", ROMX[$5F40], BANK[11]
; bank11_tiles_at_5f40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5F00End:
Bank11TilesAt5F40:
    INCBIN "roms/magination.gbc", $2DF40, $40

SECTION "ROM from $02DF80", ROMX[$5F80], BANK[11]
; bank11_tiles_at_5f80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5F80:
    INCBIN "roms/magination.gbc", $2DF80, $40

SECTION "ROM from $02DFC0", ROMX[$5FC0], BANK[11]
; bank11_tiles_at_5fc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5F80End:
Bank11TilesAt5FC0:
    INCBIN "roms/magination.gbc", $2DFC0, $40

SECTION "ROM from $02E000", ROMX[$6000], BANK[11]
; bank11_tiles_at_6000.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt5FC0End:
Bank11TilesAt6000:
    INCBIN "roms/magination.gbc", $2E000, $40

SECTION "ROM from $02E040", ROMX[$6040], BANK[11]
; bank11_tiles_at_6040.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6000End:
Bank11TilesAt6040:
    INCBIN "roms/magination.gbc", $2E040, $40

SECTION "ROM from $02E080", ROMX[$6080], BANK[11]
; bank11_tiles_at_6080.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6040End:
Bank11TilesAt6080:
    INCBIN "roms/magination.gbc", $2E080, $40

SECTION "ROM from $02E0C0", ROMX[$60C0], BANK[11]
; bank11_tiles_at_60c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6080End:
Bank11TilesAt60C0:
    INCBIN "roms/magination.gbc", $2E0C0, $40

SECTION "ROM from $02E100", ROMX[$6100], BANK[11]
; bank11_tiles_at_6100.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt60C0End:
Bank11TilesAt6100:
    INCBIN "roms/magination.gbc", $2E100, $40

SECTION "ROM from $02E140", ROMX[$6140], BANK[11]
; bank11_tiles_at_6140.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6100End:
Bank11TilesAt6140:
    INCBIN "roms/magination.gbc", $2E140, $40

SECTION "ROM from $02E180", ROMX[$6180], BANK[11]
; bank11_tiles_at_6180.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6140End:
Bank11TilesAt6180:
    INCBIN "roms/magination.gbc", $2E180, $40

SECTION "ROM from $02E1C0", ROMX[$61C0], BANK[11]
; bank11_tiles_at_61c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6180End:
Bank11TilesAt61C0:
    INCBIN "roms/magination.gbc", $2E1C0, $40

SECTION "ROM from $02E200", ROMX[$6200], BANK[11]
; bank11_tiles_at_6200.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt61C0End:
Bank11TilesAt6200:
    INCBIN "roms/magination.gbc", $2E200, $40

SECTION "ROM from $02E240", ROMX[$6240], BANK[11]
; bank11_tiles_at_6240.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6200End:
Bank11TilesAt6240:
    INCBIN "roms/magination.gbc", $2E240, $40

SECTION "ROM from $02E280", ROMX[$6280], BANK[11]
; bank11_tiles_at_6280.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6240End:
Bank11TilesAt6280:
    INCBIN "roms/magination.gbc", $2E280, $40

SECTION "ROM from $02E2C0", ROMX[$62C0], BANK[11]
; bank11_tiles_at_62c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6280End:
Bank11TilesAt62C0:
    INCBIN "roms/magination.gbc", $2E2C0, $40

SECTION "ROM from $02E300", ROMX[$6300], BANK[11]
; bank11_tiles_at_6300.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt62C0End:
Bank11TilesAt6300:
    INCBIN "roms/magination.gbc", $2E300, $40

SECTION "ROM from $02E340", ROMX[$6340], BANK[11]
; bank11_tiles_at_6340.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6300End:
Bank11TilesAt6340:
    INCBIN "roms/magination.gbc", $2E340, $40

SECTION "ROM from $02E380", ROMX[$6380], BANK[11]
; bank11_tiles_at_6380.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6340End:
Bank11TilesAt6380:
    INCBIN "roms/magination.gbc", $2E380, $40

SECTION "ROM from $02E3C0", ROMX[$63C0], BANK[11]
; bank11_tiles_at_63c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6380End:
Bank11TilesAt63C0:
    INCBIN "roms/magination.gbc", $2E3C0, $40

SECTION "ROM from $02E400", ROMX[$6400], BANK[11]
; bank11_tiles_at_6400.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt63C0End:
Bank11TilesAt6400:
    INCBIN "roms/magination.gbc", $2E400, $40

SECTION "ROM from $02E440", ROMX[$6440], BANK[11]
; bank11_tiles_at_6440.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6400End:
Bank11TilesAt6440:
    INCBIN "roms/magination.gbc", $2E440, $40

SECTION "ROM from $02E480", ROMX[$6480], BANK[11]
; bank11_tiles_at_6480.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6440End:
Bank11TilesAt6480:
    INCBIN "roms/magination.gbc", $2E480, $40

SECTION "ROM from $02E4C0", ROMX[$64C0], BANK[11]
; bank11_tiles_at_64c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6480End:
Bank11TilesAt64C0:
    INCBIN "roms/magination.gbc", $2E4C0, $40

SECTION "ROM from $02E500", ROMX[$6500], BANK[11]
; bank11_tiles_at_6500.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt64C0End:
Bank11TilesAt6500:
    INCBIN "roms/magination.gbc", $2E500, $40

SECTION "ROM from $02E540", ROMX[$6540], BANK[11]
; bank11_tiles_at_6540.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6500End:
Bank11TilesAt6540:
    INCBIN "roms/magination.gbc", $2E540, $40

SECTION "ROM from $02E580", ROMX[$6580], BANK[11]
; bank11_tiles_at_6580.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6540End:
Bank11TilesAt6580:
    INCBIN "roms/magination.gbc", $2E580, $40

SECTION "ROM from $02E5C0", ROMX[$65C0], BANK[11]
; bank11_tiles_at_65c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6580End:
Bank11TilesAt65C0:
    INCBIN "roms/magination.gbc", $2E5C0, $40

SECTION "ROM from $02E600", ROMX[$6600], BANK[11]
; bank11_tiles_at_6600.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt65C0End:
Bank11TilesAt6600:
    INCBIN "roms/magination.gbc", $2E600, $40

SECTION "ROM from $02E640", ROMX[$6640], BANK[11]
; bank11_tiles_at_6640.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6600End:
Bank11TilesAt6640:
    INCBIN "roms/magination.gbc", $2E640, $40

SECTION "ROM from $02E680", ROMX[$6680], BANK[11]
; bank11_tiles_at_6680.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6640End:
Bank11TilesAt6680:
    INCBIN "roms/magination.gbc", $2E680, $40

SECTION "ROM from $02E6C0", ROMX[$66C0], BANK[11]
; bank11_tiles_at_66c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6680End:
Bank11TilesAt66C0:
    INCBIN "roms/magination.gbc", $2E6C0, $40

SECTION "ROM from $02E700", ROMX[$6700], BANK[11]
; bank11_tiles_at_6700.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt66C0End:
Bank11TilesAt6700:
    INCBIN "roms/magination.gbc", $2E700, $40

SECTION "ROM from $02E740", ROMX[$6740], BANK[11]
; bank11_tiles_at_6740.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6700End:
Bank11TilesAt6740:
    INCBIN "roms/magination.gbc", $2E740, $40

SECTION "ROM from $02E780", ROMX[$6780], BANK[11]
; bank11_tiles_at_6780.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6740End:
Bank11TilesAt6780:
    INCBIN "roms/magination.gbc", $2E780, $40

SECTION "ROM from $02E7C0", ROMX[$67C0], BANK[11]
; bank11_tiles_at_67c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6780End:
Bank11TilesAt67C0:
    INCBIN "roms/magination.gbc", $2E7C0, $40

SECTION "ROM from $02E800", ROMX[$6800], BANK[11]
; bank11_tiles_at_6800.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt67C0End:
Bank11TilesAt6800:
    INCBIN "roms/magination.gbc", $2E800, $40

SECTION "ROM from $02E840", ROMX[$6840], BANK[11]
; bank11_tiles_at_6840.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6800End:
Bank11TilesAt6840:
    INCBIN "roms/magination.gbc", $2E840, $40

SECTION "ROM from $02E880", ROMX[$6880], BANK[11]
; bank11_tiles_at_6880.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6840End:
Bank11TilesAt6880:
    INCBIN "roms/magination.gbc", $2E880, $40

SECTION "ROM from $02E8C0", ROMX[$68C0], BANK[11]
; bank11_tiles_at_68c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6880End:
Bank11TilesAt68C0:
    INCBIN "roms/magination.gbc", $2E8C0, $40

SECTION "ROM from $02E900", ROMX[$6900], BANK[11]
; bank11_tiles_at_6900.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt68C0End:
Bank11TilesAt6900:
    INCBIN "roms/magination.gbc", $2E900, $40

SECTION "ROM from $02E940", ROMX[$6940], BANK[11]
; bank11_tiles_at_6940.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6900End:
Bank11TilesAt6940:
    INCBIN "roms/magination.gbc", $2E940, $40

SECTION "ROM from $02E980", ROMX[$6980], BANK[11]
; bank11_tiles_at_6980.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6940End:
Bank11TilesAt6980:
    INCBIN "roms/magination.gbc", $2E980, $40

SECTION "ROM from $02E9C0", ROMX[$69C0], BANK[11]
; bank11_tiles_at_69c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6980End:
Bank11TilesAt69C0:
    INCBIN "roms/magination.gbc", $2E9C0, $40

SECTION "ROM from $02EA00", ROMX[$6A00], BANK[11]
; bank11_tiles_at_6a00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt69C0End:
Bank11TilesAt6A00:
    INCBIN "roms/magination.gbc", $2EA00, $40

SECTION "ROM from $02EA40", ROMX[$6A40], BANK[11]
; bank11_tiles_at_6a40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6A00End:
Bank11TilesAt6A40:
    INCBIN "roms/magination.gbc", $2EA40, $40

SECTION "ROM from $02EA80", ROMX[$6A80], BANK[11]
; bank11_tiles_at_6a80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6A40End:
Bank11TilesAt6A80:
    INCBIN "roms/magination.gbc", $2EA80, $40

SECTION "ROM from $02EAC0", ROMX[$6AC0], BANK[11]
; bank11_tiles_at_6ac0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6A80End:
Bank11TilesAt6AC0:
    INCBIN "roms/magination.gbc", $2EAC0, $40

SECTION "ROM from $02EB00", ROMX[$6B00], BANK[11]
; bank11_tiles_at_6b00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6AC0End:
Bank11TilesAt6B00:
    INCBIN "roms/magination.gbc", $2EB00, $40

SECTION "ROM from $02EB40", ROMX[$6B40], BANK[11]
; bank11_tiles_at_6b40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6B00End:
Bank11TilesAt6B40:
    INCBIN "roms/magination.gbc", $2EB40, $40

SECTION "ROM from $02EB80", ROMX[$6B80], BANK[11]
; bank11_tiles_at_6b80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6B40End:
Bank11TilesAt6B80:
    INCBIN "roms/magination.gbc", $2EB80, $40

SECTION "ROM from $02EBC0", ROMX[$6BC0], BANK[11]
; bank11_tiles_at_6bc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6B80End:
Bank11TilesAt6BC0:
    INCBIN "roms/magination.gbc", $2EBC0, $40

SECTION "ROM from $02EC00", ROMX[$6C00], BANK[11]
; bank11_tiles_at_6c00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6BC0End:
Bank11TilesAt6C00:
    INCBIN "roms/magination.gbc", $2EC00, $40

SECTION "ROM from $02EC40", ROMX[$6C40], BANK[11]
; bank11_tiles_at_6c40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6C00End:
Bank11TilesAt6C40:
    INCBIN "roms/magination.gbc", $2EC40, $40

SECTION "ROM from $02EC80", ROMX[$6C80], BANK[11]
; bank11_tiles_at_6c80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6C40End:
Bank11TilesAt6C80:
    INCBIN "roms/magination.gbc", $2EC80, $40

SECTION "ROM from $02ECC0", ROMX[$6CC0], BANK[11]
; bank11_tiles_at_6cc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6C80End:
Bank11TilesAt6CC0:
    INCBIN "roms/magination.gbc", $2ECC0, $40

SECTION "ROM from $02ED00", ROMX[$6D00], BANK[11]
; bank11_tiles_at_6d00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6CC0End:
Bank11TilesAt6D00:
    INCBIN "roms/magination.gbc", $2ED00, $40

SECTION "ROM from $02ED40", ROMX[$6D40], BANK[11]
; bank11_tiles_at_6d40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6D00End:
Bank11TilesAt6D40:
    INCBIN "roms/magination.gbc", $2ED40, $40

SECTION "ROM from $02ED80", ROMX[$6D80], BANK[11]
; bank11_tiles_at_6d80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6D40End:
Bank11TilesAt6D80:
    INCBIN "roms/magination.gbc", $2ED80, $40

SECTION "ROM from $02EDC0", ROMX[$6DC0], BANK[11]
; bank11_tiles_at_6dc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6D80End:
Bank11TilesAt6DC0:
    INCBIN "roms/magination.gbc", $2EDC0, $40

SECTION "ROM from $02EE00", ROMX[$6E00], BANK[11]
; bank11_tiles_at_6e00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6DC0End:
Bank11TilesAt6E00:
    INCBIN "roms/magination.gbc", $2EE00, $40

SECTION "ROM from $02EE40", ROMX[$6E40], BANK[11]
; bank11_tiles_at_6e40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6E00End:
Bank11TilesAt6E40:
    INCBIN "roms/magination.gbc", $2EE40, $40

SECTION "ROM from $02EE80", ROMX[$6E80], BANK[11]
; bank11_tiles_at_6e80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6E40End:
Bank11TilesAt6E80:
    INCBIN "roms/magination.gbc", $2EE80, $40

SECTION "ROM from $02EEC0", ROMX[$6EC0], BANK[11]
; bank11_tiles_at_6ec0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6E80End:
Bank11TilesAt6EC0:
    INCBIN "roms/magination.gbc", $2EEC0, $40

SECTION "ROM from $02EF00", ROMX[$6F00], BANK[11]
; bank11_tiles_at_6f00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6EC0End:
Bank11TilesAt6F00:
    INCBIN "roms/magination.gbc", $2EF00, $40

SECTION "ROM from $02EF40", ROMX[$6F40], BANK[11]
; bank11_tiles_at_6f40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6F00End:
Bank11TilesAt6F40:
    INCBIN "roms/magination.gbc", $2EF40, $40

SECTION "ROM from $02EF80", ROMX[$6F80], BANK[11]
; bank11_tiles_at_6f80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6F40End:
Bank11TilesAt6F80:
    INCBIN "roms/magination.gbc", $2EF80, $40

SECTION "ROM from $02EFC0", ROMX[$6FC0], BANK[11]
; bank11_tiles_at_6fc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6F80End:
Bank11TilesAt6FC0:
    INCBIN "roms/magination.gbc", $2EFC0, $40

SECTION "ROM from $02F000", ROMX[$7000], BANK[11]
; bank11_tiles_at_7000.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt6FC0End:
Bank11TilesAt7000:
    INCBIN "roms/magination.gbc", $2F000, $40

SECTION "ROM from $02F040", ROMX[$7040], BANK[11]
; bank11_tiles_at_7040.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7000End:
Bank11TilesAt7040:
    INCBIN "roms/magination.gbc", $2F040, $40

SECTION "ROM from $02F080", ROMX[$7080], BANK[11]
; bank11_tiles_at_7080.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7040End:
Bank11TilesAt7080:
    INCBIN "roms/magination.gbc", $2F080, $40

SECTION "ROM from $02F0C0", ROMX[$70C0], BANK[11]
; bank11_tiles_at_70c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7080End:
Bank11TilesAt70C0:
    INCBIN "roms/magination.gbc", $2F0C0, $40

SECTION "ROM from $02F100", ROMX[$7100], BANK[11]
; bank11_tiles_at_7100.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt70C0End:
Bank11TilesAt7100:
    INCBIN "roms/magination.gbc", $2F100, $40

SECTION "ROM from $02F140", ROMX[$7140], BANK[11]
; bank11_tiles_at_7140.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7100End:
Bank11TilesAt7140:
    INCBIN "roms/magination.gbc", $2F140, $40

SECTION "ROM from $02F180", ROMX[$7180], BANK[11]
; bank11_tiles_at_7180.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7140End:
Bank11TilesAt7180:
    INCBIN "roms/magination.gbc", $2F180, $40

SECTION "ROM from $02F1C0", ROMX[$71C0], BANK[11]
; bank11_tiles_at_71c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7180End:
Bank11TilesAt71C0:
    INCBIN "roms/magination.gbc", $2F1C0, $40

SECTION "ROM from $02F200", ROMX[$7200], BANK[11]
; bank11_tiles_at_7200.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt71C0End:
Bank11TilesAt7200:
    INCBIN "roms/magination.gbc", $2F200, $40

SECTION "ROM from $02F240", ROMX[$7240], BANK[11]
; bank11_tiles_at_7240.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7200End:
Bank11TilesAt7240:
    INCBIN "roms/magination.gbc", $2F240, $40

SECTION "ROM from $02F280", ROMX[$7280], BANK[11]
; bank11_tiles_at_7280.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7240End:
Bank11TilesAt7280:
    INCBIN "roms/magination.gbc", $2F280, $40

SECTION "ROM from $02F2C0", ROMX[$72C0], BANK[11]
; bank11_tiles_at_72c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7280End:
Bank11TilesAt72C0:
    INCBIN "roms/magination.gbc", $2F2C0, $40

SECTION "ROM from $02F300", ROMX[$7300], BANK[11]
; bank11_tiles_at_7300.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt72C0End:
Bank11TilesAt7300:
    INCBIN "roms/magination.gbc", $2F300, $40

SECTION "ROM from $02F340", ROMX[$7340], BANK[11]
; bank11_tiles_at_7340.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7300End:
Bank11TilesAt7340:
    INCBIN "roms/magination.gbc", $2F340, $40

SECTION "ROM from $02F380", ROMX[$7380], BANK[11]
; bank11_tiles_at_7380.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7340End:
Bank11TilesAt7380:
    INCBIN "roms/magination.gbc", $2F380, $40

SECTION "ROM from $02F3C0", ROMX[$73C0], BANK[11]
; bank11_tiles_at_73c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7380End:
Bank11TilesAt73C0:
    INCBIN "roms/magination.gbc", $2F3C0, $40

SECTION "ROM from $02F400", ROMX[$7400], BANK[11]
; bank11_tiles_at_7400.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt73C0End:
Bank11TilesAt7400:
    INCBIN "roms/magination.gbc", $2F400, $40

SECTION "ROM from $02F440", ROMX[$7440], BANK[11]
; bank11_tiles_at_7440.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7400End:
Bank11TilesAt7440:
    INCBIN "roms/magination.gbc", $2F440, $40

SECTION "ROM from $02F480", ROMX[$7480], BANK[11]
; bank11_tiles_at_7480.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7440End:
Bank11TilesAt7480:
    INCBIN "roms/magination.gbc", $2F480, $40

SECTION "ROM from $02F4C0", ROMX[$74C0], BANK[11]
; bank11_tiles_at_74c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7480End:
Bank11TilesAt74C0:
    INCBIN "roms/magination.gbc", $2F4C0, $40

SECTION "ROM from $02F500", ROMX[$7500], BANK[11]
; bank11_tiles_at_7500.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt74C0End:
Bank11TilesAt7500:
    INCBIN "roms/magination.gbc", $2F500, $40

SECTION "ROM from $02F540", ROMX[$7540], BANK[11]
; bank11_tiles_at_7540.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7500End:
Bank11TilesAt7540:
    INCBIN "roms/magination.gbc", $2F540, $40

SECTION "ROM from $02F580", ROMX[$7580], BANK[11]
; bank11_tiles_at_7580.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7540End:
Bank11TilesAt7580:
    INCBIN "roms/magination.gbc", $2F580, $40

SECTION "ROM from $02F5C0", ROMX[$75C0], BANK[11]
; bank11_tiles_at_75c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7580End:
Bank11TilesAt75C0:
    INCBIN "roms/magination.gbc", $2F5C0, $40

SECTION "ROM from $02F600", ROMX[$7600], BANK[11]
; bank11_tiles_at_7600.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt75C0End:
Bank11TilesAt7600:
    INCBIN "roms/magination.gbc", $2F600, $40

SECTION "ROM from $02F640", ROMX[$7640], BANK[11]
; bank11_tiles_at_7640.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7600End:
Bank11TilesAt7640:
    INCBIN "roms/magination.gbc", $2F640, $40

SECTION "ROM from $02F680", ROMX[$7680], BANK[11]
; bank11_tiles_at_7680.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7640End:
Bank11TilesAt7680:
    INCBIN "roms/magination.gbc", $2F680, $40

SECTION "ROM from $02F6C0", ROMX[$76C0], BANK[11]
; bank11_tiles_at_76c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7680End:
Bank11TilesAt76C0:
    INCBIN "roms/magination.gbc", $2F6C0, $40

SECTION "ROM from $02F700", ROMX[$7700], BANK[11]
; bank11_tiles_at_7700.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt76C0End:
Bank11TilesAt7700:
    INCBIN "roms/magination.gbc", $2F700, $40

SECTION "ROM from $02F740", ROMX[$7740], BANK[11]
; bank11_tiles_at_7740.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7700End:
Bank11TilesAt7740:
    INCBIN "roms/magination.gbc", $2F740, $40

SECTION "ROM from $02F780", ROMX[$7780], BANK[11]
; bank11_tiles_at_7780.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7780:
    INCBIN "roms/magination.gbc", $2F780, $40

SECTION "ROM from $02F7C0", ROMX[$77C0], BANK[11]
; bank11_tiles_at_77c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7780End:
Bank11TilesAt77C0:
    INCBIN "roms/magination.gbc", $2F7C0, $40

SECTION "ROM from $02F800", ROMX[$7800], BANK[11]
; bank11_tiles_at_7800.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt77C0End:
Bank11TilesAt7800:
    INCBIN "roms/magination.gbc", $2F800, $40

SECTION "ROM from $02F840", ROMX[$7840], BANK[11]
; bank11_tiles_at_7840.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7800End:
Bank11TilesAt7840:
    INCBIN "roms/magination.gbc", $2F840, $40

SECTION "ROM from $02F880", ROMX[$7880], BANK[11]
; bank11_tiles_at_7880.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7840End:
Bank11TilesAt7880:
    INCBIN "roms/magination.gbc", $2F880, $40

SECTION "ROM from $02F8C0", ROMX[$78C0], BANK[11]
; bank11_tiles_at_78c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7880End:
Bank11TilesAt78C0:
    INCBIN "roms/magination.gbc", $2F8C0, $40

SECTION "ROM from $02F900", ROMX[$7900], BANK[11]
; bank11_tiles_at_7900.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt78C0End:
Bank11TilesAt7900:
    INCBIN "roms/magination.gbc", $2F900, $40

SECTION "ROM from $02F940", ROMX[$7940], BANK[11]
; bank11_tiles_at_7940.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7900End:
Bank11TilesAt7940:
    INCBIN "roms/magination.gbc", $2F940, $40

SECTION "ROM from $02F980", ROMX[$7980], BANK[11]
; bank11_tiles_at_7980.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7940End:
Bank11TilesAt7980:
    INCBIN "roms/magination.gbc", $2F980, $40

SECTION "ROM from $02F9C0", ROMX[$79C0], BANK[11]
; bank11_tiles_at_79c0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7980End:
Bank11TilesAt79C0:
    INCBIN "roms/magination.gbc", $2F9C0, $40

SECTION "ROM from $02FA00", ROMX[$7A00], BANK[11]
; bank11_tiles_at_7a00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt79C0End:
Bank11TilesAt7A00:
    INCBIN "roms/magination.gbc", $2FA00, $40

SECTION "ROM from $02FA40", ROMX[$7A40], BANK[11]
; bank11_tiles_at_7a40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7A00End:
Bank11TilesAt7A40:
    INCBIN "roms/magination.gbc", $2FA40, $40

SECTION "ROM from $02FA80", ROMX[$7A80], BANK[11]
; bank11_tiles_at_7a80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7A40End:
Bank11TilesAt7A80:
    INCBIN "roms/magination.gbc", $2FA80, $40

SECTION "ROM from $02FAC0", ROMX[$7AC0], BANK[11]
; bank11_tiles_at_7ac0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7A80End:
Bank11TilesAt7AC0:
    INCBIN "roms/magination.gbc", $2FAC0, $40

SECTION "ROM from $02FB00", ROMX[$7B00], BANK[11]
; bank11_tiles_at_7b00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7AC0End:
Bank11TilesAt7B00:
    INCBIN "roms/magination.gbc", $2FB00, $40

SECTION "ROM from $02FB40", ROMX[$7B40], BANK[11]
; bank11_tiles_at_7b40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7B00End:
Bank11TilesAt7B40:
    INCBIN "roms/magination.gbc", $2FB40, $40

SECTION "ROM from $02FB80", ROMX[$7B80], BANK[11]
; bank11_tiles_at_7b80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7B40End:
Bank11TilesAt7B80:
    INCBIN "roms/magination.gbc", $2FB80, $40

SECTION "ROM from $02FBC0", ROMX[$7BC0], BANK[11]
; bank11_tiles_at_7bc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7B80End:
Bank11TilesAt7BC0:
    INCBIN "roms/magination.gbc", $2FBC0, $40

SECTION "ROM from $02FC00", ROMX[$7C00], BANK[11]
; bank11_tiles_at_7c00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7BC0End:
Bank11TilesAt7C00:
    INCBIN "roms/magination.gbc", $2FC00, $40

SECTION "ROM from $02FC40", ROMX[$7C40], BANK[11]
; bank11_tiles_at_7c40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7C00End:
Bank11TilesAt7C40:
    INCBIN "roms/magination.gbc", $2FC40, $40

SECTION "ROM from $02FC80", ROMX[$7C80], BANK[11]
; bank11_tiles_at_7c80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7C40End:
Bank11TilesAt7C80:
    INCBIN "roms/magination.gbc", $2FC80, $40

SECTION "ROM from $02FCC0", ROMX[$7CC0], BANK[11]
; bank11_tiles_at_7cc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7C80End:
Bank11TilesAt7CC0:
    INCBIN "roms/magination.gbc", $2FCC0, $40

SECTION "ROM from $02FD00", ROMX[$7D00], BANK[11]
; bank11_tiles_at_7d00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7CC0End:
Bank11TilesAt7D00:
    INCBIN "roms/magination.gbc", $2FD00, $40

SECTION "ROM from $02FD40", ROMX[$7D40], BANK[11]
; bank11_tiles_at_7d40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7D00End:
Bank11TilesAt7D40:
    INCBIN "roms/magination.gbc", $2FD40, $40

SECTION "ROM from $02FD80", ROMX[$7D80], BANK[11]
; bank11_tiles_at_7d80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7D40End:
Bank11TilesAt7D80:
    INCBIN "roms/magination.gbc", $2FD80, $40

SECTION "ROM from $02FDC0", ROMX[$7DC0], BANK[11]
; bank11_tiles_at_7dc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7D80End:
Bank11TilesAt7DC0:
    INCBIN "roms/magination.gbc", $2FDC0, $40

SECTION "ROM from $02FE00", ROMX[$7E00], BANK[11]
; bank11_tiles_at_7e00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7DC0End:
Bank11TilesAt7E00:
    INCBIN "roms/magination.gbc", $2FE00, $40

SECTION "ROM from $02FE40", ROMX[$7E40], BANK[11]
; bank11_tiles_at_7e40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7E00End:
Bank11TilesAt7E40:
    INCBIN "roms/magination.gbc", $2FE40, $40

SECTION "ROM from $02FE80", ROMX[$7E80], BANK[11]
; bank11_tiles_at_7e80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7E40End:
Bank11TilesAt7E80:
    INCBIN "roms/magination.gbc", $2FE80, $40

SECTION "ROM from $02FEC0", ROMX[$7EC0], BANK[11]
; bank11_tiles_at_7ec0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7E80End:
Bank11TilesAt7EC0:
    INCBIN "roms/magination.gbc", $2FEC0, $40

SECTION "ROM from $02FF00", ROMX[$7F00], BANK[11]
; bank11_tiles_at_7f00.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7EC0End:
Bank11TilesAt7F00:
    INCBIN "roms/magination.gbc", $2FF00, $40

SECTION "ROM from $02FF40", ROMX[$7F40], BANK[11]
; bank11_tiles_at_7f40.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7F00End:
Bank11TilesAt7F40:
    INCBIN "roms/magination.gbc", $2FF40, $40

SECTION "ROM from $02FF80", ROMX[$7F80], BANK[11]
; bank11_tiles_at_7f80.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7F40End:
Bank11TilesAt7F80:
    INCBIN "roms/magination.gbc", $2FF80, $40

SECTION "ROM from $02FFC0", ROMX[$7FC0], BANK[11]
; bank11_tiles_at_7fc0.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7F80End:
Bank11TilesAt7FC0:
    INCBIN "roms/magination.gbc", $2FFC0, $40

SECTION "ROM Bank 012", ROMX[$4000], BANK[12]
; bank12_tiles_at_4000.asm: not published here (it assembles data copied from the ROM)
Bank11TilesAt7FC0End:
Bank12TilesAt4000:
    INCBIN "roms/magination.gbc", $30000, $40

SECTION "ROM from $030040", ROMX[$4040], BANK[12]
; bank12_tiles_at_4040.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4000End:
Bank12TilesAt4040:
    INCBIN "roms/magination.gbc", $30040, $40

SECTION "ROM from $030080", ROMX[$4080], BANK[12]
; bank12_tiles_at_4080.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4040End:
Bank12TilesAt4080:
    INCBIN "roms/magination.gbc", $30080, $40

SECTION "ROM from $0300C0", ROMX[$40C0], BANK[12]
; bank12_tiles_at_40c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4080End:
Bank12TilesAt40C0:
    INCBIN "roms/magination.gbc", $300C0, $40

SECTION "ROM from $030100", ROMX[$4100], BANK[12]
; bank12_tiles_at_4100.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt40C0End:
Bank12TilesAt4100:
    INCBIN "roms/magination.gbc", $30100, $40

SECTION "ROM from $030140", ROMX[$4140], BANK[12]
; bank12_tiles_at_4140.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4100End:
Bank12TilesAt4140:
    INCBIN "roms/magination.gbc", $30140, $40

SECTION "ROM from $030180", ROMX[$4180], BANK[12]
; bank12_tiles_at_4180.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4140End:
Bank12TilesAt4180:
    INCBIN "roms/magination.gbc", $30180, $40

SECTION "ROM from $0301C0", ROMX[$41C0], BANK[12]
; bank12_tiles_at_41c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4180End:
Bank12TilesAt41C0:
    INCBIN "roms/magination.gbc", $301C0, $40

SECTION "ROM from $030200", ROMX[$4200], BANK[12]
; bank12_tiles_at_4200.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt41C0End:
Bank12TilesAt4200:
    INCBIN "roms/magination.gbc", $30200, $40

SECTION "ROM from $030240", ROMX[$4240], BANK[12]
; bank12_tiles_at_4240.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4200End:
Bank12TilesAt4240:
    INCBIN "roms/magination.gbc", $30240, $40

SECTION "ROM from $030280", ROMX[$4280], BANK[12]
; bank12_tiles_at_4280.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4240End:
Bank12TilesAt4280:
    INCBIN "roms/magination.gbc", $30280, $40

SECTION "ROM from $0302C0", ROMX[$42C0], BANK[12]
; bank12_tiles_at_42c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4280End:
Bank12TilesAt42C0:
    INCBIN "roms/magination.gbc", $302C0, $40

SECTION "ROM from $030300", ROMX[$4300], BANK[12]
; bank12_tiles_at_4300.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt42C0End:
Bank12TilesAt4300:
    INCBIN "roms/magination.gbc", $30300, $40

SECTION "ROM from $030340", ROMX[$4340], BANK[12]
; bank12_tiles_at_4340.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4300End:
Bank12TilesAt4340:
    INCBIN "roms/magination.gbc", $30340, $40

SECTION "ROM from $030380", ROMX[$4380], BANK[12]
; bank12_tiles_at_4380.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4340End:
Bank12TilesAt4380:
    INCBIN "roms/magination.gbc", $30380, $40

SECTION "ROM from $0303C0", ROMX[$43C0], BANK[12]
; bank12_tiles_at_43c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4380End:
Bank12TilesAt43C0:
    INCBIN "roms/magination.gbc", $303C0, $40

SECTION "ROM from $030400", ROMX[$4400], BANK[12]
; bank12_tiles_at_4400.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt43C0End:
Bank12TilesAt4400:
    INCBIN "roms/magination.gbc", $30400, $40

SECTION "ROM from $030440", ROMX[$4440], BANK[12]
; bank12_tiles_at_4440.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4400End:
Bank12TilesAt4440:
    INCBIN "roms/magination.gbc", $30440, $40

SECTION "ROM from $030480", ROMX[$4480], BANK[12]
; bank12_tiles_at_4480.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4440End:
Bank12TilesAt4480:
    INCBIN "roms/magination.gbc", $30480, $40

SECTION "ROM from $0304C0", ROMX[$44C0], BANK[12]
; bank12_tiles_at_44c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4480End:
Bank12TilesAt44C0:
    INCBIN "roms/magination.gbc", $304C0, $40

SECTION "ROM from $030500", ROMX[$4500], BANK[12]
; bank12_tiles_at_4500.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt44C0End:
Bank12TilesAt4500:
    INCBIN "roms/magination.gbc", $30500, $40

SECTION "ROM from $030540", ROMX[$4540], BANK[12]
; bank12_tiles_at_4540.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4500End:
Bank12TilesAt4540:
    INCBIN "roms/magination.gbc", $30540, $40

SECTION "ROM from $030580", ROMX[$4580], BANK[12]
; bank12_tiles_at_4580.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4540End:
Bank12TilesAt4580:
    INCBIN "roms/magination.gbc", $30580, $40

SECTION "ROM from $0305C0", ROMX[$45C0], BANK[12]
; bank12_tiles_at_45c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4580End:
Bank12TilesAt45C0:
    INCBIN "roms/magination.gbc", $305C0, $40

SECTION "ROM from $030600", ROMX[$4600], BANK[12]
; bank12_tiles_at_4600.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt45C0End:
Bank12TilesAt4600:
    INCBIN "roms/magination.gbc", $30600, $40

SECTION "ROM from $030640", ROMX[$4640], BANK[12]
; bank12_tiles_at_4640.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4600End:
Bank12TilesAt4640:
    INCBIN "roms/magination.gbc", $30640, $40

SECTION "ROM from $030680", ROMX[$4680], BANK[12]
; bank12_tiles_at_4680.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4640End:
Bank12TilesAt4680:
    INCBIN "roms/magination.gbc", $30680, $40

SECTION "ROM from $0306C0", ROMX[$46C0], BANK[12]
; bank12_tiles_at_46c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4680End:
Bank12TilesAt46C0:
    INCBIN "roms/magination.gbc", $306C0, $40

SECTION "ROM from $030700", ROMX[$4700], BANK[12]
; bank12_tiles_at_4700.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt46C0End:
Bank12TilesAt4700:
    INCBIN "roms/magination.gbc", $30700, $40

SECTION "ROM from $030740", ROMX[$4740], BANK[12]
; bank12_tiles_at_4740.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4700End:
Bank12TilesAt4740:
    INCBIN "roms/magination.gbc", $30740, $40

SECTION "ROM from $030780", ROMX[$4780], BANK[12]
; bank12_tiles_at_4780.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4740End:
Bank12TilesAt4780:
    INCBIN "roms/magination.gbc", $30780, $40

SECTION "ROM from $0307C0", ROMX[$47C0], BANK[12]
; bank12_tiles_at_47c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4780End:
Bank12TilesAt47C0:
    INCBIN "roms/magination.gbc", $307C0, $40

SECTION "ROM from $030800", ROMX[$4800], BANK[12]
; bank12_tiles_at_4800.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt47C0End:
Bank12TilesAt4800:
    INCBIN "roms/magination.gbc", $30800, $40

SECTION "ROM from $030840", ROMX[$4840], BANK[12]
; bank12_tiles_at_4840.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4800End:
Bank12TilesAt4840:
    INCBIN "roms/magination.gbc", $30840, $40

SECTION "ROM from $030880", ROMX[$4880], BANK[12]
; bank12_tiles_at_4880.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4840End:
Bank12TilesAt4880:
    INCBIN "roms/magination.gbc", $30880, $40

SECTION "ROM from $0308C0", ROMX[$48C0], BANK[12]
; bank12_tiles_at_48c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4880End:
Bank12TilesAt48C0:
    INCBIN "roms/magination.gbc", $308C0, $40

SECTION "ROM from $030900", ROMX[$4900], BANK[12]
; bank12_tiles_at_4900.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt48C0End:
Bank12TilesAt4900:
    INCBIN "roms/magination.gbc", $30900, $40

SECTION "ROM from $030940", ROMX[$4940], BANK[12]
; bank12_tiles_at_4940.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4900End:
Bank12TilesAt4940:
    INCBIN "roms/magination.gbc", $30940, $40

SECTION "ROM from $030980", ROMX[$4980], BANK[12]
; bank12_tiles_at_4980.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4940End:
Bank12TilesAt4980:
    INCBIN "roms/magination.gbc", $30980, $40

SECTION "ROM from $0309C0", ROMX[$49C0], BANK[12]
; bank12_tiles_at_49c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4980End:
Bank12TilesAt49C0:
    INCBIN "roms/magination.gbc", $309C0, $40

SECTION "ROM from $030A00", ROMX[$4A00], BANK[12]
; bank12_tiles_at_4a00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt49C0End:
Bank12TilesAt4A00:
    INCBIN "roms/magination.gbc", $30A00, $40

SECTION "ROM from $030A40", ROMX[$4A40], BANK[12]
; bank12_tiles_at_4a40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4A00End:
Bank12TilesAt4A40:
    INCBIN "roms/magination.gbc", $30A40, $40

SECTION "ROM from $030A80", ROMX[$4A80], BANK[12]
; bank12_tiles_at_4a80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4A40End:
Bank12TilesAt4A80:
    INCBIN "roms/magination.gbc", $30A80, $40

SECTION "ROM from $030AC0", ROMX[$4AC0], BANK[12]
; bank12_tiles_at_4ac0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4A80End:
Bank12TilesAt4AC0:
    INCBIN "roms/magination.gbc", $30AC0, $40

SECTION "ROM from $030B00", ROMX[$4B00], BANK[12]
; bank12_tiles_at_4b00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4AC0End:
Bank12TilesAt4B00:
    INCBIN "roms/magination.gbc", $30B00, $40

SECTION "ROM from $030B40", ROMX[$4B40], BANK[12]
; bank12_tiles_at_4b40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4B00End:
Bank12TilesAt4B40:
    INCBIN "roms/magination.gbc", $30B40, $40

SECTION "ROM from $030B80", ROMX[$4B80], BANK[12]
; bank12_tiles_at_4b80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4B40End:
Bank12TilesAt4B80:
    INCBIN "roms/magination.gbc", $30B80, $40

SECTION "ROM from $030BC0", ROMX[$4BC0], BANK[12]
; bank12_tiles_at_4bc0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4B80End:
Bank12TilesAt4BC0:
    INCBIN "roms/magination.gbc", $30BC0, $40

SECTION "ROM from $030C00", ROMX[$4C00], BANK[12]
; bank12_tiles_at_4c00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4BC0End:
Bank12TilesAt4C00:
    INCBIN "roms/magination.gbc", $30C00, $40

SECTION "ROM from $030C40", ROMX[$4C40], BANK[12]
; bank12_tiles_at_4c40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4C00End:
Bank12TilesAt4C40:
    INCBIN "roms/magination.gbc", $30C40, $40

SECTION "ROM from $030C80", ROMX[$4C80], BANK[12]
; bank12_tiles_at_4c80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4C40End:
Bank12TilesAt4C80:
    INCBIN "roms/magination.gbc", $30C80, $40

SECTION "ROM from $030CC0", ROMX[$4CC0], BANK[12]
; bank12_tiles_at_4cc0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4C80End:
Bank12TilesAt4CC0:
    INCBIN "roms/magination.gbc", $30CC0, $40

SECTION "ROM from $030D00", ROMX[$4D00], BANK[12]
; bank12_tiles_at_4d00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4CC0End:
Bank12TilesAt4D00:
    INCBIN "roms/magination.gbc", $30D00, $40

SECTION "ROM from $030D40", ROMX[$4D40], BANK[12]
; bank12_tiles_at_4d40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4D00End:
Bank12TilesAt4D40:
    INCBIN "roms/magination.gbc", $30D40, $40

SECTION "ROM from $030D80", ROMX[$4D80], BANK[12]
; bank12_tiles_at_4d80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4D40End:
Bank12TilesAt4D80:
    INCBIN "roms/magination.gbc", $30D80, $40

SECTION "ROM from $030DC0", ROMX[$4DC0], BANK[12]
; bank12_tiles_at_4dc0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4D80End:
Bank12TilesAt4DC0:
    INCBIN "roms/magination.gbc", $30DC0, $40

SECTION "ROM from $030E00", ROMX[$4E00], BANK[12]
; bank12_tiles_at_4e00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4DC0End:
Bank12TilesAt4E00:
    INCBIN "roms/magination.gbc", $30E00, $40

SECTION "ROM from $030E40", ROMX[$4E40], BANK[12]
; bank12_tiles_at_4e40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4E00End:
Bank12TilesAt4E40:
    INCBIN "roms/magination.gbc", $30E40, $40

SECTION "ROM from $030E80", ROMX[$4E80], BANK[12]
; bank12_tiles_at_4e80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4E40End:
Bank12TilesAt4E80:
    INCBIN "roms/magination.gbc", $30E80, $40

SECTION "ROM from $030EC0", ROMX[$4EC0], BANK[12]
; bank12_tiles_at_4ec0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4E80End:
Bank12TilesAt4EC0:
    INCBIN "roms/magination.gbc", $30EC0, $40

SECTION "ROM from $030F00", ROMX[$4F00], BANK[12]
; bank12_tiles_at_4f00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4EC0End:
Bank12TilesAt4F00:
    INCBIN "roms/magination.gbc", $30F00, $40

SECTION "ROM from $030F40", ROMX[$4F40], BANK[12]
; bank12_tiles_at_4f40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4F00End:
Bank12TilesAt4F40:
    INCBIN "roms/magination.gbc", $30F40, $40

SECTION "ROM from $030F80", ROMX[$4F80], BANK[12]
; bank12_tiles_at_4f80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4F40End:
Bank12TilesAt4F80:
    INCBIN "roms/magination.gbc", $30F80, $40

SECTION "ROM from $030FC0", ROMX[$4FC0], BANK[12]
; bank12_tiles_at_4fc0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4F80End:
Bank12TilesAt4FC0:
    INCBIN "roms/magination.gbc", $30FC0, $40

SECTION "ROM from $031000", ROMX[$5000], BANK[12]
; bank12_tiles_at_5000.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt4FC0End:
Bank12TilesAt5000:
    INCBIN "roms/magination.gbc", $31000, $40

SECTION "ROM from $031040", ROMX[$5040], BANK[12]
; bank12_tiles_at_5040.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5000End:
Bank12TilesAt5040:
    INCBIN "roms/magination.gbc", $31040, $40

SECTION "ROM from $031080", ROMX[$5080], BANK[12]
; bank12_tiles_at_5080.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5040End:
Bank12TilesAt5080:
    INCBIN "roms/magination.gbc", $31080, $40

SECTION "ROM from $0310C0", ROMX[$50C0], BANK[12]
; bank12_tiles_at_50c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5080End:
Bank12TilesAt50C0:
    INCBIN "roms/magination.gbc", $310C0, $40

SECTION "ROM from $031100", ROMX[$5100], BANK[12]
; bank12_tiles_at_5100.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt50C0End:
Bank12TilesAt5100:
    INCBIN "roms/magination.gbc", $31100, $40

SECTION "ROM from $031140", ROMX[$5140], BANK[12]
; bank12_tiles_at_5140.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5100End:
Bank12TilesAt5140:
    INCBIN "roms/magination.gbc", $31140, $40

SECTION "ROM from $031180", ROMX[$5180], BANK[12]
; bank12_tiles_at_5180.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5140End:
Bank12TilesAt5180:
    INCBIN "roms/magination.gbc", $31180, $40

SECTION "ROM from $0311C0", ROMX[$51C0], BANK[12]
; bank12_tiles_at_51c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5180End:
Bank12TilesAt51C0:
    INCBIN "roms/magination.gbc", $311C0, $40

SECTION "ROM from $031200", ROMX[$5200], BANK[12]
; bank12_tiles_at_5200.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt51C0End:
Bank12TilesAt5200:
    INCBIN "roms/magination.gbc", $31200, $40

SECTION "ROM from $031240", ROMX[$5240], BANK[12]
; bank12_tiles_at_5240.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5240:
    INCBIN "roms/magination.gbc", $31240, $40

SECTION "ROM from $031280", ROMX[$5280], BANK[12]
; bank12_tiles_at_5280.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5240End:
Bank12TilesAt5280:
    INCBIN "roms/magination.gbc", $31280, $40

SECTION "ROM from $0312C0", ROMX[$52C0], BANK[12]
; bank12_tiles_at_52c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5280End:
Bank12TilesAt52C0:
    INCBIN "roms/magination.gbc", $312C0, $40

SECTION "ROM from $031300", ROMX[$5300], BANK[12]
; bank12_tiles_at_5300.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt52C0End:
Bank12TilesAt5300:
    INCBIN "roms/magination.gbc", $31300, $40

SECTION "ROM from $031340", ROMX[$5340], BANK[12]
; bank12_tiles_at_5340.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5300End:
Bank12TilesAt5340:
    INCBIN "roms/magination.gbc", $31340, $40

SECTION "ROM from $031380", ROMX[$5380], BANK[12]
; bank12_tiles_at_5380.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5340End:
Bank12TilesAt5380:
    INCBIN "roms/magination.gbc", $31380, $40

SECTION "ROM from $0313C0", ROMX[$53C0], BANK[12]
; bank12_tiles_at_53c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5380End:
Bank12TilesAt53C0:
    INCBIN "roms/magination.gbc", $313C0, $40

SECTION "ROM from $031400", ROMX[$5400], BANK[12]
; bank12_tiles_at_5400.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt53C0End:
Bank12TilesAt5400:
    INCBIN "roms/magination.gbc", $31400, $40

SECTION "ROM from $031440", ROMX[$5440], BANK[12]
; bank12_tiles_at_5440.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5400End:
Bank12TilesAt5440:
    INCBIN "roms/magination.gbc", $31440, $40

SECTION "ROM from $031480", ROMX[$5480], BANK[12]
; bank12_tiles_at_5480.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5440End:
Bank12TilesAt5480:
    INCBIN "roms/magination.gbc", $31480, $40

SECTION "ROM from $0314C0", ROMX[$54C0], BANK[12]
; bank12_tiles_at_54c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5480End:
Bank12TilesAt54C0:
    INCBIN "roms/magination.gbc", $314C0, $40

SECTION "ROM from $031500", ROMX[$5500], BANK[12]
; bank12_tiles_at_5500.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt54C0End:
Bank12TilesAt5500:
    INCBIN "roms/magination.gbc", $31500, $40

SECTION "ROM from $031540", ROMX[$5540], BANK[12]
; bank12_tiles_at_5540.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5500End:
Bank12TilesAt5540:
    INCBIN "roms/magination.gbc", $31540, $40

SECTION "ROM from $031580", ROMX[$5580], BANK[12]
; bank12_tiles_at_5580.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5540End:
Bank12TilesAt5580:
    INCBIN "roms/magination.gbc", $31580, $40

SECTION "ROM from $0315C0", ROMX[$55C0], BANK[12]
; bank12_tiles_at_55c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5580End:
Bank12TilesAt55C0:
    INCBIN "roms/magination.gbc", $315C0, $40

SECTION "ROM from $031600", ROMX[$5600], BANK[12]
; bank12_tiles_at_5600.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt55C0End:
Bank12TilesAt5600:
    INCBIN "roms/magination.gbc", $31600, $40

SECTION "ROM from $031640", ROMX[$5640], BANK[12]
; bank12_tiles_at_5640.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5600End:
Bank12TilesAt5640:
    INCBIN "roms/magination.gbc", $31640, $40

SECTION "ROM from $031680", ROMX[$5680], BANK[12]
; bank12_tiles_at_5680.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5640End:
Bank12TilesAt5680:
    INCBIN "roms/magination.gbc", $31680, $40

SECTION "ROM from $0316C0", ROMX[$56C0], BANK[12]
; bank12_tiles_at_56c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5680End:
Bank12TilesAt56C0:
    INCBIN "roms/magination.gbc", $316C0, $40

SECTION "ROM from $031700", ROMX[$5700], BANK[12]
; bank12_tiles_at_5700.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt56C0End:
Bank12TilesAt5700:
    INCBIN "roms/magination.gbc", $31700, $40

SECTION "ROM from $031740", ROMX[$5740], BANK[12]
; bank12_tiles_at_5740.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5700End:
Bank12TilesAt5740:
    INCBIN "roms/magination.gbc", $31740, $40

SECTION "ROM from $031780", ROMX[$5780], BANK[12]
; bank12_tiles_at_5780.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5740End:
Bank12TilesAt5780:
    INCBIN "roms/magination.gbc", $31780, $40

SECTION "ROM from $0317C0", ROMX[$57C0], BANK[12]
; bank12_tiles_at_57c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5780End:
Bank12TilesAt57C0:
    INCBIN "roms/magination.gbc", $317C0, $40

SECTION "ROM from $031800", ROMX[$5800], BANK[12]
; bank12_tiles_at_5800.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt57C0End:
Bank12TilesAt5800:
    INCBIN "roms/magination.gbc", $31800, $40

SECTION "ROM from $031840", ROMX[$5840], BANK[12]
; bank12_tiles_at_5840.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5800End:
Bank12TilesAt5840:
    INCBIN "roms/magination.gbc", $31840, $40

SECTION "ROM from $031880", ROMX[$5880], BANK[12]
; bank12_tiles_at_5880.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5840End:
Bank12TilesAt5880:
    INCBIN "roms/magination.gbc", $31880, $40

SECTION "ROM from $0318C0", ROMX[$58C0], BANK[12]
; bank12_tiles_at_58c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5880End:
Bank12TilesAt58C0:
    INCBIN "roms/magination.gbc", $318C0, $40

SECTION "ROM from $031900", ROMX[$5900], BANK[12]
; bank12_tiles_at_5900.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt58C0End:
Bank12TilesAt5900:
    INCBIN "roms/magination.gbc", $31900, $40

SECTION "ROM from $031940", ROMX[$5940], BANK[12]
; bank12_tiles_at_5940.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5900End:
Bank12TilesAt5940:
    INCBIN "roms/magination.gbc", $31940, $40

SECTION "ROM from $031980", ROMX[$5980], BANK[12]
; bank12_tiles_at_5980.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5940End:
Bank12TilesAt5980:
    INCBIN "roms/magination.gbc", $31980, $40

SECTION "ROM from $0319C0", ROMX[$59C0], BANK[12]
; bank12_tiles_at_59c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5980End:
Bank12TilesAt59C0:
    INCBIN "roms/magination.gbc", $319C0, $40

SECTION "ROM from $031A00", ROMX[$5A00], BANK[12]
; bank12_tiles_at_5a00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt59C0End:
Bank12TilesAt5A00:
    INCBIN "roms/magination.gbc", $31A00, $40

SECTION "ROM from $031A40", ROMX[$5A40], BANK[12]
; bank12_tiles_at_5a40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5A00End:
Bank12TilesAt5A40:
    INCBIN "roms/magination.gbc", $31A40, $40

SECTION "ROM from $031A80", ROMX[$5A80], BANK[12]
; bank12_tiles_at_5a80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5A40End:
Bank12TilesAt5A80:
    INCBIN "roms/magination.gbc", $31A80, $40

SECTION "ROM from $031AC0", ROMX[$5AC0], BANK[12]
; bank12_tiles_at_5ac0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5A80End:
Bank12TilesAt5AC0:
    INCBIN "roms/magination.gbc", $31AC0, $40

SECTION "ROM from $031B00", ROMX[$5B00], BANK[12]
; bank12_tiles_at_5b00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5AC0End:
Bank12TilesAt5B00:
    INCBIN "roms/magination.gbc", $31B00, $40

SECTION "ROM from $031B40", ROMX[$5B40], BANK[12]
; bank12_tiles_at_5b40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5B00End:
Bank12TilesAt5B40:
    INCBIN "roms/magination.gbc", $31B40, $40

SECTION "ROM from $031B80", ROMX[$5B80], BANK[12]
; bank12_tiles_at_5b80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5B40End:
Bank12TilesAt5B80:
    INCBIN "roms/magination.gbc", $31B80, $40

SECTION "ROM from $031BC0", ROMX[$5BC0], BANK[12]
; bank12_tiles_at_5bc0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5B80End:
Bank12TilesAt5BC0:
    INCBIN "roms/magination.gbc", $31BC0, $40

SECTION "ROM from $031C00", ROMX[$5C00], BANK[12]
; bank12_tiles_at_5c00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5BC0End:
Bank12TilesAt5C00:
    INCBIN "roms/magination.gbc", $31C00, $40

SECTION "ROM from $031C40", ROMX[$5C40], BANK[12]
; bank12_tiles_at_5c40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5C00End:
Bank12TilesAt5C40:
    INCBIN "roms/magination.gbc", $31C40, $40

SECTION "ROM from $031C80", ROMX[$5C80], BANK[12]
; bank12_tiles_at_5c80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5C40End:
Bank12TilesAt5C80:
    INCBIN "roms/magination.gbc", $31C80, $40

SECTION "ROM from $031CC0", ROMX[$5CC0], BANK[12]
; bank12_tiles_at_5cc0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5C80End:
Bank12TilesAt5CC0:
    INCBIN "roms/magination.gbc", $31CC0, $40

SECTION "ROM from $031D00", ROMX[$5D00], BANK[12]
; bank12_tiles_at_5d00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5CC0End:
Bank12TilesAt5D00:
    INCBIN "roms/magination.gbc", $31D00, $40

SECTION "ROM from $031D40", ROMX[$5D40], BANK[12]
; bank12_tiles_at_5d40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5D00End:
Bank12TilesAt5D40:
    INCBIN "roms/magination.gbc", $31D40, $40

SECTION "ROM from $031D80", ROMX[$5D80], BANK[12]
; bank12_tiles_at_5d80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5D40End:
Bank12TilesAt5D80:
    INCBIN "roms/magination.gbc", $31D80, $40

SECTION "ROM from $031DC0", ROMX[$5DC0], BANK[12]
; bank12_tiles_at_5dc0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5D80End:
Bank12TilesAt5DC0:
    INCBIN "roms/magination.gbc", $31DC0, $40

SECTION "ROM from $031E00", ROMX[$5E00], BANK[12]
; bank12_tiles_at_5e00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5DC0End:
Bank12TilesAt5E00:
    INCBIN "roms/magination.gbc", $31E00, $40

SECTION "ROM from $031E40", ROMX[$5E40], BANK[12]
; bank12_tiles_at_5e40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5E00End:
Bank12TilesAt5E40:
    INCBIN "roms/magination.gbc", $31E40, $40

SECTION "ROM from $031E80", ROMX[$5E80], BANK[12]
; bank12_tiles_at_5e80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5E40End:
Bank12TilesAt5E80:
    INCBIN "roms/magination.gbc", $31E80, $40

SECTION "ROM from $031EC0", ROMX[$5EC0], BANK[12]
; bank12_tiles_at_5ec0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5E80End:
Bank12TilesAt5EC0:
    INCBIN "roms/magination.gbc", $31EC0, $40

SECTION "ROM from $031F00", ROMX[$5F00], BANK[12]
; bank12_tiles_at_5f00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5EC0End:
Bank12TilesAt5F00:
    INCBIN "roms/magination.gbc", $31F00, $40

SECTION "ROM from $031F40", ROMX[$5F40], BANK[12]
; bank12_tiles_at_5f40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5F00End:
Bank12TilesAt5F40:
    INCBIN "roms/magination.gbc", $31F40, $40

SECTION "ROM from $031F80", ROMX[$5F80], BANK[12]
; bank12_tiles_at_5f80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5F40End:
Bank12TilesAt5F80:
    INCBIN "roms/magination.gbc", $31F80, $40

SECTION "ROM from $031FC0", ROMX[$5FC0], BANK[12]
; bank12_tiles_at_5fc0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5F80End:
Bank12TilesAt5FC0:
    INCBIN "roms/magination.gbc", $31FC0, $40

SECTION "ROM from $032000", ROMX[$6000], BANK[12]
; bank12_tiles_at_6000.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt5FC0End:
Bank12TilesAt6000:
    INCBIN "roms/magination.gbc", $32000, $40

SECTION "ROM from $032040", ROMX[$6040], BANK[12]
; bank12_tiles_at_6040.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6000End:
Bank12TilesAt6040:
    INCBIN "roms/magination.gbc", $32040, $40

SECTION "ROM from $032080", ROMX[$6080], BANK[12]
; bank12_tiles_at_6080.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6040End:
Bank12TilesAt6080:
    INCBIN "roms/magination.gbc", $32080, $40

SECTION "ROM from $0320C0", ROMX[$60C0], BANK[12]
; bank12_tiles_at_60c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6080End:
Bank12TilesAt60C0:
    INCBIN "roms/magination.gbc", $320C0, $40

SECTION "ROM from $032100", ROMX[$6100], BANK[12]
; bank12_tiles_at_6100.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt60C0End:
Bank12TilesAt6100:
    INCBIN "roms/magination.gbc", $32100, $40

SECTION "ROM from $032140", ROMX[$6140], BANK[12]
; bank12_tiles_at_6140.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6100End:
Bank12TilesAt6140:
    INCBIN "roms/magination.gbc", $32140, $40

SECTION "ROM from $032180", ROMX[$6180], BANK[12]
; bank12_tiles_at_6180.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6140End:
Bank12TilesAt6180:
    INCBIN "roms/magination.gbc", $32180, $40

SECTION "ROM from $0321C0", ROMX[$61C0], BANK[12]
; bank12_tiles_at_61c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6180End:
Bank12TilesAt61C0:
    INCBIN "roms/magination.gbc", $321C0, $40

SECTION "ROM from $032200", ROMX[$6200], BANK[12]
; bank12_tiles_at_6200.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt61C0End:
Bank12TilesAt6200:
    INCBIN "roms/magination.gbc", $32200, $40

SECTION "ROM from $032240", ROMX[$6240], BANK[12]
; bank12_tiles_at_6240.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6200End:
Bank12TilesAt6240:
    INCBIN "roms/magination.gbc", $32240, $40

SECTION "ROM from $032280", ROMX[$6280], BANK[12]
; bank12_tiles_at_6280.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6240End:
Bank12TilesAt6280:
    INCBIN "roms/magination.gbc", $32280, $40

SECTION "ROM from $0322C0", ROMX[$62C0], BANK[12]
; bank12_tiles_at_62c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6280End:
Bank12TilesAt62C0:
    INCBIN "roms/magination.gbc", $322C0, $40

SECTION "ROM from $032300", ROMX[$6300], BANK[12]
; bank12_tiles_at_6300.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt62C0End:
Bank12TilesAt6300:
    INCBIN "roms/magination.gbc", $32300, $40

SECTION "ROM from $032340", ROMX[$6340], BANK[12]
; bank12_tiles_at_6340.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6340:
    INCBIN "roms/magination.gbc", $32340, $40

SECTION "ROM from $032380", ROMX[$6380], BANK[12]
; bank12_tiles_at_6380.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6340End:
Bank12TilesAt6380:
    INCBIN "roms/magination.gbc", $32380, $40

SECTION "ROM from $0323C0", ROMX[$63C0], BANK[12]
; bank12_tiles_at_63c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6380End:
Bank12TilesAt63C0:
    INCBIN "roms/magination.gbc", $323C0, $40

SECTION "ROM from $032400", ROMX[$6400], BANK[12]
; bank12_tiles_at_6400.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt63C0End:
Bank12TilesAt6400:
    INCBIN "roms/magination.gbc", $32400, $40

SECTION "ROM from $032440", ROMX[$6440], BANK[12]
; bank12_tiles_at_6440.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6400End:
Bank12TilesAt6440:
    INCBIN "roms/magination.gbc", $32440, $40

SECTION "ROM from $032480", ROMX[$6480], BANK[12]
; bank12_tiles_at_6480.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6440End:
Bank12TilesAt6480:
    INCBIN "roms/magination.gbc", $32480, $40

SECTION "ROM from $0324C0", ROMX[$64C0], BANK[12]
; bank12_tiles_at_64c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6480End:
Bank12TilesAt64C0:
    INCBIN "roms/magination.gbc", $324C0, $40

SECTION "ROM from $032500", ROMX[$6500], BANK[12]
; bank12_tiles_at_6500.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt64C0End:
Bank12TilesAt6500:
    INCBIN "roms/magination.gbc", $32500, $40

SECTION "ROM from $032540", ROMX[$6540], BANK[12]
; bank12_tiles_at_6540.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6500End:
Bank12TilesAt6540:
    INCBIN "roms/magination.gbc", $32540, $40

SECTION "ROM from $032580", ROMX[$6580], BANK[12]
; bank12_tiles_at_6580.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6540End:
Bank12TilesAt6580:
    INCBIN "roms/magination.gbc", $32580, $40

SECTION "ROM from $0325C0", ROMX[$65C0], BANK[12]
; bank12_tiles_at_65c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6580End:
Bank12TilesAt65C0:
    INCBIN "roms/magination.gbc", $325C0, $40

SECTION "ROM from $032600", ROMX[$6600], BANK[12]
; bank12_tiles_at_6600.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt65C0End:
Bank12TilesAt6600:
    INCBIN "roms/magination.gbc", $32600, $40

SECTION "ROM from $032640", ROMX[$6640], BANK[12]
; bank12_tiles_at_6640.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6600End:
Bank12TilesAt6640:
    INCBIN "roms/magination.gbc", $32640, $40

SECTION "ROM from $032680", ROMX[$6680], BANK[12]
; bank12_tiles_at_6680.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6640End:
Bank12TilesAt6680:
    INCBIN "roms/magination.gbc", $32680, $40

SECTION "ROM from $0326C0", ROMX[$66C0], BANK[12]
; bank12_tiles_at_66c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6680End:
Bank12TilesAt66C0:
    INCBIN "roms/magination.gbc", $326C0, $40

SECTION "ROM from $032700", ROMX[$6700], BANK[12]
; bank12_tiles_at_6700.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt66C0End:
Bank12TilesAt6700:
    INCBIN "roms/magination.gbc", $32700, $40

SECTION "ROM from $032740", ROMX[$6740], BANK[12]
; bank12_tiles_at_6740.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6700End:
Bank12TilesAt6740:
    INCBIN "roms/magination.gbc", $32740, $40

SECTION "ROM from $032780", ROMX[$6780], BANK[12]
; bank12_tiles_at_6780.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6780:
    INCBIN "roms/magination.gbc", $32780, $40

SECTION "ROM from $0327C0", ROMX[$67C0], BANK[12]
; bank12_tiles_at_67c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt67C0:
    INCBIN "roms/magination.gbc", $327C0, $40

SECTION "ROM from $032800", ROMX[$6800], BANK[12]
; bank12_tiles_at_6800.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6800:
    INCBIN "roms/magination.gbc", $32800, $40

SECTION "ROM from $032840", ROMX[$6840], BANK[12]
; bank12_tiles_at_6840.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6840:
    INCBIN "roms/magination.gbc", $32840, $40

SECTION "ROM from $032880", ROMX[$6880], BANK[12]
; bank12_tiles_at_6880.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6880:
    INCBIN "roms/magination.gbc", $32880, $40

SECTION "ROM from $0328C0", ROMX[$68C0], BANK[12]
; bank12_tiles_at_68c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt68C0:
    INCBIN "roms/magination.gbc", $328C0, $40

SECTION "ROM from $032900", ROMX[$6900], BANK[12]
; bank12_tiles_at_6900.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6900:
    INCBIN "roms/magination.gbc", $32900, $40

SECTION "ROM from $032940", ROMX[$6940], BANK[12]
; bank12_tiles_at_6940.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6940:
    INCBIN "roms/magination.gbc", $32940, $40

SECTION "ROM from $032980", ROMX[$6980], BANK[12]
; bank12_tiles_at_6980.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6980:
    INCBIN "roms/magination.gbc", $32980, $40

SECTION "ROM from $0329C0", ROMX[$69C0], BANK[12]
; bank12_tiles_at_69c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt69C0:
    INCBIN "roms/magination.gbc", $329C0, $40

SECTION "ROM from $032A00", ROMX[$6A00], BANK[12]
; bank12_tiles_at_6a00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6A00:
    INCBIN "roms/magination.gbc", $32A00, $40

SECTION "ROM from $032A40", ROMX[$6A40], BANK[12]
; bank12_tiles_at_6a40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6A40:
    INCBIN "roms/magination.gbc", $32A40, $40

SECTION "ROM from $032A80", ROMX[$6A80], BANK[12]
; bank12_tiles_at_6a80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6A80:
    INCBIN "roms/magination.gbc", $32A80, $40

SECTION "ROM from $032AC0", ROMX[$6AC0], BANK[12]
    INCBIN "roms/magination.gbc", $32AC0, $0040

SECTION "ROM from $032B00", ROMX[$6B00], BANK[12]
; bank12_tiles_at_6b00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6B00:
    INCBIN "roms/magination.gbc", $32B00, $40

SECTION "ROM from $032B40", ROMX[$6B40], BANK[12]
; bank12_tiles_at_6b40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6B40:
    INCBIN "roms/magination.gbc", $32B40, $40

SECTION "ROM from $032B80", ROMX[$6B80], BANK[12]
; bank12_tiles_at_6b80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6B80:
    INCBIN "roms/magination.gbc", $32B80, $40

SECTION "ROM from $032BC0", ROMX[$6BC0], BANK[12]
; bank12_tiles_at_6bc0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6BC0:
    INCBIN "roms/magination.gbc", $32BC0, $40

SECTION "ROM from $032C00", ROMX[$6C00], BANK[12]
; bank12_tiles_at_6c00.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6C00:
    INCBIN "roms/magination.gbc", $32C00, $40

SECTION "ROM from $032C40", ROMX[$6C40], BANK[12]
; bank12_tiles_at_6c40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6C40:
    INCBIN "roms/magination.gbc", $32C40, $40

SECTION "ROM from $032C80", ROMX[$6C80], BANK[12]
; bank12_tiles_at_6c80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6C40End:
Bank12TilesAt6C80:
    INCBIN "roms/magination.gbc", $32C80, $40

SECTION "ROM from $032CC0", ROMX[$6CC0], BANK[12]
; bank12_tiles_at_6cc0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6C80End:
Bank12TilesAt6CC0:
    INCBIN "roms/magination.gbc", $32CC0, $40

SECTION "ROM from $032D00", ROMX[$6D00], BANK[12]
    INCBIN "roms/magination.gbc", $32D00, $0240

SECTION "ROM from $032F40", ROMX[$6F40], BANK[12]
; bank12_tiles_at_6f40.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6F40:
    INCBIN "roms/magination.gbc", $32F40, $40

SECTION "ROM from $032F80", ROMX[$6F80], BANK[12]
; bank12_tiles_at_6f80.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6F80:
    INCBIN "roms/magination.gbc", $32F80, $40

SECTION "ROM from $032FC0", ROMX[$6FC0], BANK[12]
; bank12_tiles_at_6fc0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt6FC0:
    INCBIN "roms/magination.gbc", $32FC0, $40

SECTION "ROM from $033000", ROMX[$7000], BANK[12]
; bank12_tiles_at_7000.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt7000:
    INCBIN "roms/magination.gbc", $33000, $40

SECTION "ROM from $033040", ROMX[$7040], BANK[12]
; bank12_tiles_at_7040.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt7000End:
Bank12TilesAt7040:
    INCBIN "roms/magination.gbc", $33040, $40

SECTION "ROM from $033080", ROMX[$7080], BANK[12]
; bank12_tiles_at_7080.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt7040End:
Bank12TilesAt7080:
    INCBIN "roms/magination.gbc", $33080, $40

SECTION "ROM from $0330C0", ROMX[$70C0], BANK[12]
; bank12_tiles_at_70c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt7080End:
Bank12TilesAt70C0:
    INCBIN "roms/magination.gbc", $330C0, $40

SECTION "ROM from $033100", ROMX[$7100], BANK[12]
    INCBIN "roms/magination.gbc", $33100, $0240

SECTION "ROM from $033340", ROMX[$7340], BANK[12]
; bank12_tiles_at_7340.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt7340:
    INCBIN "roms/magination.gbc", $33340, $40

SECTION "ROM from $033380", ROMX[$7380], BANK[12]
; bank12_tiles_at_7380.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt7380:
    INCBIN "roms/magination.gbc", $33380, $40

SECTION "ROM from $0333C0", ROMX[$73C0], BANK[12]
; bank12_tiles_at_73c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt73C0:
    INCBIN "roms/magination.gbc", $333C0, $40

SECTION "ROM from $033400", ROMX[$7400], BANK[12]
    INCBIN "roms/magination.gbc", $33400, $03C0

SECTION "ROM from $0337C0", ROMX[$77C0], BANK[12]
; bank12_tiles_at_77c0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt77C0:
    INCBIN "roms/magination.gbc", $337C0, $40

SECTION "ROM from $033800", ROMX[$7800], BANK[12]
    INCBIN "roms/magination.gbc", $33800, $03C0

SECTION "ROM from $033BC0", ROMX[$7BC0], BANK[12]
; bank12_tiles_at_7bc0.asm: not published here (it assembles data copied from the ROM)
Bank12TilesAt7BC0:
    INCBIN "roms/magination.gbc", $33BC0, $40

SECTION "ROM from $033C00", ROMX[$7C00], BANK[12]
    INCBIN "roms/magination.gbc", $33C00, $03C0

SECTION "ROM from $033FC0", ROMX[$7FC0], BANK[12]
INCLUDE "src/bank12_tiles_at_7fc0.asm"

SECTION "ROM Bank 013", ROMX[$4000], BANK[13]
; bank13_tiles_at_4000.asm: not published here (it assembles data copied from the ROM)
Bank13TilesAt4000:
    INCBIN "roms/magination.gbc", $34000, $40

SECTION "ROM from $034040", ROMX[$4040], BANK[13]
    INCBIN "roms/magination.gbc", $34040, $03C0

SECTION "ROM from $034400", ROMX[$4400], BANK[13]
; bank13_tiles_at_4400.asm: not published here (it assembles data copied from the ROM)
Bank13TilesAt4400:
    INCBIN "roms/magination.gbc", $34400, $40

SECTION "ROM from $034440", ROMX[$4440], BANK[13]
    INCBIN "roms/magination.gbc", $34440, $30D0

SECTION "Zero padding from $037510", ROMX[$7510], BANK[13]
    ds $AF0, $00 ; zero padding to the end of bank $0D

SECTION "Sprite lists bank $0E", ROMX[$4000], BANK[14]
; sprite_lists_bank0e.asm: not published here (it assembles data copied from the ROM)
SpriteList0E_00:
    INCBIN "roms/magination.gbc", $38000, $3D

SECTION "Sprite lists bank $0E @$03803D", ROMX[$403D], BANK[14]
SpriteList0E_01:
    INCBIN "roms/magination.gbc", $3803D, $3D

SECTION "Sprite lists bank $0E @$03807A", ROMX[$407A], BANK[14]
SpriteList0E_02:
    INCBIN "roms/magination.gbc", $3807A, $3D

SECTION "Sprite lists bank $0E @$0380B7", ROMX[$40B7], BANK[14]
SpriteList0E_03:
    INCBIN "roms/magination.gbc", $380B7, $3D

SECTION "Sprite lists bank $0E @$0380F4", ROMX[$40F4], BANK[14]
SpriteList0E_04:
    INCBIN "roms/magination.gbc", $380F4, $3D

SECTION "Sprite lists bank $0E @$038131", ROMX[$4131], BANK[14]
SpriteList0E_05:
    INCBIN "roms/magination.gbc", $38131, $3D

SECTION "Sprite lists bank $0E @$03816E", ROMX[$416E], BANK[14]
SpriteList0E_06:
    INCBIN "roms/magination.gbc", $3816E, $3D

SECTION "Sprite lists bank $0E @$0381AB", ROMX[$41AB], BANK[14]
SpriteList0E_07:
    INCBIN "roms/magination.gbc", $381AB, $3D

SECTION "Sprite lists bank $0E @$0381E8", ROMX[$41E8], BANK[14]
SpriteList0E_08:
    INCBIN "roms/magination.gbc", $381E8, $29

SECTION "Sprite lists bank $0E @$038211", ROMX[$4211], BANK[14]
SpriteList0E_09:
    INCBIN "roms/magination.gbc", $38211, $29

SECTION "Sprite lists bank $0E @$03823A", ROMX[$423A], BANK[14]
SpriteList0E_10:
    INCBIN "roms/magination.gbc", $3823A, $29

SECTION "Sprite lists bank $0E @$038263", ROMX[$4263], BANK[14]
SpriteList0E_11:
    INCBIN "roms/magination.gbc", $38263, $29

SECTION "Sprite lists bank $0E @$03828C", ROMX[$428C], BANK[14]
SpriteList0E_12:
    INCBIN "roms/magination.gbc", $3828C, $29

SECTION "Sprite lists bank $0E @$0382B5", ROMX[$42B5], BANK[14]
SpriteList0E_13:
    INCBIN "roms/magination.gbc", $382B5, $29

SECTION "Sprite lists bank $0E @$0382DE", ROMX[$42DE], BANK[14]
SpriteList0E_14:
    INCBIN "roms/magination.gbc", $382DE, $3D

SECTION "Sprite lists bank $0E @$03831B", ROMX[$431B], BANK[14]
SpriteList0E_15:
    INCBIN "roms/magination.gbc", $3831B, $4D

SECTION "Sprite lists bank $0E @$038368", ROMX[$4368], BANK[14]
SpriteList0E_16:
    INCBIN "roms/magination.gbc", $38368, $55

SECTION "Sprite lists bank $0E @$0383BD", ROMX[$43BD], BANK[14]
SpriteList0E_17:
    INCBIN "roms/magination.gbc", $383BD, $5D

SECTION "Sprite lists bank $0E @$03841A", ROMX[$441A], BANK[14]
SpriteList0E_18:
    INCBIN "roms/magination.gbc", $3841A, $5D

SECTION "Sprite lists bank $0E @$038477", ROMX[$4477], BANK[14]
SpriteList0E_19:
    INCBIN "roms/magination.gbc", $38477, $5D

SECTION "Sprite lists bank $0E @$0384D4", ROMX[$44D4], BANK[14]
SpriteList0E_20:
    INCBIN "roms/magination.gbc", $384D4, $5D

SECTION "Sprite lists bank $0E @$038531", ROMX[$4531], BANK[14]
SpriteList0E_21:
    INCBIN "roms/magination.gbc", $38531, $5D

SECTION "Sprite lists bank $0E @$03858E", ROMX[$458E], BANK[14]
SpriteList0E_22:
    INCBIN "roms/magination.gbc", $3858E, $4D

SECTION "Sprite lists bank $0E @$0385DB", ROMX[$45DB], BANK[14]
SpriteList0E_23:
    INCBIN "roms/magination.gbc", $385DB, $4D

SECTION "Sprite lists bank $0E @$038628", ROMX[$4628], BANK[14]
SpriteList0E_24:
    INCBIN "roms/magination.gbc", $38628, $4D

SECTION "Sprite lists bank $0E @$038675", ROMX[$4675], BANK[14]
SpriteList0E_25:
    INCBIN "roms/magination.gbc", $38675, $35

SECTION "Sprite lists bank $0E @$0386AA", ROMX[$46AA], BANK[14]
SpriteList0E_26:
    INCBIN "roms/magination.gbc", $386AA, $45

SECTION "Sprite lists bank $0E @$0386EF", ROMX[$46EF], BANK[14]
SpriteList0E_27:
    INCBIN "roms/magination.gbc", $386EF, $49

SECTION "Sprite lists bank $0E @$038738", ROMX[$4738], BANK[14]
SpriteList0E_28:
    INCBIN "roms/magination.gbc", $38738, $49

SECTION "Sprite animation scripts bank $0E", ROMX[$4781], BANK[14]
    INCBIN "roms/magination.gbc", $38781, $387F

SECTION "Sprite lists bank $0F", ROMX[$4000], BANK[15]
; sprite_lists_bank0f.asm: not published here (it assembles data copied from the ROM)
SpriteList0F_00:
    INCBIN "roms/magination.gbc", $3C000, $19

SECTION "Sprite lists bank $0F @$03C019", ROMX[$4019], BANK[15]
SpriteList0F_01:
    INCBIN "roms/magination.gbc", $3C019, $19

SECTION "Sprite lists bank $0F @$03C032", ROMX[$4032], BANK[15]
SpriteList0F_02:
    INCBIN "roms/magination.gbc", $3C032, $19

SECTION "Sprite lists bank $0F @$03C04B", ROMX[$404B], BANK[15]
SpriteList0F_03:
    INCBIN "roms/magination.gbc", $3C04B, $19

SECTION "Sprite lists bank $0F @$03C064", ROMX[$4064], BANK[15]
SpriteList0F_04:
    INCBIN "roms/magination.gbc", $3C064, $19

SECTION "Sprite lists bank $0F @$03C07D", ROMX[$407D], BANK[15]
SpriteList0F_05:
    INCBIN "roms/magination.gbc", $3C07D, $19

SECTION "Sprite lists bank $0F @$03C096", ROMX[$4096], BANK[15]
SpriteList0F_06:
    INCBIN "roms/magination.gbc", $3C096, $19

SECTION "Sprite lists bank $0F @$03C0AF", ROMX[$40AF], BANK[15]
SpriteList0F_07:
    INCBIN "roms/magination.gbc", $3C0AF, $19

SECTION "Sprite lists bank $0F @$03C0C8", ROMX[$40C8], BANK[15]
SpriteList0F_08:
    INCBIN "roms/magination.gbc", $3C0C8, $19

SECTION "Sprite lists bank $0F @$03C0E1", ROMX[$40E1], BANK[15]
SpriteList0F_09:
    INCBIN "roms/magination.gbc", $3C0E1, $19

SECTION "Sprite lists bank $0F @$03C0FA", ROMX[$40FA], BANK[15]
SpriteList0F_10:
    INCBIN "roms/magination.gbc", $3C0FA, $19

SECTION "Sprite lists bank $0F @$03C113", ROMX[$4113], BANK[15]
SpriteList0F_11:
    INCBIN "roms/magination.gbc", $3C113, $19

SECTION "Sprite lists bank $0F @$03C12C", ROMX[$412C], BANK[15]
SpriteList0F_12:
    INCBIN "roms/magination.gbc", $3C12C, $19

SECTION "Sprite lists bank $0F @$03C145", ROMX[$4145], BANK[15]
SpriteList0F_13:
    INCBIN "roms/magination.gbc", $3C145, $19

SECTION "Sprite lists bank $0F @$03C15E", ROMX[$415E], BANK[15]
SpriteList0F_14:
    INCBIN "roms/magination.gbc", $3C15E, $19

SECTION "Sprite lists bank $0F @$03C177", ROMX[$4177], BANK[15]
SpriteList0F_15:
    INCBIN "roms/magination.gbc", $3C177, $19

SECTION "Sprite animation scripts bank $0F", ROMX[$4190], BANK[15]
    INCBIN "roms/magination.gbc", $3C190, $3E70

SECTION "Sprite lists bank $10", ROMX[$4000], BANK[16]
; sprite_lists_bank10.asm: not published here (it assembles data copied from the ROM)
SpriteList10_00:
    INCBIN "roms/magination.gbc", $40000, $19

SECTION "Sprite lists bank $10 @$040019", ROMX[$4019], BANK[16]
SpriteList10_01:
    INCBIN "roms/magination.gbc", $40019, $19

SECTION "Sprite lists bank $10 @$040032", ROMX[$4032], BANK[16]
SpriteList10_02:
    INCBIN "roms/magination.gbc", $40032, $19

SECTION "Sprite lists bank $10 @$04004B", ROMX[$404B], BANK[16]
SpriteList10_03:
    INCBIN "roms/magination.gbc", $4004B, $19

SECTION "Sprite lists bank $10 @$040064", ROMX[$4064], BANK[16]
SpriteList10_04:
    INCBIN "roms/magination.gbc", $40064, $19

SECTION "Sprite lists bank $10 @$04007D", ROMX[$407D], BANK[16]
SpriteList10_05:
    INCBIN "roms/magination.gbc", $4007D, $19

SECTION "Sprite lists bank $10 @$040096", ROMX[$4096], BANK[16]
SpriteList10_06:
    INCBIN "roms/magination.gbc", $40096, $19

SECTION "Sprite lists bank $10 @$0400AF", ROMX[$40AF], BANK[16]
SpriteList10_07:
    INCBIN "roms/magination.gbc", $400AF, $19

SECTION "Sprite lists bank $10 @$0400C8", ROMX[$40C8], BANK[16]
SpriteList10_08:
    INCBIN "roms/magination.gbc", $400C8, $19

SECTION "Sprite lists bank $10 @$0400E1", ROMX[$40E1], BANK[16]
SpriteList10_09:
    INCBIN "roms/magination.gbc", $400E1, $19

SECTION "Sprite lists bank $10 @$0400FA", ROMX[$40FA], BANK[16]
SpriteList10_10:
    INCBIN "roms/magination.gbc", $400FA, $19

SECTION "Sprite lists bank $10 @$040113", ROMX[$4113], BANK[16]
SpriteList10_11:
    INCBIN "roms/magination.gbc", $40113, $19

SECTION "Sprite lists bank $10 @$04012C", ROMX[$412C], BANK[16]
SpriteList10_12:
    INCBIN "roms/magination.gbc", $4012C, $19

SECTION "Sprite lists bank $10 @$040145", ROMX[$4145], BANK[16]
SpriteList10_13:
    INCBIN "roms/magination.gbc", $40145, $19

SECTION "Sprite lists bank $10 @$04015E", ROMX[$415E], BANK[16]
SpriteList10_14:
    INCBIN "roms/magination.gbc", $4015E, $19

SECTION "Sprite lists bank $10 @$040177", ROMX[$4177], BANK[16]
SpriteList10_15:
    INCBIN "roms/magination.gbc", $40177, $19

SECTION "Sprite lists bank $10 @$040190", ROMX[$4190], BANK[16]
SpriteList10_16:
    INCBIN "roms/magination.gbc", $40190, $19

SECTION "Sprite lists bank $10 @$0401A9", ROMX[$41A9], BANK[16]
SpriteList10_17:
    INCBIN "roms/magination.gbc", $401A9, $21

SECTION "Sprite lists bank $10 @$0401CA", ROMX[$41CA], BANK[16]
SpriteList10_18:
    INCBIN "roms/magination.gbc", $401CA, $19

SECTION "Sprite lists bank $10 @$0401E3", ROMX[$41E3], BANK[16]
SpriteList10_19:
    INCBIN "roms/magination.gbc", $401E3, $19

SECTION "Sprite lists bank $10 @$0401FC", ROMX[$41FC], BANK[16]
SpriteList10_20:
    INCBIN "roms/magination.gbc", $401FC, $19

SECTION "Sprite lists bank $10 @$040215", ROMX[$4215], BANK[16]
SpriteList10_21:
    INCBIN "roms/magination.gbc", $40215, $19

SECTION "Sprite lists bank $10 @$04022E", ROMX[$422E], BANK[16]
SpriteList10_22:
    INCBIN "roms/magination.gbc", $4022E, $1D

SECTION "Sprite lists bank $10 @$04024B", ROMX[$424B], BANK[16]
SpriteList10_23:
    INCBIN "roms/magination.gbc", $4024B, $1D

SECTION "Sprite animation scripts bank $10", ROMX[$4268], BANK[16]
    INCBIN "roms/magination.gbc", $40268, $3D98

SECTION "Sprite lists bank $11", ROMX[$4000], BANK[17]
; sprite_lists_bank11.asm: not published here (it assembles data copied from the ROM)
SpriteList11_00:
    INCBIN "roms/magination.gbc", $44000, $19

SECTION "Sprite lists bank $11 @$044019", ROMX[$4019], BANK[17]
SpriteList11_01:
    INCBIN "roms/magination.gbc", $44019, $19

SECTION "Sprite lists bank $11 @$044032", ROMX[$4032], BANK[17]
SpriteList11_02:
    INCBIN "roms/magination.gbc", $44032, $19

SECTION "Sprite lists bank $11 @$04404B", ROMX[$404B], BANK[17]
SpriteList11_03:
    INCBIN "roms/magination.gbc", $4404B, $19

SECTION "Sprite lists bank $11 @$044064", ROMX[$4064], BANK[17]
SpriteList11_04:
    INCBIN "roms/magination.gbc", $44064, $19

SECTION "Sprite lists bank $11 @$04407D", ROMX[$407D], BANK[17]
SpriteList11_05:
    INCBIN "roms/magination.gbc", $4407D, $19

SECTION "Sprite lists bank $11 @$044096", ROMX[$4096], BANK[17]
SpriteList11_06:
    INCBIN "roms/magination.gbc", $44096, $19

SECTION "Sprite animation scripts bank $11", ROMX[$40AF], BANK[17]
    INCBIN "roms/magination.gbc", $440AF, $3CEA

SECTION "Zero padding from $047D99", ROMX[$7D99], BANK[17]
    ds $267, $00 ; zero padding to the end of bank $11

SECTION "ROM Bank 018", ROMX[$4000], BANK[18]
    INCBIN "roms/magination.gbc", $48000, $3A1D

SECTION "Zero padding from $04BA1D", ROMX[$7A1D], BANK[18]
    ds $5E3, $00 ; zero padding to the end of bank $12

SECTION "ROM Bank 019", ROMX[$4000], BANK[19]
    INCBIN "roms/magination.gbc", $4C000, $3AC7

SECTION "Zero padding from $04FAC7", ROMX[$7AC7], BANK[19]
    ds $539, $00 ; zero padding to the end of bank $13

SECTION "ROM Bank 020", ROMX[$4000], BANK[20]
    INCBIN "roms/magination.gbc", $50000, $3E88

SECTION "Zero padding from $053E88", ROMX[$7E88], BANK[20]
    ds $178, $00 ; zero padding to the end of bank $14

SECTION "ROM Bank 021", ROMX[$4000], BANK[21]
    INCBIN "roms/magination.gbc", $54000, $3852

SECTION "Zero padding from $057852", ROMX[$7852], BANK[21]
    ds $7AE, $00 ; zero padding to the end of bank $15

SECTION "ROM Bank 022", ROMX[$4000], BANK[22]
    INCBIN "roms/magination.gbc", $58000, $4000

SECTION "ROM Bank 023", ROMX[$4000], BANK[23]
    INCBIN "roms/magination.gbc", $5C000, $388C

SECTION "Zero padding from $05F88C", ROMX[$788C], BANK[23]
    ds $774, $00 ; zero padding to the end of bank $17

SECTION "ROM Bank 024", ROMX[$4000], BANK[24]
    INCBIN "roms/magination.gbc", $60000, $3667

SECTION "Zero padding from $063667", ROMX[$7667], BANK[24]
    ds $999, $00 ; zero padding to the end of bank $18

SECTION "ROM Bank 025", ROMX[$4000], BANK[25]
    INCBIN "roms/magination.gbc", $64000, $3E5F

SECTION "Zero padding from $067E5F", ROMX[$7E5F], BANK[25]
    ds $1A1, $00 ; zero padding to the end of bank $19

SECTION "ROM Bank 026", ROMX[$4000], BANK[26]
    INCBIN "roms/magination.gbc", $68000, $3C39

SECTION "Zero padding from $06BC39", ROMX[$7C39], BANK[26]
    ds $3C7, $00 ; zero padding to the end of bank $1A

SECTION "ROM Bank 027", ROMX[$4000], BANK[27]
    INCBIN "roms/magination.gbc", $6C000, $4000

SECTION "ROM Bank 028", ROMX[$4000], BANK[28]
    INCBIN "roms/magination.gbc", $70000, $3D48

SECTION "Zero padding from $073D48", ROMX[$7D48], BANK[28]
    ds $2B8, $00 ; zero padding to the end of bank $1C

SECTION "ROM Bank 029", ROMX[$4000], BANK[29]
    INCBIN "roms/magination.gbc", $74000, $3A06

SECTION "Zero padding from $077A06", ROMX[$7A06], BANK[29]
    ds $5FA, $00 ; zero padding to the end of bank $1D

SECTION "ROM Bank 030", ROMX[$4000], BANK[30]
    INCBIN "roms/magination.gbc", $78000, $3744

SECTION "Zero padding from $07B744", ROMX[$7744], BANK[30]
    ds $8BC, $00 ; zero padding to the end of bank $1E

SECTION "ROM Bank 031", ROMX[$4000], BANK[31]
    INCBIN "roms/magination.gbc", $7C000, $3C23

SECTION "Zero padding from $07FC23", ROMX[$7C23], BANK[31]
    ds $3DD, $00 ; zero padding to the end of bank $1F

SECTION "ROM Bank 032", ROMX[$4000], BANK[32]
; sprite_lists_bank20.asm: not published here (it assembles data copied from the ROM)
SpriteList20_00:
    INCBIN "roms/magination.gbc", $80000, $19

SECTION "ROM Bank 032 @$080019", ROMX[$4019], BANK[32]
SpriteList20_01:
    INCBIN "roms/magination.gbc", $80019, $19

SECTION "ROM Bank 032 @$080032", ROMX[$4032], BANK[32]
SpriteList20_02:
    INCBIN "roms/magination.gbc", $80032, $19

SECTION "ROM Bank 032 @$08004B", ROMX[$404B], BANK[32]
SpriteList20_03:
    INCBIN "roms/magination.gbc", $8004B, $19

SECTION "ROM Bank 032 @$080064", ROMX[$4064], BANK[32]
SpriteList20_04:
    INCBIN "roms/magination.gbc", $80064, $19

SECTION "ROM Bank 032 @$08007D", ROMX[$407D], BANK[32]
SpriteList20_05:
    INCBIN "roms/magination.gbc", $8007D, $19

SECTION "ROM Bank 032 @$080096", ROMX[$4096], BANK[32]
SpriteList20_06:
    INCBIN "roms/magination.gbc", $80096, $19

SECTION "ROM Bank 032 @$0800AF", ROMX[$40AF], BANK[32]
SpriteList20_07:
    INCBIN "roms/magination.gbc", $800AF, $19

SECTION "ROM Bank 032 @$0800C8", ROMX[$40C8], BANK[32]
SpriteList20_08:
    INCBIN "roms/magination.gbc", $800C8, $19

SECTION "ROM Bank 032 @$0800E1", ROMX[$40E1], BANK[32]
SpriteList20_09:
    INCBIN "roms/magination.gbc", $800E1, $19

SECTION "ROM Bank 032 @$0800FA", ROMX[$40FA], BANK[32]
SpriteList20_10:
    INCBIN "roms/magination.gbc", $800FA, $19

SECTION "ROM Bank 032 @$080113", ROMX[$4113], BANK[32]
SpriteList20_11:
    INCBIN "roms/magination.gbc", $80113, $19

SECTION "ROM Bank 032 @$08012C", ROMX[$412C], BANK[32]
SpriteList20_12:
    INCBIN "roms/magination.gbc", $8012C, $15

SECTION "ROM Bank 032 @$080141", ROMX[$4141], BANK[32]
SpriteList20_13:
    INCBIN "roms/magination.gbc", $80141, $19

SECTION "ROM Bank 032 @$08015A", ROMX[$415A], BANK[32]
SpriteList20_14:
    INCBIN "roms/magination.gbc", $8015A, $15

SECTION "ROM Bank 032 @$08016F", ROMX[$416F], BANK[32]
SpriteList20_15:
    INCBIN "roms/magination.gbc", $8016F, $15

SECTION "ROM Bank 032 @$080184", ROMX[$4184], BANK[32]
SpriteList20_16:
    INCBIN "roms/magination.gbc", $80184, $19

SECTION "ROM Bank 032 @$08019D", ROMX[$419D], BANK[32]
SpriteList20_17:
    INCBIN "roms/magination.gbc", $8019D, $15

SECTION "ROM Bank 032 @$0801B2", ROMX[$41B2], BANK[32]
SpriteList20_18:
    INCBIN "roms/magination.gbc", $801B2, $19

SECTION "ROM Bank 032 @$0801CB", ROMX[$41CB], BANK[32]
SpriteList20_19:
    INCBIN "roms/magination.gbc", $801CB, $19

SECTION "ROM Bank 032 @$0801E4", ROMX[$41E4], BANK[32]
SpriteList20_20:
    INCBIN "roms/magination.gbc", $801E4, $19

SECTION "ROM Bank 032 @$0801FD", ROMX[$41FD], BANK[32]
SpriteList20_21:
    INCBIN "roms/magination.gbc", $801FD, $19

SECTION "ROM Bank 032 @$080216", ROMX[$4216], BANK[32]
SpriteList20_22:
    INCBIN "roms/magination.gbc", $80216, $19

SECTION "ROM Bank 032 @$08022F", ROMX[$422F], BANK[32]
SpriteList20_23:
    INCBIN "roms/magination.gbc", $8022F, $19

SECTION "ROM Bank 032 @$080248", ROMX[$4248], BANK[32]
SpriteList20_24:
    INCBIN "roms/magination.gbc", $80248, $19

SECTION "ROM Bank 032 @$080261", ROMX[$4261], BANK[32]
SpriteList20_25:
    INCBIN "roms/magination.gbc", $80261, $19

SECTION "ROM Bank 032 @$08027A", ROMX[$427A], BANK[32]
SpriteList20_26:
    INCBIN "roms/magination.gbc", $8027A, $19

SECTION "ROM Bank 032 @$080293", ROMX[$4293], BANK[32]
SpriteList20_27:
    INCBIN "roms/magination.gbc", $80293, $19

SECTION "ROM Bank 032 @$0802AC", ROMX[$42AC], BANK[32]
SpriteList20_28:
    INCBIN "roms/magination.gbc", $802AC, $19

SECTION "ROM Bank 032 @$0802C5", ROMX[$42C5], BANK[32]
SpriteList20_29:
    INCBIN "roms/magination.gbc", $802C5, $19

SECTION "ROM Bank 032 @$0802DE", ROMX[$42DE], BANK[32]
SpriteList20_30:
    INCBIN "roms/magination.gbc", $802DE, $1D

SECTION "ROM Bank 032 @$0802FB", ROMX[$42FB], BANK[32]
SpriteList20_31:
    INCBIN "roms/magination.gbc", $802FB, $19

SECTION "ROM Bank 032 @$080314", ROMX[$4314], BANK[32]
SpriteList20_32:
    INCBIN "roms/magination.gbc", $80314, $1D

SECTION "ROM Bank 032 @$080331", ROMX[$4331], BANK[32]
SpriteList20_33:
    INCBIN "roms/magination.gbc", $80331, $1D

SECTION "ROM Bank 032 @$08034E", ROMX[$434E], BANK[32]
SpriteList20_34:
    INCBIN "roms/magination.gbc", $8034E, $19

SECTION "ROM Bank 032 @$080367", ROMX[$4367], BANK[32]
SpriteList20_35:
    INCBIN "roms/magination.gbc", $80367, $1D

SECTION "ROM Bank 032 @$080384", ROMX[$4384], BANK[32]
SpriteList20_36:
    INCBIN "roms/magination.gbc", $80384, $19

SECTION "ROM Bank 032 @$08039D", ROMX[$439D], BANK[32]
SpriteList20_37:
    INCBIN "roms/magination.gbc", $8039D, $19

SECTION "ROM Bank 032 @$0803B6", ROMX[$43B6], BANK[32]
SpriteList20_38:
    INCBIN "roms/magination.gbc", $803B6, $19

SECTION "ROM Bank 032 @$0803CF", ROMX[$43CF], BANK[32]
SpriteList20_39:
    INCBIN "roms/magination.gbc", $803CF, $15

SECTION "ROM Bank 032 @$0803E4", ROMX[$43E4], BANK[32]
SpriteList20_40:
    INCBIN "roms/magination.gbc", $803E4, $19

SECTION "ROM Bank 032 @$0803FD", ROMX[$43FD], BANK[32]
SpriteList20_41:
    INCBIN "roms/magination.gbc", $803FD, $19

SECTION "ROM Bank 032 @$080416", ROMX[$4416], BANK[32]
SpriteList20_42:
    INCBIN "roms/magination.gbc", $80416, $19

SECTION "ROM Bank 032 @$08042F", ROMX[$442F], BANK[32]
SpriteList20_43:
    INCBIN "roms/magination.gbc", $8042F, $19

SECTION "ROM Bank 032 @$080448", ROMX[$4448], BANK[32]
SpriteList20_44:
    INCBIN "roms/magination.gbc", $80448, $19

SECTION "ROM Bank 032 @$080461", ROMX[$4461], BANK[32]
SpriteList20_45:
    INCBIN "roms/magination.gbc", $80461, $19

SECTION "ROM Bank 032 @$08047A", ROMX[$447A], BANK[32]
SpriteList20_46:
    INCBIN "roms/magination.gbc", $8047A, $19

SECTION "ROM Bank 032 @$080493", ROMX[$4493], BANK[32]
SpriteList20_47:
    INCBIN "roms/magination.gbc", $80493, $19

SECTION "ROM Bank 032 @$0804AC", ROMX[$44AC], BANK[32]
SpriteList20_48:
    INCBIN "roms/magination.gbc", $804AC, $11

SECTION "ROM Bank 032 @$0804BD", ROMX[$44BD], BANK[32]
SpriteList20_49:
    INCBIN "roms/magination.gbc", $804BD, $11

SECTION "ROM Bank 032 @$0804CE", ROMX[$44CE], BANK[32]
SpriteList20_50:
    INCBIN "roms/magination.gbc", $804CE, $11

SECTION "ROM Bank 032 @$0804DF", ROMX[$44DF], BANK[32]
SpriteList20_51:
    INCBIN "roms/magination.gbc", $804DF, $11

SECTION "ROM Bank 032 @$0804F0", ROMX[$44F0], BANK[32]
SpriteList20_52:
    INCBIN "roms/magination.gbc", $804F0, $11

SECTION "ROM Bank 032 @$080501", ROMX[$4501], BANK[32]
SpriteList20_53:
    INCBIN "roms/magination.gbc", $80501, $11

SECTION "ROM Bank 032 @$080512", ROMX[$4512], BANK[32]
SpriteList20_54:
    INCBIN "roms/magination.gbc", $80512, $11

SECTION "ROM Bank 032 @$080523", ROMX[$4523], BANK[32]
SpriteList20_55:
    INCBIN "roms/magination.gbc", $80523, $11

SECTION "ROM Bank 032 @$080534", ROMX[$4534], BANK[32]
SpriteList20_56:
    INCBIN "roms/magination.gbc", $80534, $19

SECTION "ROM Bank 032 @$08054D", ROMX[$454D], BANK[32]
SpriteList20_57:
    INCBIN "roms/magination.gbc", $8054D, $19

SECTION "ROM Bank 032 @$080566", ROMX[$4566], BANK[32]
SpriteList20_58:
    INCBIN "roms/magination.gbc", $80566, $19

SECTION "ROM Bank 032 @$08057F", ROMX[$457F], BANK[32]
SpriteList20_59:
    INCBIN "roms/magination.gbc", $8057F, $19

SECTION "ROM Bank 032 @$080598", ROMX[$4598], BANK[32]
SpriteList20_60:
    INCBIN "roms/magination.gbc", $80598, $25

SECTION "ROM Bank 032 @$0805BD", ROMX[$45BD], BANK[32]
SpriteList20_61:
    INCBIN "roms/magination.gbc", $805BD, $25

SECTION "ROM Bank 032 @$0805E2", ROMX[$45E2], BANK[32]
SpriteList20_62:
    INCBIN "roms/magination.gbc", $805E2, $19

SECTION "ROM Bank 032 @$0805FB", ROMX[$45FB], BANK[32]
SpriteList20_63:
    INCBIN "roms/magination.gbc", $805FB, $25

SECTION "ROM Bank 032 @$080620", ROMX[$4620], BANK[32]
SpriteList20_64:
    INCBIN "roms/magination.gbc", $80620, $31

SECTION "ROM Bank 032 @$080651", ROMX[$4651], BANK[32]
SpriteList20_65:
    INCBIN "roms/magination.gbc", $80651, $31

SECTION "ROM Bank 032 @$080682", ROMX[$4682], BANK[32]
SpriteList20_66:
    INCBIN "roms/magination.gbc", $80682, $19

SECTION "ROM Bank 032 @$08069B", ROMX[$469B], BANK[32]
SpriteList20_67:
    INCBIN "roms/magination.gbc", $8069B, $25

SECTION "ROM Bank 032 @$0806C0", ROMX[$46C0], BANK[32]
SpriteList20_68:
    INCBIN "roms/magination.gbc", $806C0, $31

SECTION "ROM Bank 032 @$0806F1", ROMX[$46F1], BANK[32]
SpriteList20_69:
    INCBIN "roms/magination.gbc", $806F1, $15

SECTION "ROM Bank 032 @$080706", ROMX[$4706], BANK[32]
SpriteList20_70:
    INCBIN "roms/magination.gbc", $80706, $1D

SECTION "ROM Bank 032 @$080723", ROMX[$4723], BANK[32]
SpriteList20_71:
    INCBIN "roms/magination.gbc", $80723, $25

SECTION "ROM Bank 032 @$080748", ROMX[$4748], BANK[32]
SpriteList20_72:
    INCBIN "roms/magination.gbc", $80748, $19

SECTION "ROM Bank 032 @$080761", ROMX[$4761], BANK[32]
SpriteList20_73:
    INCBIN "roms/magination.gbc", $80761, $31

SECTION "ROM Bank 032 @$080792", ROMX[$4792], BANK[32]
SpriteList20_74:
    INCBIN "roms/magination.gbc", $80792, $31

SECTION "ROM Bank 032 @$0807C3", ROMX[$47C3], BANK[32]
SpriteList20_75:
    INCBIN "roms/magination.gbc", $807C3, $9

SECTION "ROM Bank 032 @$0807CC", ROMX[$47CC], BANK[32]
SpriteList20_76:
    INCBIN "roms/magination.gbc", $807CC, $9

SECTION "ROM Bank 032 @$0807D5", ROMX[$47D5], BANK[32]
SpriteList20_77:
    INCBIN "roms/magination.gbc", $807D5, $19

SECTION "ROM Bank 032 @$0807EE", ROMX[$47EE], BANK[32]
SpriteList20_78:
    INCBIN "roms/magination.gbc", $807EE, $19

SECTION "ROM Bank 032 @$080807", ROMX[$4807], BANK[32]
SpriteList20_79:
    INCBIN "roms/magination.gbc", $80807, $19

SECTION "ROM Bank 032 @$080820", ROMX[$4820], BANK[32]
SpriteList20_80:
    INCBIN "roms/magination.gbc", $80820, $19

SECTION "ROM Bank 032 @$080839", ROMX[$4839], BANK[32]
SpriteList20_81:
    INCBIN "roms/magination.gbc", $80839, $19

SECTION "ROM Bank 032 @$080852", ROMX[$4852], BANK[32]
SpriteList20_82:
    INCBIN "roms/magination.gbc", $80852, $1D

SECTION "ROM Bank 032 @$08086F", ROMX[$486F], BANK[32]
SpriteList20_83:
    INCBIN "roms/magination.gbc", $8086F, $1D

SECTION "ROM Bank 032 @$08088C", ROMX[$488C], BANK[32]
SpriteList20_84:
    INCBIN "roms/magination.gbc", $8088C, $25

SECTION "ROM Bank 032 @$0808B1", ROMX[$48B1], BANK[32]
SpriteList20_85:
    INCBIN "roms/magination.gbc", $808B1, $19

SECTION "ROM Bank 032 @$0808CA", ROMX[$48CA], BANK[32]
SpriteList20_86:
    INCBIN "roms/magination.gbc", $808CA, $21

SECTION "ROM Bank 032 @$0808EB", ROMX[$48EB], BANK[32]
SpriteList20_87:
    INCBIN "roms/magination.gbc", $808EB, $19

SECTION "ROM Bank 032 @$080904", ROMX[$4904], BANK[32]
SpriteList20_88:
    INCBIN "roms/magination.gbc", $80904, $19

SECTION "ROM Bank 032 @$08091D", ROMX[$491D], BANK[32]
SpriteList20_89:
    INCBIN "roms/magination.gbc", $8091D, $19

SECTION "ROM Bank 032 @$080936", ROMX[$4936], BANK[32]
SpriteList20_90:
    INCBIN "roms/magination.gbc", $80936, $25

SECTION "ROM Bank 032 @$08095B", ROMX[$495B], BANK[32]
SpriteList20_91:
    INCBIN "roms/magination.gbc", $8095B, $25

SECTION "ROM Bank 032 @$080980", ROMX[$4980], BANK[32]
SpriteList20_92:
    INCBIN "roms/magination.gbc", $80980, $25

SECTION "ROM Bank 032 @$0809A5", ROMX[$49A5], BANK[32]
SpriteList20_93:
    INCBIN "roms/magination.gbc", $809A5, $25

SECTION "ROM Bank 032 @$0809CA", ROMX[$49CA], BANK[32]
SpriteList20_94:
    INCBIN "roms/magination.gbc", $809CA, $25

SECTION "ROM Bank 032 @$0809EF", ROMX[$49EF], BANK[32]
SpriteList20_95:
    INCBIN "roms/magination.gbc", $809EF, $25

SECTION "ROM Bank 032 @$080A14", ROMX[$4A14], BANK[32]
SpriteList20_96:
    INCBIN "roms/magination.gbc", $80A14, $19

SECTION "ROM Bank 032 @$080A2D", ROMX[$4A2D], BANK[32]
SpriteList20_97:
    INCBIN "roms/magination.gbc", $80A2D, $19

SECTION "ROM Bank 032 @$080A46", ROMX[$4A46], BANK[32]
SpriteList20_98:
    INCBIN "roms/magination.gbc", $80A46, $19

SECTION "ROM Bank 032 @$080A5F", ROMX[$4A5F], BANK[32]
SpriteList20_99:
    INCBIN "roms/magination.gbc", $80A5F, $19

SECTION "ROM Bank 032 @$080A78", ROMX[$4A78], BANK[32]
SpriteList20_100:
    INCBIN "roms/magination.gbc", $80A78, $19

SECTION "ROM Bank 032 @$080A91", ROMX[$4A91], BANK[32]
SpriteList20_101:
    INCBIN "roms/magination.gbc", $80A91, $19

SECTION "ROM Bank 032 @$080AAA", ROMX[$4AAA], BANK[32]
SpriteList20_102:
    INCBIN "roms/magination.gbc", $80AAA, $19

SECTION "ROM Bank 032 @$080AC3", ROMX[$4AC3], BANK[32]
SpriteList20_103:
    INCBIN "roms/magination.gbc", $80AC3, $19

SECTION "ROM Bank 032 @$080ADC", ROMX[$4ADC], BANK[32]
SpriteList20_104:
    INCBIN "roms/magination.gbc", $80ADC, $19

SECTION "ROM Bank 032 @$080AF5", ROMX[$4AF5], BANK[32]
SpriteList20_105:
    INCBIN "roms/magination.gbc", $80AF5, $19

SECTION "ROM Bank 032 @$080B0E", ROMX[$4B0E], BANK[32]
SpriteList20_106:
    INCBIN "roms/magination.gbc", $80B0E, $19

SECTION "ROM Bank 032 @$080B27", ROMX[$4B27], BANK[32]
SpriteList20_107:
    INCBIN "roms/magination.gbc", $80B27, $9

SECTION "ROM Bank 032 @$080B30", ROMX[$4B30], BANK[32]
SpriteList20_108:
    INCBIN "roms/magination.gbc", $80B30, $11

SECTION "ROM Bank 032 @$080B41", ROMX[$4B41], BANK[32]
SpriteList20_109:
    INCBIN "roms/magination.gbc", $80B41, $11

SECTION "ROM Bank 032 @$080B52", ROMX[$4B52], BANK[32]
SpriteList20_110:
    INCBIN "roms/magination.gbc", $80B52, $11

SECTION "ROM Bank 032 @$080B63", ROMX[$4B63], BANK[32]
SpriteList20_111:
    INCBIN "roms/magination.gbc", $80B63, $11

SECTION "ROM Bank 032 @$080B74", ROMX[$4B74], BANK[32]
SpriteList20_112:
    INCBIN "roms/magination.gbc", $80B74, $11

SECTION "ROM Bank 032 @$080B85", ROMX[$4B85], BANK[32]
SpriteList20_113:
    INCBIN "roms/magination.gbc", $80B85, $11

SECTION "ROM Bank 032 @$080B96", ROMX[$4B96], BANK[32]
SpriteList20_114:
    INCBIN "roms/magination.gbc", $80B96, $21

SECTION "ROM Bank 032 @$080BB7", ROMX[$4BB7], BANK[32]
SpriteList20_115:
    INCBIN "roms/magination.gbc", $80BB7, $21

SECTION "ROM Bank 032 @$080BD8", ROMX[$4BD8], BANK[32]
SpriteList20_116:
    INCBIN "roms/magination.gbc", $80BD8, $21

SECTION "ROM Bank 032 @$080BF9", ROMX[$4BF9], BANK[32]
SpriteList20_117:
    INCBIN "roms/magination.gbc", $80BF9, $21

SECTION "ROM Bank 032 @$080C1A", ROMX[$4C1A], BANK[32]
SpriteList20_118:
    INCBIN "roms/magination.gbc", $80C1A, $21

SECTION "ROM Bank 032 @$080C3B", ROMX[$4C3B], BANK[32]
SpriteList20_119:
    INCBIN "roms/magination.gbc", $80C3B, $21

SECTION "ROM Bank 032 @$080C5C", ROMX[$4C5C], BANK[32]
SpriteList20_120:
    INCBIN "roms/magination.gbc", $80C5C, $19

SECTION "ROM Bank 032 @$080C75", ROMX[$4C75], BANK[32]
SpriteList20_121:
    INCBIN "roms/magination.gbc", $80C75, $19

SECTION "ROM Bank 032 @$080C8E", ROMX[$4C8E], BANK[32]
SpriteList20_122:
    INCBIN "roms/magination.gbc", $80C8E, $19

SECTION "ROM Bank 032 @$080CA7", ROMX[$4CA7], BANK[32]
SpriteList20_123:
    INCBIN "roms/magination.gbc", $80CA7, $19

SECTION "ROM Bank 032 @$080CC0", ROMX[$4CC0], BANK[32]
SpriteList20_124:
    INCBIN "roms/magination.gbc", $80CC0, $19

SECTION "ROM Bank 032 @$080CD9", ROMX[$4CD9], BANK[32]
SpriteList20_125:
    INCBIN "roms/magination.gbc", $80CD9, $19

SECTION "ROM Bank 032 @$080CF2", ROMX[$4CF2], BANK[32]
SpriteList20_126:
    INCBIN "roms/magination.gbc", $80CF2, $19

SECTION "ROM Bank 032 @$080D0B", ROMX[$4D0B], BANK[32]
SpriteList20_127:
    INCBIN "roms/magination.gbc", $80D0B, $19

SECTION "ROM Bank 032 @$080D24", ROMX[$4D24], BANK[32]
SpriteList20_128:
    INCBIN "roms/magination.gbc", $80D24, $19

SECTION "ROM Bank 032 @$080D3D", ROMX[$4D3D], BANK[32]
SpriteList20_129:
    INCBIN "roms/magination.gbc", $80D3D, $19

SECTION "ROM Bank 032 @$080D56", ROMX[$4D56], BANK[32]
SpriteList20_130:
    INCBIN "roms/magination.gbc", $80D56, $19

SECTION "ROM Bank 032 @$080D6F", ROMX[$4D6F], BANK[32]
SpriteList20_131:
    INCBIN "roms/magination.gbc", $80D6F, $19

SECTION "ROM Bank 032 @$080D88", ROMX[$4D88], BANK[32]
SpriteList20_132:
    INCBIN "roms/magination.gbc", $80D88, $19

SECTION "ROM Bank 032 @$080DA1", ROMX[$4DA1], BANK[32]
SpriteList20_133:
    INCBIN "roms/magination.gbc", $80DA1, $19

SECTION "ROM Bank 032 @$080DBA", ROMX[$4DBA], BANK[32]
SpriteList20_134:
    INCBIN "roms/magination.gbc", $80DBA, $19

SECTION "ROM Bank 032 @$080DD3", ROMX[$4DD3], BANK[32]
SpriteList20_135:
    INCBIN "roms/magination.gbc", $80DD3, $19

SECTION "ROM Bank 032 @$080DEC", ROMX[$4DEC], BANK[32]
SpriteList20_136:
    INCBIN "roms/magination.gbc", $80DEC, $19

SECTION "ROM Bank 032 @$080E05", ROMX[$4E05], BANK[32]
SpriteList20_137:
    INCBIN "roms/magination.gbc", $80E05, $19

SECTION "ROM Bank 032 @$080E1E", ROMX[$4E1E], BANK[32]
SpriteList20_138:
    INCBIN "roms/magination.gbc", $80E1E, $D

SECTION "ROM Bank 032 @$080E2B", ROMX[$4E2B], BANK[32]
SpriteList20_139:
    INCBIN "roms/magination.gbc", $80E2B, $D

SECTION "ROM Bank 032 @$080E38", ROMX[$4E38], BANK[32]
SpriteList20_140:
    INCBIN "roms/magination.gbc", $80E38, $D

SECTION "ROM Bank 032 @$080E45", ROMX[$4E45], BANK[32]
SpriteList20_141:
    INCBIN "roms/magination.gbc", $80E45, $D

SECTION "ROM Bank 032 @$080E52", ROMX[$4E52], BANK[32]
SpriteList20_142:
    INCBIN "roms/magination.gbc", $80E52, $D

SECTION "ROM Bank 032 @$080E5F", ROMX[$4E5F], BANK[32]
SpriteList20_143:
    INCBIN "roms/magination.gbc", $80E5F, $D

SECTION "ROM Bank 032 @$080E6C", ROMX[$4E6C], BANK[32]
SpriteList20_144:
    INCBIN "roms/magination.gbc", $80E6C, $11

SECTION "ROM Bank 032 @$080E7D", ROMX[$4E7D], BANK[32]
SpriteList20_145:
    INCBIN "roms/magination.gbc", $80E7D, $D

SECTION "ROM Bank 032 @$080E8A", ROMX[$4E8A], BANK[32]
SpriteList20_146:
    INCBIN "roms/magination.gbc", $80E8A, $11

SECTION "ROM Bank 032 @$080E9B", ROMX[$4E9B], BANK[32]
SpriteList20_147:
    INCBIN "roms/magination.gbc", $80E9B, $11

SECTION "ROM Bank 032 @$080EAC", ROMX[$4EAC], BANK[32]
SpriteList20_148:
    INCBIN "roms/magination.gbc", $80EAC, $D

SECTION "ROM Bank 032 @$080EB9", ROMX[$4EB9], BANK[32]
SpriteList20_149:
    INCBIN "roms/magination.gbc", $80EB9, $11

SECTION "ROM Bank 032 @$080ECA", ROMX[$4ECA], BANK[32]
SpriteList20_150:
    INCBIN "roms/magination.gbc", $80ECA, $21

SECTION "ROM Bank 032 @$080EEB", ROMX[$4EEB], BANK[32]
SpriteList20_151:
    INCBIN "roms/magination.gbc", $80EEB, $21

SECTION "ROM Bank 032 @$080F0C", ROMX[$4F0C], BANK[32]
SpriteList20_152:
    INCBIN "roms/magination.gbc", $80F0C, $21

SECTION "ROM Bank 032 @$080F2D", ROMX[$4F2D], BANK[32]
SpriteList20_153:
    INCBIN "roms/magination.gbc", $80F2D, $21

SECTION "Sprite animation scripts bank $20", ROMX[$4F4E], BANK[32]
    INCBIN "roms/magination.gbc", $80F4E, $2E5A

SECTION "Zero padding from $083DA8", ROMX[$7DA8], BANK[32]
    ds $258, $00 ; zero padding to the end of bank $20

SECTION "ROM Bank 033", ROMX[$4000], BANK[33]
; script_lists_bank21.asm: not published here (it assembles data copied from the ROM)
ScriptList21_4000:
    INCBIN "roms/magination.gbc", $84000, $9

SECTION "ROM Bank 033 @$084009", ROMX[$4009], BANK[33]
ScriptList21_4009:
    INCBIN "roms/magination.gbc", $84009, $9

SECTION "ROM Bank 033 @$084012", ROMX[$4012], BANK[33]
ScriptList21_4012:
    INCBIN "roms/magination.gbc", $84012, $5

SECTION "ROM Bank 033 @$084017", ROMX[$4017], BANK[33]
ScriptList21_4017:
    INCBIN "roms/magination.gbc", $84017, $9

SECTION "ROM Bank 033 @$084020", ROMX[$4020], BANK[33]
ScriptList21_4020:
    INCBIN "roms/magination.gbc", $84020, $9

SECTION "ROM Bank 033 @$084029", ROMX[$4029], BANK[33]
ScriptList21_4029:
    INCBIN "roms/magination.gbc", $84029, $9

SECTION "ROM Bank 033 @$084032", ROMX[$4032], BANK[33]
ScriptList21_4032:
    INCBIN "roms/magination.gbc", $84032, $D

SECTION "ROM Bank 033 @$08403F", ROMX[$403F], BANK[33]
ScriptList21_403F:
    INCBIN "roms/magination.gbc", $8403F, $9

SECTION "ROM Bank 033 @$084048", ROMX[$4048], BANK[33]
ScriptList21_4048:
    INCBIN "roms/magination.gbc", $84048, $5

SECTION "ROM Bank 033 @$08404D", ROMX[$404D], BANK[33]
ScriptList21_404D:
    INCBIN "roms/magination.gbc", $8404D, $9

SECTION "ROM Bank 033 @$084056", ROMX[$4056], BANK[33]
ScriptList21_4056:
    INCBIN "roms/magination.gbc", $84056, $5

SECTION "ROM Bank 033 @$08405B", ROMX[$405B], BANK[33]
ScriptList21_405B:
    INCBIN "roms/magination.gbc", $8405B, $D

SECTION "ROM Bank 033 @$084068", ROMX[$4068], BANK[33]
ScriptList21_4068:
    INCBIN "roms/magination.gbc", $84068, $5

SECTION "ROM Bank 033 @$08406D", ROMX[$406D], BANK[33]
ScriptList21_406D:
    INCBIN "roms/magination.gbc", $8406D, $5

SECTION "ROM Bank 033 @$084072", ROMX[$4072], BANK[33]
ScriptList21_4072:
    INCBIN "roms/magination.gbc", $84072, $9

SECTION "ROM Bank 033 @$08407B", ROMX[$407B], BANK[33]
ScriptList21_407B:
    INCBIN "roms/magination.gbc", $8407B, $9

SECTION "ROM Bank 033 @$084084", ROMX[$4084], BANK[33]
ScriptList21_4084:
    INCBIN "roms/magination.gbc", $84084, $9

SECTION "ROM Bank 033 @$08408D", ROMX[$408D], BANK[33]
ScriptList21_408D:
    INCBIN "roms/magination.gbc", $8408D, $9

SECTION "ROM Bank 033 @$084096", ROMX[$4096], BANK[33]
ScriptList21_4096:
    INCBIN "roms/magination.gbc", $84096, $D

SECTION "ROM Bank 033 @$0840A3", ROMX[$40A3], BANK[33]
ScriptList21_40A3:
    INCBIN "roms/magination.gbc", $840A3, $9

SECTION "ROM Bank 033 @$0840AC", ROMX[$40AC], BANK[33]
ScriptList21_40AC:
    INCBIN "roms/magination.gbc", $840AC, $5

SECTION "ROM Bank 033 @$0840B1", ROMX[$40B1], BANK[33]
ScriptList21_40B1:
    INCBIN "roms/magination.gbc", $840B1, $D

SECTION "ROM Bank 033 @$0840BE", ROMX[$40BE], BANK[33]
ScriptList21_40BE:
    INCBIN "roms/magination.gbc", $840BE, $D

SECTION "ROM Bank 033 @$0840CB", ROMX[$40CB], BANK[33]
ScriptList21_40CB:
    INCBIN "roms/magination.gbc", $840CB, $D

SECTION "ROM Bank 033 @$0840D8", ROMX[$40D8], BANK[33]
ScriptList21_40D8:
    INCBIN "roms/magination.gbc", $840D8, $D

SECTION "ROM Bank 033 @$0840E5", ROMX[$40E5], BANK[33]
ScriptList21_40E5:
    INCBIN "roms/magination.gbc", $840E5, $5

SECTION "ROM Bank 033 @$0840EA", ROMX[$40EA], BANK[33]
ScriptList21_40EA:
    INCBIN "roms/magination.gbc", $840EA, $9

SECTION "ROM Bank 033 @$0840F3", ROMX[$40F3], BANK[33]
ScriptList21_40F3:
    INCBIN "roms/magination.gbc", $840F3, $5

SECTION "ROM Bank 033 @$0840F8", ROMX[$40F8], BANK[33]
ScriptList21_40F8:
    INCBIN "roms/magination.gbc", $840F8, $D

SECTION "ROM Bank 033 @$084105", ROMX[$4105], BANK[33]
ScriptList21_4105:
    INCBIN "roms/magination.gbc", $84105, $5

SECTION "ROM Bank 033 @$08410A", ROMX[$410A], BANK[33]
ScriptList21_410A:
    INCBIN "roms/magination.gbc", $8410A, $11

SECTION "ROM Bank 033 @$08411B", ROMX[$411B], BANK[33]
ScriptList21_411B:
    INCBIN "roms/magination.gbc", $8411B, $5

SECTION "ROM Bank 033 @$084120", ROMX[$4120], BANK[33]
ScriptList21_4120:
    INCBIN "roms/magination.gbc", $84120, $11

SECTION "ROM Bank 033 @$084131", ROMX[$4131], BANK[33]
ScriptList21_4131:
    INCBIN "roms/magination.gbc", $84131, $D

SECTION "ROM Bank 033 @$08413E", ROMX[$413E], BANK[33]
ScriptList21_413E:
    INCBIN "roms/magination.gbc", $8413E, $9

SECTION "ROM Bank 033 @$084147", ROMX[$4147], BANK[33]
ScriptList21_4147:
    INCBIN "roms/magination.gbc", $84147, $5

SECTION "ROM Bank 033 @$08414C", ROMX[$414C], BANK[33]
ScriptList21_414C:
    INCBIN "roms/magination.gbc", $8414C, $9

SECTION "ROM Bank 033 @$084155", ROMX[$4155], BANK[33]
ScriptList21_4155:
    INCBIN "roms/magination.gbc", $84155, $5

SECTION "ROM Bank 033 @$08415A", ROMX[$415A], BANK[33]
ScriptList21_415A:
    INCBIN "roms/magination.gbc", $8415A, $D

SECTION "ROM Bank 033 @$084167", ROMX[$4167], BANK[33]
ScriptList21_4167:
    INCBIN "roms/magination.gbc", $84167, $5

SECTION "ROM Bank 033 @$08416C", ROMX[$416C], BANK[33]
ScriptList21_416C:
    INCBIN "roms/magination.gbc", $8416C, $9

SECTION "ROM Bank 033 @$084175", ROMX[$4175], BANK[33]
ScriptList21_4175:
    INCBIN "roms/magination.gbc", $84175, $5

SECTION "ROM Bank 033 @$08417A", ROMX[$417A], BANK[33]
ScriptList21_417A:
    INCBIN "roms/magination.gbc", $8417A, $9

SECTION "ROM Bank 033 @$084183", ROMX[$4183], BANK[33]
ScriptList21_4183:
    INCBIN "roms/magination.gbc", $84183, $5

SECTION "ROM Bank 033 @$084188", ROMX[$4188], BANK[33]
ScriptList21_4188:
    INCBIN "roms/magination.gbc", $84188, $D

SECTION "ROM Bank 033 @$084195", ROMX[$4195], BANK[33]
ScriptList21_4195:
    INCBIN "roms/magination.gbc", $84195, $9

SECTION "ROM Bank 033 @$08419E", ROMX[$419E], BANK[33]
ScriptList21_419E:
    INCBIN "roms/magination.gbc", $8419E, $9

SECTION "ROM Bank 033 @$0841A7", ROMX[$41A7], BANK[33]
ScriptList21_41A7:
    INCBIN "roms/magination.gbc", $841A7, $D

SECTION "ROM Bank 033 @$0841B4", ROMX[$41B4], BANK[33]
ScriptList21_41B4:
    INCBIN "roms/magination.gbc", $841B4, $5

SECTION "ROM Bank 033 @$0841B9", ROMX[$41B9], BANK[33]
ScriptList21_41B9:
    INCBIN "roms/magination.gbc", $841B9, $5

SECTION "ROM Bank 033 @$0841BE", ROMX[$41BE], BANK[33]
ScriptList21_41BE:
    INCBIN "roms/magination.gbc", $841BE, $5

SECTION "ROM Bank 033 @$0841C3", ROMX[$41C3], BANK[33]
ScriptList21_41C3:
    INCBIN "roms/magination.gbc", $841C3, $9

SECTION "ROM Bank 033 @$0841CC", ROMX[$41CC], BANK[33]
ScriptList21_41CC:
    INCBIN "roms/magination.gbc", $841CC, $5

SECTION "ROM Bank 033 @$0841D1", ROMX[$41D1], BANK[33]
ScriptList21_41D1:
    INCBIN "roms/magination.gbc", $841D1, $5

SECTION "ROM Bank 033 @$0841D6", ROMX[$41D6], BANK[33]
ScriptList21_41D6:
    INCBIN "roms/magination.gbc", $841D6, $9

SECTION "ROM Bank 033 @$0841DF", ROMX[$41DF], BANK[33]
ScriptList21_41DF:
    INCBIN "roms/magination.gbc", $841DF, $D

SECTION "ROM Bank 033 @$0841EC", ROMX[$41EC], BANK[33]
ScriptList21_41EC:
    INCBIN "roms/magination.gbc", $841EC, $D

SECTION "ROM Bank 033 @$0841F9", ROMX[$41F9], BANK[33]
ScriptList21_41F9:
    INCBIN "roms/magination.gbc", $841F9, $5

SECTION "ROM Bank 033 @$0841FE", ROMX[$41FE], BANK[33]
ScriptList21_41FE:
    INCBIN "roms/magination.gbc", $841FE, $5

SECTION "ROM Bank 033 @$084203", ROMX[$4203], BANK[33]
ScriptList21_4203:
    INCBIN "roms/magination.gbc", $84203, $9

SECTION "ROM Bank 033 @$08420C", ROMX[$420C], BANK[33]
ScriptList21_420C:
    INCBIN "roms/magination.gbc", $8420C, $9

SECTION "ROM Bank 033 @$084215", ROMX[$4215], BANK[33]
ScriptList21_4215:
    INCBIN "roms/magination.gbc", $84215, $5

SECTION "ROM Bank 033 @$08421A", ROMX[$421A], BANK[33]
ScriptList21_421A:
    INCBIN "roms/magination.gbc", $8421A, $9

SECTION "ROM Bank 033 @$084223", ROMX[$4223], BANK[33]
ScriptList21_4223:
    INCBIN "roms/magination.gbc", $84223, $5

SECTION "ROM Bank 033 @$084228", ROMX[$4228], BANK[33]
ScriptList21_4228:
    INCBIN "roms/magination.gbc", $84228, $9

SECTION "ROM Bank 033 @$084231", ROMX[$4231], BANK[33]
ScriptList21_4231:
    INCBIN "roms/magination.gbc", $84231, $9

SECTION "ROM Bank 033 @$08423A", ROMX[$423A], BANK[33]
ScriptList21_423A:
    INCBIN "roms/magination.gbc", $8423A, $5

SECTION "ROM Bank 033 @$08423F", ROMX[$423F], BANK[33]
ScriptList21_423F:
    INCBIN "roms/magination.gbc", $8423F, $9

SECTION "ROM Bank 033 @$084248", ROMX[$4248], BANK[33]
ScriptList21_4248:
    INCBIN "roms/magination.gbc", $84248, $29

SECTION "ROM Bank 033 @$084271", ROMX[$4271], BANK[33]
ScriptList21_4271:
    INCBIN "roms/magination.gbc", $84271, $D

SECTION "ROM Bank 033 @$08427E", ROMX[$427E], BANK[33]
ScriptList21_427E:
    INCBIN "roms/magination.gbc", $8427E, $15

SECTION "ROM Bank 033 @$084293", ROMX[$4293], BANK[33]
ScriptList21_4293:
    INCBIN "roms/magination.gbc", $84293, $5

SECTION "ROM Bank 033 @$084298", ROMX[$4298], BANK[33]
ScriptList21_4298:
    INCBIN "roms/magination.gbc", $84298, $5

SECTION "ROM Bank 033 @$08429D", ROMX[$429D], BANK[33]
ScriptList21_429D:
    INCBIN "roms/magination.gbc", $8429D, $D

SECTION "ROM Bank 033 @$0842AA", ROMX[$42AA], BANK[33]
ScriptList21_42AA:
    INCBIN "roms/magination.gbc", $842AA, $5

SECTION "ROM Bank 033 @$0842AF", ROMX[$42AF], BANK[33]
ScriptList21_42AF:
    INCBIN "roms/magination.gbc", $842AF, $5

SECTION "ROM Bank 033 @$0842B4", ROMX[$42B4], BANK[33]
ScriptList21_42B4:
    INCBIN "roms/magination.gbc", $842B4, $D

SECTION "ROM Bank 033 @$0842C1", ROMX[$42C1], BANK[33]
ScriptList21_42C1:
    INCBIN "roms/magination.gbc", $842C1, $5

SECTION "ROM Bank 033 @$0842C6", ROMX[$42C6], BANK[33]
ScriptList21_42C6:
    INCBIN "roms/magination.gbc", $842C6, $15

SECTION "ROM Bank 033 @$0842DB", ROMX[$42DB], BANK[33]
ScriptList21_42DB:
    INCBIN "roms/magination.gbc", $842DB, $9

SECTION "ROM Bank 033 @$0842E4", ROMX[$42E4], BANK[33]
ScriptList21_42E4:
    INCBIN "roms/magination.gbc", $842E4, $9

SECTION "ROM Bank 033 @$0842ED", ROMX[$42ED], BANK[33]
ScriptList21_42ED:
    INCBIN "roms/magination.gbc", $842ED, $9

SECTION "ROM Bank 033 @$0842F6", ROMX[$42F6], BANK[33]
ScriptList21_42F6:
    INCBIN "roms/magination.gbc", $842F6, $19

SECTION "ROM Bank 033 @$08430F", ROMX[$430F], BANK[33]
ScriptList21_430F:
    INCBIN "roms/magination.gbc", $8430F, $D

SECTION "ROM Bank 033 @$08431C", ROMX[$431C], BANK[33]
ScriptList21_431C:
    INCBIN "roms/magination.gbc", $8431C, $D

SECTION "ROM Bank 033 @$084329", ROMX[$4329], BANK[33]
ScriptList21_4329:
    INCBIN "roms/magination.gbc", $84329, $D

SECTION "ROM Bank 033 @$084336", ROMX[$4336], BANK[33]
ScriptList21_4336:
    INCBIN "roms/magination.gbc", $84336, $5

SECTION "ROM Bank 033 @$08433B", ROMX[$433B], BANK[33]
ScriptList21_433B:
    INCBIN "roms/magination.gbc", $8433B, $9

SECTION "ROM Bank 033 @$084344", ROMX[$4344], BANK[33]
ScriptList21_4344:
    INCBIN "roms/magination.gbc", $84344, $D

SECTION "ROM Bank 033 @$084351", ROMX[$4351], BANK[33]
ScriptList21_4351:
    INCBIN "roms/magination.gbc", $84351, $9

SECTION "ROM Bank 033 @$08435A", ROMX[$435A], BANK[33]
ScriptList21_435A:
    INCBIN "roms/magination.gbc", $8435A, $9

SECTION "ROM Bank 033 @$084363", ROMX[$4363], BANK[33]
ScriptList21_4363:
    INCBIN "roms/magination.gbc", $84363, $9

SECTION "ROM Bank 033 @$08436C", ROMX[$436C], BANK[33]
ScriptList21_436C:
    INCBIN "roms/magination.gbc", $8436C, $9

SECTION "ROM Bank 033 @$084375", ROMX[$4375], BANK[33]
ScriptList21_4375:
    INCBIN "roms/magination.gbc", $84375, $1D

SECTION "ROM Bank 033 @$084392", ROMX[$4392], BANK[33]
ScriptList21_4392:
    INCBIN "roms/magination.gbc", $84392, $9

SECTION "ROM Bank 033 @$08439B", ROMX[$439B], BANK[33]
ScriptList21_439B:
    INCBIN "roms/magination.gbc", $8439B, $15

SECTION "ROM Bank 033 @$0843B0", ROMX[$43B0], BANK[33]
ScriptList21_43B0:
    INCBIN "roms/magination.gbc", $843B0, $5

SECTION "ROM Bank 033 @$0843B5", ROMX[$43B5], BANK[33]
ScriptList21_43B5:
    INCBIN "roms/magination.gbc", $843B5, $11

SECTION "ROM Bank 033 @$0843C6", ROMX[$43C6], BANK[33]
ScriptList21_43C6:
    INCBIN "roms/magination.gbc", $843C6, $5

SECTION "ROM Bank 033 @$0843CB", ROMX[$43CB], BANK[33]
ScriptList21_43CB:
    INCBIN "roms/magination.gbc", $843CB, $21

SECTION "ROM Bank 033 @$0843EC", ROMX[$43EC], BANK[33]
ScriptList21_43EC:
    INCBIN "roms/magination.gbc", $843EC, $15

SECTION "ROM Bank 033 @$084401", ROMX[$4401], BANK[33]
ScriptList21_4401:
    INCBIN "roms/magination.gbc", $84401, $15

SECTION "ROM Bank 033 @$084416", ROMX[$4416], BANK[33]
ScriptList21_4416:
    INCBIN "roms/magination.gbc", $84416, $D

SECTION "ROM Bank 033 @$084423", ROMX[$4423], BANK[33]
ScriptList21_4423:
    INCBIN "roms/magination.gbc", $84423, $5

SECTION "ROM Bank 033 @$084428", ROMX[$4428], BANK[33]
ScriptList21_4428:
    INCBIN "roms/magination.gbc", $84428, $11

SECTION "ROM Bank 033 @$084439", ROMX[$4439], BANK[33]
ScriptList21_4439:
    INCBIN "roms/magination.gbc", $84439, $9

SECTION "ROM Bank 033 @$084442", ROMX[$4442], BANK[33]
ScriptList21_4442:
    INCBIN "roms/magination.gbc", $84442, $9

SECTION "ROM Bank 033 @$08444B", ROMX[$444B], BANK[33]
ScriptList21_444B:
    INCBIN "roms/magination.gbc", $8444B, $5

SECTION "ROM Bank 033 @$084450", ROMX[$4450], BANK[33]
ScriptList21_4450:
    INCBIN "roms/magination.gbc", $84450, $5

SECTION "ROM Bank 033 @$084455", ROMX[$4455], BANK[33]
ScriptList21_4455:
    INCBIN "roms/magination.gbc", $84455, $5

SECTION "ROM Bank 033 @$08445A", ROMX[$445A], BANK[33]
ScriptList21_445A:
    INCBIN "roms/magination.gbc", $8445A, $15

SECTION "ROM Bank 033 @$08446F", ROMX[$446F], BANK[33]
ScriptList21_446F:
    INCBIN "roms/magination.gbc", $8446F, $5

SECTION "ROM Bank 033 @$084474", ROMX[$4474], BANK[33]
ScriptList21_4474:
    INCBIN "roms/magination.gbc", $84474, $15

SECTION "ROM Bank 033 @$084489", ROMX[$4489], BANK[33]
ScriptList21_4489:
    INCBIN "roms/magination.gbc", $84489, $5

SECTION "ROM Bank 033 @$08448E", ROMX[$448E], BANK[33]
ScriptList21_448E:
    INCBIN "roms/magination.gbc", $8448E, $15

SECTION "ROM Bank 033 @$0844A3", ROMX[$44A3], BANK[33]
ScriptList21_44A3:
    INCBIN "roms/magination.gbc", $844A3, $5

SECTION "ROM Bank 033 @$0844A8", ROMX[$44A8], BANK[33]
ScriptList21_44A8:
    INCBIN "roms/magination.gbc", $844A8, $15

SECTION "ROM Bank 033 @$0844BD", ROMX[$44BD], BANK[33]
ScriptList21_44BD:
    INCBIN "roms/magination.gbc", $844BD, $9

SECTION "ROM Bank 033 @$0844C6", ROMX[$44C6], BANK[33]
ScriptList21_44C6:
    INCBIN "roms/magination.gbc", $844C6, $5

SECTION "ROM Bank 033 @$0844CB", ROMX[$44CB], BANK[33]
ScriptList21_44CB:
    INCBIN "roms/magination.gbc", $844CB, $5

SECTION "ROM Bank 033 @$0844D0", ROMX[$44D0], BANK[33]
ScriptList21_44D0:
    INCBIN "roms/magination.gbc", $844D0, $5

SECTION "ROM Bank 033 @$0844D5", ROMX[$44D5], BANK[33]
ScriptList21_44D5:
    INCBIN "roms/magination.gbc", $844D5, $1D

SECTION "ROM Bank 033 @$0844F2", ROMX[$44F2], BANK[33]
ScriptList21_44F2:
    INCBIN "roms/magination.gbc", $844F2, $5

SECTION "ROM Bank 033 @$0844F7", ROMX[$44F7], BANK[33]
ScriptList21_44F7:
    INCBIN "roms/magination.gbc", $844F7, $5

SECTION "ROM Bank 033 @$0844FC", ROMX[$44FC], BANK[33]
ScriptList21_44FC:
    INCBIN "roms/magination.gbc", $844FC, $9

SECTION "ROM Bank 033 @$084505", ROMX[$4505], BANK[33]
ScriptList21_4505:
    INCBIN "roms/magination.gbc", $84505, $31

SECTION "ROM Bank 033 @$084536", ROMX[$4536], BANK[33]
ScriptList21_4536:
    INCBIN "roms/magination.gbc", $84536, $5

SECTION "ROM Bank 033 @$08453B", ROMX[$453B], BANK[33]
ScriptList21_453B:
    INCBIN "roms/magination.gbc", $8453B, $31

SECTION "ROM Bank 033 @$08456C", ROMX[$456C], BANK[33]
ScriptList21_456C:
    INCBIN "roms/magination.gbc", $8456C, $5

SECTION "ROM Bank 033 @$084571", ROMX[$4571], BANK[33]
ScriptList21_4571:
    INCBIN "roms/magination.gbc", $84571, $15

SECTION "ROM Bank 033 @$084586", ROMX[$4586], BANK[33]
ScriptList21_4586:
    INCBIN "roms/magination.gbc", $84586, $5

SECTION "ROM Bank 033 @$08458B", ROMX[$458B], BANK[33]
ScriptList21_458B:
    INCBIN "roms/magination.gbc", $8458B, $1D

SECTION "ROM Bank 033 @$0845A8", ROMX[$45A8], BANK[33]
ScriptList21_45A8:
    INCBIN "roms/magination.gbc", $845A8, $5

SECTION "ROM Bank 033 @$0845AD", ROMX[$45AD], BANK[33]
ScriptList21_45AD:
    INCBIN "roms/magination.gbc", $845AD, $11

SECTION "ROM Bank 033 @$0845BE", ROMX[$45BE], BANK[33]
ScriptList21_45BE:
    INCBIN "roms/magination.gbc", $845BE, $5

SECTION "ROM Bank 033 @$0845C3", ROMX[$45C3], BANK[33]
ScriptList21_45C3:
    INCBIN "roms/magination.gbc", $845C3, $D

SECTION "ROM Bank 033 @$0845D0", ROMX[$45D0], BANK[33]
ScriptList21_45D0:
    INCBIN "roms/magination.gbc", $845D0, $5

SECTION "ROM Bank 033 @$0845D5", ROMX[$45D5], BANK[33]
ScriptList21_45D5:
    INCBIN "roms/magination.gbc", $845D5, $1D

SECTION "ROM Bank 033 @$0845F2", ROMX[$45F2], BANK[33]
ScriptList21_45F2:
    INCBIN "roms/magination.gbc", $845F2, $5

SECTION "ROM Bank 033 @$0845F7", ROMX[$45F7], BANK[33]
ScriptList21_45F7:
    INCBIN "roms/magination.gbc", $845F7, $19

SECTION "ROM Bank 033 @$084610", ROMX[$4610], BANK[33]
ScriptList21_4610:
    INCBIN "roms/magination.gbc", $84610, $5

SECTION "ROM Bank 033 @$084615", ROMX[$4615], BANK[33]
ScriptList21_4615:
    INCBIN "roms/magination.gbc", $84615, $5

SECTION "ROM Bank 033 @$08461A", ROMX[$461A], BANK[33]
ScriptList21_461A:
    INCBIN "roms/magination.gbc", $8461A, $15

SECTION "ROM Bank 033 @$08462F", ROMX[$462F], BANK[33]
ScriptList21_462F:
    INCBIN "roms/magination.gbc", $8462F, $15

SECTION "ROM Bank 033 @$084644", ROMX[$4644], BANK[33]
ScriptList21_4644:
    INCBIN "roms/magination.gbc", $84644, $1

SECTION "ROM Bank 033 @$084645", ROMX[$4645], BANK[33]
ScriptList21_4645:
    INCBIN "roms/magination.gbc", $84645, $D

SECTION "ROM Bank 033 @$084652", ROMX[$4652], BANK[33]
ScriptList21_4652:
    INCBIN "roms/magination.gbc", $84652, $D

SECTION "ROM Bank 033 @$08465F", ROMX[$465F], BANK[33]
ScriptList21_465F:
    INCBIN "roms/magination.gbc", $8465F, $9

SECTION "ROM Bank 033 @$084668", ROMX[$4668], BANK[33]
ScriptList21_4668:
    INCBIN "roms/magination.gbc", $84668, $9

SECTION "ROM Bank 033 @$084671", ROMX[$4671], BANK[33]
ScriptList21_4671:
    INCBIN "roms/magination.gbc", $84671, $D

SECTION "ROM Bank 033 @$08467E", ROMX[$467E], BANK[33]
ScriptList21_467E:
    INCBIN "roms/magination.gbc", $8467E, $9

SECTION "ROM Bank 033 @$084687", ROMX[$4687], BANK[33]
ScriptList21_4687:
    INCBIN "roms/magination.gbc", $84687, $9

SECTION "ROM Bank 033 @$084690", ROMX[$4690], BANK[33]
ScriptList21_4690:
    INCBIN "roms/magination.gbc", $84690, $9

SECTION "ROM Bank 033 @$084699", ROMX[$4699], BANK[33]
ScriptList21_4699:
    INCBIN "roms/magination.gbc", $84699, $9

SECTION "ROM Bank 033 @$0846A2", ROMX[$46A2], BANK[33]
ScriptList21_46A2:
    INCBIN "roms/magination.gbc", $846A2, $9

SECTION "ROM Bank 033 @$0846AB", ROMX[$46AB], BANK[33]
ScriptList21_46AB:
    INCBIN "roms/magination.gbc", $846AB, $9

SECTION "ROM Bank 033 @$0846B4", ROMX[$46B4], BANK[33]
ScriptList21_46B4:
    INCBIN "roms/magination.gbc", $846B4, $9

SECTION "ROM Bank 033 @$0846BD", ROMX[$46BD], BANK[33]
ScriptList21_46BD:
    INCBIN "roms/magination.gbc", $846BD, $5

SECTION "ROM Bank 033 @$0846C2", ROMX[$46C2], BANK[33]
ScriptList21_46C2:
    INCBIN "roms/magination.gbc", $846C2, $5

SECTION "ROM Bank 033 @$0846C7", ROMX[$46C7], BANK[33]
ScriptList21_46C7:
    INCBIN "roms/magination.gbc", $846C7, $9

SECTION "ROM Bank 033 @$0846D0", ROMX[$46D0], BANK[33]
ScriptList21_46D0:
    INCBIN "roms/magination.gbc", $846D0, $D

SECTION "ROM Bank 033 @$0846DD", ROMX[$46DD], BANK[33]
ScriptList21_46DD:
    INCBIN "roms/magination.gbc", $846DD, $9

SECTION "ROM Bank 033 @$0846E6", ROMX[$46E6], BANK[33]
ScriptList21_46E6:
    INCBIN "roms/magination.gbc", $846E6, $11

SECTION "ROM Bank 033 @$0846F7", ROMX[$46F7], BANK[33]
ScriptList21_46F7:
    INCBIN "roms/magination.gbc", $846F7, $5

SECTION "ROM Bank 033 @$0846FC", ROMX[$46FC], BANK[33]
ScriptList21_46FC:
    INCBIN "roms/magination.gbc", $846FC, $5

SECTION "ROM Bank 033 @$084701", ROMX[$4701], BANK[33]
ScriptList21_4701:
    INCBIN "roms/magination.gbc", $84701, $D

SECTION "ROM Bank 033 @$08470E", ROMX[$470E], BANK[33]
ScriptList21_470E:
    INCBIN "roms/magination.gbc", $8470E, $5

SECTION "ROM Bank 033 @$084713", ROMX[$4713], BANK[33]
ScriptList21_4713:
    INCBIN "roms/magination.gbc", $84713, $5

SECTION "ROM Bank 033 @$084718", ROMX[$4718], BANK[33]
ScriptList21_4718:
    INCBIN "roms/magination.gbc", $84718, $11

SECTION "ROM Bank 033 @$084729", ROMX[$4729], BANK[33]
ScriptList21_4729:
    INCBIN "roms/magination.gbc", $84729, $5

SECTION "ROM Bank 033 @$08472E", ROMX[$472E], BANK[33]
ScriptList21_472E:
    INCBIN "roms/magination.gbc", $8472E, $9

SECTION "ROM Bank 033 @$084737", ROMX[$4737], BANK[33]
ScriptList21_4737:
    INCBIN "roms/magination.gbc", $84737, $D

SECTION "ROM Bank 033 @$084744", ROMX[$4744], BANK[33]
ScriptList21_4744:
    INCBIN "roms/magination.gbc", $84744, $9

SECTION "ROM Bank 033 @$08474D", ROMX[$474D], BANK[33]
ScriptList21_474D:
    INCBIN "roms/magination.gbc", $8474D, $5

SECTION "ROM Bank 033 @$084752", ROMX[$4752], BANK[33]
ScriptList21_4752:
    INCBIN "roms/magination.gbc", $84752, $9

SECTION "ROM Bank 033 @$08475B", ROMX[$475B], BANK[33]
ScriptList21_475B:
    INCBIN "roms/magination.gbc", $8475B, $11

SECTION "ROM Bank 033 @$08476C", ROMX[$476C], BANK[33]
ScriptList21_476C:
    INCBIN "roms/magination.gbc", $8476C, $5

SECTION "ROM Bank 033 @$084771", ROMX[$4771], BANK[33]
ScriptList21_4771:
    INCBIN "roms/magination.gbc", $84771, $9

SECTION "ROM Bank 033 @$08477A", ROMX[$477A], BANK[33]
ScriptList21_477A:
    INCBIN "roms/magination.gbc", $8477A, $D

SECTION "ROM Bank 033 @$084787", ROMX[$4787], BANK[33]
ScriptList21_4787:
    INCBIN "roms/magination.gbc", $84787, $9

SECTION "ROM Bank 033 @$084790", ROMX[$4790], BANK[33]
ScriptList21_4790:
    INCBIN "roms/magination.gbc", $84790, $9

SECTION "ROM Bank 033 @$084799", ROMX[$4799], BANK[33]
ScriptList21_4799:
    INCBIN "roms/magination.gbc", $84799, $9

SECTION "ROM Bank 033 @$0847A2", ROMX[$47A2], BANK[33]
ScriptList21_47A2:
    INCBIN "roms/magination.gbc", $847A2, $11

SECTION "ROM Bank 033 @$0847B3", ROMX[$47B3], BANK[33]
ScriptList21_47B3:
    INCBIN "roms/magination.gbc", $847B3, $D

SECTION "ROM Bank 033 @$0847C0", ROMX[$47C0], BANK[33]
ScriptList21_47C0:
    INCBIN "roms/magination.gbc", $847C0, $D

SECTION "ROM Bank 033 @$0847CD", ROMX[$47CD], BANK[33]
ScriptList21_47CD:
    INCBIN "roms/magination.gbc", $847CD, $D

SECTION "ROM Bank 033 @$0847DA", ROMX[$47DA], BANK[33]
ScriptList21_47DA:
    INCBIN "roms/magination.gbc", $847DA, $D

SECTION "ROM Bank 033 @$0847E7", ROMX[$47E7], BANK[33]
ScriptList21_47E7:
    INCBIN "roms/magination.gbc", $847E7, $9

SECTION "ROM Bank 033 @$0847F0", ROMX[$47F0], BANK[33]
ScriptList21_47F0:
    INCBIN "roms/magination.gbc", $847F0, $19

SECTION "ROM Bank 033 @$084809", ROMX[$4809], BANK[33]
ScriptList21_4809:
    INCBIN "roms/magination.gbc", $84809, $9

SECTION "ROM Bank 033 @$084812", ROMX[$4812], BANK[33]
ScriptList21_4812:
    INCBIN "roms/magination.gbc", $84812, $5

SECTION "ROM Bank 033 @$084817", ROMX[$4817], BANK[33]
ScriptList21_4817:
    INCBIN "roms/magination.gbc", $84817, $D

SECTION "ROM Bank 033 @$084824", ROMX[$4824], BANK[33]
ScriptList21_4824:
    INCBIN "roms/magination.gbc", $84824, $5

SECTION "ROM Bank 033 @$084829", ROMX[$4829], BANK[33]
ScriptList21_4829:
    INCBIN "roms/magination.gbc", $84829, $D

SECTION "ROM Bank 033 @$084836", ROMX[$4836], BANK[33]
ScriptList21_4836:
    INCBIN "roms/magination.gbc", $84836, $9

SECTION "ROM Bank 033 @$08483F", ROMX[$483F], BANK[33]
ScriptList21_483F:
    INCBIN "roms/magination.gbc", $8483F, $15

SECTION "ROM Bank 033 @$084854", ROMX[$4854], BANK[33]
ScriptList21_4854:
    INCBIN "roms/magination.gbc", $84854, $9

SECTION "ROM Bank 033 @$08485D", ROMX[$485D], BANK[33]
ScriptList21_485D:
    INCBIN "roms/magination.gbc", $8485D, $5

SECTION "ROM Bank 033 @$084862", ROMX[$4862], BANK[33]
ScriptList21_4862:
    INCBIN "roms/magination.gbc", $84862, $19

SECTION "ROM Bank 033 @$08487B", ROMX[$487B], BANK[33]
ScriptList21_487B:
    INCBIN "roms/magination.gbc", $8487B, $15

SECTION "ROM Bank 033 @$084890", ROMX[$4890], BANK[33]
ScriptList21_4890:
    INCBIN "roms/magination.gbc", $84890, $5

SECTION "ROM Bank 033 @$084895", ROMX[$4895], BANK[33]
ScriptList21_4895:
    INCBIN "roms/magination.gbc", $84895, $21

SECTION "ROM Bank 033 @$0848B6", ROMX[$48B6], BANK[33]
ScriptList21_48B6:
    INCBIN "roms/magination.gbc", $848B6, $19

SECTION "ROM Bank 033 @$0848CF", ROMX[$48CF], BANK[33]
ScriptList21_48CF:
    INCBIN "roms/magination.gbc", $848CF, $5

SECTION "ROM Bank 033 @$0848D4", ROMX[$48D4], BANK[33]
ScriptList21_48D4:
    INCBIN "roms/magination.gbc", $848D4, $5

SECTION "ROM Bank 033 @$0848D9", ROMX[$48D9], BANK[33]
ScriptList21_48D9:
    INCBIN "roms/magination.gbc", $848D9, $D

SECTION "ROM Bank 033 @$0848E6", ROMX[$48E6], BANK[33]
ScriptList21_48E6:
    INCBIN "roms/magination.gbc", $848E6, $21

SECTION "ROM Bank 033 @$084907", ROMX[$4907], BANK[33]
ScriptList21_4907:
    INCBIN "roms/magination.gbc", $84907, $5

SECTION "ROM Bank 033 @$08490C", ROMX[$490C], BANK[33]
ScriptList21_490C:
    INCBIN "roms/magination.gbc", $8490C, $1D

SECTION "ROM Bank 033 @$084929", ROMX[$4929], BANK[33]
ScriptList21_4929:
    INCBIN "roms/magination.gbc", $84929, $9

SECTION "ROM Bank 033 @$084932", ROMX[$4932], BANK[33]
ScriptList21_4932:
    INCBIN "roms/magination.gbc", $84932, $5

SECTION "ROM Bank 033 @$084937", ROMX[$4937], BANK[33]
ScriptList21_4937:
    INCBIN "roms/magination.gbc", $84937, $5

SECTION "ROM Bank 033 @$08493C", ROMX[$493C], BANK[33]
ScriptList21_493C:
    INCBIN "roms/magination.gbc", $8493C, $1D

SECTION "ROM Bank 033 @$084959", ROMX[$4959], BANK[33]
ScriptList21_4959:
    INCBIN "roms/magination.gbc", $84959, $19

SECTION "ROM Bank 033 @$084972", ROMX[$4972], BANK[33]
ScriptList21_4972:
    INCBIN "roms/magination.gbc", $84972, $19

SECTION "ROM Bank 033 @$08498B", ROMX[$498B], BANK[33]
ScriptList21_498B:
    INCBIN "roms/magination.gbc", $8498B, $11

SECTION "ROM Bank 033 @$08499C", ROMX[$499C], BANK[33]
ScriptList21_499C:
    INCBIN "roms/magination.gbc", $8499C, $9

SECTION "ROM Bank 033 @$0849A5", ROMX[$49A5], BANK[33]
ScriptList21_49A5:
    INCBIN "roms/magination.gbc", $849A5, $9

SECTION "ROM Bank 033 @$0849AE", ROMX[$49AE], BANK[33]
ScriptList21_49AE:
    INCBIN "roms/magination.gbc", $849AE, $9

SECTION "ROM Bank 033 @$0849B7", ROMX[$49B7], BANK[33]
ScriptList21_49B7:
    INCBIN "roms/magination.gbc", $849B7, $9

SECTION "ROM Bank 033 @$0849C0", ROMX[$49C0], BANK[33]
ScriptList21_49C0:
    INCBIN "roms/magination.gbc", $849C0, $9

SECTION "ROM Bank 033 @$0849C9", ROMX[$49C9], BANK[33]
ScriptList21_49C9:
    INCBIN "roms/magination.gbc", $849C9, $5

SECTION "ROM Bank 033 @$0849CE", ROMX[$49CE], BANK[33]
ScriptList21_49CE:
    INCBIN "roms/magination.gbc", $849CE, $9

SECTION "ROM Bank 033 @$0849D7", ROMX[$49D7], BANK[33]
ScriptList21_49D7:
    INCBIN "roms/magination.gbc", $849D7, $D

SECTION "ROM Bank 033 @$0849E4", ROMX[$49E4], BANK[33]
ScriptList21_49E4:
    INCBIN "roms/magination.gbc", $849E4, $5

SECTION "ROM Bank 033 @$0849E9", ROMX[$49E9], BANK[33]
ScriptList21_49E9:
    INCBIN "roms/magination.gbc", $849E9, $D

SECTION "ROM Bank 033 @$0849F6", ROMX[$49F6], BANK[33]
ScriptList21_49F6:
    INCBIN "roms/magination.gbc", $849F6, $39

SECTION "ROM Bank 033 @$084A2F", ROMX[$4A2F], BANK[33]
ScriptList21_4A2F:
    INCBIN "roms/magination.gbc", $84A2F, $39

SECTION "ROM Bank 033 @$084A68", ROMX[$4A68], BANK[33]
ScriptList21_4A68:
    INCBIN "roms/magination.gbc", $84A68, $39

SECTION "ROM Bank 033 @$084AA1", ROMX[$4AA1], BANK[33]
ScriptList21_4AA1:
    INCBIN "roms/magination.gbc", $84AA1, $39

SECTION "ROM Bank 033 @$084ADA", ROMX[$4ADA], BANK[33]
ScriptList21_4ADA:
    INCBIN "roms/magination.gbc", $84ADA, $11

SECTION "ROM Bank 033 @$084AEB", ROMX[$4AEB], BANK[33]
ScriptList21_4AEB:
    INCBIN "roms/magination.gbc", $84AEB, $D

SECTION "ROM Bank 033 @$084AF8", ROMX[$4AF8], BANK[33]
ScriptList21_4AF8:
    INCBIN "roms/magination.gbc", $84AF8, $9

SECTION "ROM Bank 033 @$084B01", ROMX[$4B01], BANK[33]
ScriptList21_4B01:
    INCBIN "roms/magination.gbc", $84B01, $5

SECTION "ROM Bank 033 @$084B06", ROMX[$4B06], BANK[33]
ScriptList21_4B06:
    INCBIN "roms/magination.gbc", $84B06, $19

SECTION "ROM Bank 033 @$084B1F", ROMX[$4B1F], BANK[33]
ScriptList21_4B1F:
    INCBIN "roms/magination.gbc", $84B1F, $5

SECTION "ROM Bank 033 @$084B24", ROMX[$4B24], BANK[33]
ScriptList21_4B24:
    INCBIN "roms/magination.gbc", $84B24, $15

SECTION "ROM Bank 033 @$084B39", ROMX[$4B39], BANK[33]
ScriptList21_4B39:
    INCBIN "roms/magination.gbc", $84B39, $5

SECTION "ROM Bank 033 @$084B3E", ROMX[$4B3E], BANK[33]
ScriptList21_4B3E:
    INCBIN "roms/magination.gbc", $84B3E, $5

SECTION "ROM Bank 033 @$084B43", ROMX[$4B43], BANK[33]
ScriptList21_4B43:
    INCBIN "roms/magination.gbc", $84B43, $2D

SECTION "ROM Bank 033 @$084B70", ROMX[$4B70], BANK[33]
ScriptList21_4B70:
    INCBIN "roms/magination.gbc", $84B70, $2D

SECTION "ROM Bank 033 @$084B9D", ROMX[$4B9D], BANK[33]
ScriptList21_4B9D:
    INCBIN "roms/magination.gbc", $84B9D, $5

SECTION "ROM Bank 033 @$084BA2", ROMX[$4BA2], BANK[33]
ScriptList21_4BA2:
    INCBIN "roms/magination.gbc", $84BA2, $15

SECTION "ROM Bank 033 @$084BB7", ROMX[$4BB7], BANK[33]
ScriptList21_4BB7:
    INCBIN "roms/magination.gbc", $84BB7, $5

SECTION "ROM Bank 033 @$084BBC", ROMX[$4BBC], BANK[33]
ScriptList21_4BBC:
    INCBIN "roms/magination.gbc", $84BBC, $21

SECTION "ROM Bank 033 @$084BDD", ROMX[$4BDD], BANK[33]
ScriptList21_4BDD:
    INCBIN "roms/magination.gbc", $84BDD, $5

SECTION "ROM Bank 033 @$084BE2", ROMX[$4BE2], BANK[33]
ScriptList21_4BE2:
    INCBIN "roms/magination.gbc", $84BE2, $25

SECTION "ROM Bank 033 @$084C07", ROMX[$4C07], BANK[33]
ScriptList21_4C07:
    INCBIN "roms/magination.gbc", $84C07, $9

SECTION "ROM Bank 033 @$084C10", ROMX[$4C10], BANK[33]
ScriptList21_4C10:
    INCBIN "roms/magination.gbc", $84C10, $5

SECTION "ROM Bank 033 @$084C15", ROMX[$4C15], BANK[33]
ScriptList21_4C15:
    INCBIN "roms/magination.gbc", $84C15, $21

SECTION "ROM Bank 033 @$084C36", ROMX[$4C36], BANK[33]
ScriptList21_4C36:
    INCBIN "roms/magination.gbc", $84C36, $D

SECTION "ROM Bank 033 @$084C43", ROMX[$4C43], BANK[33]
ScriptList21_4C43:
    INCBIN "roms/magination.gbc", $84C43, $9

SECTION "ROM Bank 033 @$084C4C", ROMX[$4C4C], BANK[33]
ScriptList21_4C4C:
    INCBIN "roms/magination.gbc", $84C4C, $D

SECTION "ROM Bank 033 @$084C59", ROMX[$4C59], BANK[33]
ScriptList21_4C59:
    INCBIN "roms/magination.gbc", $84C59, $5

SECTION "ROM Bank 033 @$084C5E", ROMX[$4C5E], BANK[33]
ScriptList21_4C5E:
    INCBIN "roms/magination.gbc", $84C5E, $9

SECTION "ROM Bank 033 @$084C67", ROMX[$4C67], BANK[33]
ScriptList21_4C67:
    INCBIN "roms/magination.gbc", $84C67, $9

SECTION "ROM Bank 033 @$084C70", ROMX[$4C70], BANK[33]
ScriptList21_4C70:
    INCBIN "roms/magination.gbc", $84C70, $9

SECTION "ROM Bank 033 @$084C79", ROMX[$4C79], BANK[33]
ScriptList21_4C79:
    INCBIN "roms/magination.gbc", $84C79, $9

SECTION "ROM Bank 033 @$084C82", ROMX[$4C82], BANK[33]
ScriptList21_4C82:
    INCBIN "roms/magination.gbc", $84C82, $15

SECTION "ROM Bank 033 @$084C97", ROMX[$4C97], BANK[33]
ScriptList21_4C97:
    INCBIN "roms/magination.gbc", $84C97, $9

SECTION "ROM Bank 033 @$084CA0", ROMX[$4CA0], BANK[33]
ScriptList21_4CA0:
    INCBIN "roms/magination.gbc", $84CA0, $5

SECTION "ROM Bank 033 @$084CA5", ROMX[$4CA5], BANK[33]
ScriptList21_4CA5:
    INCBIN "roms/magination.gbc", $84CA5, $D

SECTION "ROM Bank 033 @$084CB2", ROMX[$4CB2], BANK[33]
ScriptList21_4CB2:
    INCBIN "roms/magination.gbc", $84CB2, $D

SECTION "ROM Bank 033 @$084CBF", ROMX[$4CBF], BANK[33]
ScriptList21_4CBF:
    INCBIN "roms/magination.gbc", $84CBF, $9

SECTION "ROM Bank 033 @$084CC8", ROMX[$4CC8], BANK[33]
ScriptList21_4CC8:
    INCBIN "roms/magination.gbc", $84CC8, $5

SECTION "ROM Bank 033 @$084CCD", ROMX[$4CCD], BANK[33]
ScriptList21_4CCD:
    INCBIN "roms/magination.gbc", $84CCD, $21

SECTION "ROM Bank 033 @$084CEE", ROMX[$4CEE], BANK[33]
ScriptList21_4CEE:
    INCBIN "roms/magination.gbc", $84CEE, $9

SECTION "ROM Bank 033 @$084CF7", ROMX[$4CF7], BANK[33]
ScriptList21_4CF7:
    INCBIN "roms/magination.gbc", $84CF7, $D

SECTION "ROM Bank 033 @$084D04", ROMX[$4D04], BANK[33]
ScriptList21_4D04:
    INCBIN "roms/magination.gbc", $84D04, $9

SECTION "ROM Bank 033 @$084D0D", ROMX[$4D0D], BANK[33]
ScriptList21_4D0D:
    INCBIN "roms/magination.gbc", $84D0D, $11

SECTION "ROM Bank 033 @$084D1E", ROMX[$4D1E], BANK[33]
ScriptList21_4D1E:
    INCBIN "roms/magination.gbc", $84D1E, $9

SECTION "ROM Bank 033 @$084D27", ROMX[$4D27], BANK[33]
ScriptList21_4D27:
    INCBIN "roms/magination.gbc", $84D27, $9

SECTION "ROM Bank 033 @$084D30", ROMX[$4D30], BANK[33]
ScriptList21_4D30:
    INCBIN "roms/magination.gbc", $84D30, $9

SECTION "ROM Bank 033 @$084D39", ROMX[$4D39], BANK[33]
ScriptList21_4D39:
    INCBIN "roms/magination.gbc", $84D39, $11

SECTION "ROM Bank 033 @$084D4A", ROMX[$4D4A], BANK[33]
ScriptList21_4D4A:
    INCBIN "roms/magination.gbc", $84D4A, $11

SECTION "ROM Bank 033 @$084D5B", ROMX[$4D5B], BANK[33]
ScriptList21_4D5B:
    INCBIN "roms/magination.gbc", $84D5B, $5

SECTION "ROM Bank 033 @$084D60", ROMX[$4D60], BANK[33]
ScriptList21_4D60:
    INCBIN "roms/magination.gbc", $84D60, $5

SECTION "ROM Bank 033 @$084D65", ROMX[$4D65], BANK[33]
ScriptList21_4D65:
    INCBIN "roms/magination.gbc", $84D65, $5

SECTION "ROM Bank 033 @$084D6A", ROMX[$4D6A], BANK[33]
ScriptList21_4D6A:
    INCBIN "roms/magination.gbc", $84D6A, $5

SECTION "ROM Bank 033 @$084D6F", ROMX[$4D6F], BANK[33]
ScriptList21_4D6F:
    INCBIN "roms/magination.gbc", $84D6F, $5

SECTION "ROM Bank 033 @$084D74", ROMX[$4D74], BANK[33]
ScriptList21_4D74:
    INCBIN "roms/magination.gbc", $84D74, $5

SECTION "ROM Bank 033 @$084D79", ROMX[$4D79], BANK[33]
ScriptList21_4D79:
    INCBIN "roms/magination.gbc", $84D79, $9

SECTION "ROM Bank 033 @$084D82", ROMX[$4D82], BANK[33]
ScriptList21_4D82:
    INCBIN "roms/magination.gbc", $84D82, $5

SECTION "ROM Bank 033 @$084D87", ROMX[$4D87], BANK[33]
ScriptList21_4D87:
    INCBIN "roms/magination.gbc", $84D87, $D

SECTION "ROM Bank 033 @$084D94", ROMX[$4D94], BANK[33]
ScriptList21_4D94:
    INCBIN "roms/magination.gbc", $84D94, $9

SECTION "ROM Bank 033 @$084D9D", ROMX[$4D9D], BANK[33]
ScriptList21_4D9D:
    INCBIN "roms/magination.gbc", $84D9D, $D

SECTION "ROM Bank 033 @$084DAA", ROMX[$4DAA], BANK[33]
ScriptList21_4DAA:
    INCBIN "roms/magination.gbc", $84DAA, $5

SECTION "ROM Bank 033 @$084DAF", ROMX[$4DAF], BANK[33]
ScriptList21_4DAF:
    INCBIN "roms/magination.gbc", $84DAF, $5

SECTION "ROM Bank 033 @$084DB4", ROMX[$4DB4], BANK[33]
ScriptList21_4DB4:
    INCBIN "roms/magination.gbc", $84DB4, $19

SECTION "ROM Bank 033 @$084DCD", ROMX[$4DCD], BANK[33]
ScriptList21_4DCD:
    INCBIN "roms/magination.gbc", $84DCD, $9

SECTION "ROM Bank 033 @$084DD6", ROMX[$4DD6], BANK[33]
ScriptList21_4DD6:
    INCBIN "roms/magination.gbc", $84DD6, $5

SECTION "ROM Bank 033 @$084DDB", ROMX[$4DDB], BANK[33]
ScriptList21_4DDB:
    INCBIN "roms/magination.gbc", $84DDB, $5

SECTION "ROM Bank 033 @$084DE0", ROMX[$4DE0], BANK[33]
ScriptList21_4DE0:
    INCBIN "roms/magination.gbc", $84DE0, $9

SECTION "ROM Bank 033 @$084DE9", ROMX[$4DE9], BANK[33]
ScriptList21_4DE9:
    INCBIN "roms/magination.gbc", $84DE9, $9

SECTION "ROM Bank 033 @$084DF2", ROMX[$4DF2], BANK[33]
ScriptList21_4DF2:
    INCBIN "roms/magination.gbc", $84DF2, $5

SECTION "ROM Bank 033 @$084DF7", ROMX[$4DF7], BANK[33]
ScriptList21_4DF7:
    INCBIN "roms/magination.gbc", $84DF7, $5

SECTION "ROM Bank 033 @$084DFC", ROMX[$4DFC], BANK[33]
ScriptList21_4DFC:
    INCBIN "roms/magination.gbc", $84DFC, $5

SECTION "ROM Bank 033 @$084E01", ROMX[$4E01], BANK[33]
ScriptList21_4E01:
    INCBIN "roms/magination.gbc", $84E01, $5

SECTION "ROM Bank 033 @$084E06", ROMX[$4E06], BANK[33]
ScriptList21_4E06:
    INCBIN "roms/magination.gbc", $84E06, $5

SECTION "ROM Bank 033 @$084E0B", ROMX[$4E0B], BANK[33]
ScriptList21_4E0B:
    INCBIN "roms/magination.gbc", $84E0B, $9

SECTION "ROM Bank 033 @$084E14", ROMX[$4E14], BANK[33]
ScriptList21_4E14:
    INCBIN "roms/magination.gbc", $84E14, $29

SECTION "ROM Bank 033 @$084E3D", ROMX[$4E3D], BANK[33]
ScriptList21_4E3D:
    INCBIN "roms/magination.gbc", $84E3D, $79

SECTION "ROM Bank 033 @$084EB6", ROMX[$4EB6], BANK[33]
ScriptList21_4EB6:
    INCBIN "roms/magination.gbc", $84EB6, $41

SECTION "ROM Bank 033 @$084EF7", ROMX[$4EF7], BANK[33]
ScriptList21_4EF7:
    INCBIN "roms/magination.gbc", $84EF7, $49

SECTION "ROM Bank 033 @$084F40", ROMX[$4F40], BANK[33]
ScriptList21_4F40:
    INCBIN "roms/magination.gbc", $84F40, $11

SECTION "ROM Bank 033 @$084F51", ROMX[$4F51], BANK[33]
ScriptList21_4F51:
    INCBIN "roms/magination.gbc", $84F51, $9

SECTION "ROM Bank 033 @$084F5A", ROMX[$4F5A], BANK[33]
ScriptList21_4F5A:
    INCBIN "roms/magination.gbc", $84F5A, $11

SECTION "ROM Bank 033 @$084F6B", ROMX[$4F6B], BANK[33]
ScriptList21_4F6B:
    INCBIN "roms/magination.gbc", $84F6B, $5

SECTION "ROM Bank 033 @$084F70", ROMX[$4F70], BANK[33]
ScriptList21_4F70:
    INCBIN "roms/magination.gbc", $84F70, $1

SECTION "ROM Bank 033 @$084F71", ROMX[$4F71], BANK[33]
ScriptList21_4F71:
    INCBIN "roms/magination.gbc", $84F71, $9

SECTION "ROM Bank 033 @$084F7A", ROMX[$4F7A], BANK[33]
ScriptList21_4F7A:
    INCBIN "roms/magination.gbc", $84F7A, $9

SECTION "ROM Bank 033 @$084F83", ROMX[$4F83], BANK[33]
ScriptList21_4F83:
    INCBIN "roms/magination.gbc", $84F83, $11

SECTION "ROM Bank 033 @$084F94", ROMX[$4F94], BANK[33]
ScriptList21_4F94:
    INCBIN "roms/magination.gbc", $84F94, $D

SECTION "ROM Bank 033 @$084FA1", ROMX[$4FA1], BANK[33]
ScriptList21_4FA1:
    INCBIN "roms/magination.gbc", $84FA1, $9

SECTION "ROM Bank 033 @$084FAA", ROMX[$4FAA], BANK[33]
ScriptList21_4FAA:
    INCBIN "roms/magination.gbc", $84FAA, $9

SECTION "ROM Bank 033 @$084FB3", ROMX[$4FB3], BANK[33]
ScriptList21_4FB3:
    INCBIN "roms/magination.gbc", $84FB3, $5

SECTION "ROM Bank 033 @$084FB8", ROMX[$4FB8], BANK[33]
ScriptList21_4FB8:
    INCBIN "roms/magination.gbc", $84FB8, $9

SECTION "ROM Bank 033 @$084FC1", ROMX[$4FC1], BANK[33]
ScriptList21_4FC1:
    INCBIN "roms/magination.gbc", $84FC1, $9

SECTION "ROM Bank 033 @$084FCA", ROMX[$4FCA], BANK[33]
ScriptList21_4FCA:
    INCBIN "roms/magination.gbc", $84FCA, $D

SECTION "ROM Bank 033 @$084FD7", ROMX[$4FD7], BANK[33]
ScriptList21_4FD7:
    INCBIN "roms/magination.gbc", $84FD7, $5

SECTION "ROM Bank 033 @$084FDC", ROMX[$4FDC], BANK[33]
ScriptList21_4FDC:
    INCBIN "roms/magination.gbc", $84FDC, $9

SECTION "ROM Bank 033 @$084FE5", ROMX[$4FE5], BANK[33]
ScriptList21_4FE5:
    INCBIN "roms/magination.gbc", $84FE5, $9

SECTION "ROM Bank 033 @$084FEE", ROMX[$4FEE], BANK[33]
ScriptList21_4FEE:
    INCBIN "roms/magination.gbc", $84FEE, $9

SECTION "ROM Bank 033 @$084FF7", ROMX[$4FF7], BANK[33]
ScriptList21_4FF7:
    INCBIN "roms/magination.gbc", $84FF7, $D

SECTION "ROM Bank 033 @$085004", ROMX[$5004], BANK[33]
ScriptList21_5004:
    INCBIN "roms/magination.gbc", $85004, $D

SECTION "ROM Bank 033 @$085011", ROMX[$5011], BANK[33]
ScriptList21_5011:
    INCBIN "roms/magination.gbc", $85011, $5

SECTION "ROM Bank 033 @$085016", ROMX[$5016], BANK[33]
ScriptList21_5016:
    INCBIN "roms/magination.gbc", $85016, $9

SECTION "ROM Bank 033 @$08501F", ROMX[$501F], BANK[33]
ScriptList21_501F:
    INCBIN "roms/magination.gbc", $8501F, $9

SECTION "ROM Bank 033 @$085028", ROMX[$5028], BANK[33]
ScriptList21_5028:
    INCBIN "roms/magination.gbc", $85028, $9

SECTION "ROM Bank 033 @$085031", ROMX[$5031], BANK[33]
ScriptList21_5031:
    INCBIN "roms/magination.gbc", $85031, $9

SECTION "ROM Bank 033 @$08503A", ROMX[$503A], BANK[33]
ScriptList21_503A:
    INCBIN "roms/magination.gbc", $8503A, $5

SECTION "ROM Bank 033 @$08503F", ROMX[$503F], BANK[33]
ScriptList21_503F:
    INCBIN "roms/magination.gbc", $8503F, $9

SECTION "ROM Bank 033 @$085048", ROMX[$5048], BANK[33]
ScriptList21_5048:
    INCBIN "roms/magination.gbc", $85048, $9

SECTION "ROM Bank 033 @$085051", ROMX[$5051], BANK[33]
ScriptList21_5051:
    INCBIN "roms/magination.gbc", $85051, $11

SECTION "ROM Bank 033 @$085062", ROMX[$5062], BANK[33]
ScriptList21_5062:
    INCBIN "roms/magination.gbc", $85062, $9

SECTION "ROM Bank 033 @$08506B", ROMX[$506B], BANK[33]
ScriptList21_506B:
    INCBIN "roms/magination.gbc", $8506B, $5

SECTION "ROM Bank 033 @$085070", ROMX[$5070], BANK[33]
ScriptList21_5070:
    INCBIN "roms/magination.gbc", $85070, $9

SECTION "ROM Bank 033 @$085079", ROMX[$5079], BANK[33]
ScriptList21_5079:
    INCBIN "roms/magination.gbc", $85079, $11

SECTION "ROM Bank 033 @$08508A", ROMX[$508A], BANK[33]
ScriptList21_508A:
    INCBIN "roms/magination.gbc", $8508A, $5

SECTION "ROM Bank 033 @$08508F", ROMX[$508F], BANK[33]
ScriptList21_508F:
    INCBIN "roms/magination.gbc", $8508F, $D

SECTION "ROM Bank 033 @$08509C", ROMX[$509C], BANK[33]
ScriptList21_509C:
    INCBIN "roms/magination.gbc", $8509C, $D

SECTION "ROM Bank 033 @$0850A9", ROMX[$50A9], BANK[33]
ScriptList21_50A9:
    INCBIN "roms/magination.gbc", $850A9, $9

SECTION "ROM Bank 033 @$0850B2", ROMX[$50B2], BANK[33]
ScriptList21_50B2:
    INCBIN "roms/magination.gbc", $850B2, $D

SECTION "ROM Bank 033 @$0850BF", ROMX[$50BF], BANK[33]
ScriptList21_50BF:
    INCBIN "roms/magination.gbc", $850BF, $29

SECTION "ROM Bank 033 @$0850E8", ROMX[$50E8], BANK[33]
ScriptList21_50E8:
    INCBIN "roms/magination.gbc", $850E8, $5

SECTION "ROM Bank 033 @$0850ED", ROMX[$50ED], BANK[33]
ScriptList21_50ED:
    INCBIN "roms/magination.gbc", $850ED, $5

SECTION "ROM Bank 033 @$0850F2", ROMX[$50F2], BANK[33]
ScriptList21_50F2:
    INCBIN "roms/magination.gbc", $850F2, $21

SECTION "ROM Bank 033 @$085113", ROMX[$5113], BANK[33]
ScriptList21_5113:
    INCBIN "roms/magination.gbc", $85113, $D

SECTION "ROM Bank 033 @$085120", ROMX[$5120], BANK[33]
ScriptList21_5120:
    INCBIN "roms/magination.gbc", $85120, $21

SECTION "ROM Bank 033 @$085141", ROMX[$5141], BANK[33]
ScriptList21_5141:
    INCBIN "roms/magination.gbc", $85141, $21

SECTION "ROM Bank 033 @$085162", ROMX[$5162], BANK[33]
ScriptList21_5162:
    INCBIN "roms/magination.gbc", $85162, $9

SECTION "ROM Bank 033 @$08516B", ROMX[$516B], BANK[33]
ScriptList21_516B:
    INCBIN "roms/magination.gbc", $8516B, $D

SECTION "ROM Bank 033 @$085178", ROMX[$5178], BANK[33]
ScriptList21_5178:
    INCBIN "roms/magination.gbc", $85178, $9

SECTION "ROM Bank 033 @$085181", ROMX[$5181], BANK[33]
ScriptList21_5181:
    INCBIN "roms/magination.gbc", $85181, $5

SECTION "ROM Bank 033 @$085186", ROMX[$5186], BANK[33]
ScriptList21_5186:
    INCBIN "roms/magination.gbc", $85186, $9

SECTION "ROM Bank 033 @$08518F", ROMX[$518F], BANK[33]
ScriptList21_518F:
    INCBIN "roms/magination.gbc", $8518F, $11

SECTION "ROM Bank 033 @$0851A0", ROMX[$51A0], BANK[33]
ScriptList21_51A0:
    INCBIN "roms/magination.gbc", $851A0, $5

SECTION "ROM Bank 033 @$0851A5", ROMX[$51A5], BANK[33]
ScriptList21_51A5:
    INCBIN "roms/magination.gbc", $851A5, $9

SECTION "ROM Bank 033 @$0851AE", ROMX[$51AE], BANK[33]
ScriptList21_51AE:
    INCBIN "roms/magination.gbc", $851AE, $D

SECTION "ROM Bank 033 @$0851BB", ROMX[$51BB], BANK[33]
ScriptList21_51BB:
    INCBIN "roms/magination.gbc", $851BB, $5

SECTION "ROM Bank 033 @$0851C0", ROMX[$51C0], BANK[33]
ScriptList21_51C0:
    INCBIN "roms/magination.gbc", $851C0, $15

SECTION "ROM Bank 033 @$0851D5", ROMX[$51D5], BANK[33]
ScriptList21_51D5:
    INCBIN "roms/magination.gbc", $851D5, $15

SECTION "ROM Bank 033 @$0851EA", ROMX[$51EA], BANK[33]
ScriptList21_51EA:
    INCBIN "roms/magination.gbc", $851EA, $9

SECTION "ROM Bank 033 @$0851F3", ROMX[$51F3], BANK[33]
ScriptList21_51F3:
    INCBIN "roms/magination.gbc", $851F3, $5

SECTION "ROM Bank 033 @$0851F8", ROMX[$51F8], BANK[33]
ScriptList21_51F8:
    INCBIN "roms/magination.gbc", $851F8, $9

SECTION "ROM Bank 033 @$085201", ROMX[$5201], BANK[33]
ScriptList21_5201:
    INCBIN "roms/magination.gbc", $85201, $1D

SECTION "ROM Bank 033 @$08521E", ROMX[$521E], BANK[33]
ScriptList21_521E:
    INCBIN "roms/magination.gbc", $8521E, $5

SECTION "ROM Bank 033 @$085223", ROMX[$5223], BANK[33]
ScriptList21_5223:
    INCBIN "roms/magination.gbc", $85223, $1D

SECTION "ROM Bank 033 @$085240", ROMX[$5240], BANK[33]
ScriptList21_5240:
    INCBIN "roms/magination.gbc", $85240, $5

SECTION "ROM Bank 033 @$085245", ROMX[$5245], BANK[33]
ScriptList21_5245:
    INCBIN "roms/magination.gbc", $85245, $9

SECTION "ROM Bank 033 @$08524E", ROMX[$524E], BANK[33]
ScriptList21_524E:
    INCBIN "roms/magination.gbc", $8524E, $51

SECTION "ROM Bank 033 @$08529F", ROMX[$529F], BANK[33]
ScriptList21_529F:
    INCBIN "roms/magination.gbc", $8529F, $D

SECTION "ROM Bank 033 @$0852AC", ROMX[$52AC], BANK[33]
ScriptList21_52AC:
    INCBIN "roms/magination.gbc", $852AC, $11

SECTION "ROM Bank 033 @$0852BD", ROMX[$52BD], BANK[33]
ScriptList21_52BD:
    INCBIN "roms/magination.gbc", $852BD, $9

SECTION "ROM Bank 033 @$0852C6", ROMX[$52C6], BANK[33]
ScriptList21_52C6:
    INCBIN "roms/magination.gbc", $852C6, $5

SECTION "ROM Bank 033 @$0852CB", ROMX[$52CB], BANK[33]
ScriptList21_52CB:
    INCBIN "roms/magination.gbc", $852CB, $9

SECTION "ROM Bank 033 @$0852D4", ROMX[$52D4], BANK[33]
ScriptList21_52D4:
    INCBIN "roms/magination.gbc", $852D4, $5

SECTION "ROM Bank 033 @$0852D9", ROMX[$52D9], BANK[33]
ScriptList21_52D9:
    INCBIN "roms/magination.gbc", $852D9, $9

SECTION "ROM Bank 033 @$0852E2", ROMX[$52E2], BANK[33]
ScriptList21_52E2:
    INCBIN "roms/magination.gbc", $852E2, $9

SECTION "ROM Bank 033 @$0852EB", ROMX[$52EB], BANK[33]
ScriptList21_52EB:
    INCBIN "roms/magination.gbc", $852EB, $5

SECTION "ROM Bank 033 @$0852F0", ROMX[$52F0], BANK[33]
ScriptList21_52F0:
    INCBIN "roms/magination.gbc", $852F0, $9

SECTION "ROM Bank 033 @$0852F9", ROMX[$52F9], BANK[33]
ScriptList21_52F9:
    INCBIN "roms/magination.gbc", $852F9, $D

SECTION "ROM Bank 033 @$085306", ROMX[$5306], BANK[33]
ScriptList21_5306:
    INCBIN "roms/magination.gbc", $85306, $5

SECTION "ROM Bank 033 @$08530B", ROMX[$530B], BANK[33]
ScriptList21_530B:
    INCBIN "roms/magination.gbc", $8530B, $D

SECTION "ROM Bank 033 @$085318", ROMX[$5318], BANK[33]
ScriptList21_5318:
    INCBIN "roms/magination.gbc", $85318, $D

SECTION "ROM Bank 033 @$085325", ROMX[$5325], BANK[33]
ScriptList21_5325:
    INCBIN "roms/magination.gbc", $85325, $D

SECTION "ROM Bank 033 @$085332", ROMX[$5332], BANK[33]
ScriptList21_5332:
    INCBIN "roms/magination.gbc", $85332, $5

SECTION "ROM Bank 033 @$085337", ROMX[$5337], BANK[33]
ScriptList21_5337:
    INCBIN "roms/magination.gbc", $85337, $9

SECTION "ROM Bank 033 @$085340", ROMX[$5340], BANK[33]
ScriptList21_5340:
    INCBIN "roms/magination.gbc", $85340, $9

SECTION "ROM Bank 033 @$085349", ROMX[$5349], BANK[33]
ScriptList21_5349:
    INCBIN "roms/magination.gbc", $85349, $9

SECTION "ROM Bank 033 @$085352", ROMX[$5352], BANK[33]
ScriptList21_5352:
    INCBIN "roms/magination.gbc", $85352, $D

SECTION "ROM Bank 033 @$08535F", ROMX[$535F], BANK[33]
ScriptList21_535F:
    INCBIN "roms/magination.gbc", $8535F, $9

SECTION "ROM Bank 033 @$085368", ROMX[$5368], BANK[33]
ScriptList21_5368:
    INCBIN "roms/magination.gbc", $85368, $9

SECTION "ROM Bank 033 @$085371", ROMX[$5371], BANK[33]
ScriptList21_5371:
    INCBIN "roms/magination.gbc", $85371, $11

SECTION "ROM Bank 033 @$085382", ROMX[$5382], BANK[33]
ScriptList21_5382:
    INCBIN "roms/magination.gbc", $85382, $9

SECTION "ROM Bank 033 @$08538B", ROMX[$538B], BANK[33]
ScriptList21_538B:
    INCBIN "roms/magination.gbc", $8538B, $15

SECTION "ROM Bank 033 @$0853A0", ROMX[$53A0], BANK[33]
ScriptList21_53A0:
    INCBIN "roms/magination.gbc", $853A0, $D

SECTION "ROM Bank 033 @$0853AD", ROMX[$53AD], BANK[33]
ScriptList21_53AD:
    INCBIN "roms/magination.gbc", $853AD, $1D

SECTION "ROM Bank 033 @$0853CA", ROMX[$53CA], BANK[33]
ScriptList21_53CA:
    INCBIN "roms/magination.gbc", $853CA, $9

SECTION "ROM Bank 033 @$0853D3", ROMX[$53D3], BANK[33]
ScriptList21_53D3:
    INCBIN "roms/magination.gbc", $853D3, $9

SECTION "ROM Bank 033 @$0853DC", ROMX[$53DC], BANK[33]
ScriptList21_53DC:
    INCBIN "roms/magination.gbc", $853DC, $19

SECTION "ROM Bank 033 @$0853F5", ROMX[$53F5], BANK[33]
ScriptList21_53F5:
    INCBIN "roms/magination.gbc", $853F5, $15

SECTION "ROM Bank 033 @$08540A", ROMX[$540A], BANK[33]
ScriptList21_540A:
    INCBIN "roms/magination.gbc", $8540A, $9

SECTION "ROM Bank 033 @$085413", ROMX[$5413], BANK[33]
ScriptList21_5413:
    INCBIN "roms/magination.gbc", $85413, $9

SECTION "ROM Bank 033 @$08541C", ROMX[$541C], BANK[33]
ScriptList21_541C:
    INCBIN "roms/magination.gbc", $8541C, $9

SECTION "ROM Bank 033 @$085425", ROMX[$5425], BANK[33]
ScriptList21_5425:
    INCBIN "roms/magination.gbc", $85425, $D

SECTION "ROM Bank 033 @$085432", ROMX[$5432], BANK[33]
ScriptList21_5432:
    INCBIN "roms/magination.gbc", $85432, $9

SECTION "ROM Bank 033 @$08543B", ROMX[$543B], BANK[33]
ScriptList21_543B:
    INCBIN "roms/magination.gbc", $8543B, $9

SECTION "ROM Bank 033 @$085444", ROMX[$5444], BANK[33]
ScriptList21_5444:
    INCBIN "roms/magination.gbc", $85444, $5

SECTION "ROM Bank 033 @$085449", ROMX[$5449], BANK[33]
ScriptList21_5449:
    INCBIN "roms/magination.gbc", $85449, $11

SECTION "ROM Bank 033 @$08545A", ROMX[$545A], BANK[33]
ScriptList21_545A:
    INCBIN "roms/magination.gbc", $8545A, $9

SECTION "ROM Bank 033 @$085463", ROMX[$5463], BANK[33]
ScriptList21_5463:
    INCBIN "roms/magination.gbc", $85463, $9

SECTION "ROM Bank 033 @$08546C", ROMX[$546C], BANK[33]
ScriptList21_546C:
    INCBIN "roms/magination.gbc", $8546C, $35

SECTION "ROM Bank 033 @$0854A1", ROMX[$54A1], BANK[33]
ScriptList21_54A1:
    INCBIN "roms/magination.gbc", $854A1, $25

SECTION "ROM Bank 033 @$0854C6", ROMX[$54C6], BANK[33]
ScriptList21_54C6:
    INCBIN "roms/magination.gbc", $854C6, $9

SECTION "ROM Bank 033 @$0854CF", ROMX[$54CF], BANK[33]
ScriptList21_54CF:
    INCBIN "roms/magination.gbc", $854CF, $5

SECTION "ROM Bank 033 @$0854D4", ROMX[$54D4], BANK[33]
ScriptList21_54D4:
    INCBIN "roms/magination.gbc", $854D4, $5

SECTION "ROM Bank 033 @$0854D9", ROMX[$54D9], BANK[33]
ScriptList21_54D9:
    INCBIN "roms/magination.gbc", $854D9, $D

SECTION "ROM Bank 033 @$0854E6", ROMX[$54E6], BANK[33]
ScriptList21_54E6:
    INCBIN "roms/magination.gbc", $854E6, $1

SECTION "ROM Bank 033 @$0854E7", ROMX[$54E7], BANK[33]
ScriptList21_54E7:
    INCBIN "roms/magination.gbc", $854E7, $9

SECTION "ROM Bank 033 @$0854F0", ROMX[$54F0], BANK[33]
ScriptList21_54F0:
    INCBIN "roms/magination.gbc", $854F0, $D

SECTION "ROM Bank 033 @$0854FD", ROMX[$54FD], BANK[33]
ScriptList21_54FD:
    INCBIN "roms/magination.gbc", $854FD, $9

SECTION "ROM Bank 033 @$085506", ROMX[$5506], BANK[33]
ScriptList21_5506:
    INCBIN "roms/magination.gbc", $85506, $9

SECTION "ROM Bank 033 @$08550F", ROMX[$550F], BANK[33]
ScriptList21_550F:
    INCBIN "roms/magination.gbc", $8550F, $5

SECTION "ROM Bank 033 @$085514", ROMX[$5514], BANK[33]
ScriptList21_5514:
    INCBIN "roms/magination.gbc", $85514, $11

SECTION "ROM Bank 033 @$085525", ROMX[$5525], BANK[33]
ScriptList21_5525:
    INCBIN "roms/magination.gbc", $85525, $5

SECTION "ROM Bank 033 @$08552A", ROMX[$552A], BANK[33]
ScriptList21_552A:
    INCBIN "roms/magination.gbc", $8552A, $65

SECTION "ROM Bank 033 @$08558F", ROMX[$558F], BANK[33]
ScriptList21_558F:
    INCBIN "roms/magination.gbc", $8558F, $5

SECTION "ROM Bank 033 @$085594", ROMX[$5594], BANK[33]
ScriptList21_5594:
    INCBIN "roms/magination.gbc", $85594, $5

SECTION "ROM Bank 033 @$085599", ROMX[$5599], BANK[33]
ScriptList21_5599:
    INCBIN "roms/magination.gbc", $85599, $1D

SECTION "ROM Bank 033 @$0855B6", ROMX[$55B6], BANK[33]
ScriptList21_55B6:
    INCBIN "roms/magination.gbc", $855B6, $1D

SECTION "ROM Bank 033 @$0855D3", ROMX[$55D3], BANK[33]
ScriptList21_55D3:
    INCBIN "roms/magination.gbc", $855D3, $25

SECTION "ROM Bank 033 @$0855F8", ROMX[$55F8], BANK[33]
ScriptList21_55F8:
    INCBIN "roms/magination.gbc", $855F8, $31

SECTION "ROM Bank 033 @$085629", ROMX[$5629], BANK[33]
ScriptList21_5629:
    INCBIN "roms/magination.gbc", $85629, $5

SECTION "ROM Bank 033 @$08562E", ROMX[$562E], BANK[33]
ScriptList21_562E:
    INCBIN "roms/magination.gbc", $8562E, $5

SECTION "ROM Bank 033 @$085633", ROMX[$5633], BANK[33]
ScriptList21_5633:
    INCBIN "roms/magination.gbc", $85633, $15

SECTION "ROM Bank 033 @$085648", ROMX[$5648], BANK[33]
ScriptList21_5648:
    INCBIN "roms/magination.gbc", $85648, $15

SECTION "ROM Bank 033 @$08565D", ROMX[$565D], BANK[33]
ScriptList21_565D:
    INCBIN "roms/magination.gbc", $8565D, $19

SECTION "ROM Bank 033 @$085676", ROMX[$5676], BANK[33]
ScriptList21_5676:
    INCBIN "roms/magination.gbc", $85676, $15

SECTION "ROM Bank 033 @$08568B", ROMX[$568B], BANK[33]
ScriptList21_568B:
    INCBIN "roms/magination.gbc", $8568B, $9

SECTION "ROM Bank 033 @$085694", ROMX[$5694], BANK[33]
ScriptList21_5694:
    INCBIN "roms/magination.gbc", $85694, $9

SECTION "ROM Bank 033 @$08569D", ROMX[$569D], BANK[33]
ScriptList21_569D:
    INCBIN "roms/magination.gbc", $8569D, $9

SECTION "ROM Bank 033 @$0856A6", ROMX[$56A6], BANK[33]
ScriptList21_56A6:
    INCBIN "roms/magination.gbc", $856A6, $9

SECTION "ROM Bank 033 @$0856AF", ROMX[$56AF], BANK[33]
ScriptList21_56AF:
    INCBIN "roms/magination.gbc", $856AF, $5

SECTION "ROM Bank 033 @$0856B4", ROMX[$56B4], BANK[33]
ScriptList21_56B4:
    INCBIN "roms/magination.gbc", $856B4, $5

SECTION "ROM Bank 033 @$0856B9", ROMX[$56B9], BANK[33]
ScriptList21_56B9:
    INCBIN "roms/magination.gbc", $856B9, $9

SECTION "ROM Bank 033 @$0856C2", ROMX[$56C2], BANK[33]
ScriptList21_56C2:
    INCBIN "roms/magination.gbc", $856C2, $9

SECTION "ROM Bank 033 @$0856CB", ROMX[$56CB], BANK[33]
ScriptList21_56CB:
    INCBIN "roms/magination.gbc", $856CB, $5

SECTION "ROM Bank 033 @$0856D0", ROMX[$56D0], BANK[33]
ScriptList21_56D0:
    INCBIN "roms/magination.gbc", $856D0, $9

SECTION "ROM Bank 033 @$0856D9", ROMX[$56D9], BANK[33]
ScriptList21_56D9:
    INCBIN "roms/magination.gbc", $856D9, $5

SECTION "ROM Bank 033 @$0856DE", ROMX[$56DE], BANK[33]
ScriptList21_56DE:
    INCBIN "roms/magination.gbc", $856DE, $9

SECTION "ROM Bank 033 @$0856E7", ROMX[$56E7], BANK[33]
ScriptList21_56E7:
    INCBIN "roms/magination.gbc", $856E7, $5

SECTION "ROM Bank 033 @$0856EC", ROMX[$56EC], BANK[33]
ScriptList21_56EC:
    INCBIN "roms/magination.gbc", $856EC, $9

SECTION "ROM Bank 033 @$0856F5", ROMX[$56F5], BANK[33]
ScriptList21_56F5:
    INCBIN "roms/magination.gbc", $856F5, $9

SECTION "ROM Bank 033 @$0856FE", ROMX[$56FE], BANK[33]
ScriptList21_56FE:
    INCBIN "roms/magination.gbc", $856FE, $D

SECTION "ROM Bank 033 @$08570B", ROMX[$570B], BANK[33]
ScriptList21_570B:
    INCBIN "roms/magination.gbc", $8570B, $5

SECTION "ROM Bank 033 @$085710", ROMX[$5710], BANK[33]
ScriptList21_5710:
    INCBIN "roms/magination.gbc", $85710, $9

SECTION "ROM Bank 033 @$085719", ROMX[$5719], BANK[33]
ScriptList21_5719:
    INCBIN "roms/magination.gbc", $85719, $9

SECTION "ROM Bank 033 @$085722", ROMX[$5722], BANK[33]
ScriptList21_5722:
    INCBIN "roms/magination.gbc", $85722, $9

SECTION "ROM Bank 033 @$08572B", ROMX[$572B], BANK[33]
ScriptList21_572B:
    INCBIN "roms/magination.gbc", $8572B, $9

SECTION "ROM Bank 033 @$085734", ROMX[$5734], BANK[33]
ScriptList21_5734:
    INCBIN "roms/magination.gbc", $85734, $D

SECTION "ROM Bank 033 @$085741", ROMX[$5741], BANK[33]
ScriptList21_5741:
    INCBIN "roms/magination.gbc", $85741, $9

SECTION "ROM Bank 033 @$08574A", ROMX[$574A], BANK[33]
ScriptList21_574A:
    INCBIN "roms/magination.gbc", $8574A, $11

SECTION "ROM Bank 033 @$08575B", ROMX[$575B], BANK[33]
ScriptList21_575B:
    INCBIN "roms/magination.gbc", $8575B, $11

SECTION "ROM Bank 033 @$08576C", ROMX[$576C], BANK[33]
ScriptList21_576C:
    INCBIN "roms/magination.gbc", $8576C, $D

SECTION "ROM Bank 033 @$085779", ROMX[$5779], BANK[33]
ScriptList21_5779:
    INCBIN "roms/magination.gbc", $85779, $9

SECTION "ROM Bank 033 @$085782", ROMX[$5782], BANK[33]
ScriptList21_5782:
    INCBIN "roms/magination.gbc", $85782, $11

SECTION "ROM Bank 033 @$085793", ROMX[$5793], BANK[33]
ScriptList21_5793:
    INCBIN "roms/magination.gbc", $85793, $9

SECTION "ROM Bank 033 @$08579C", ROMX[$579C], BANK[33]
ScriptList21_579C:
    INCBIN "roms/magination.gbc", $8579C, $9

SECTION "ROM Bank 033 @$0857A5", ROMX[$57A5], BANK[33]
ScriptList21_57A5:
    INCBIN "roms/magination.gbc", $857A5, $9

SECTION "ROM Bank 033 @$0857AE", ROMX[$57AE], BANK[33]
ScriptList21_57AE:
    INCBIN "roms/magination.gbc", $857AE, $11

SECTION "ROM Bank 033 @$0857BF", ROMX[$57BF], BANK[33]
ScriptList21_57BF:
    INCBIN "roms/magination.gbc", $857BF, $9

SECTION "ROM Bank 033 @$0857C8", ROMX[$57C8], BANK[33]
ScriptList21_57C8:
    INCBIN "roms/magination.gbc", $857C8, $9

SECTION "ROM Bank 033 @$0857D1", ROMX[$57D1], BANK[33]
ScriptList21_57D1:
    INCBIN "roms/magination.gbc", $857D1, $59

SECTION "ROM Bank 033 @$08582A", ROMX[$582A], BANK[33]
ScriptList21_582A:
    INCBIN "roms/magination.gbc", $8582A, $1D

SECTION "ROM Bank 033 @$085847", ROMX[$5847], BANK[33]
ScriptList21_5847:
    INCBIN "roms/magination.gbc", $85847, $5

SECTION "ROM Bank 033 @$08584C", ROMX[$584C], BANK[33]
ScriptList21_584C:
    INCBIN "roms/magination.gbc", $8584C, $11

SECTION "ROM Bank 033 @$08585D", ROMX[$585D], BANK[33]
ScriptList21_585D:
    INCBIN "roms/magination.gbc", $8585D, $9

SECTION "ROM Bank 033 @$085866", ROMX[$5866], BANK[33]
ScriptList21_5866:
    INCBIN "roms/magination.gbc", $85866, $1D

SECTION "ROM Bank 033 @$085883", ROMX[$5883], BANK[33]
ScriptList21_5883:
    INCBIN "roms/magination.gbc", $85883, $9

SECTION "ROM Bank 033 @$08588C", ROMX[$588C], BANK[33]
ScriptList21_588C:
    INCBIN "roms/magination.gbc", $8588C, $D

SECTION "ROM Bank 033 @$085899", ROMX[$5899], BANK[33]
ScriptList21_5899:
    INCBIN "roms/magination.gbc", $85899, $9

SECTION "ROM Bank 033 @$0858A2", ROMX[$58A2], BANK[33]
ScriptList21_58A2:
    INCBIN "roms/magination.gbc", $858A2, $5

SECTION "ROM Bank 033 @$0858A7", ROMX[$58A7], BANK[33]
ScriptList21_58A7:
    INCBIN "roms/magination.gbc", $858A7, $5

SECTION "ROM Bank 033 @$0858AC", ROMX[$58AC], BANK[33]
ScriptList21_58AC:
    INCBIN "roms/magination.gbc", $858AC, $5

SECTION "ROM Bank 033 @$0858B1", ROMX[$58B1], BANK[33]
ScriptList21_58B1:
    INCBIN "roms/magination.gbc", $858B1, $5

SECTION "ROM Bank 033 @$0858B6", ROMX[$58B6], BANK[33]
ScriptList21_58B6:
    INCBIN "roms/magination.gbc", $858B6, $5

SECTION "ROM Bank 033 @$0858BB", ROMX[$58BB], BANK[33]
ScriptList21_58BB:
    INCBIN "roms/magination.gbc", $858BB, $D

SECTION "ROM Bank 033 @$0858C8", ROMX[$58C8], BANK[33]
ScriptList21_58C8:
    INCBIN "roms/magination.gbc", $858C8, $5

SECTION "ROM Bank 033 @$0858CD", ROMX[$58CD], BANK[33]
ScriptList21_58CD:
    INCBIN "roms/magination.gbc", $858CD, $11

SECTION "ROM Bank 033 @$0858DE", ROMX[$58DE], BANK[33]
ScriptList21_58DE:
    INCBIN "roms/magination.gbc", $858DE, $5

SECTION "ROM Bank 033 @$0858E3", ROMX[$58E3], BANK[33]
ScriptList21_58E3:
    INCBIN "roms/magination.gbc", $858E3, $5

SECTION "ROM Bank 033 @$0858E8", ROMX[$58E8], BANK[33]
ScriptList21_58E8:
    INCBIN "roms/magination.gbc", $858E8, $5

SECTION "ROM Bank 033 @$0858ED", ROMX[$58ED], BANK[33]
ScriptList21_58ED:
    INCBIN "roms/magination.gbc", $858ED, $9

SECTION "ROM Bank 033 @$0858F6", ROMX[$58F6], BANK[33]
ScriptList21_58F6:
    INCBIN "roms/magination.gbc", $858F6, $11

SECTION "ROM Bank 033 @$085907", ROMX[$5907], BANK[33]
ScriptList21_5907:
    INCBIN "roms/magination.gbc", $85907, $D

SECTION "ROM Bank 033 @$085914", ROMX[$5914], BANK[33]
ScriptList21_5914:
    INCBIN "roms/magination.gbc", $85914, $D

SECTION "ROM Bank 033 @$085921", ROMX[$5921], BANK[33]
ScriptList21_5921:
    INCBIN "roms/magination.gbc", $85921, $11

SECTION "ROM Bank 033 @$085932", ROMX[$5932], BANK[33]
ScriptList21_5932:
    INCBIN "roms/magination.gbc", $85932, $D

SECTION "ROM Bank 033 @$08593F", ROMX[$593F], BANK[33]
ScriptList21_593F:
    INCBIN "roms/magination.gbc", $8593F, $D

SECTION "ROM Bank 033 @$08594C", ROMX[$594C], BANK[33]
ScriptList21_594C:
    INCBIN "roms/magination.gbc", $8594C, $5

SECTION "ROM Bank 033 @$085951", ROMX[$5951], BANK[33]
ScriptList21_5951:
    INCBIN "roms/magination.gbc", $85951, $9

SECTION "ROM Bank 033 @$08595A", ROMX[$595A], BANK[33]
ScriptList21_595A:
    INCBIN "roms/magination.gbc", $8595A, $1

SECTION "ROM Bank 033 @$08595B", ROMX[$595B], BANK[33]
ScriptList21_595B:
    INCBIN "roms/magination.gbc", $8595B, $15

SECTION "ROM Bank 033 @$085970", ROMX[$5970], BANK[33]
ScriptList21_5970:
    INCBIN "roms/magination.gbc", $85970, $9

SECTION "ROM Bank 033 @$085979", ROMX[$5979], BANK[33]
ScriptList21_5979:
    INCBIN "roms/magination.gbc", $85979, $D

SECTION "ROM Bank 033 @$085986", ROMX[$5986], BANK[33]
ScriptList21_5986:
    INCBIN "roms/magination.gbc", $85986, $21

SECTION "ROM Bank 033 @$0859A7", ROMX[$59A7], BANK[33]
ScriptList21_59A7:
    INCBIN "roms/magination.gbc", $859A7, $5

SECTION "ROM Bank 033 @$0859AC", ROMX[$59AC], BANK[33]
ScriptList21_59AC:
    INCBIN "roms/magination.gbc", $859AC, $5

SECTION "ROM Bank 033 @$0859B1", ROMX[$59B1], BANK[33]
ScriptList21_59B1:
    INCBIN "roms/magination.gbc", $859B1, $D

SECTION "ROM Bank 033 @$0859BE", ROMX[$59BE], BANK[33]
ScriptList21_59BE:
    INCBIN "roms/magination.gbc", $859BE, $9

SECTION "ROM Bank 033 @$0859C7", ROMX[$59C7], BANK[33]
ScriptList21_59C7:
    INCBIN "roms/magination.gbc", $859C7, $1

SECTION "ROM Bank 033 @$0859C8", ROMX[$59C8], BANK[33]
ScriptList21_59C8:
    INCBIN "roms/magination.gbc", $859C8, $9

SECTION "ROM Bank 033 @$0859D1", ROMX[$59D1], BANK[33]
ScriptList21_59D1:
    INCBIN "roms/magination.gbc", $859D1, $11

SECTION "ROM Bank 033 @$0859E2", ROMX[$59E2], BANK[33]
ScriptList21_59E2:
    INCBIN "roms/magination.gbc", $859E2, $9

SECTION "ROM Bank 033 @$0859EB", ROMX[$59EB], BANK[33]
ScriptList21_59EB:
    INCBIN "roms/magination.gbc", $859EB, $5

SECTION "ROM Bank 033 @$0859F0", ROMX[$59F0], BANK[33]
ScriptList21_59F0:
    INCBIN "roms/magination.gbc", $859F0, $9

SECTION "ROM Bank 033 @$0859F9", ROMX[$59F9], BANK[33]
ScriptList21_59F9:
    INCBIN "roms/magination.gbc", $859F9, $11

SECTION "ROM Bank 033 @$085A0A", ROMX[$5A0A], BANK[33]
ScriptList21_5A0A:
    INCBIN "roms/magination.gbc", $85A0A, $5

SECTION "ROM Bank 033 @$085A0F", ROMX[$5A0F], BANK[33]
ScriptList21_5A0F:
    INCBIN "roms/magination.gbc", $85A0F, $D

SECTION "ROM Bank 033 @$085A1C", ROMX[$5A1C], BANK[33]
ScriptList21_5A1C:
    INCBIN "roms/magination.gbc", $85A1C, $5

SECTION "ROM Bank 033 @$085A21", ROMX[$5A21], BANK[33]
ScriptList21_5A21:
    INCBIN "roms/magination.gbc", $85A21, $9

SECTION "ROM Bank 033 @$085A2A", ROMX[$5A2A], BANK[33]
ScriptList21_5A2A:
    INCBIN "roms/magination.gbc", $85A2A, $5

SECTION "ROM Bank 033 @$085A2F", ROMX[$5A2F], BANK[33]
ScriptList21_5A2F:
    INCBIN "roms/magination.gbc", $85A2F, $D

SECTION "ROM Bank 033 @$085A3C", ROMX[$5A3C], BANK[33]
ScriptList21_5A3C:
    INCBIN "roms/magination.gbc", $85A3C, $D

SECTION "ROM Bank 033 @$085A49", ROMX[$5A49], BANK[33]
ScriptList21_5A49:
    INCBIN "roms/magination.gbc", $85A49, $9

SECTION "ROM Bank 033 @$085A52", ROMX[$5A52], BANK[33]
ScriptList21_5A52:
    INCBIN "roms/magination.gbc", $85A52, $D

SECTION "ROM Bank 033 @$085A5F", ROMX[$5A5F], BANK[33]
ScriptList21_5A5F:
    INCBIN "roms/magination.gbc", $85A5F, $15

SECTION "ROM Bank 033 @$085A74", ROMX[$5A74], BANK[33]
ScriptList21_5A74:
    INCBIN "roms/magination.gbc", $85A74, $D

SECTION "ROM Bank 033 @$085A81", ROMX[$5A81], BANK[33]
ScriptList21_5A81:
    INCBIN "roms/magination.gbc", $85A81, $9

SECTION "ROM Bank 033 @$085A8A", ROMX[$5A8A], BANK[33]
ScriptList21_5A8A:
    INCBIN "roms/magination.gbc", $85A8A, $11

SECTION "ROM Bank 033 @$085A9B", ROMX[$5A9B], BANK[33]
ScriptList21_5A9B:
    INCBIN "roms/magination.gbc", $85A9B, $1D

SECTION "ROM Bank 033 @$085AB8", ROMX[$5AB8], BANK[33]
ScriptList21_5AB8:
    INCBIN "roms/magination.gbc", $85AB8, $11

SECTION "ROM Bank 033 @$085AC9", ROMX[$5AC9], BANK[33]
ScriptList21_5AC9:
    INCBIN "roms/magination.gbc", $85AC9, $D

SECTION "ROM Bank 033 @$085AD6", ROMX[$5AD6], BANK[33]
ScriptList21_5AD6:
    INCBIN "roms/magination.gbc", $85AD6, $5

SECTION "ROM Bank 033 @$085ADB", ROMX[$5ADB], BANK[33]
ScriptList21_5ADB:
    INCBIN "roms/magination.gbc", $85ADB, $21

SECTION "ROM Bank 033 @$085AFC", ROMX[$5AFC], BANK[33]
ScriptList21_5AFC:
    INCBIN "roms/magination.gbc", $85AFC, $9

SECTION "ROM Bank 033 @$085B05", ROMX[$5B05], BANK[33]
ScriptList21_5B05:
    INCBIN "roms/magination.gbc", $85B05, $5

SECTION "ROM Bank 033 @$085B0A", ROMX[$5B0A], BANK[33]
ScriptList21_5B0A:
    INCBIN "roms/magination.gbc", $85B0A, $D

SECTION "ROM Bank 033 @$085B17", ROMX[$5B17], BANK[33]
ScriptList21_5B17:
    INCBIN "roms/magination.gbc", $85B17, $9

SECTION "ROM Bank 033 @$085B20", ROMX[$5B20], BANK[33]
ScriptList21_5B20:
    INCBIN "roms/magination.gbc", $85B20, $9

SECTION "ROM Bank 033 @$085B29", ROMX[$5B29], BANK[33]
ScriptList21_5B29:
    INCBIN "roms/magination.gbc", $85B29, $29

SECTION "ROM Bank 033 @$085B52", ROMX[$5B52], BANK[33]
ScriptList21_5B52:
    INCBIN "roms/magination.gbc", $85B52, $11

SECTION "ROM Bank 033 @$085B63", ROMX[$5B63], BANK[33]
ScriptList21_5B63:
    INCBIN "roms/magination.gbc", $85B63, $5

SECTION "ROM Bank 033 @$085B68", ROMX[$5B68], BANK[33]
ScriptList21_5B68:
    INCBIN "roms/magination.gbc", $85B68, $5

SECTION "ROM Bank 033 @$085B6D", ROMX[$5B6D], BANK[33]
ScriptList21_5B6D:
    INCBIN "roms/magination.gbc", $85B6D, $15

SECTION "ROM Bank 033 @$085B82", ROMX[$5B82], BANK[33]
ScriptList21_5B82:
    INCBIN "roms/magination.gbc", $85B82, $5

SECTION "ROM Bank 033 @$085B87", ROMX[$5B87], BANK[33]
ScriptList21_5B87:
    INCBIN "roms/magination.gbc", $85B87, $9

SECTION "ROM Bank 033 @$085B90", ROMX[$5B90], BANK[33]
ScriptList21_5B90:
    INCBIN "roms/magination.gbc", $85B90, $5

SECTION "ROM Bank 033 @$085B95", ROMX[$5B95], BANK[33]
ScriptList21_5B95:
    INCBIN "roms/magination.gbc", $85B95, $15

SECTION "ROM Bank 033 @$085BAA", ROMX[$5BAA], BANK[33]
ScriptList21_5BAA:
    INCBIN "roms/magination.gbc", $85BAA, $29

SECTION "ROM Bank 033 @$085BD3", ROMX[$5BD3], BANK[33]
ScriptList21_5BD3:
    INCBIN "roms/magination.gbc", $85BD3, $D

SECTION "ROM Bank 033 @$085BE0", ROMX[$5BE0], BANK[33]
ScriptList21_5BE0:
    INCBIN "roms/magination.gbc", $85BE0, $5

SECTION "ROM Bank 033 @$085BE5", ROMX[$5BE5], BANK[33]
ScriptList21_5BE5:
    INCBIN "roms/magination.gbc", $85BE5, $9

SECTION "ROM Bank 033 @$085BEE", ROMX[$5BEE], BANK[33]
ScriptList21_5BEE:
    INCBIN "roms/magination.gbc", $85BEE, $D

SECTION "ROM Bank 033 @$085BFB", ROMX[$5BFB], BANK[33]
ScriptList21_5BFB:
    INCBIN "roms/magination.gbc", $85BFB, $D

SECTION "ROM Bank 033 @$085C08", ROMX[$5C08], BANK[33]
ScriptList21_5C08:
    INCBIN "roms/magination.gbc", $85C08, $9

SECTION "ROM Bank 033 @$085C11", ROMX[$5C11], BANK[33]
ScriptList21_5C11:
    INCBIN "roms/magination.gbc", $85C11, $11

SECTION "ROM Bank 033 @$085C22", ROMX[$5C22], BANK[33]
ScriptList21_5C22:
    INCBIN "roms/magination.gbc", $85C22, $5

SECTION "ROM Bank 033 @$085C27", ROMX[$5C27], BANK[33]
ScriptList21_5C27:
    INCBIN "roms/magination.gbc", $85C27, $5

SECTION "ROM Bank 033 @$085C2C", ROMX[$5C2C], BANK[33]
ScriptList21_5C2C:
    INCBIN "roms/magination.gbc", $85C2C, $9

SECTION "ROM Bank 033 @$085C35", ROMX[$5C35], BANK[33]
ScriptList21_5C35:
    INCBIN "roms/magination.gbc", $85C35, $9

SECTION "ROM Bank 033 @$085C3E", ROMX[$5C3E], BANK[33]
ScriptList21_5C3E:
    INCBIN "roms/magination.gbc", $85C3E, $2D

SECTION "ROM Bank 033 @$085C6B", ROMX[$5C6B], BANK[33]
ScriptList21_5C6B:
    INCBIN "roms/magination.gbc", $85C6B, $9

SECTION "ROM Bank 033 @$085C74", ROMX[$5C74], BANK[33]
ScriptList21_5C74:
    INCBIN "roms/magination.gbc", $85C74, $9

SECTION "ROM Bank 033 @$085C7D", ROMX[$5C7D], BANK[33]
ScriptList21_5C7D:
    INCBIN "roms/magination.gbc", $85C7D, $9

SECTION "ROM Bank 033 @$085C86", ROMX[$5C86], BANK[33]
ScriptList21_5C86:
    INCBIN "roms/magination.gbc", $85C86, $9

SECTION "ROM Bank 033 @$085C8F", ROMX[$5C8F], BANK[33]
ScriptList21_5C8F:
    INCBIN "roms/magination.gbc", $85C8F, $5

SECTION "ROM Bank 033 @$085C94", ROMX[$5C94], BANK[33]
ScriptList21_5C94:
    INCBIN "roms/magination.gbc", $85C94, $D

SECTION "ROM Bank 033 @$085CA1", ROMX[$5CA1], BANK[33]
ScriptList21_5CA1:
    INCBIN "roms/magination.gbc", $85CA1, $D

SECTION "ROM Bank 033 @$085CAE", ROMX[$5CAE], BANK[33]
ScriptList21_5CAE:
    INCBIN "roms/magination.gbc", $85CAE, $9

SECTION "ROM Bank 033 @$085CB7", ROMX[$5CB7], BANK[33]
ScriptList21_5CB7:
    INCBIN "roms/magination.gbc", $85CB7, $9

SECTION "Palettes21_5CC0", ROMX[$5CC0], BANK[33]
; palettes_bank21.asm: not published here (it assembles data copied from the ROM)
Palettes21_5CC0:
ScriptListsEnd:
    INCBIN "roms/magination.gbc", $85CC0, $138

SECTION "Palettes21_5CC0 @$085DF8", ROMX[$5DF8], BANK[33]
EntryPalettes004:
Palettes21_5DF8:
    INCBIN "roms/magination.gbc", $85DF8, $18

SECTION "Palettes21_5CC0 @$085E10", ROMX[$5E10], BANK[33]
EntryPalettes006:
Palettes21_5E10:
    INCBIN "roms/magination.gbc", $85E10, $18

SECTION "Palettes21_5CC0 @$085E28", ROMX[$5E28], BANK[33]
EntryPalettes025:
Palettes21_5E28:
    INCBIN "roms/magination.gbc", $85E28, $18

SECTION "Palettes21_5CC0 @$085E40", ROMX[$5E40], BANK[33]
EntryPalettes028:
Palettes21_5E40:
    INCBIN "roms/magination.gbc", $85E40, $18

SECTION "Palettes21_5CC0 @$085E58", ROMX[$5E58], BANK[33]
EntryPalettes045:
Palettes21_5E58:
    INCBIN "roms/magination.gbc", $85E58, $18

SECTION "Palettes21_5CC0 @$085E70", ROMX[$5E70], BANK[33]
EntryPalettes056:
Palettes21_5E70:
    INCBIN "roms/magination.gbc", $85E70, $18

SECTION "Palettes21_5CC0 @$085E88", ROMX[$5E88], BANK[33]
EntryPalettes061:
Palettes21_5E88:
    INCBIN "roms/magination.gbc", $85E88, $18

SECTION "Palettes21_5CC0 @$085EA0", ROMX[$5EA0], BANK[33]
EntryPalettes072:
Palettes21_5EA0:
    INCBIN "roms/magination.gbc", $85EA0, $18

SECTION "Palettes21_5CC0 @$085EB8", ROMX[$5EB8], BANK[33]
EntryPalettes075:
Palettes21_5EB8:
    INCBIN "roms/magination.gbc", $85EB8, $18

SECTION "Palettes21_5CC0 @$085ED0", ROMX[$5ED0], BANK[33]
EntryPalettes079:
Palettes21_5ED0:
    INCBIN "roms/magination.gbc", $85ED0, $18

SECTION "Palettes21_5CC0 @$085EE8", ROMX[$5EE8], BANK[33]
EntryPalettes083:
Palettes21_5EE8:
    INCBIN "roms/magination.gbc", $85EE8, $18

SECTION "Palettes21_5CC0 @$085F00", ROMX[$5F00], BANK[33]
EntryPalettes000:
Palettes21_5F00:
    INCBIN "roms/magination.gbc", $85F00, $18

SECTION "Palettes21_5CC0 @$085F18", ROMX[$5F18], BANK[33]
EntryPalettes012:
Palettes21_5F18:
    INCBIN "roms/magination.gbc", $85F18, $18

SECTION "Palettes21_5CC0 @$085F30", ROMX[$5F30], BANK[33]
EntryPalettes016:
Palettes21_5F30:
    INCBIN "roms/magination.gbc", $85F30, $18

SECTION "Palettes21_5CC0 @$085F48", ROMX[$5F48], BANK[33]
EntryPalettes021:
Palettes21_5F48:
    INCBIN "roms/magination.gbc", $85F48, $18

SECTION "Palettes21_5CC0 @$085F60", ROMX[$5F60], BANK[33]
EntryPalettes036:
Palettes21_5F60:
    INCBIN "roms/magination.gbc", $85F60, $18

SECTION "Palettes21_5CC0 @$085F78", ROMX[$5F78], BANK[33]
EntryPalettes047:
Palettes21_5F78:
    INCBIN "roms/magination.gbc", $85F78, $18

SECTION "Palettes21_5CC0 @$085F90", ROMX[$5F90], BANK[33]
EntryPalettes052:
Palettes21_5F90:
    INCBIN "roms/magination.gbc", $85F90, $18

SECTION "Palettes21_5CC0 @$085FA8", ROMX[$5FA8], BANK[33]
EntryPalettes053:
Palettes21_5FA8:
    INCBIN "roms/magination.gbc", $85FA8, $18

SECTION "Palettes21_5CC0 @$085FC0", ROMX[$5FC0], BANK[33]
EntryPalettes055:
Palettes21_5FC0:
    INCBIN "roms/magination.gbc", $85FC0, $18

SECTION "Palettes21_5CC0 @$085FD8", ROMX[$5FD8], BANK[33]
EntryPalettes069:
Palettes21_5FD8:
    INCBIN "roms/magination.gbc", $85FD8, $18

SECTION "Palettes21_5CC0 @$085FF0", ROMX[$5FF0], BANK[33]
EntryPalettes001:
Palettes21_5FF0:
    INCBIN "roms/magination.gbc", $85FF0, $18

SECTION "Palettes21_5CC0 @$086008", ROMX[$6008], BANK[33]
EntryPalettes007:
Palettes21_6008:
    INCBIN "roms/magination.gbc", $86008, $18

SECTION "Palettes21_5CC0 @$086020", ROMX[$6020], BANK[33]
EntryPalettes011:
Palettes21_6020:
    INCBIN "roms/magination.gbc", $86020, $18

SECTION "Palettes21_5CC0 @$086038", ROMX[$6038], BANK[33]
EntryPalettes014:
Palettes21_6038:
    INCBIN "roms/magination.gbc", $86038, $18

SECTION "Palettes21_5CC0 @$086050", ROMX[$6050], BANK[33]
EntryPalettes030:
Palettes21_6050:
    INCBIN "roms/magination.gbc", $86050, $18

SECTION "Palettes21_5CC0 @$086068", ROMX[$6068], BANK[33]
EntryPalettes033:
Palettes21_6068:
    INCBIN "roms/magination.gbc", $86068, $18

SECTION "Palettes21_5CC0 @$086080", ROMX[$6080], BANK[33]
EntryPalettes048:
Palettes21_6080:
    INCBIN "roms/magination.gbc", $86080, $18

SECTION "Palettes21_5CC0 @$086098", ROMX[$6098], BANK[33]
EntryPalettes054:
Palettes21_6098:
    INCBIN "roms/magination.gbc", $86098, $18

SECTION "Palettes21_5CC0 @$0860B0", ROMX[$60B0], BANK[33]
EntryPalettes013:
Palettes21_60B0:
    INCBIN "roms/magination.gbc", $860B0, $18

SECTION "Palettes21_5CC0 @$0860C8", ROMX[$60C8], BANK[33]
EntryPalettes080:
Palettes21_60C8:
    INCBIN "roms/magination.gbc", $860C8, $18

SECTION "Palettes21_5CC0 @$0860E0", ROMX[$60E0], BANK[33]
EntryPalettes051:
Palettes21_60E0:
    INCBIN "roms/magination.gbc", $860E0, $18

SECTION "Palettes21_5CC0 @$0860F8", ROMX[$60F8], BANK[33]
EntryPalettes003:
Palettes21_60F8:
    INCBIN "roms/magination.gbc", $860F8, $18

SECTION "Palettes21_5CC0 @$086110", ROMX[$6110], BANK[33]
EntryPalettes022:
Palettes21_6110:
    INCBIN "roms/magination.gbc", $86110, $18

SECTION "Palettes21_5CC0 @$086128", ROMX[$6128], BANK[33]
EntryPalettes023:
Palettes21_6128:
    INCBIN "roms/magination.gbc", $86128, $18

SECTION "Palettes21_5CC0 @$086140", ROMX[$6140], BANK[33]
EntryPalettes027:
Palettes21_6140:
    INCBIN "roms/magination.gbc", $86140, $18

SECTION "Palettes21_5CC0 @$086158", ROMX[$6158], BANK[33]
EntryPalettes038:
Palettes21_6158:
    INCBIN "roms/magination.gbc", $86158, $18

SECTION "Palettes21_5CC0 @$086170", ROMX[$6170], BANK[33]
EntryPalettes041:
Palettes21_6170:
    INCBIN "roms/magination.gbc", $86170, $18

SECTION "Palettes21_5CC0 @$086188", ROMX[$6188], BANK[33]
EntryPalettes042:
Palettes21_6188:
    INCBIN "roms/magination.gbc", $86188, $18

SECTION "Palettes21_5CC0 @$0861A0", ROMX[$61A0], BANK[33]
EntryPalettes043:
Palettes21_61A0:
    INCBIN "roms/magination.gbc", $861A0, $18

SECTION "Palettes21_5CC0 @$0861B8", ROMX[$61B8], BANK[33]
EntryPalettes046:
Palettes21_61B8:
    INCBIN "roms/magination.gbc", $861B8, $18

SECTION "Palettes21_5CC0 @$0861D0", ROMX[$61D0], BANK[33]
EntryPalettes058:
Palettes21_61D0:
    INCBIN "roms/magination.gbc", $861D0, $18

SECTION "Palettes21_5CC0 @$0861E8", ROMX[$61E8], BANK[33]
EntryPalettes060:
Palettes21_61E8:
    INCBIN "roms/magination.gbc", $861E8, $18

SECTION "Palettes21_5CC0 @$086200", ROMX[$6200], BANK[33]
EntryPalettes002:
Palettes21_6200:
    INCBIN "roms/magination.gbc", $86200, $18

SECTION "Palettes21_5CC0 @$086218", ROMX[$6218], BANK[33]
EntryPalettes005:
Palettes21_6218:
    INCBIN "roms/magination.gbc", $86218, $18

SECTION "Palettes21_5CC0 @$086230", ROMX[$6230], BANK[33]
EntryPalettes026:
Palettes21_6230:
    INCBIN "roms/magination.gbc", $86230, $18

SECTION "Palettes21_5CC0 @$086248", ROMX[$6248], BANK[33]
EntryPalettes009:
Palettes21_6248:
    INCBIN "roms/magination.gbc", $86248, $18

SECTION "Palettes21_5CC0 @$086260", ROMX[$6260], BANK[33]
EntryPalettes049:
EntryPalettes108:
Palettes21_6260:
    INCBIN "roms/magination.gbc", $86260, $18

SECTION "Palettes21_5CC0 @$086278", ROMX[$6278], BANK[33]
EntryPalettes050:
Palettes21_6278:
    INCBIN "roms/magination.gbc", $86278, $18

SECTION "Palettes21_5CC0 @$086290", ROMX[$6290], BANK[33]
EntryPalettes071:
Palettes21_6290:
    INCBIN "roms/magination.gbc", $86290, $18

SECTION "Palettes21_5CC0 @$0862A8", ROMX[$62A8], BANK[33]
EntryPalettes076:
Palettes21_62A8:
    INCBIN "roms/magination.gbc", $862A8, $18

SECTION "Palettes21_5CC0 @$0862C0", ROMX[$62C0], BANK[33]
EntryPalettes077:
Palettes21_62C0:
    INCBIN "roms/magination.gbc", $862C0, $18

SECTION "Palettes21_5CC0 @$0862D8", ROMX[$62D8], BANK[33]
EntryPalettes084:
Palettes21_62D8:
    INCBIN "roms/magination.gbc", $862D8, $18

SECTION "Palettes21_5CC0 @$0862F0", ROMX[$62F0], BANK[33]
EntryPalettes008:
Palettes21_62F0:
    INCBIN "roms/magination.gbc", $862F0, $18

SECTION "Palettes21_5CC0 @$086308", ROMX[$6308], BANK[33]
EntryPalettes015:
Palettes21_6308:
    INCBIN "roms/magination.gbc", $86308, $18

SECTION "Palettes21_5CC0 @$086320", ROMX[$6320], BANK[33]
EntryPalettes017:
Palettes21_6320:
    INCBIN "roms/magination.gbc", $86320, $18

SECTION "Palettes21_5CC0 @$086338", ROMX[$6338], BANK[33]
EntryPalettes018:
Palettes21_6338:
    INCBIN "roms/magination.gbc", $86338, $18

SECTION "Palettes21_5CC0 @$086350", ROMX[$6350], BANK[33]
EntryPalettes024:
Palettes21_6350:
    INCBIN "roms/magination.gbc", $86350, $18

SECTION "Palettes21_5CC0 @$086368", ROMX[$6368], BANK[33]
EntryPalettes032:
Palettes21_6368:
    INCBIN "roms/magination.gbc", $86368, $18

SECTION "Palettes21_5CC0 @$086380", ROMX[$6380], BANK[33]
EntryPalettes040:
Palettes21_6380:
    INCBIN "roms/magination.gbc", $86380, $18

SECTION "Palettes21_5CC0 @$086398", ROMX[$6398], BANK[33]
EntryPalettes065:
Palettes21_6398:
    INCBIN "roms/magination.gbc", $86398, $18

SECTION "Palettes21_5CC0 @$0863B0", ROMX[$63B0], BANK[33]
EntryPalettes066:
Palettes21_63B0:
    INCBIN "roms/magination.gbc", $863B0, $18

SECTION "Palettes21_5CC0 @$0863C8", ROMX[$63C8], BANK[33]
EntryPalettes068:
Palettes21_63C8:
    INCBIN "roms/magination.gbc", $863C8, $18

SECTION "Palettes21_5CC0 @$0863E0", ROMX[$63E0], BANK[33]
EntryPalettes085:
EntryPalettes086:
EntryPalettes087:
Palettes21_63E0:
    INCBIN "roms/magination.gbc", $863E0, $18

SECTION "Palettes21_5CC0 @$0863F8", ROMX[$63F8], BANK[33]
EntryPalettes019:
Palettes21_63F8:
    INCBIN "roms/magination.gbc", $863F8, $18

SECTION "Palettes21_5CC0 @$086410", ROMX[$6410], BANK[33]
EntryPalettes020:
Palettes21_6410:
    INCBIN "roms/magination.gbc", $86410, $18

SECTION "Palettes21_5CC0 @$086428", ROMX[$6428], BANK[33]
EntryPalettes034:
Palettes21_6428:
    INCBIN "roms/magination.gbc", $86428, $18

SECTION "Palettes21_5CC0 @$086440", ROMX[$6440], BANK[33]
EntryPalettes035:
Palettes21_6440:
    INCBIN "roms/magination.gbc", $86440, $18

SECTION "Palettes21_5CC0 @$086458", ROMX[$6458], BANK[33]
EntryPalettes037:
Palettes21_6458:
    INCBIN "roms/magination.gbc", $86458, $18

SECTION "Palettes21_5CC0 @$086470", ROMX[$6470], BANK[33]
EntryPalettes039:
Palettes21_6470:
    INCBIN "roms/magination.gbc", $86470, $18

SECTION "Palettes21_5CC0 @$086488", ROMX[$6488], BANK[33]
EntryPalettes063:
Palettes21_6488:
    INCBIN "roms/magination.gbc", $86488, $18

SECTION "Palettes21_5CC0 @$0864A0", ROMX[$64A0], BANK[33]
EntryPalettes070:
Palettes21_64A0:
    INCBIN "roms/magination.gbc", $864A0, $18

SECTION "Palettes21_5CC0 @$0864B8", ROMX[$64B8], BANK[33]
EntryPalettes078:
Palettes21_64B8:
    INCBIN "roms/magination.gbc", $864B8, $18

SECTION "Palettes21_5CC0 @$0864D0", ROMX[$64D0], BANK[33]
EntryPalettes010:
Palettes21_64D0:
    INCBIN "roms/magination.gbc", $864D0, $18

SECTION "Palettes21_5CC0 @$0864E8", ROMX[$64E8], BANK[33]
EntryPalettes029:
Palettes21_64E8:
    INCBIN "roms/magination.gbc", $864E8, $18

SECTION "Palettes21_5CC0 @$086500", ROMX[$6500], BANK[33]
EntryPalettes057:
Palettes21_6500:
    INCBIN "roms/magination.gbc", $86500, $18

SECTION "Palettes21_5CC0 @$086518", ROMX[$6518], BANK[33]
EntryPalettes074:
Palettes21_6518:
    INCBIN "roms/magination.gbc", $86518, $18

SECTION "Palettes21_5CC0 @$086530", ROMX[$6530], BANK[33]
EntryPalettes082:
Palettes21_6530:
    INCBIN "roms/magination.gbc", $86530, $18

SECTION "Palettes21_5CC0 @$086548", ROMX[$6548], BANK[33]
EntryPalettes031:
Palettes21_6548:
    INCBIN "roms/magination.gbc", $86548, $18

SECTION "Palettes21_5CC0 @$086560", ROMX[$6560], BANK[33]
EntryPalettes062:
Palettes21_6560:
    INCBIN "roms/magination.gbc", $86560, $18

SECTION "Palettes21_5CC0 @$086578", ROMX[$6578], BANK[33]
EntryPalettes044:
Palettes21_6578:
    INCBIN "roms/magination.gbc", $86578, $18

SECTION "Palettes21_5CC0 @$086590", ROMX[$6590], BANK[33]
EntryPalettes059:
Palettes21_6590:
    INCBIN "roms/magination.gbc", $86590, $18

SECTION "Palettes21_5CC0 @$0865A8", ROMX[$65A8], BANK[33]
EntryPalettes073:
Palettes21_65A8:
    INCBIN "roms/magination.gbc", $865A8, $18

SECTION "Palettes21_5CC0 @$0865C0", ROMX[$65C0], BANK[33]
EntryPalettes081:
Palettes21_65C0:
    INCBIN "roms/magination.gbc", $865C0, $18

SECTION "Palettes21_5CC0 @$0865D8", ROMX[$65D8], BANK[33]
EntryPalettes064:
Palettes21_65D8:
    INCBIN "roms/magination.gbc", $865D8, $18

SECTION "Palettes21_5CC0 @$0865F0", ROMX[$65F0], BANK[33]
EntryPalettes067:
Palettes21_65F0:
    INCBIN "roms/magination.gbc", $865F0, $18

SECTION "Palettes21_5CC0 @$086608", ROMX[$6608], BANK[33]
EntryPalettes088:
Palettes21_6608:
    INCBIN "roms/magination.gbc", $86608, $18

SECTION "Palettes21_5CC0 @$086620", ROMX[$6620], BANK[33]
EntryPalettes089:
Palettes21_6620:
    INCBIN "roms/magination.gbc", $86620, $18

SECTION "Palettes21_5CC0 @$086638", ROMX[$6638], BANK[33]
EntryPalettes090:
Palettes21_6638:
    INCBIN "roms/magination.gbc", $86638, $18

SECTION "Palettes21_5CC0 @$086650", ROMX[$6650], BANK[33]
EntryPalettes091:
Palettes21_6650:
    INCBIN "roms/magination.gbc", $86650, $18

SECTION "Palettes21_5CC0 @$086668", ROMX[$6668], BANK[33]
EntryPalettes092:
Palettes21_6668:
    INCBIN "roms/magination.gbc", $86668, $18

SECTION "Palettes21_5CC0 @$086680", ROMX[$6680], BANK[33]
EntryPalettes093:
Palettes21_6680:
    INCBIN "roms/magination.gbc", $86680, $18

SECTION "Palettes21_5CC0 @$086698", ROMX[$6698], BANK[33]
EntryPalettes094:
Palettes21_6698:
    INCBIN "roms/magination.gbc", $86698, $18

SECTION "Palettes21_5CC0 @$0866B0", ROMX[$66B0], BANK[33]
EntryPalettes095:
Palettes21_66B0:
    INCBIN "roms/magination.gbc", $866B0, $18

SECTION "Palettes21_5CC0 @$0866C8", ROMX[$66C8], BANK[33]
EntryPalettes096:
Palettes21_66C8:
    INCBIN "roms/magination.gbc", $866C8, $18

SECTION "Palettes21_5CC0 @$0866E0", ROMX[$66E0], BANK[33]
EntryPalettes097:
Palettes21_66E0:
    INCBIN "roms/magination.gbc", $866E0, $18

SECTION "Palettes21_5CC0 @$0866F8", ROMX[$66F8], BANK[33]
EntryPalettes098:
Palettes21_66F8:
    INCBIN "roms/magination.gbc", $866F8, $18

SECTION "Palettes21_5CC0 @$086710", ROMX[$6710], BANK[33]
EntryPalettes099:
Palettes21_6710:
    INCBIN "roms/magination.gbc", $86710, $18

SECTION "Palettes21_5CC0 @$086728", ROMX[$6728], BANK[33]
EntryPalettes100:
Palettes21_6728:
    INCBIN "roms/magination.gbc", $86728, $18

SECTION "Palettes21_5CC0 @$086740", ROMX[$6740], BANK[33]
EntryPalettes101:
Palettes21_6740:
    INCBIN "roms/magination.gbc", $86740, $18

SECTION "Palettes21_5CC0 @$086758", ROMX[$6758], BANK[33]
EntryPalettes102:
Palettes21_6758:
    INCBIN "roms/magination.gbc", $86758, $18

SECTION "Palettes21_5CC0 @$086770", ROMX[$6770], BANK[33]
EntryPalettes103:
Palettes21_6770:
    INCBIN "roms/magination.gbc", $86770, $18

SECTION "Palettes21_5CC0 @$086788", ROMX[$6788], BANK[33]
EntryPalettes104:
Palettes21_6788:
    INCBIN "roms/magination.gbc", $86788, $18

SECTION "Palettes21_5CC0 @$0867A0", ROMX[$67A0], BANK[33]
EntryPalettes105:
Palettes21_67A0:
    INCBIN "roms/magination.gbc", $867A0, $18

SECTION "Palettes21_5CC0 @$0867B8", ROMX[$67B8], BANK[33]
EntryPalettes106:
Palettes21_67B8:
    INCBIN "roms/magination.gbc", $867B8, $18

SECTION "Palettes21_5CC0 @$0867D0", ROMX[$67D0], BANK[33]
EntryPalettes107:
Palettes21_67D0:
    INCBIN "roms/magination.gbc", $867D0, $18

SECTION "ROM from $0867E8", ROMX[$67E8], BANK[33]
    INCBIN "roms/magination.gbc", $867E8, $11BF

SECTION "Zero padding from $0879A7", ROMX[$79A7], BANK[33]
    ds $659, $00 ; zero padding to the end of bank $21

SECTION "ROM Bank 034", ROMX[$4000], BANK[34]
    INCBIN "roms/magination.gbc", $88000, $3C5A

SECTION "Zero padding from $08BC5A", ROMX[$7C5A], BANK[34]
    ds $3A6, $00 ; zero padding to the end of bank $22

SECTION "ROM Bank 035", ROMX[$4000], BANK[35]
    INCBIN "roms/magination.gbc", $8C000, $3DBB

SECTION "Zero padding from $08FDBB", ROMX[$7DBB], BANK[35]
    ds $245, $00 ; zero padding to the end of bank $23

SECTION "ROM Bank 036", ROMX[$4000], BANK[36]
    INCBIN "roms/magination.gbc", $90000, $4000

SECTION "Sprite lists bank $25", ROMX[$4000], BANK[37]
; sprite_lists_bank25.asm: not published here (it assembles data copied from the ROM)
SpriteList25_00:
    INCBIN "roms/magination.gbc", $94000, $29

SECTION "Sprite lists bank $25 @$094029", ROMX[$4029], BANK[37]
SpriteList25_01:
    INCBIN "roms/magination.gbc", $94029, $29

SECTION "Sprite lists bank $25 @$094052", ROMX[$4052], BANK[37]
SpriteList25_02:
    INCBIN "roms/magination.gbc", $94052, $2D

SECTION "Sprite lists bank $25 @$09407F", ROMX[$407F], BANK[37]
SpriteList25_03:
    INCBIN "roms/magination.gbc", $9407F, $29

SECTION "Sprite lists bank $25 @$0940A8", ROMX[$40A8], BANK[37]
SpriteList25_04:
    INCBIN "roms/magination.gbc", $940A8, $29

SECTION "Sprite lists bank $25 @$0940D1", ROMX[$40D1], BANK[37]
SpriteList25_05:
    INCBIN "roms/magination.gbc", $940D1, $2D

SECTION "Sprite lists bank $25 @$0940FE", ROMX[$40FE], BANK[37]
SpriteList25_06:
    INCBIN "roms/magination.gbc", $940FE, $29

SECTION "Sprite lists bank $25 @$094127", ROMX[$4127], BANK[37]
SpriteList25_07:
    INCBIN "roms/magination.gbc", $94127, $25

SECTION "Sprite lists bank $25 @$09414C", ROMX[$414C], BANK[37]
SpriteList25_08:
    INCBIN "roms/magination.gbc", $9414C, $21

SECTION "Sprite lists bank $25 @$09416D", ROMX[$416D], BANK[37]
SpriteList25_09:
    INCBIN "roms/magination.gbc", $9416D, $5

SECTION "Sprite lists bank $25 @$094172", ROMX[$4172], BANK[37]
SpriteList25_10:
    INCBIN "roms/magination.gbc", $94172, $15

SECTION "Sprite lists bank $25 @$094187", ROMX[$4187], BANK[37]
SpriteList25_11:
    INCBIN "roms/magination.gbc", $94187, $29

SECTION "Sprite lists bank $25 @$0941B0", ROMX[$41B0], BANK[37]
SpriteList25_12:
    INCBIN "roms/magination.gbc", $941B0, $25

SECTION "Sprite lists bank $25 @$0941D5", ROMX[$41D5], BANK[37]
SpriteList25_13:
    INCBIN "roms/magination.gbc", $941D5, $21

SECTION "Sprite lists bank $25 @$0941F6", ROMX[$41F6], BANK[37]
SpriteList25_14:
    INCBIN "roms/magination.gbc", $941F6, $5

SECTION "Sprite lists bank $25 @$0941FB", ROMX[$41FB], BANK[37]
SpriteList25_15:
    INCBIN "roms/magination.gbc", $941FB, $15

SECTION "Sprite animation scripts bank $25", ROMX[$4210], BANK[37]
    INCBIN "roms/magination.gbc", $94210, $383A

SECTION "Zero padding from $097A4A", ROMX[$7A4A], BANK[37]
    ds $5B6, $00 ; zero padding to the end of bank $25

SECTION "ROM Bank 038", ROMX[$4000], BANK[38]
    INCBIN "roms/magination.gbc", $98000, $3A5E

SECTION "Zero padding from $09BA5E", ROMX[$7A5E], BANK[38]
    ds $5A2, $00 ; zero padding to the end of bank $26

SECTION "bank39_gfx", ROMX[$4000], BANK[39]
; gfx/bank39_gfx.asm: not published here (it assembles data copied from the ROM)
Bank39Gfx:
    INCBIN "roms/magination.gbc", $9C000, $18E0

SECTION "ROM from $09D8E0", ROMX[$58E0], BANK[39]
    INCBIN "roms/magination.gbc", $09D8E0, $1977

SECTION "Zero padding from $09F257", ROMX[$7257], BANK[39]
    ds $DA9, $00 ; zero padding to the end of bank $27

SECTION "ROM Bank 040", ROMX[$4000], BANK[40]
    INCBIN "roms/magination.gbc", $A0000, $35E9

SECTION "Zero padding from $0A35E9", ROMX[$75E9], BANK[40]
    ds $A17, $00 ; zero padding to the end of bank $28

SECTION "ROM Bank 041", ROMX[$4000], BANK[41]
    INCBIN "roms/magination.gbc", $A4000, $117A

SECTION "Zero padding from $0A517A", ROMX[$517A], BANK[41]
    ds $2E86, $00 ; zero padding to the end of bank $29

SECTION "ROM Bank 042", ROMX[$4000], BANK[42]
    INCBIN "roms/magination.gbc", $A8000, $3404

SECTION "Zero padding from $0AB404", ROMX[$7404], BANK[42]
    ds $BFC, $00 ; zero padding to the end of bank $2A

SECTION "ROM Bank 043", ROMX[$4000], BANK[43]
    INCBIN "roms/magination.gbc", $AC000, $3274

SECTION "Zero padding from $0AF274", ROMX[$7274], BANK[43]
    ds $D8C, $00 ; zero padding to the end of bank $2B

SECTION "ROM Bank 044", ROMX[$4000], BANK[44]
    ds $4000, $00 ; zero padding to the end of bank $2C

SECTION "ROM Bank 045", ROMX[$4000], BANK[45]
    ds $4000, $00 ; zero padding to the end of bank $2D

SECTION "ROM Bank 046", ROMX[$4000], BANK[46]
    INCBIN "roms/magination.gbc", $B8000, $1643

SECTION "Zero padding from $0B9643", ROMX[$5643], BANK[46]
    ds $29BD, $00 ; zero padding to the end of bank $2E

SECTION "ROM Bank 047", ROMX[$4000], BANK[47]
    INCBIN "roms/magination.gbc", $BC000, $0CCE

SECTION "Zero padding from $0BCCCE", ROMX[$4CCE], BANK[47]
    ds $3332, $00 ; zero padding to the end of bank $2F

SECTION "Multiply A by C", ROMX[$4000], BANK[48]
INCLUDE "src/multiply_a_by_c.asm"

SECTION "Multiply Hl By Bc32", ROMX[$4041], BANK[48]
INCLUDE "src/multiply_hl_by_bc32.asm"

MultiplyHlByBc32End:

SECTION "Divide HL by BC", ROMX[$40AA], BANK[48]
INCLUDE "src/divide_hl_by_bc.asm"

SECTION "Divide HL by BC with remainder", ROMX[$40B0], BANK[48]
INCLUDE "src/divide_hl_by_bc_remainder.asm"

SECTION "Compare HL with BC", ROMX[$418D], BANK[48]
INCLUDE "src/compare_hl_bc.asm"

SECTION "Compare HL with DE", ROMX[$4198], BANK[48]
INCLUDE "src/compare_hl_de.asm"

SECTION "Step DF03", ROMX[$41A3], BANK[48]
INCLUDE "src/step_df03.asm"

SECTION "Step DF03 modulo B", ROMX[$41AF], BANK[48]
INCLUDE "src/step_df03_modulo_b.asm"

SECTION "Fold DF03 step into HL", ROMX[$41B9], BANK[48]
INCLUDE "src/fold_df03_step_into_hl.asm"

SECTION "Reset Sound Slots", ROMX[$41E8], BANK[48]
INCLUDE "src/reset_sound_slots.asm"

ResetSoundSlotsEnd:

SECTION "Stop All Sound", ROMX[$4212], BANK[48]
INCLUDE "src/stop_all_sound.asm"

StopAllSoundEnd:

SECTION "Play Wave Setup Guarded", ROMX[$421D], BANK[48]
INCLUDE "src/play_wave_setup_guarded.asm"

PlayWaveSetupGuardedEnd:

SECTION "Toggle Cpu Speed", ROMX[$4288], BANK[48]
INCLUDE "src/toggle_cpu_speed.asm"

ToggleCpuSpeedEnd:

SECTION "Start Mapped Waveform", ROMX[$42A0], BANK[48]
INCLUDE "src/start_mapped_waveform.asm"

StartMappedWaveformEnd:

SECTION "Maybe Continue Wave Stream", ROMX[$42FE], BANK[48]
INCLUDE "src/maybe_continue_wave_stream.asm"

MaybeContinueWaveStreamEnd:

SECTION "Set Master Volume", ROMX[$4307], BANK[48]
INCLUDE "src/set_master_volume.asm"

SetMasterVolumeEnd:

SECTION "Set Slot Mix Low", ROMX[$4320], BANK[48]
INCLUDE "src/set_slot_mix_low.asm"

SetSlotMixLowEnd:

SECTION "Set Slot Mix High", ROMX[$4339], BANK[48]
INCLUDE "src/set_slot_mix_high.asm"

SetSlotMixHighEnd:

SECTION "Update sound", ROMX[$4356], BANK[48]
INCLUDE "src/update_sound.asm"

SECTION "Update wave duty", ROMX[$43E0], BANK[48]
INCLUDE "src/update_wave_duty.asm"

SECTION "Reset Apu", ROMX[$449D], BANK[48]
INCLUDE "src/reset_apu.asm"

ResetApuEnd:

SECTION "Init Sound Work Area", ROMX[$44EF], BANK[48]
INCLUDE "src/init_sound_work_area.asm"

InitSoundWorkAreaEnd:

SECTION "Reload channel lengths", ROMX[$4524], BANK[48]
; reload_channel_lengths.asm: not published here (it assembles data copied from the ROM)
ReloadChannelLengths:
    INCBIN "roms/magination.gbc", $C0524, $39

SECTION "Sound command 00", ROMX[$455D], BANK[48]
INCLUDE "src/sound_command_00.asm"

SECTION "Sound Command Skip Byte", ROMX[$4574], BANK[48]
INCLUDE "src/sound_command_skip_byte.asm"

SoundCommandSkipByteEnd:

SECTION "Sound command 04", ROMX[$457C], BANK[48]
INCLUDE "src/sound_command_04.asm"

SECTION "Sound command 05", ROMX[$45EC], BANK[48]
INCLUDE "src/sound_command_05.asm"

SECTION "Sound command 06", ROMX[$461A], BANK[48]
INCLUDE "src/sound_command_06.asm"

SECTION "Sound Command Phase Script", ROMX[$462B], BANK[48]
INCLUDE "src/sound_command_phase_script.asm"

SoundCommandPhaseScriptEnd:

SECTION "Sound Command Set Envelope From Mix", ROMX[$4652], BANK[48]
INCLUDE "src/sound_command_set_envelope_from_mix.asm"

SoundCommandSetEnvelopeFromMixEnd:

SECTION "Sound Command Set Envelope And Level", ROMX[$467F], BANK[48]
INCLUDE "src/sound_command_set_envelope_and_level.asm"

SoundCommandSetEnvelopeAndLevelEnd:

SECTION "Apply caller channel byte", ROMX[$4690], BANK[48]
INCLUDE "src/apply_caller_channel_byte.asm"

SECTION "Update channel output mask", ROMX[$469A], BANK[48]
INCLUDE "src/update_channel_output_mask.asm"

SECTION "unk_0C06DA", ROMX[$46DA], BANK[48]
; unk_0c06da.asm: not published here (it assembles data copied from the ROM)
unk_0C06DA:
    INCBIN "roms/magination.gbc", $C06DA, $4

SECTION "unk_0C06DA @$0C06DE", ROMX[$46DE], BANK[48]
unk_0C06DE:
    INCBIN "roms/magination.gbc", $C06DE, $C

SECTION "Sound Command Restart With Duty", ROMX[$46EA], BANK[48]
INCLUDE "src/sound_command_restart_with_duty.asm"

SoundCommandRestartWithDutyEnd:

SECTION "Continue cleared channel", ROMX[$4710], BANK[48]
INCLUDE "src/continue_cleared_channel.asm"

SECTION "Sound Command Random Period", ROMX[$4717], BANK[48]
INCLUDE "src/sound_command_random_period.asm"

SoundCommandRandomPeriodEnd:

SECTION "Sound Command Set Or Add Slide", ROMX[$47E7], BANK[48]
INCLUDE "src/sound_command_set_or_add_slide.asm"

SoundCommandSetOrAddSlideEnd:

SECTION "Sound Command Slide Toward", ROMX[$483A], BANK[48]
INCLUDE "src/sound_command_slide_toward.asm"

SoundCommandSlideTowardEnd:

SECTION "Sound command 02", ROMX[$4868], BANK[48]
INCLUDE "src/sound_command_02.asm"

SECTION "Sound command 01", ROMX[$4889], BANK[48]
INCLUDE "src/sound_command_01.asm"

SECTION "Sound command 03", ROMX[$48A3], BANK[48]
INCLUDE "src/sound_command_03.asm"

SECTION "Sound Command Set Noise", ROMX[$48C4], BANK[48]
INCLUDE "src/sound_command_set_noise.asm"

SoundCommandSetNoiseEnd:

SECTION "Sound Command Arm Countdown", ROMX[$48D1], BANK[48]
INCLUDE "src/sound_command_arm_countdown.asm"

SoundCommandArmCountdownEnd:

SECTION "Arm channel after countdown", ROMX[$48DD], BANK[48]
INCLUDE "src/arm_channel_after_countdown.asm"

SECTION "Sound Command Start Phase", ROMX[$493D], BANK[48]
INCLUDE "src/sound_command_start_phase.asm"

SoundCommandStartPhaseEnd:

SECTION "Sound Command Set Envelope", ROMX[$4973], BANK[48]
; sound_command_set_envelope.asm: not published here (it assembles data copied from the ROM)
SoundCommandSetEnvelope:
    INCBIN "roms/magination.gbc", $C0973, $36

SECTION "Sound Command Set Envelope @$0C09A9", ROMX[$49A9], BANK[48]
EnvelopeRegisterBySlot:
    INCBIN "roms/magination.gbc", $C09A9, $3

SoundCommandSetEnvelopeEnd:

SECTION "Start Default Wave Sweep", ROMX[$49AC], BANK[48]
INCLUDE "src/start_default_wave_sweep.asm"

StartDefaultWaveSweepEnd:

SECTION "Clear Wave Tail", ROMX[$49E8], BANK[48]
INCLUDE "src/clear_wave_tail.asm"

ClearWaveTailEnd:

SECTION "Sound Command Load Wave Sweep", ROMX[$49FA], BANK[48]
INCLUDE "src/sound_command_load_wave_sweep.asm"

SoundCommandLoadWaveSweepEnd:

SECTION "Sound Command Reset Wave Sweep", ROMX[$4A2A], BANK[48]
INCLUDE "src/sound_command_reset_wave_sweep.asm"

SoundCommandResetWaveSweepEnd:

SECTION "Restart Wave Sweep From Dff6", ROMX[$4A61], BANK[48]
INCLUDE "src/restart_wave_sweep_from_dff6.asm"

RestartWaveSweepFromDff6End:

SECTION "Sound Command Set Loop Point", ROMX[$4A66], BANK[48]
INCLUDE "src/sound_command_set_loop_point.asm"

SoundCommandSetLoopPointEnd:

SECTION "Clear Slot Loop Point", ROMX[$4A8C], BANK[48]
INCLUDE "src/clear_slot_loop_point.asm"

ClearSlotLoopPointEnd:

SECTION "Clear Slot Effects", ROMX[$4A9C], BANK[48]
INCLUDE "src/clear_slot_effects.asm"

ClearSlotEffectsEnd:

SECTION "Clear Slot Effects And Slide", ROMX[$4AB9], BANK[48]
INCLUDE "src/clear_slot_effects_and_slide.asm"

ClearSlotEffectsAndSlideEnd:

SECTION "Sound Command Set Df33 Bit", ROMX[$4ACA], BANK[48]
INCLUDE "src/sound_command_set_df33_bit.asm"

SoundCommandSetDf33BitEnd:

SECTION "ROM from $0C0AE1", ROMX[$4AE1], BANK[48]
    INCBIN "roms/magination.gbc", $C0AE1, $0023

SECTION "Sound Command Branch If Period At Least", ROMX[$4B04], BANK[48]
INCLUDE "src/sound_command_branch_if_period_at_least.asm"

SoundCommandBranchIfPeriodAtLeastEnd:

SECTION "Sound Command Branch If Envelope At Least", ROMX[$4B21], BANK[48]
INCLUDE "src/sound_command_branch_if_envelope_at_least.asm"

SoundCommandBranchIfEnvelopeAtLeastEnd:

SECTION "Sound Command Branch If Random At Least", ROMX[$4B2D], BANK[48]
INCLUDE "src/sound_command_branch_if_random_at_least.asm"

SoundCommandBranchIfRandomAtLeastEnd:

SECTION "Sound Command Select Wave", ROMX[$4B40], BANK[48]
INCLUDE "src/sound_command_select_wave.asm"

SoundCommandSelectWaveEnd:

SECTION "Stage Wave And Restart", ROMX[$4B7E], BANK[48]
INCLUDE "src/stage_wave_and_restart.asm"

StageWaveAndRestartEnd:

SECTION "Set Wave Period Delta", ROMX[$4BA9], BANK[48]
INCLUDE "src/set_wave_period_delta.asm"

SetWavePeriodDeltaEnd:

SECTION "Start Sound Timer", ROMX[$4BD2], BANK[48]
INCLUDE "src/start_sound_timer.asm"

StartSoundTimerEnd:

SECTION "Step Wave Slot", ROMX[$4C17], BANK[48]
INCLUDE "src/step_wave_slot.asm"

StepWaveSlotEnd:

SECTION "Sound Command Slide Relative", ROMX[$4C7E], BANK[48]
INCLUDE "src/sound_command_slide_relative.asm"

SoundCommandSlideRelativeEnd:

SECTION "Sound Command Trigger Tag", ROMX[$4CB3], BANK[48]
INCLUDE "src/sound_command_trigger_tag.asm"

SoundCommandTriggerTagEnd:

SECTION "Sound Command Glide", ROMX[$4D04], BANK[48]
INCLUDE "src/sound_command_glide.asm"

SoundCommandGlideEnd:

SECTION "Sound Command Start Phase Down", ROMX[$4D43], BANK[48]
INCLUDE "src/sound_command_start_phase_down.asm"

SoundCommandStartPhaseDownEnd:

SECTION "Sound Command Adjust Priority", ROMX[$4D78], BANK[48]
INCLUDE "src/sound_command_adjust_priority.asm"

SoundCommandAdjustPriorityEnd:

SECTION "unk_0C0DA6", ROMX[$4DA6], BANK[48]
; unk_0c0da6.asm: not published here (it assembles data copied from the ROM)
unk_0C0DA6:
    INCBIN "roms/magination.gbc", $C0DA6, $54

SECTION "Open channel for tag", ROMX[$4DFA], BANK[48]
INCLUDE "src/open_channel_for_tag.asm"

SECTION "ChannelOwnMasks", ROMX[$4EDA], BANK[48]
; channel_own_masks.asm: not published here (it assembles data copied from the ROM)
ChannelOwnMasks:
    INCBIN "roms/magination.gbc", $C0EDA, $4

SECTION "Install tag stream", ROMX[$4EDE], BANK[48]
INCLUDE "src/install_tag_stream.asm"

SECTION "Prime Channel From Tag D1", ROMX[$4F15], BANK[48]
INCLUDE "src/prime_channel_from_tag_d1.asm"

PrimeChannelFromTagD1End:

SECTION "Prime channel from tag", ROMX[$4F1A], BANK[48]
INCLUDE "src/prime_channel_from_tag.asm"

SECTION "Open slot channel", ROMX[$4F44], BANK[48]
INCLUDE "src/open_slot_channel.asm"

SECTION "Find Slot For Companion", ROMX[$4FD8], BANK[48]
INCLUDE "src/find_slot_for_companion.asm"

FindSlotForCompanionEnd:

SECTION "Arm Slot For Companion", ROMX[$4FF1], BANK[48]
INCLUDE "src/arm_slot_for_companion.asm"

ArmSlotForCompanionEnd:

SECTION "ROM from $0C0FF8", ROMX[$4FF8], BANK[48]
    INCBIN "roms/magination.gbc", $C0FF8, $000E

SECTION "Step sound streams", ROMX[$5006], BANK[48]
INCLUDE "src/step_sound_streams.asm"

SECTION "Run sound stream", ROMX[$5032], BANK[48]
INCLUDE "src/run_sound_stream.asm"

RunSoundStreamEnd:

SECTION "Drop channel output", ROMX[$505B], BANK[48]
INCLUDE "src/drop_channel_output.asm"

SECTION "Write channel envelope", ROMX[$5070], BANK[48]
INCLUDE "src/write_channel_envelope.asm"

WriteChannelEnvelopeEnd:

SECTION "unk_0C10DA", ROMX[$50DA], BANK[48]
; unk_0c10da.asm: not published here (it assembles data copied from the ROM)
unk_0C10DA:
    INCBIN "roms/magination.gbc", $C10DA, $4

SECTION "unk_0C10DA @$0C10DE", ROMX[$50DE], BANK[48]
unk_0C10DE:
    INCBIN "roms/magination.gbc", $C10DE, $4

SECTION "unk_0C10DA @$0C10E2", ROMX[$50E2], BANK[48]
unk_0C10E2:
    INCBIN "roms/magination.gbc", $C10E2, $4

SECTION "Restart Channel", ROMX[$50E6], BANK[48]
INCLUDE "src/restart_channel.asm"

RestartChannelEnd:

SECTION "unk_0C1151", ROMX[$5151], BANK[48]
; unk_0c1151.asm: not published here (it assembles data copied from the ROM)
unk_0C1151:
    INCBIN "roms/magination.gbc", $C1151, $2

SECTION "unk_0C1151 @$0C1153", ROMX[$5153], BANK[48]
unk_0C1153:
    INCBIN "roms/magination.gbc", $C1153, $3

SECTION "unk_0C1151 @$0C1156", ROMX[$5156], BANK[48]
ChannelNr51ClearMask:
    INCBIN "roms/magination.gbc", $C1156, $4

SECTION "Lookup Wave Record", ROMX[$515A], BANK[48]
INCLUDE "src/lookup_wave_record.asm"

LookupWaveRecordEnd:

SECTION "Write channel period", ROMX[$5184], BANK[48]
INCLUDE "src/write_channel_period.asm"

SECTION "PeriodLowPort", ROMX[$51D3], BANK[48]
; period_low_port.asm: not published here (it assembles data copied from the ROM)
PeriodLowPort:
    INCBIN "roms/magination.gbc", $C11D3, $5

SECTION "PeriodLowPort @$0C11D8", ROMX[$51D8], BANK[48]
PeriodTable:
    INCBIN "roms/magination.gbc", $C11D8, $AA

SECTION "PeriodLowPort @$0C1282", ROMX[$5282], BANK[48]
PeriodScale:
    INCBIN "roms/magination.gbc", $C1282, $54

SECTION "Arm channel glide", ROMX[$52D6], BANK[48]
INCLUDE "src/arm_channel_glide.asm"

ArmChannelGlideEnd:

SECTION "Arm channel vibrato", ROMX[$536D], BANK[48]
INCLUDE "src/arm_channel_vibrato.asm"

ArmChannelVibratoEnd:

SECTION "Arm channel ramp", ROMX[$539C], BANK[48]
INCLUDE "src/arm_channel_ramp.asm"

SECTION "Step channel slides", ROMX[$53DE], BANK[48]
INCLUDE "src/step_channel_slides.asm"

SECTION "Fold slide step", ROMX[$54B6], BANK[48]
INCLUDE "src/fold_slide_step.asm"

SECTION "Start Phase Script", ROMX[$54EC], BANK[48]
INCLUDE "src/start_phase_script.asm"

StartPhaseScriptEnd:

SECTION "Step channel phases", ROMX[$551E], BANK[48]
INCLUDE "src/step_channel_phases.asm"

SECTION "Lookup channel nibble", ROMX[$5632], BANK[48]
INCLUDE "src/lookup_channel_nibble.asm"

SECTION "ChannelNibbleTable", ROMX[$564B], BANK[48]
; channel_nibble_table.asm: not published here (it assembles data copied from the ROM)
ChannelNibbleTable:
    INCBIN "roms/magination.gbc", $C164B, $80

SECTION "Advance wave stream", ROMX[$56CB], BANK[48]
INCLUDE "src/advance_wave_stream.asm"

AdvanceWaveStreamEnd:

SECTION "Install sound index", ROMX[$5702], BANK[48]
INCLUDE "src/install_sound_index.asm"

InstallSoundIndexEnd:

SECTION "Test countdown still running", ROMX[$5759], BANK[48]
INCLUDE "src/test_countdown_still_running.asm"

TestCountdownStillRunningEnd:

SECTION "Scale Countdown Step", ROMX[$576B], BANK[48]
INCLUDE "src/scale_countdown_step.asm"

ScaleCountdownStepEnd:

SECTION "Fill countdown step", ROMX[$577F], BANK[48]
INCLUDE "src/fill_countdown_step.asm"

FillCountdownStepEnd:

SECTION "Test countdown and drop gate", ROMX[$5798], BANK[48]
INCLUDE "src/test_countdown_and_drop_gate.asm"

SECTION "Drop countdown gate", ROMX[$57A0], BANK[48]
INCLUDE "src/drop_countdown_gate.asm"

DropCountdownGateEnd:

SECTION "Reset channel stream", ROMX[$57B5], BANK[48]
INCLUDE "src/reset_channel_stream.asm"

ResetChannelStreamEnd:

SECTION "Latch countdown gate", ROMX[$57CF], BANK[48]
INCLUDE "src/latch_countdown_gate.asm"

LatchCountdownGateEnd:

SECTION "Sound Signature Value", ROMX[$57DD], BANK[48]
INCLUDE "src/sound_signature_value.asm"

SoundSignatureValueEnd:

SECTION "Copy countdown block", ROMX[$57E0], BANK[48]
INCLUDE "src/copy_countdown_block.asm"

CopyCountdownBlockEnd:

SECTION "Restore countdown block", ROMX[$57EE], BANK[48]
INCLUDE "src/restore_countdown_block.asm"

RestoreCountdownBlockEnd:

SECTION "Step sound countdowns", ROMX[$57FC], BANK[48]
INCLUDE "src/step_sound_countdowns.asm"

StepSoundCountdownsEnd:

SECTION "CountdownMasks", ROMX[$58A7], BANK[48]
; countdown_masks.asm: not published here (it assembles data copied from the ROM)
CountdownMasks:
    INCBIN "roms/magination.gbc", $C18A7, $4

SECTION "CountdownMasks @$0C18AB", ROMX[$58AB], BANK[48]
UpperCountdownMasks:
    INCBIN "roms/magination.gbc", $C18AB, $4

SECTION "Step upper sound countdowns", ROMX[$58AF], BANK[48]
INCLUDE "src/step_upper_sound_countdowns.asm"

StepUpperSoundCountdownsEnd:

SECTION "Step lower sound countdowns", ROMX[$5921], BANK[48]
INCLUDE "src/step_lower_sound_countdowns.asm"

StepLowerSoundCountdownsEnd:

SECTION "Start lower sound countdown", ROMX[$596A], BANK[48]
INCLUDE "src/start_lower_sound_countdown.asm"

SECTION "Service lower countdown expiry", ROMX[$599D], BANK[48]
INCLUDE "src/service_lower_countdown_expiry.asm"

SECTION "Sound data", ROMX[$5A75], BANK[48]
; sound_data.asm: not published here (it assembles data copied from the ROM)
SoundDataLead:
    INCBIN "roms/magination.gbc", $C1A75, $4

SECTION "Sound data @$0C1A79", ROMX[$5A79], BANK[48]
SoundDataHeader:
    INCBIN "roms/magination.gbc", $C1A79, $F

SECTION "Sound data @$0C1A88", ROMX[$5A88], BANK[48]
SoundStreamTable:
    INCBIN "roms/magination.gbc", $C1A88, $64

SECTION "Sound data @$0C1AEC", ROMX[$5AEC], BANK[48]
SfxStream00:
    INCBIN "roms/magination.gbc", $C1AEC, $1B

SECTION "Sound data @$0C1B07", ROMX[$5B07], BANK[48]
SfxStream01:
    INCBIN "roms/magination.gbc", $C1B07, $20

SECTION "Sound data @$0C1B27", ROMX[$5B27], BANK[48]
SfxStream02:
    INCBIN "roms/magination.gbc", $C1B27, $11

SECTION "Sound data @$0C1B38", ROMX[$5B38], BANK[48]
SfxStream03:
    INCBIN "roms/magination.gbc", $C1B38, $19

SECTION "Sound data @$0C1B51", ROMX[$5B51], BANK[48]
SfxStream04:
    INCBIN "roms/magination.gbc", $C1B51, $1F

SECTION "Sound data @$0C1B70", ROMX[$5B70], BANK[48]
SfxStream05:
    INCBIN "roms/magination.gbc", $C1B70, $23

SECTION "Sound data @$0C1B93", ROMX[$5B93], BANK[48]
SfxStream06:
    INCBIN "roms/magination.gbc", $C1B93, $1B

SECTION "Sound data @$0C1BAE", ROMX[$5BAE], BANK[48]
SfxStream07:
    INCBIN "roms/magination.gbc", $C1BAE, $1A

SECTION "Sound data @$0C1BC8", ROMX[$5BC8], BANK[48]
SfxStream08:
    INCBIN "roms/magination.gbc", $C1BC8, $16

SECTION "Sound data @$0C1BDE", ROMX[$5BDE], BANK[48]
SfxStream09:
    INCBIN "roms/magination.gbc", $C1BDE, $27

SECTION "Sound data @$0C1C05", ROMX[$5C05], BANK[48]
SfxStream10:
    INCBIN "roms/magination.gbc", $C1C05, $1A

SECTION "Sound data @$0C1C1F", ROMX[$5C1F], BANK[48]
SfxStream11:
    INCBIN "roms/magination.gbc", $C1C1F, $18

SECTION "Sound data @$0C1C37", ROMX[$5C37], BANK[48]
SfxStream12:
    INCBIN "roms/magination.gbc", $C1C37, $11

SECTION "Sound data @$0C1C48", ROMX[$5C48], BANK[48]
SfxStream13:
    INCBIN "roms/magination.gbc", $C1C48, $11

SECTION "Sound data @$0C1C59", ROMX[$5C59], BANK[48]
SfxStream14:
    INCBIN "roms/magination.gbc", $C1C59, $1A

SECTION "Sound data @$0C1C73", ROMX[$5C73], BANK[48]
SfxStream15:
    INCBIN "roms/magination.gbc", $C1C73, $1E

SECTION "Sound data @$0C1C91", ROMX[$5C91], BANK[48]
SfxStream16:
    INCBIN "roms/magination.gbc", $C1C91, $11

SECTION "Sound data @$0C1CA2", ROMX[$5CA2], BANK[48]
SfxStream17:
    INCBIN "roms/magination.gbc", $C1CA2, $20

SECTION "Sound data @$0C1CC2", ROMX[$5CC2], BANK[48]
SfxStream18:
    INCBIN "roms/magination.gbc", $C1CC2, $4E

SECTION "Sound data @$0C1D10", ROMX[$5D10], BANK[48]
SfxStream19:
    INCBIN "roms/magination.gbc", $C1D10, $18

SECTION "Sound data @$0C1D28", ROMX[$5D28], BANK[48]
SfxStream20:
    INCBIN "roms/magination.gbc", $C1D28, $F

SECTION "Sound data @$0C1D37", ROMX[$5D37], BANK[48]
SfxStream21:
    INCBIN "roms/magination.gbc", $C1D37, $20

SECTION "Sound data @$0C1D57", ROMX[$5D57], BANK[48]
SfxStream22:
    INCBIN "roms/magination.gbc", $C1D57, $51

SECTION "Sound data @$0C1DA8", ROMX[$5DA8], BANK[48]
SfxStream23:
    INCBIN "roms/magination.gbc", $C1DA8, $24

SECTION "Sound data @$0C1DCC", ROMX[$5DCC], BANK[48]
SfxStream24:
    INCBIN "roms/magination.gbc", $C1DCC, $1D

SECTION "Sound data @$0C1DE9", ROMX[$5DE9], BANK[48]
SfxStream25:
    INCBIN "roms/magination.gbc", $C1DE9, $2D

SECTION "Sound data @$0C1E16", ROMX[$5E16], BANK[48]
SfxStream26:
    INCBIN "roms/magination.gbc", $C1E16, $46

SECTION "Sound data @$0C1E5C", ROMX[$5E5C], BANK[48]
SfxStream27:
    INCBIN "roms/magination.gbc", $C1E5C, $53

SECTION "Sound data @$0C1EAF", ROMX[$5EAF], BANK[48]
SfxStream28:
    INCBIN "roms/magination.gbc", $C1EAF, $29

SECTION "Sound data @$0C1ED8", ROMX[$5ED8], BANK[48]
SfxStream29:
    INCBIN "roms/magination.gbc", $C1ED8, $1A

SECTION "Sound data @$0C1EF2", ROMX[$5EF2], BANK[48]
SfxStream30:
    INCBIN "roms/magination.gbc", $C1EF2, $18

SECTION "Sound data @$0C1F0A", ROMX[$5F0A], BANK[48]
SfxStream31:
    INCBIN "roms/magination.gbc", $C1F0A, $27

SECTION "Sound data @$0C1F31", ROMX[$5F31], BANK[48]
SfxStream32:
    INCBIN "roms/magination.gbc", $C1F31, $E

SECTION "Sound data @$0C1F3F", ROMX[$5F3F], BANK[48]
SfxStream33:
    INCBIN "roms/magination.gbc", $C1F3F, $33

SECTION "Sound data @$0C1F72", ROMX[$5F72], BANK[48]
SfxStream34:
    INCBIN "roms/magination.gbc", $C1F72, $16

SECTION "Sound data @$0C1F88", ROMX[$5F88], BANK[48]
SfxStream35:
    INCBIN "roms/magination.gbc", $C1F88, $11

SECTION "Sound data @$0C1F99", ROMX[$5F99], BANK[48]
SfxStream36:
    INCBIN "roms/magination.gbc", $C1F99, $15

SECTION "Sound data @$0C1FAE", ROMX[$5FAE], BANK[48]
SfxStream37:
    INCBIN "roms/magination.gbc", $C1FAE, $C

SECTION "Sound data @$0C1FBA", ROMX[$5FBA], BANK[48]
SfxStream38:
    INCBIN "roms/magination.gbc", $C1FBA, $3

SECTION "Sound data @$0C1FBD", ROMX[$5FBD], BANK[48]
SfxStream39:
    INCBIN "roms/magination.gbc", $C1FBD, $24

SECTION "Sound data @$0C1FE1", ROMX[$5FE1], BANK[48]
SfxStream40:
    INCBIN "roms/magination.gbc", $C1FE1, $10

SECTION "Sound data @$0C1FF1", ROMX[$5FF1], BANK[48]
SfxStream41:
    INCBIN "roms/magination.gbc", $C1FF1, $10

SECTION "Sound data @$0C2001", ROMX[$6001], BANK[48]
SfxStream42:
    INCBIN "roms/magination.gbc", $C2001, $22

SECTION "Sound data @$0C2023", ROMX[$6023], BANK[48]
SfxStream43:
    INCBIN "roms/magination.gbc", $C2023, $15

SECTION "Sound data @$0C2038", ROMX[$6038], BANK[48]
SfxStream44:
    INCBIN "roms/magination.gbc", $C2038, $1D

SECTION "Sound data @$0C2055", ROMX[$6055], BANK[48]
SfxStream45:
    INCBIN "roms/magination.gbc", $C2055, $C

SECTION "Sound data @$0C2061", ROMX[$6061], BANK[48]
SfxStream46:
    INCBIN "roms/magination.gbc", $C2061, $22

SECTION "Sound data @$0C2083", ROMX[$6083], BANK[48]
SfxStream47:
    INCBIN "roms/magination.gbc", $C2083, $26

SECTION "Sound data @$0C20A9", ROMX[$60A9], BANK[48]
SfxStream48:
    INCBIN "roms/magination.gbc", $C20A9, $D

SECTION "Sound data @$0C20B6", ROMX[$60B6], BANK[48]
SfxStream49:
    INCBIN "roms/magination.gbc", $C20B6, $2

SECTION "Sound data @$0C20B8", ROMX[$60B8], BANK[48]
PhaseScriptTable:
    INCBIN "roms/magination.gbc", $C20B8, $12

SECTION "Sound data @$0C20CA", ROMX[$60CA], BANK[48]
SlotEntries:
    INCBIN "roms/magination.gbc", $C20CA, $A0

SECTION "Sound data @$0C216A", ROMX[$616A], BANK[48]
WaveRecords:
    INCBIN "roms/magination.gbc", $C216A, $18

SECTION "Sound data @$0C2182", ROMX[$6182], BANK[48]
SongList:
    INCBIN "roms/magination.gbc", $C2182, $1E7E

SECTION "ROM Bank 049", ROMX[$4000], BANK[49]
; wave_frames_bank31.asm: not published here (it assembles data copied from the ROM)
WaveFramesA:
    INCBIN "roms/magination.gbc", $C4000, $C0

SECTION "ROM Bank 049 @$0C40C0", ROMX[$40C0], BANK[49]
WaveFramesB:
    INCBIN "roms/magination.gbc", $C40C0, $10

SECTION "ROM Bank 049 @$0C40D0", ROMX[$40D0], BANK[49]
WaveFramesC:
    INCBIN "roms/magination.gbc", $C40D0, $10

SECTION "ROM Bank 049 @$0C40E0", ROMX[$40E0], BANK[49]
WaveFramesD:
    INCBIN "roms/magination.gbc", $C40E0, $10

SECTION "ROM Bank 049 @$0C40F0", ROMX[$40F0], BANK[49]
WaveFramesEnd:
    INCBIN "roms/magination.gbc", $C40F0, $110
    ; $4200-$7FFF: build-disk leftover (DOS stub, gm2song listing); no code reads it

SECTION "ROM from $0C4200", ROMX[$4200], BANK[49]
    INCBIN "roms/magination.gbc", $C4200, $3E00

SECTION "ROM Bank 050", ROMX[$4000], BANK[50]
; music_bank32.asm: not published here (it assembles data copied from the ROM)
Song05:
    INCBIN "roms/magination.gbc", $C8000, $84

SECTION "ROM Bank 050 @$0C8084", ROMX[$4084], BANK[50]
Song05_Table:
    INCBIN "roms/magination.gbc", $C8084, $6

SECTION "ROM Bank 050 @$0C808A", ROMX[$408A], BANK[50]
Song05_Tracks:
    INCBIN "roms/magination.gbc", $C808A, $8

SECTION "ROM Bank 050 @$0C8092", ROMX[$4092], BANK[50]
Song05_Track0:
    INCBIN "roms/magination.gbc", $C8092, $A

SECTION "ROM Bank 050 @$0C809C", ROMX[$409C], BANK[50]
Song05_Track1:
    INCBIN "roms/magination.gbc", $C809C, $A

SECTION "ROM Bank 050 @$0C80A6", ROMX[$40A6], BANK[50]
Song05_Track2:
    INCBIN "roms/magination.gbc", $C80A6, $A

SECTION "ROM Bank 050 @$0C80B0", ROMX[$40B0], BANK[50]
Song05_Track3:
    INCBIN "roms/magination.gbc", $C80B0, $A

SECTION "ROM Bank 050 @$0C80BA", ROMX[$40BA], BANK[50]
Song05_Patterns:
    INCBIN "roms/magination.gbc", $C80BA, $8

SECTION "ROM Bank 050 @$0C80C2", ROMX[$40C2], BANK[50]
Song05_Pattern00:
    INCBIN "roms/magination.gbc", $C80C2, $A54

SECTION "ROM Bank 050 @$0C8B16", ROMX[$4B16], BANK[50]
Song05_Pattern01:
    INCBIN "roms/magination.gbc", $C8B16, $8B1

SECTION "ROM Bank 050 @$0C93C7", ROMX[$53C7], BANK[50]
Song05_Pattern02:
    INCBIN "roms/magination.gbc", $C93C7, $79A

SECTION "ROM Bank 050 @$0C9B61", ROMX[$5B61], BANK[50]
Song05_Pattern03:
    INCBIN "roms/magination.gbc", $C9B61, $1AD9

SECTION "ROM Bank 050 @$0CB63A", ROMX[$763A], BANK[50]
Song25:
    INCBIN "roms/magination.gbc", $CB63A, $84

SECTION "ROM Bank 050 @$0CB6BE", ROMX[$76BE], BANK[50]
Song25_Table:
    INCBIN "roms/magination.gbc", $CB6BE, $6

SECTION "ROM Bank 050 @$0CB6C4", ROMX[$76C4], BANK[50]
Song25_Tracks:
    INCBIN "roms/magination.gbc", $CB6C4, $8

SECTION "ROM Bank 050 @$0CB6CC", ROMX[$76CC], BANK[50]
Song25_Track0:
    INCBIN "roms/magination.gbc", $CB6CC, $A

SECTION "ROM Bank 050 @$0CB6D6", ROMX[$76D6], BANK[50]
Song25_Track1:
    INCBIN "roms/magination.gbc", $CB6D6, $A

SECTION "ROM Bank 050 @$0CB6E0", ROMX[$76E0], BANK[50]
Song25_Track2:
    INCBIN "roms/magination.gbc", $CB6E0, $A

SECTION "ROM Bank 050 @$0CB6EA", ROMX[$76EA], BANK[50]
Song25_Track3:
    INCBIN "roms/magination.gbc", $CB6EA, $A

SECTION "ROM Bank 050 @$0CB6F4", ROMX[$76F4], BANK[50]
Song25_Patterns:
    INCBIN "roms/magination.gbc", $CB6F4, $8

SECTION "ROM Bank 050 @$0CB6FC", ROMX[$76FC], BANK[50]
Song25_Pattern00:
    INCBIN "roms/magination.gbc", $CB6FC, $22C

SECTION "ROM Bank 050 @$0CB928", ROMX[$7928], BANK[50]
Song25_Pattern01:
    INCBIN "roms/magination.gbc", $CB928, $1CC

SECTION "ROM Bank 050 @$0CBAF4", ROMX[$7AF4], BANK[50]
Song25_Pattern02:
    INCBIN "roms/magination.gbc", $CBAF4, $1A0

SECTION "ROM Bank 050 @$0CBC94", ROMX[$7C94], BANK[50]
Song25_Pattern03:
    INCBIN "roms/magination.gbc", $CBC94, $36C

SECTION "ROM Bank 051", ROMX[$4000], BANK[51]
; music_bank33.asm: not published here (it assembles data copied from the ROM)
Song04:
    INCBIN "roms/magination.gbc", $CC000, $84

SECTION "ROM Bank 051 @$0CC084", ROMX[$4084], BANK[51]
Song04_Table:
    INCBIN "roms/magination.gbc", $CC084, $6

SECTION "ROM Bank 051 @$0CC08A", ROMX[$408A], BANK[51]
Song04_Tracks:
    INCBIN "roms/magination.gbc", $CC08A, $8

SECTION "ROM Bank 051 @$0CC092", ROMX[$4092], BANK[51]
Song04_Track0:
    INCBIN "roms/magination.gbc", $CC092, $A

SECTION "ROM Bank 051 @$0CC09C", ROMX[$409C], BANK[51]
Song04_Track1:
    INCBIN "roms/magination.gbc", $CC09C, $A

SECTION "ROM Bank 051 @$0CC0A6", ROMX[$40A6], BANK[51]
Song04_Track2:
    INCBIN "roms/magination.gbc", $CC0A6, $A

SECTION "ROM Bank 051 @$0CC0B0", ROMX[$40B0], BANK[51]
Song04_Track3:
    INCBIN "roms/magination.gbc", $CC0B0, $A

SECTION "ROM Bank 051 @$0CC0BA", ROMX[$40BA], BANK[51]
Song04_Patterns:
    INCBIN "roms/magination.gbc", $CC0BA, $8

SECTION "ROM Bank 051 @$0CC0C2", ROMX[$40C2], BANK[51]
Song04_Pattern00:
    INCBIN "roms/magination.gbc", $CC0C2, $74C

SECTION "ROM Bank 051 @$0CC80E", ROMX[$480E], BANK[51]
Song04_Pattern01:
    INCBIN "roms/magination.gbc", $CC80E, $9C5

SECTION "ROM Bank 051 @$0CD1D3", ROMX[$51D3], BANK[51]
Song04_Pattern02:
    INCBIN "roms/magination.gbc", $CD1D3, $4A9

SECTION "ROM Bank 051 @$0CD67C", ROMX[$567C], BANK[51]
Song04_Pattern03:
    INCBIN "roms/magination.gbc", $CD67C, $84E

SECTION "ROM Bank 051 @$0CDECA", ROMX[$5ECA], BANK[51]
Song06:
    INCBIN "roms/magination.gbc", $CDECA, $84

SECTION "ROM Bank 051 @$0CDF4E", ROMX[$5F4E], BANK[51]
Song06_Table:
    INCBIN "roms/magination.gbc", $CDF4E, $6

SECTION "ROM Bank 051 @$0CDF54", ROMX[$5F54], BANK[51]
Song06_Tracks:
    INCBIN "roms/magination.gbc", $CDF54, $8

SECTION "ROM Bank 051 @$0CDF5C", ROMX[$5F5C], BANK[51]
Song06_Track0:
    INCBIN "roms/magination.gbc", $CDF5C, $A

SECTION "ROM Bank 051 @$0CDF66", ROMX[$5F66], BANK[51]
Song06_Track1:
    INCBIN "roms/magination.gbc", $CDF66, $A

SECTION "ROM Bank 051 @$0CDF70", ROMX[$5F70], BANK[51]
Song06_Track2:
    INCBIN "roms/magination.gbc", $CDF70, $A

SECTION "ROM Bank 051 @$0CDF7A", ROMX[$5F7A], BANK[51]
Song06_Track3:
    INCBIN "roms/magination.gbc", $CDF7A, $A

SECTION "ROM Bank 051 @$0CDF84", ROMX[$5F84], BANK[51]
Song06_Patterns:
    INCBIN "roms/magination.gbc", $CDF84, $8

SECTION "ROM Bank 051 @$0CDF8C", ROMX[$5F8C], BANK[51]
Song06_Pattern00:
    INCBIN "roms/magination.gbc", $CDF8C, $574

SECTION "ROM Bank 051 @$0CE500", ROMX[$6500], BANK[51]
Song06_Pattern01:
    INCBIN "roms/magination.gbc", $CE500, $70D

SECTION "ROM Bank 051 @$0CEC0D", ROMX[$6C0D], BANK[51]
Song06_Pattern02:
    INCBIN "roms/magination.gbc", $CEC0D, $3FA

SECTION "ROM Bank 051 @$0CF007", ROMX[$7007], BANK[51]
Song06_Pattern03:
    INCBIN "roms/magination.gbc", $CF007, $9BF

SECTION "ROM Bank 051 @$0CF9C6", ROMX[$79C6], BANK[51]
Song22:
    INCBIN "roms/magination.gbc", $CF9C6, $84

SECTION "ROM Bank 051 @$0CFA4A", ROMX[$7A4A], BANK[51]
Song22_Table:
    INCBIN "roms/magination.gbc", $CFA4A, $6

SECTION "ROM Bank 051 @$0CFA50", ROMX[$7A50], BANK[51]
Song22_Tracks:
    INCBIN "roms/magination.gbc", $CFA50, $8

SECTION "ROM Bank 051 @$0CFA58", ROMX[$7A58], BANK[51]
Song22_Track0:
    INCBIN "roms/magination.gbc", $CFA58, $A

SECTION "ROM Bank 051 @$0CFA62", ROMX[$7A62], BANK[51]
Song22_Track1:
    INCBIN "roms/magination.gbc", $CFA62, $A

SECTION "ROM Bank 051 @$0CFA6C", ROMX[$7A6C], BANK[51]
Song22_Track2:
    INCBIN "roms/magination.gbc", $CFA6C, $A

SECTION "ROM Bank 051 @$0CFA76", ROMX[$7A76], BANK[51]
Song22_Track3:
    INCBIN "roms/magination.gbc", $CFA76, $A

SECTION "ROM Bank 051 @$0CFA80", ROMX[$7A80], BANK[51]
Song22_Patterns:
    INCBIN "roms/magination.gbc", $CFA80, $8

SECTION "ROM Bank 051 @$0CFA88", ROMX[$7A88], BANK[51]
Song22_Pattern00:
    INCBIN "roms/magination.gbc", $CFA88, $184

SECTION "ROM Bank 051 @$0CFC0C", ROMX[$7C0C], BANK[51]
Song22_Pattern01:
    INCBIN "roms/magination.gbc", $CFC0C, $130

SECTION "ROM Bank 051 @$0CFD3C", ROMX[$7D3C], BANK[51]
Song22_Pattern02:
    INCBIN "roms/magination.gbc", $CFD3C, $114

SECTION "ROM Bank 051 @$0CFE50", ROMX[$7E50], BANK[51]
Song22_Pattern03:
    INCBIN "roms/magination.gbc", $CFE50, $1B0

SECTION "ROM Bank 052", ROMX[$4000], BANK[52]
; music_bank34.asm: not published here (it assembles data copied from the ROM)
Song08:
    INCBIN "roms/magination.gbc", $D0000, $84

SECTION "ROM Bank 052 @$0D0084", ROMX[$4084], BANK[52]
Song08_Table:
    INCBIN "roms/magination.gbc", $D0084, $6

SECTION "ROM Bank 052 @$0D008A", ROMX[$408A], BANK[52]
Song08_Tracks:
    INCBIN "roms/magination.gbc", $D008A, $8

SECTION "ROM Bank 052 @$0D0092", ROMX[$4092], BANK[52]
Song08_Track0:
    INCBIN "roms/magination.gbc", $D0092, $A

SECTION "ROM Bank 052 @$0D009C", ROMX[$409C], BANK[52]
Song08_Track1:
    INCBIN "roms/magination.gbc", $D009C, $A

SECTION "ROM Bank 052 @$0D00A6", ROMX[$40A6], BANK[52]
Song08_Track2:
    INCBIN "roms/magination.gbc", $D00A6, $A

SECTION "ROM Bank 052 @$0D00B0", ROMX[$40B0], BANK[52]
Song08_Track3:
    INCBIN "roms/magination.gbc", $D00B0, $A

SECTION "ROM Bank 052 @$0D00BA", ROMX[$40BA], BANK[52]
Song08_Patterns:
    INCBIN "roms/magination.gbc", $D00BA, $8

SECTION "ROM Bank 052 @$0D00C2", ROMX[$40C2], BANK[52]
Song08_Pattern00:
    INCBIN "roms/magination.gbc", $D00C2, $70C

SECTION "ROM Bank 052 @$0D07CE", ROMX[$47CE], BANK[52]
Song08_Pattern01:
    INCBIN "roms/magination.gbc", $D07CE, $7A9

SECTION "ROM Bank 052 @$0D0F77", ROMX[$4F77], BANK[52]
Song08_Pattern02:
    INCBIN "roms/magination.gbc", $D0F77, $43F

SECTION "ROM Bank 052 @$0D13B6", ROMX[$53B6], BANK[52]
Song08_Pattern03:
    INCBIN "roms/magination.gbc", $D13B6, $70D

SECTION "ROM Bank 052 @$0D1AC3", ROMX[$5AC3], BANK[52]
Song11:
    INCBIN "roms/magination.gbc", $D1AC3, $84

SECTION "ROM Bank 052 @$0D1B47", ROMX[$5B47], BANK[52]
Song11_Table:
    INCBIN "roms/magination.gbc", $D1B47, $6

SECTION "ROM Bank 052 @$0D1B4D", ROMX[$5B4D], BANK[52]
Song11_Tracks:
    INCBIN "roms/magination.gbc", $D1B4D, $8

SECTION "ROM Bank 052 @$0D1B55", ROMX[$5B55], BANK[52]
Song11_Track0:
    INCBIN "roms/magination.gbc", $D1B55, $A

SECTION "ROM Bank 052 @$0D1B5F", ROMX[$5B5F], BANK[52]
Song11_Track1:
    INCBIN "roms/magination.gbc", $D1B5F, $A

SECTION "ROM Bank 052 @$0D1B69", ROMX[$5B69], BANK[52]
Song11_Track2:
    INCBIN "roms/magination.gbc", $D1B69, $A

SECTION "ROM Bank 052 @$0D1B73", ROMX[$5B73], BANK[52]
Song11_Track3:
    INCBIN "roms/magination.gbc", $D1B73, $A

SECTION "ROM Bank 052 @$0D1B7D", ROMX[$5B7D], BANK[52]
Song11_Patterns:
    INCBIN "roms/magination.gbc", $D1B7D, $8

SECTION "ROM Bank 052 @$0D1B85", ROMX[$5B85], BANK[52]
Song11_Pattern00:
    INCBIN "roms/magination.gbc", $D1B85, $330

SECTION "ROM Bank 052 @$0D1EB5", ROMX[$5EB5], BANK[52]
Song11_Pattern01:
    INCBIN "roms/magination.gbc", $D1EB5, $424

SECTION "ROM Bank 052 @$0D22D9", ROMX[$62D9], BANK[52]
Song11_Pattern02:
    INCBIN "roms/magination.gbc", $D22D9, $1B2

SECTION "ROM Bank 052 @$0D248B", ROMX[$648B], BANK[52]
Song11_Pattern03:
    INCBIN "roms/magination.gbc", $D248B, $1084

SECTION "ROM Bank 052 @$0D350F", ROMX[$750F], BANK[52]
Song36:
    INCBIN "roms/magination.gbc", $D350F, $84

SECTION "ROM Bank 052 @$0D3593", ROMX[$7593], BANK[52]
Song36_Table:
    INCBIN "roms/magination.gbc", $D3593, $6

SECTION "ROM Bank 052 @$0D3599", ROMX[$7599], BANK[52]
Song36_Tracks:
    INCBIN "roms/magination.gbc", $D3599, $8

SECTION "ROM Bank 052 @$0D35A1", ROMX[$75A1], BANK[52]
Song36_Track0:
    INCBIN "roms/magination.gbc", $D35A1, $D

SECTION "ROM Bank 052 @$0D35AE", ROMX[$75AE], BANK[52]
Song36_Track1:
    INCBIN "roms/magination.gbc", $D35AE, $D

SECTION "ROM Bank 052 @$0D35BB", ROMX[$75BB], BANK[52]
Song36_Track2:
    INCBIN "roms/magination.gbc", $D35BB, $D

SECTION "ROM Bank 052 @$0D35C8", ROMX[$75C8], BANK[52]
Song36_Track3:
    INCBIN "roms/magination.gbc", $D35C8, $D

SECTION "ROM Bank 052 @$0D35D5", ROMX[$75D5], BANK[52]
Song36_Patterns:
    INCBIN "roms/magination.gbc", $D35D5, $10

SECTION "ROM Bank 052 @$0D35E5", ROMX[$75E5], BANK[52]
Song36_Pattern00:
    INCBIN "roms/magination.gbc", $D35E5, $15C

SECTION "ROM Bank 052 @$0D3741", ROMX[$7741], BANK[52]
Song36_Pattern01:
    INCBIN "roms/magination.gbc", $D3741, $38

SECTION "ROM Bank 052 @$0D3779", ROMX[$7779], BANK[52]
Song36_Pattern02:
    INCBIN "roms/magination.gbc", $D3779, $91

SECTION "ROM Bank 052 @$0D380A", ROMX[$780A], BANK[52]
Song36_Pattern03:
    INCBIN "roms/magination.gbc", $D380A, $9

SECTION "ROM Bank 052 @$0D3813", ROMX[$7813], BANK[52]
Song36_Pattern04:
    INCBIN "roms/magination.gbc", $D3813, $D7

SECTION "ROM Bank 052 @$0D38EA", ROMX[$78EA], BANK[52]
Song36_Pattern05:
    INCBIN "roms/magination.gbc", $D38EA, $103

SECTION "ROM Bank 052 @$0D39ED", ROMX[$79ED], BANK[52]
Song36_Pattern06:
    INCBIN "roms/magination.gbc", $D39ED, $4C4

SECTION "ROM Bank 052 @$0D3EB1", ROMX[$7EB1], BANK[52]
Song36_Pattern07:
    INCBIN "roms/magination.gbc", $D3EB1, $14F

SECTION "ROM Bank 053", ROMX[$4000], BANK[53]
; music_bank35.asm: not published here (it assembles data copied from the ROM)
Song31:
    INCBIN "roms/magination.gbc", $D4000, $84

SECTION "ROM Bank 053 @$0D4084", ROMX[$4084], BANK[53]
Song31_Table:
    INCBIN "roms/magination.gbc", $D4084, $6

SECTION "ROM Bank 053 @$0D408A", ROMX[$408A], BANK[53]
Song31_Tracks:
    INCBIN "roms/magination.gbc", $D408A, $8

SECTION "ROM Bank 053 @$0D4092", ROMX[$4092], BANK[53]
Song31_Track0:
    INCBIN "roms/magination.gbc", $D4092, $A

SECTION "ROM Bank 053 @$0D409C", ROMX[$409C], BANK[53]
Song31_Track1:
    INCBIN "roms/magination.gbc", $D409C, $A

SECTION "ROM Bank 053 @$0D40A6", ROMX[$40A6], BANK[53]
Song31_Track2:
    INCBIN "roms/magination.gbc", $D40A6, $A

SECTION "ROM Bank 053 @$0D40B0", ROMX[$40B0], BANK[53]
Song31_Track3:
    INCBIN "roms/magination.gbc", $D40B0, $A

SECTION "ROM Bank 053 @$0D40BA", ROMX[$40BA], BANK[53]
Song31_Patterns:
    INCBIN "roms/magination.gbc", $D40BA, $8

SECTION "ROM Bank 053 @$0D40C2", ROMX[$40C2], BANK[53]
Song31_Pattern00:
    INCBIN "roms/magination.gbc", $D40C2, $594

SECTION "ROM Bank 053 @$0D4656", ROMX[$4656], BANK[53]
Song31_Pattern01:
    INCBIN "roms/magination.gbc", $D4656, $527

SECTION "ROM Bank 053 @$0D4B7D", ROMX[$4B7D], BANK[53]
Song31_Pattern02:
    INCBIN "roms/magination.gbc", $D4B7D, $337

SECTION "ROM Bank 053 @$0D4EB4", ROMX[$4EB4], BANK[53]
Song31_Pattern03:
    INCBIN "roms/magination.gbc", $D4EB4, $9AC

SECTION "ROM Bank 053 @$0D5860", ROMX[$5860], BANK[53]
Song28:
    INCBIN "roms/magination.gbc", $D5860, $84

SECTION "ROM Bank 053 @$0D58E4", ROMX[$58E4], BANK[53]
Song28_Table:
    INCBIN "roms/magination.gbc", $D58E4, $6

SECTION "ROM Bank 053 @$0D58EA", ROMX[$58EA], BANK[53]
Song28_Tracks:
    INCBIN "roms/magination.gbc", $D58EA, $8

SECTION "ROM Bank 053 @$0D58F2", ROMX[$58F2], BANK[53]
Song28_Track0:
    INCBIN "roms/magination.gbc", $D58F2, $A

SECTION "ROM Bank 053 @$0D58FC", ROMX[$58FC], BANK[53]
Song28_Track1:
    INCBIN "roms/magination.gbc", $D58FC, $A

SECTION "ROM Bank 053 @$0D5906", ROMX[$5906], BANK[53]
Song28_Track2:
    INCBIN "roms/magination.gbc", $D5906, $A

SECTION "ROM Bank 053 @$0D5910", ROMX[$5910], BANK[53]
Song28_Track3:
    INCBIN "roms/magination.gbc", $D5910, $A

SECTION "ROM Bank 053 @$0D591A", ROMX[$591A], BANK[53]
Song28_Patterns:
    INCBIN "roms/magination.gbc", $D591A, $8

SECTION "ROM Bank 053 @$0D5922", ROMX[$5922], BANK[53]
Song28_Pattern00:
    INCBIN "roms/magination.gbc", $D5922, $50C

SECTION "ROM Bank 053 @$0D5E2E", ROMX[$5E2E], BANK[53]
Song28_Pattern01:
    INCBIN "roms/magination.gbc", $D5E2E, $1D3

SECTION "ROM Bank 053 @$0D6001", ROMX[$6001], BANK[53]
Song28_Pattern02:
    INCBIN "roms/magination.gbc", $D6001, $7B4

SECTION "ROM Bank 053 @$0D67B5", ROMX[$67B5], BANK[53]
Song28_Pattern03:
    INCBIN "roms/magination.gbc", $D67B5, $864

SECTION "ROM Bank 053 @$0D7019", ROMX[$7019], BANK[53]
Song34:
    INCBIN "roms/magination.gbc", $D7019, $84

SECTION "ROM Bank 053 @$0D709D", ROMX[$709D], BANK[53]
Song34_Table:
    INCBIN "roms/magination.gbc", $D709D, $6

SECTION "ROM Bank 053 @$0D70A3", ROMX[$70A3], BANK[53]
Song34_Tracks:
    INCBIN "roms/magination.gbc", $D70A3, $8

SECTION "ROM Bank 053 @$0D70AB", ROMX[$70AB], BANK[53]
Song34_Track0:
    INCBIN "roms/magination.gbc", $D70AB, $A

SECTION "ROM Bank 053 @$0D70B5", ROMX[$70B5], BANK[53]
Song34_Track1:
    INCBIN "roms/magination.gbc", $D70B5, $A

SECTION "ROM Bank 053 @$0D70BF", ROMX[$70BF], BANK[53]
Song34_Track2:
    INCBIN "roms/magination.gbc", $D70BF, $A

SECTION "ROM Bank 053 @$0D70C9", ROMX[$70C9], BANK[53]
Song34_Track3:
    INCBIN "roms/magination.gbc", $D70C9, $A

SECTION "ROM Bank 053 @$0D70D3", ROMX[$70D3], BANK[53]
Song34_Patterns:
    INCBIN "roms/magination.gbc", $D70D3, $8

SECTION "ROM Bank 053 @$0D70DB", ROMX[$70DB], BANK[53]
Song34_Pattern00:
    INCBIN "roms/magination.gbc", $D70DB, $328

SECTION "ROM Bank 053 @$0D7403", ROMX[$7403], BANK[53]
Song34_Pattern01:
    INCBIN "roms/magination.gbc", $D7403, $5FC

SECTION "ROM Bank 053 @$0D79FF", ROMX[$79FF], BANK[53]
Song34_Pattern02:
    INCBIN "roms/magination.gbc", $D79FF, $2F7

SECTION "ROM Bank 053 @$0D7CF6", ROMX[$7CF6], BANK[53]
Song34_Pattern03:
    INCBIN "roms/magination.gbc", $D7CF6, $30A

SECTION "ROM Bank 054", ROMX[$4000], BANK[54]
; music_bank36.asm: not published here (it assembles data copied from the ROM)
Song39:
    INCBIN "roms/magination.gbc", $D8000, $84

SECTION "ROM Bank 054 @$0D8084", ROMX[$4084], BANK[54]
Song39_Table:
    INCBIN "roms/magination.gbc", $D8084, $6

SECTION "ROM Bank 054 @$0D808A", ROMX[$408A], BANK[54]
Song39_Tracks:
    INCBIN "roms/magination.gbc", $D808A, $8

SECTION "ROM Bank 054 @$0D8092", ROMX[$4092], BANK[54]
Song39_Track0:
    INCBIN "roms/magination.gbc", $D8092, $D

SECTION "ROM Bank 054 @$0D809F", ROMX[$409F], BANK[54]
Song39_Track1:
    INCBIN "roms/magination.gbc", $D809F, $D

SECTION "ROM Bank 054 @$0D80AC", ROMX[$40AC], BANK[54]
Song39_Track2:
    INCBIN "roms/magination.gbc", $D80AC, $D

SECTION "ROM Bank 054 @$0D80B9", ROMX[$40B9], BANK[54]
Song39_Track3:
    INCBIN "roms/magination.gbc", $D80B9, $D

SECTION "ROM Bank 054 @$0D80C6", ROMX[$40C6], BANK[54]
Song39_Patterns:
    INCBIN "roms/magination.gbc", $D80C6, $10

SECTION "ROM Bank 054 @$0D80D6", ROMX[$40D6], BANK[54]
Song39_Pattern00:
    INCBIN "roms/magination.gbc", $D80D6, $517

SECTION "ROM Bank 054 @$0D85ED", ROMX[$45ED], BANK[54]
Song39_Pattern01:
    INCBIN "roms/magination.gbc", $D85ED, $A8

SECTION "ROM Bank 054 @$0D8695", ROMX[$4695], BANK[54]
Song39_Pattern02:
    INCBIN "roms/magination.gbc", $D8695, $5AC

SECTION "ROM Bank 054 @$0D8C41", ROMX[$4C41], BANK[54]
Song39_Pattern03:
    INCBIN "roms/magination.gbc", $D8C41, $1E8

SECTION "ROM Bank 054 @$0D8E29", ROMX[$4E29], BANK[54]
Song39_Pattern04:
    INCBIN "roms/magination.gbc", $D8E29, $1C0

SECTION "ROM Bank 054 @$0D8FE9", ROMX[$4FE9], BANK[54]
Song39_Pattern05:
    INCBIN "roms/magination.gbc", $D8FE9, $78

SECTION "ROM Bank 054 @$0D9061", ROMX[$5061], BANK[54]
Song39_Pattern06:
    INCBIN "roms/magination.gbc", $D9061, $643

SECTION "ROM Bank 054 @$0D96A4", ROMX[$56A4], BANK[54]
Song39_Pattern07:
    INCBIN "roms/magination.gbc", $D96A4, $6

SECTION "ROM Bank 054 @$0D96AA", ROMX[$56AA], BANK[54]
Song07:
    INCBIN "roms/magination.gbc", $D96AA, $84

SECTION "ROM Bank 054 @$0D972E", ROMX[$572E], BANK[54]
Song07_Table:
    INCBIN "roms/magination.gbc", $D972E, $6

SECTION "ROM Bank 054 @$0D9734", ROMX[$5734], BANK[54]
Song07_Tracks:
    INCBIN "roms/magination.gbc", $D9734, $8

SECTION "ROM Bank 054 @$0D973C", ROMX[$573C], BANK[54]
Song07_Track0:
    INCBIN "roms/magination.gbc", $D973C, $A

SECTION "ROM Bank 054 @$0D9746", ROMX[$5746], BANK[54]
Song07_Track1:
    INCBIN "roms/magination.gbc", $D9746, $A

SECTION "ROM Bank 054 @$0D9750", ROMX[$5750], BANK[54]
Song07_Track2:
    INCBIN "roms/magination.gbc", $D9750, $A

SECTION "ROM Bank 054 @$0D975A", ROMX[$575A], BANK[54]
Song07_Track3:
    INCBIN "roms/magination.gbc", $D975A, $A

SECTION "ROM Bank 054 @$0D9764", ROMX[$5764], BANK[54]
Song07_Patterns:
    INCBIN "roms/magination.gbc", $D9764, $8

SECTION "ROM Bank 054 @$0D976C", ROMX[$576C], BANK[54]
Song07_Pattern00:
    INCBIN "roms/magination.gbc", $D976C, $4F8

SECTION "ROM Bank 054 @$0D9C64", ROMX[$5C64], BANK[54]
Song07_Pattern01:
    INCBIN "roms/magination.gbc", $D9C64, $3C4

SECTION "ROM Bank 054 @$0DA028", ROMX[$6028], BANK[54]
Song07_Pattern02:
    INCBIN "roms/magination.gbc", $DA028, $494

SECTION "ROM Bank 054 @$0DA4BC", ROMX[$64BC], BANK[54]
Song07_Pattern03:
    INCBIN "roms/magination.gbc", $DA4BC, $828

SECTION "ROM Bank 054 @$0DACE4", ROMX[$6CE4], BANK[54]
Song40:
    INCBIN "roms/magination.gbc", $DACE4, $84

SECTION "ROM Bank 054 @$0DAD68", ROMX[$6D68], BANK[54]
Song40_Table:
    INCBIN "roms/magination.gbc", $DAD68, $6

SECTION "ROM Bank 054 @$0DAD6E", ROMX[$6D6E], BANK[54]
Song40_Tracks:
    INCBIN "roms/magination.gbc", $DAD6E, $8

SECTION "ROM Bank 054 @$0DAD76", ROMX[$6D76], BANK[54]
Song40_Track0:
    INCBIN "roms/magination.gbc", $DAD76, $A

SECTION "ROM Bank 054 @$0DAD80", ROMX[$6D80], BANK[54]
Song40_Track1:
    INCBIN "roms/magination.gbc", $DAD80, $A

SECTION "ROM Bank 054 @$0DAD8A", ROMX[$6D8A], BANK[54]
Song40_Track2:
    INCBIN "roms/magination.gbc", $DAD8A, $A

SECTION "ROM Bank 054 @$0DAD94", ROMX[$6D94], BANK[54]
Song40_Track3:
    INCBIN "roms/magination.gbc", $DAD94, $A

SECTION "ROM Bank 054 @$0DAD9E", ROMX[$6D9E], BANK[54]
Song40_Patterns:
    INCBIN "roms/magination.gbc", $DAD9E, $8

SECTION "ROM Bank 054 @$0DADA6", ROMX[$6DA6], BANK[54]
Song40_Pattern00:
    INCBIN "roms/magination.gbc", $DADA6, $2B8

SECTION "ROM Bank 054 @$0DB05E", ROMX[$705E], BANK[54]
Song40_Pattern01:
    INCBIN "roms/magination.gbc", $DB05E, $5D0

SECTION "ROM Bank 054 @$0DB62E", ROMX[$762E], BANK[54]
Song40_Pattern02:
    INCBIN "roms/magination.gbc", $DB62E, $33C

SECTION "ROM Bank 054 @$0DB96A", ROMX[$796A], BANK[54]
Song40_Pattern03:
    INCBIN "roms/magination.gbc", $DB96A, $598

SECTION "ROM Bank 054 @$0DBF02", ROMX[$7F02], BANK[54]
Song02:
    INCBIN "roms/magination.gbc", $DBF02, $84

SECTION "ROM Bank 054 @$0DBF86", ROMX[$7F86], BANK[54]
Song02_Table:
    INCBIN "roms/magination.gbc", $DBF86, $6

SECTION "ROM Bank 054 @$0DBF8C", ROMX[$7F8C], BANK[54]
Song02_Tracks:
    INCBIN "roms/magination.gbc", $DBF8C, $8

SECTION "ROM Bank 054 @$0DBF94", ROMX[$7F94], BANK[54]
Song02_Track0:
    INCBIN "roms/magination.gbc", $DBF94, $A

SECTION "ROM Bank 054 @$0DBF9E", ROMX[$7F9E], BANK[54]
Song02_Track1:
    INCBIN "roms/magination.gbc", $DBF9E, $A

SECTION "ROM Bank 054 @$0DBFA8", ROMX[$7FA8], BANK[54]
Song02_Track2:
    INCBIN "roms/magination.gbc", $DBFA8, $A

SECTION "ROM Bank 054 @$0DBFB2", ROMX[$7FB2], BANK[54]
Song02_Patterns:
    INCBIN "roms/magination.gbc", $DBFB2, $6

SECTION "ROM Bank 054 @$0DBFB8", ROMX[$7FB8], BANK[54]
Song02_Pattern00:
    INCBIN "roms/magination.gbc", $DBFB8, $18

SECTION "ROM Bank 054 @$0DBFD0", ROMX[$7FD0], BANK[54]
Song02_Pattern01:
    INCBIN "roms/magination.gbc", $DBFD0, $18

SECTION "ROM Bank 054 @$0DBFE8", ROMX[$7FE8], BANK[54]
Song02_Pattern02:
    INCBIN "roms/magination.gbc", $DBFE8, $18

SECTION "ROM Bank 055", ROMX[$4000], BANK[55]
    ds $4000, $00 ; zero padding to the end of bank $37

SECTION "ROM Bank 056", ROMX[$4000], BANK[56]
; music_bank38.asm: not published here (it assembles data copied from the ROM)
Song18:
    INCBIN "roms/magination.gbc", $E0000, $84

SECTION "ROM Bank 056 @$0E0084", ROMX[$4084], BANK[56]
Song18_Table:
    INCBIN "roms/magination.gbc", $E0084, $6

SECTION "ROM Bank 056 @$0E008A", ROMX[$408A], BANK[56]
Song18_Tracks:
    INCBIN "roms/magination.gbc", $E008A, $8

SECTION "ROM Bank 056 @$0E0092", ROMX[$4092], BANK[56]
Song18_Track0:
    INCBIN "roms/magination.gbc", $E0092, $A

SECTION "ROM Bank 056 @$0E009C", ROMX[$409C], BANK[56]
Song18_Track1:
    INCBIN "roms/magination.gbc", $E009C, $A

SECTION "ROM Bank 056 @$0E00A6", ROMX[$40A6], BANK[56]
Song18_Track2:
    INCBIN "roms/magination.gbc", $E00A6, $A

SECTION "ROM Bank 056 @$0E00B0", ROMX[$40B0], BANK[56]
Song18_Track3:
    INCBIN "roms/magination.gbc", $E00B0, $A

SECTION "ROM Bank 056 @$0E00BA", ROMX[$40BA], BANK[56]
Song18_Patterns:
    INCBIN "roms/magination.gbc", $E00BA, $8

SECTION "ROM Bank 056 @$0E00C2", ROMX[$40C2], BANK[56]
Song18_Pattern00:
    INCBIN "roms/magination.gbc", $E00C2, $480

SECTION "ROM Bank 056 @$0E0542", ROMX[$4542], BANK[56]
Song18_Pattern01:
    INCBIN "roms/magination.gbc", $E0542, $984

SECTION "ROM Bank 056 @$0E0EC6", ROMX[$4EC6], BANK[56]
Song18_Pattern02:
    INCBIN "roms/magination.gbc", $E0EC6, $25F

SECTION "ROM Bank 056 @$0E1125", ROMX[$5125], BANK[56]
Song18_Pattern03:
    INCBIN "roms/magination.gbc", $E1125, $498

SECTION "ROM Bank 056 @$0E15BD", ROMX[$55BD], BANK[56]
Song32:
    INCBIN "roms/magination.gbc", $E15BD, $84

SECTION "ROM Bank 056 @$0E1641", ROMX[$5641], BANK[56]
Song32_Table:
    INCBIN "roms/magination.gbc", $E1641, $6

SECTION "ROM Bank 056 @$0E1647", ROMX[$5647], BANK[56]
Song32_Tracks:
    INCBIN "roms/magination.gbc", $E1647, $8

SECTION "ROM Bank 056 @$0E164F", ROMX[$564F], BANK[56]
Song32_Track0:
    INCBIN "roms/magination.gbc", $E164F, $A

SECTION "ROM Bank 056 @$0E1659", ROMX[$5659], BANK[56]
Song32_Track1:
    INCBIN "roms/magination.gbc", $E1659, $A

SECTION "ROM Bank 056 @$0E1663", ROMX[$5663], BANK[56]
Song32_Track2:
    INCBIN "roms/magination.gbc", $E1663, $A

SECTION "ROM Bank 056 @$0E166D", ROMX[$566D], BANK[56]
Song32_Track3:
    INCBIN "roms/magination.gbc", $E166D, $A

SECTION "ROM Bank 056 @$0E1677", ROMX[$5677], BANK[56]
Song32_Patterns:
    INCBIN "roms/magination.gbc", $E1677, $8

SECTION "ROM Bank 056 @$0E167F", ROMX[$567F], BANK[56]
Song32_Pattern00:
    INCBIN "roms/magination.gbc", $E167F, $3C8

SECTION "ROM Bank 056 @$0E1A47", ROMX[$5A47], BANK[56]
Song32_Pattern01:
    INCBIN "roms/magination.gbc", $E1A47, $7A0

SECTION "ROM Bank 056 @$0E21E7", ROMX[$61E7], BANK[56]
Song32_Pattern02:
    INCBIN "roms/magination.gbc", $E21E7, $139

SECTION "ROM Bank 056 @$0E2320", ROMX[$6320], BANK[56]
Song32_Pattern03:
    INCBIN "roms/magination.gbc", $E2320, $79C

SECTION "ROM Bank 056 @$0E2ABC", ROMX[$6ABC], BANK[56]
Song33:
    INCBIN "roms/magination.gbc", $E2ABC, $84

SECTION "ROM Bank 056 @$0E2B40", ROMX[$6B40], BANK[56]
Song33_Table:
    INCBIN "roms/magination.gbc", $E2B40, $6

SECTION "ROM Bank 056 @$0E2B46", ROMX[$6B46], BANK[56]
Song33_Tracks:
    INCBIN "roms/magination.gbc", $E2B46, $8

SECTION "ROM Bank 056 @$0E2B4E", ROMX[$6B4E], BANK[56]
Song33_Track0:
    INCBIN "roms/magination.gbc", $E2B4E, $A

SECTION "ROM Bank 056 @$0E2B58", ROMX[$6B58], BANK[56]
Song33_Track1:
    INCBIN "roms/magination.gbc", $E2B58, $A

SECTION "ROM Bank 056 @$0E2B62", ROMX[$6B62], BANK[56]
Song33_Track2:
    INCBIN "roms/magination.gbc", $E2B62, $A

SECTION "ROM Bank 056 @$0E2B6C", ROMX[$6B6C], BANK[56]
Song33_Track3:
    INCBIN "roms/magination.gbc", $E2B6C, $A

SECTION "ROM Bank 056 @$0E2B76", ROMX[$6B76], BANK[56]
Song33_Patterns:
    INCBIN "roms/magination.gbc", $E2B76, $8

SECTION "ROM Bank 056 @$0E2B7E", ROMX[$6B7E], BANK[56]
Song33_Pattern00:
    INCBIN "roms/magination.gbc", $E2B7E, $2C4

SECTION "ROM Bank 056 @$0E2E42", ROMX[$6E42], BANK[56]
Song33_Pattern01:
    INCBIN "roms/magination.gbc", $E2E42, $6AC

SECTION "ROM Bank 056 @$0E34EE", ROMX[$74EE], BANK[56]
Song33_Pattern02:
    INCBIN "roms/magination.gbc", $E34EE, $594

SECTION "ROM Bank 056 @$0E3A82", ROMX[$7A82], BANK[56]
Song33_Pattern03:
    INCBIN "roms/magination.gbc", $E3A82, $57E

SECTION "ROM Bank 057", ROMX[$4000], BANK[57]
; music_bank39.asm: not published here (it assembles data copied from the ROM)
Song15:
    INCBIN "roms/magination.gbc", $E4000, $84

SECTION "ROM Bank 057 @$0E4084", ROMX[$4084], BANK[57]
Song15_Table:
    INCBIN "roms/magination.gbc", $E4084, $6

SECTION "ROM Bank 057 @$0E408A", ROMX[$408A], BANK[57]
Song15_Tracks:
    INCBIN "roms/magination.gbc", $E408A, $8

SECTION "ROM Bank 057 @$0E4092", ROMX[$4092], BANK[57]
Song15_Track0:
    INCBIN "roms/magination.gbc", $E4092, $A

SECTION "ROM Bank 057 @$0E409C", ROMX[$409C], BANK[57]
Song15_Track1:
    INCBIN "roms/magination.gbc", $E409C, $A

SECTION "ROM Bank 057 @$0E40A6", ROMX[$40A6], BANK[57]
Song15_Track2:
    INCBIN "roms/magination.gbc", $E40A6, $A

SECTION "ROM Bank 057 @$0E40B0", ROMX[$40B0], BANK[57]
Song15_Track3:
    INCBIN "roms/magination.gbc", $E40B0, $A

SECTION "ROM Bank 057 @$0E40BA", ROMX[$40BA], BANK[57]
Song15_Patterns:
    INCBIN "roms/magination.gbc", $E40BA, $8

SECTION "ROM Bank 057 @$0E40C2", ROMX[$40C2], BANK[57]
Song15_Pattern00:
    INCBIN "roms/magination.gbc", $E40C2, $5C8

SECTION "ROM Bank 057 @$0E468A", ROMX[$468A], BANK[57]
Song15_Pattern01:
    INCBIN "roms/magination.gbc", $E468A, $43C

SECTION "ROM Bank 057 @$0E4AC6", ROMX[$4AC6], BANK[57]
Song15_Pattern02:
    INCBIN "roms/magination.gbc", $E4AC6, $4EC

SECTION "ROM Bank 057 @$0E4FB2", ROMX[$4FB2], BANK[57]
Song15_Pattern03:
    INCBIN "roms/magination.gbc", $E4FB2, $488

SECTION "ROM Bank 057 @$0E543A", ROMX[$543A], BANK[57]
Song35:
    INCBIN "roms/magination.gbc", $E543A, $84

SECTION "ROM Bank 057 @$0E54BE", ROMX[$54BE], BANK[57]
Song35_Table:
    INCBIN "roms/magination.gbc", $E54BE, $6

SECTION "ROM Bank 057 @$0E54C4", ROMX[$54C4], BANK[57]
Song35_Tracks:
    INCBIN "roms/magination.gbc", $E54C4, $8

SECTION "ROM Bank 057 @$0E54CC", ROMX[$54CC], BANK[57]
Song35_Track0:
    INCBIN "roms/magination.gbc", $E54CC, $D

SECTION "ROM Bank 057 @$0E54D9", ROMX[$54D9], BANK[57]
Song35_Track1:
    INCBIN "roms/magination.gbc", $E54D9, $D

SECTION "ROM Bank 057 @$0E54E6", ROMX[$54E6], BANK[57]
Song35_Track2:
    INCBIN "roms/magination.gbc", $E54E6, $D

SECTION "ROM Bank 057 @$0E54F3", ROMX[$54F3], BANK[57]
Song35_Track3:
    INCBIN "roms/magination.gbc", $E54F3, $D

SECTION "ROM Bank 057 @$0E5500", ROMX[$5500], BANK[57]
Song35_Patterns:
    INCBIN "roms/magination.gbc", $E5500, $10

SECTION "ROM Bank 057 @$0E5510", ROMX[$5510], BANK[57]
Song35_Pattern00:
    INCBIN "roms/magination.gbc", $E5510, $303

SECTION "ROM Bank 057 @$0E5813", ROMX[$5813], BANK[57]
Song35_Pattern01:
    INCBIN "roms/magination.gbc", $E5813, $44

SECTION "ROM Bank 057 @$0E5857", ROMX[$5857], BANK[57]
Song35_Pattern02:
    INCBIN "roms/magination.gbc", $E5857, $137

SECTION "ROM Bank 057 @$0E598E", ROMX[$598E], BANK[57]
Song35_Pattern03:
    INCBIN "roms/magination.gbc", $E598E, $16

SECTION "ROM Bank 057 @$0E59A4", ROMX[$59A4], BANK[57]
Song35_Pattern04:
    INCBIN "roms/magination.gbc", $E59A4, $146

SECTION "ROM Bank 057 @$0E5AEA", ROMX[$5AEA], BANK[57]
Song35_Pattern05:
    INCBIN "roms/magination.gbc", $E5AEA, $6

SECTION "ROM Bank 057 @$0E5AF0", ROMX[$5AF0], BANK[57]
Song35_Pattern06:
    INCBIN "roms/magination.gbc", $E5AF0, $A03

SECTION "ROM Bank 057 @$0E64F3", ROMX[$64F3], BANK[57]
Song35_Pattern07:
    INCBIN "roms/magination.gbc", $E64F3, $104

SECTION "ROM Bank 057 @$0E65F7", ROMX[$65F7], BANK[57]
Song12:
    INCBIN "roms/magination.gbc", $E65F7, $84

SECTION "ROM Bank 057 @$0E667B", ROMX[$667B], BANK[57]
Song12_Table:
    INCBIN "roms/magination.gbc", $E667B, $6

SECTION "ROM Bank 057 @$0E6681", ROMX[$6681], BANK[57]
Song12_Tracks:
    INCBIN "roms/magination.gbc", $E6681, $8

SECTION "ROM Bank 057 @$0E6689", ROMX[$6689], BANK[57]
Song12_Track0:
    INCBIN "roms/magination.gbc", $E6689, $A

SECTION "ROM Bank 057 @$0E6693", ROMX[$6693], BANK[57]
Song12_Track1:
    INCBIN "roms/magination.gbc", $E6693, $A

SECTION "ROM Bank 057 @$0E669D", ROMX[$669D], BANK[57]
Song12_Track2:
    INCBIN "roms/magination.gbc", $E669D, $A

SECTION "ROM Bank 057 @$0E66A7", ROMX[$66A7], BANK[57]
Song12_Track3:
    INCBIN "roms/magination.gbc", $E66A7, $A

SECTION "ROM Bank 057 @$0E66B1", ROMX[$66B1], BANK[57]
Song12_Patterns:
    INCBIN "roms/magination.gbc", $E66B1, $8

SECTION "ROM Bank 057 @$0E66B9", ROMX[$66B9], BANK[57]
Song12_Pattern00:
    INCBIN "roms/magination.gbc", $E66B9, $60C

SECTION "ROM Bank 057 @$0E6CC5", ROMX[$6CC5], BANK[57]
Song12_Pattern01:
    INCBIN "roms/magination.gbc", $E6CC5, $25C

SECTION "ROM Bank 057 @$0E6F21", ROMX[$6F21], BANK[57]
Song12_Pattern02:
    INCBIN "roms/magination.gbc", $E6F21, $246

SECTION "ROM Bank 057 @$0E7167", ROMX[$7167], BANK[57]
Song12_Pattern03:
    INCBIN "roms/magination.gbc", $E7167, $524

SECTION "ROM Bank 057 @$0E768B", ROMX[$768B], BANK[57]
Song27:
    INCBIN "roms/magination.gbc", $E768B, $84

SECTION "ROM Bank 057 @$0E770F", ROMX[$770F], BANK[57]
Song27_Table:
    INCBIN "roms/magination.gbc", $E770F, $6

SECTION "ROM Bank 057 @$0E7715", ROMX[$7715], BANK[57]
Song27_Tracks:
    INCBIN "roms/magination.gbc", $E7715, $8

SECTION "ROM Bank 057 @$0E771D", ROMX[$771D], BANK[57]
Song27_Track0:
    INCBIN "roms/magination.gbc", $E771D, $A

SECTION "ROM Bank 057 @$0E7727", ROMX[$7727], BANK[57]
Song27_Track1:
    INCBIN "roms/magination.gbc", $E7727, $A

SECTION "ROM Bank 057 @$0E7731", ROMX[$7731], BANK[57]
Song27_Track2:
    INCBIN "roms/magination.gbc", $E7731, $A

SECTION "ROM Bank 057 @$0E773B", ROMX[$773B], BANK[57]
Song27_Track3:
    INCBIN "roms/magination.gbc", $E773B, $A

SECTION "ROM Bank 057 @$0E7745", ROMX[$7745], BANK[57]
Song27_Patterns:
    INCBIN "roms/magination.gbc", $E7745, $8

SECTION "ROM Bank 057 @$0E774D", ROMX[$774D], BANK[57]
Song27_Pattern00:
    INCBIN "roms/magination.gbc", $E774D, $204

SECTION "ROM Bank 057 @$0E7951", ROMX[$7951], BANK[57]
Song27_Pattern01:
    INCBIN "roms/magination.gbc", $E7951, $D0

SECTION "ROM Bank 057 @$0E7A21", ROMX[$7A21], BANK[57]
Song27_Pattern02:
    INCBIN "roms/magination.gbc", $E7A21, $13C

SECTION "ROM Bank 057 @$0E7B5D", ROMX[$7B5D], BANK[57]
Song27_Pattern03:
    INCBIN "roms/magination.gbc", $E7B5D, $384

SECTION "ROM Bank 057 @$0E7EE1", ROMX[$7EE1], BANK[57]
Song03:
    INCBIN "roms/magination.gbc", $E7EE1, $84

SECTION "ROM Bank 057 @$0E7F65", ROMX[$7F65], BANK[57]
Song03_Table:
    INCBIN "roms/magination.gbc", $E7F65, $6

SECTION "ROM Bank 057 @$0E7F6B", ROMX[$7F6B], BANK[57]
Song03_Tracks:
    INCBIN "roms/magination.gbc", $E7F6B, $8

SECTION "ROM Bank 057 @$0E7F73", ROMX[$7F73], BANK[57]
Song03_Track0:
    INCBIN "roms/magination.gbc", $E7F73, $A

SECTION "ROM Bank 057 @$0E7F7D", ROMX[$7F7D], BANK[57]
Song03_Track1:
    INCBIN "roms/magination.gbc", $E7F7D, $A

SECTION "ROM Bank 057 @$0E7F87", ROMX[$7F87], BANK[57]
Song03_Track2:
    INCBIN "roms/magination.gbc", $E7F87, $A

SECTION "ROM Bank 057 @$0E7F91", ROMX[$7F91], BANK[57]
Song03_Patterns:
    INCBIN "roms/magination.gbc", $E7F91, $6

SECTION "ROM Bank 057 @$0E7F97", ROMX[$7F97], BANK[57]
Song03_Pattern00:
    INCBIN "roms/magination.gbc", $E7F97, $6

SECTION "ROM Bank 057 @$0E7F9D", ROMX[$7F9D], BANK[57]
Song03_Pattern01:
    INCBIN "roms/magination.gbc", $E7F9D, $6

SECTION "ROM Bank 057 @$0E7FA3", ROMX[$7FA3], BANK[57]
Song03_Pattern02:
    INCBIN "roms/magination.gbc", $E7FA3, $5D

SECTION "ROM Bank 058", ROMX[$4000], BANK[58]
; music_bank3a.asm: not published here (it assembles data copied from the ROM)
Song14:
    INCBIN "roms/magination.gbc", $E8000, $84

SECTION "ROM Bank 058 @$0E8084", ROMX[$4084], BANK[58]
Song14_Table:
    INCBIN "roms/magination.gbc", $E8084, $6

SECTION "ROM Bank 058 @$0E808A", ROMX[$408A], BANK[58]
Song14_Tracks:
    INCBIN "roms/magination.gbc", $E808A, $8

SECTION "ROM Bank 058 @$0E8092", ROMX[$4092], BANK[58]
Song14_Track0:
    INCBIN "roms/magination.gbc", $E8092, $A

SECTION "ROM Bank 058 @$0E809C", ROMX[$409C], BANK[58]
Song14_Track1:
    INCBIN "roms/magination.gbc", $E809C, $A

SECTION "ROM Bank 058 @$0E80A6", ROMX[$40A6], BANK[58]
Song14_Track2:
    INCBIN "roms/magination.gbc", $E80A6, $A

SECTION "ROM Bank 058 @$0E80B0", ROMX[$40B0], BANK[58]
Song14_Track3:
    INCBIN "roms/magination.gbc", $E80B0, $A

SECTION "ROM Bank 058 @$0E80BA", ROMX[$40BA], BANK[58]
Song14_Patterns:
    INCBIN "roms/magination.gbc", $E80BA, $8

SECTION "ROM Bank 058 @$0E80C2", ROMX[$40C2], BANK[58]
Song14_Pattern00:
    INCBIN "roms/magination.gbc", $E80C2, $324

SECTION "ROM Bank 058 @$0E83E6", ROMX[$43E6], BANK[58]
Song14_Pattern01:
    INCBIN "roms/magination.gbc", $E83E6, $324

SECTION "ROM Bank 058 @$0E870A", ROMX[$470A], BANK[58]
Song14_Pattern02:
    INCBIN "roms/magination.gbc", $E870A, $1CA

SECTION "ROM Bank 058 @$0E88D4", ROMX[$48D4], BANK[58]
Song14_Pattern03:
    INCBIN "roms/magination.gbc", $E88D4, $778

SECTION "ROM Bank 058 @$0E904C", ROMX[$504C], BANK[58]
Song17:
    INCBIN "roms/magination.gbc", $E904C, $84

SECTION "ROM Bank 058 @$0E90D0", ROMX[$50D0], BANK[58]
Song17_Table:
    INCBIN "roms/magination.gbc", $E90D0, $6

SECTION "ROM Bank 058 @$0E90D6", ROMX[$50D6], BANK[58]
Song17_Tracks:
    INCBIN "roms/magination.gbc", $E90D6, $8

SECTION "ROM Bank 058 @$0E90DE", ROMX[$50DE], BANK[58]
Song17_Track0:
    INCBIN "roms/magination.gbc", $E90DE, $A

SECTION "ROM Bank 058 @$0E90E8", ROMX[$50E8], BANK[58]
Song17_Track1:
    INCBIN "roms/magination.gbc", $E90E8, $A

SECTION "ROM Bank 058 @$0E90F2", ROMX[$50F2], BANK[58]
Song17_Track2:
    INCBIN "roms/magination.gbc", $E90F2, $A

SECTION "ROM Bank 058 @$0E90FC", ROMX[$50FC], BANK[58]
Song17_Track3:
    INCBIN "roms/magination.gbc", $E90FC, $A

SECTION "ROM Bank 058 @$0E9106", ROMX[$5106], BANK[58]
Song17_Patterns:
    INCBIN "roms/magination.gbc", $E9106, $8

SECTION "ROM Bank 058 @$0E910E", ROMX[$510E], BANK[58]
Song17_Pattern00:
    INCBIN "roms/magination.gbc", $E910E, $584

SECTION "ROM Bank 058 @$0E9692", ROMX[$5692], BANK[58]
Song17_Pattern01:
    INCBIN "roms/magination.gbc", $E9692, $350

SECTION "ROM Bank 058 @$0E99E2", ROMX[$59E2], BANK[58]
Song17_Pattern02:
    INCBIN "roms/magination.gbc", $E99E2, $33C

SECTION "ROM Bank 058 @$0E9D1E", ROMX[$5D1E], BANK[58]
Song17_Pattern03:
    INCBIN "roms/magination.gbc", $E9D1E, $29C

SECTION "ROM Bank 058 @$0E9FBA", ROMX[$5FBA], BANK[58]
Song23:
    INCBIN "roms/magination.gbc", $E9FBA, $84

SECTION "ROM Bank 058 @$0EA03E", ROMX[$603E], BANK[58]
Song23_Table:
    INCBIN "roms/magination.gbc", $EA03E, $6

SECTION "ROM Bank 058 @$0EA044", ROMX[$6044], BANK[58]
Song23_Tracks:
    INCBIN "roms/magination.gbc", $EA044, $8

SECTION "ROM Bank 058 @$0EA04C", ROMX[$604C], BANK[58]
Song23_Track0:
    INCBIN "roms/magination.gbc", $EA04C, $A

SECTION "ROM Bank 058 @$0EA056", ROMX[$6056], BANK[58]
Song23_Track1:
    INCBIN "roms/magination.gbc", $EA056, $A

SECTION "ROM Bank 058 @$0EA060", ROMX[$6060], BANK[58]
Song23_Track2:
    INCBIN "roms/magination.gbc", $EA060, $A

SECTION "ROM Bank 058 @$0EA06A", ROMX[$606A], BANK[58]
Song23_Track3:
    INCBIN "roms/magination.gbc", $EA06A, $A

SECTION "ROM Bank 058 @$0EA074", ROMX[$6074], BANK[58]
Song23_Patterns:
    INCBIN "roms/magination.gbc", $EA074, $8

SECTION "ROM Bank 058 @$0EA07C", ROMX[$607C], BANK[58]
Song23_Pattern00:
    INCBIN "roms/magination.gbc", $EA07C, $604

SECTION "ROM Bank 058 @$0EA680", ROMX[$6680], BANK[58]
Song23_Pattern01:
    INCBIN "roms/magination.gbc", $EA680, $204

SECTION "ROM Bank 058 @$0EA884", ROMX[$6884], BANK[58]
Song23_Pattern02:
    INCBIN "roms/magination.gbc", $EA884, $254

SECTION "ROM Bank 058 @$0EAAD8", ROMX[$6AD8], BANK[58]
Song23_Pattern03:
    INCBIN "roms/magination.gbc", $EAAD8, $404

SECTION "ROM Bank 058 @$0EAEDC", ROMX[$6EDC], BANK[58]
Song24:
    INCBIN "roms/magination.gbc", $EAEDC, $84

SECTION "ROM Bank 058 @$0EAF60", ROMX[$6F60], BANK[58]
Song24_Table:
    INCBIN "roms/magination.gbc", $EAF60, $6

SECTION "ROM Bank 058 @$0EAF66", ROMX[$6F66], BANK[58]
Song24_Tracks:
    INCBIN "roms/magination.gbc", $EAF66, $8

SECTION "ROM Bank 058 @$0EAF6E", ROMX[$6F6E], BANK[58]
Song24_Track0:
    INCBIN "roms/magination.gbc", $EAF6E, $A

SECTION "ROM Bank 058 @$0EAF78", ROMX[$6F78], BANK[58]
Song24_Track1:
    INCBIN "roms/magination.gbc", $EAF78, $A

SECTION "ROM Bank 058 @$0EAF82", ROMX[$6F82], BANK[58]
Song24_Track2:
    INCBIN "roms/magination.gbc", $EAF82, $A

SECTION "ROM Bank 058 @$0EAF8C", ROMX[$6F8C], BANK[58]
Song24_Track3:
    INCBIN "roms/magination.gbc", $EAF8C, $A

SECTION "ROM Bank 058 @$0EAF96", ROMX[$6F96], BANK[58]
Song24_Patterns:
    INCBIN "roms/magination.gbc", $EAF96, $8

SECTION "ROM Bank 058 @$0EAF9E", ROMX[$6F9E], BANK[58]
Song24_Pattern00:
    INCBIN "roms/magination.gbc", $EAF9E, $39C

SECTION "ROM Bank 058 @$0EB33A", ROMX[$733A], BANK[58]
Song24_Pattern01:
    INCBIN "roms/magination.gbc", $EB33A, $568

SECTION "ROM Bank 058 @$0EB8A2", ROMX[$78A2], BANK[58]
Song24_Pattern02:
    INCBIN "roms/magination.gbc", $EB8A2, $227

SECTION "ROM Bank 058 @$0EBAC9", ROMX[$7AC9], BANK[58]
Song24_Pattern03:
    INCBIN "roms/magination.gbc", $EBAC9, $2A4

SECTION "ROM Bank 058 @$0EBD6D", ROMX[$7D6D], BANK[58]
Song01:
    INCBIN "roms/magination.gbc", $EBD6D, $84

SECTION "ROM Bank 058 @$0EBDF1", ROMX[$7DF1], BANK[58]
Song01_Table:
    INCBIN "roms/magination.gbc", $EBDF1, $6

SECTION "ROM Bank 058 @$0EBDF7", ROMX[$7DF7], BANK[58]
Song01_Tracks:
    INCBIN "roms/magination.gbc", $EBDF7, $8

SECTION "ROM Bank 058 @$0EBDFF", ROMX[$7DFF], BANK[58]
Song01_Track0:
    INCBIN "roms/magination.gbc", $EBDFF, $A

SECTION "ROM Bank 058 @$0EBE09", ROMX[$7E09], BANK[58]
Song01_Track1:
    INCBIN "roms/magination.gbc", $EBE09, $A

SECTION "ROM Bank 058 @$0EBE13", ROMX[$7E13], BANK[58]
Song01_Patterns:
    INCBIN "roms/magination.gbc", $EBE13, $4

SECTION "ROM Bank 058 @$0EBE17", ROMX[$7E17], BANK[58]
Song01_Pattern00:
    INCBIN "roms/magination.gbc", $EBE17, $44

SECTION "ROM Bank 058 @$0EBE5B", ROMX[$7E5B], BANK[58]
Song01_Pattern01:
    INCBIN "roms/magination.gbc", $EBE5B, $44

SECTION "Zero padding from $0EBE9F", ROMX[$7E9F], BANK[58]
    ds $161, $00 ; zero padding to the end of bank $3A

SECTION "ROM Bank 059", ROMX[$4000], BANK[59]
; music_bank3b.asm: not published here (it assembles data copied from the ROM)
Song20:
    INCBIN "roms/magination.gbc", $EC000, $84

SECTION "ROM Bank 059 @$0EC084", ROMX[$4084], BANK[59]
Song20_Table:
    INCBIN "roms/magination.gbc", $EC084, $6

SECTION "ROM Bank 059 @$0EC08A", ROMX[$408A], BANK[59]
Song20_Tracks:
    INCBIN "roms/magination.gbc", $EC08A, $8

SECTION "ROM Bank 059 @$0EC092", ROMX[$4092], BANK[59]
Song20_Track0:
    INCBIN "roms/magination.gbc", $EC092, $A

SECTION "ROM Bank 059 @$0EC09C", ROMX[$409C], BANK[59]
Song20_Track1:
    INCBIN "roms/magination.gbc", $EC09C, $A

SECTION "ROM Bank 059 @$0EC0A6", ROMX[$40A6], BANK[59]
Song20_Track2:
    INCBIN "roms/magination.gbc", $EC0A6, $A

SECTION "ROM Bank 059 @$0EC0B0", ROMX[$40B0], BANK[59]
Song20_Track3:
    INCBIN "roms/magination.gbc", $EC0B0, $A

SECTION "ROM Bank 059 @$0EC0BA", ROMX[$40BA], BANK[59]
Song20_Patterns:
    INCBIN "roms/magination.gbc", $EC0BA, $8

SECTION "ROM Bank 059 @$0EC0C2", ROMX[$40C2], BANK[59]
Song20_Pattern00:
    INCBIN "roms/magination.gbc", $EC0C2, $3A0

SECTION "ROM Bank 059 @$0EC462", ROMX[$4462], BANK[59]
Song20_Pattern01:
    INCBIN "roms/magination.gbc", $EC462, $384

SECTION "ROM Bank 059 @$0EC7E6", ROMX[$47E6], BANK[59]
Song20_Pattern02:
    INCBIN "roms/magination.gbc", $EC7E6, $1BC

SECTION "ROM Bank 059 @$0EC9A2", ROMX[$49A2], BANK[59]
Song20_Pattern03:
    INCBIN "roms/magination.gbc", $EC9A2, $414

SECTION "ROM Bank 059 @$0ECDB6", ROMX[$4DB6], BANK[59]
Song19:
    INCBIN "roms/magination.gbc", $ECDB6, $84

SECTION "ROM Bank 059 @$0ECE3A", ROMX[$4E3A], BANK[59]
Song19_Table:
    INCBIN "roms/magination.gbc", $ECE3A, $6

SECTION "ROM Bank 059 @$0ECE40", ROMX[$4E40], BANK[59]
Song19_Tracks:
    INCBIN "roms/magination.gbc", $ECE40, $8

SECTION "ROM Bank 059 @$0ECE48", ROMX[$4E48], BANK[59]
Song19_Track0:
    INCBIN "roms/magination.gbc", $ECE48, $A

SECTION "ROM Bank 059 @$0ECE52", ROMX[$4E52], BANK[59]
Song19_Track1:
    INCBIN "roms/magination.gbc", $ECE52, $A

SECTION "ROM Bank 059 @$0ECE5C", ROMX[$4E5C], BANK[59]
Song19_Track2:
    INCBIN "roms/magination.gbc", $ECE5C, $A

SECTION "ROM Bank 059 @$0ECE66", ROMX[$4E66], BANK[59]
Song19_Track3:
    INCBIN "roms/magination.gbc", $ECE66, $A

SECTION "ROM Bank 059 @$0ECE70", ROMX[$4E70], BANK[59]
Song19_Patterns:
    INCBIN "roms/magination.gbc", $ECE70, $8

SECTION "ROM Bank 059 @$0ECE78", ROMX[$4E78], BANK[59]
Song19_Pattern00:
    INCBIN "roms/magination.gbc", $ECE78, $3E8

SECTION "ROM Bank 059 @$0ED260", ROMX[$5260], BANK[59]
Song19_Pattern01:
    INCBIN "roms/magination.gbc", $ED260, $30E

SECTION "ROM Bank 059 @$0ED56E", ROMX[$556E], BANK[59]
Song19_Pattern02:
    INCBIN "roms/magination.gbc", $ED56E, $263

SECTION "ROM Bank 059 @$0ED7D1", ROMX[$57D1], BANK[59]
Song19_Pattern03:
    INCBIN "roms/magination.gbc", $ED7D1, $370

SECTION "ROM Bank 059 @$0EDB41", ROMX[$5B41], BANK[59]
Song09:
    INCBIN "roms/magination.gbc", $EDB41, $84

SECTION "ROM Bank 059 @$0EDBC5", ROMX[$5BC5], BANK[59]
Song09_Table:
    INCBIN "roms/magination.gbc", $EDBC5, $6

SECTION "ROM Bank 059 @$0EDBCB", ROMX[$5BCB], BANK[59]
Song09_Tracks:
    INCBIN "roms/magination.gbc", $EDBCB, $8

SECTION "ROM Bank 059 @$0EDBD3", ROMX[$5BD3], BANK[59]
Song09_Track0:
    INCBIN "roms/magination.gbc", $EDBD3, $A

SECTION "ROM Bank 059 @$0EDBDD", ROMX[$5BDD], BANK[59]
Song09_Track1:
    INCBIN "roms/magination.gbc", $EDBDD, $A

SECTION "ROM Bank 059 @$0EDBE7", ROMX[$5BE7], BANK[59]
Song09_Track2:
    INCBIN "roms/magination.gbc", $EDBE7, $A

SECTION "ROM Bank 059 @$0EDBF1", ROMX[$5BF1], BANK[59]
Song09_Track3:
    INCBIN "roms/magination.gbc", $EDBF1, $A

SECTION "ROM Bank 059 @$0EDBFB", ROMX[$5BFB], BANK[59]
Song09_Patterns:
    INCBIN "roms/magination.gbc", $EDBFB, $8

SECTION "ROM Bank 059 @$0EDC03", ROMX[$5C03], BANK[59]
Song09_Pattern00:
    INCBIN "roms/magination.gbc", $EDC03, $2F0

SECTION "ROM Bank 059 @$0EDEF3", ROMX[$5EF3], BANK[59]
Song09_Pattern01:
    INCBIN "roms/magination.gbc", $EDEF3, $254

SECTION "ROM Bank 059 @$0EE147", ROMX[$6147], BANK[59]
Song09_Pattern02:
    INCBIN "roms/magination.gbc", $EE147, $3AC

SECTION "ROM Bank 059 @$0EE4F3", ROMX[$64F3], BANK[59]
Song09_Pattern03:
    INCBIN "roms/magination.gbc", $EE4F3, $35C

SECTION "ROM Bank 059 @$0EE84F", ROMX[$684F], BANK[59]
Song16:
    INCBIN "roms/magination.gbc", $EE84F, $84

SECTION "ROM Bank 059 @$0EE8D3", ROMX[$68D3], BANK[59]
Song16_Table:
    INCBIN "roms/magination.gbc", $EE8D3, $6

SECTION "ROM Bank 059 @$0EE8D9", ROMX[$68D9], BANK[59]
Song16_Tracks:
    INCBIN "roms/magination.gbc", $EE8D9, $8

SECTION "ROM Bank 059 @$0EE8E1", ROMX[$68E1], BANK[59]
Song16_Track0:
    INCBIN "roms/magination.gbc", $EE8E1, $D

SECTION "ROM Bank 059 @$0EE8EE", ROMX[$68EE], BANK[59]
Song16_Track1:
    INCBIN "roms/magination.gbc", $EE8EE, $D

SECTION "ROM Bank 059 @$0EE8FB", ROMX[$68FB], BANK[59]
Song16_Track2:
    INCBIN "roms/magination.gbc", $EE8FB, $D

SECTION "ROM Bank 059 @$0EE908", ROMX[$6908], BANK[59]
Song16_Track3:
    INCBIN "roms/magination.gbc", $EE908, $D

SECTION "ROM Bank 059 @$0EE915", ROMX[$6915], BANK[59]
Song16_Patterns:
    INCBIN "roms/magination.gbc", $EE915, $10

SECTION "ROM Bank 059 @$0EE925", ROMX[$6925], BANK[59]
Song16_Pattern00:
    INCBIN "roms/magination.gbc", $EE925, $36F

SECTION "ROM Bank 059 @$0EEC94", ROMX[$6C94], BANK[59]
Song16_Pattern01:
    INCBIN "roms/magination.gbc", $EEC94, $40

SECTION "ROM Bank 059 @$0EECD4", ROMX[$6CD4], BANK[59]
Song16_Pattern02:
    INCBIN "roms/magination.gbc", $EECD4, $1C7

SECTION "ROM Bank 059 @$0EEE9B", ROMX[$6E9B], BANK[59]
Song16_Pattern03:
    INCBIN "roms/magination.gbc", $EEE9B, $6

SECTION "ROM Bank 059 @$0EEEA1", ROMX[$6EA1], BANK[59]
Song16_Pattern04:
    INCBIN "roms/magination.gbc", $EEEA1, $22B

SECTION "ROM Bank 059 @$0EF0CC", ROMX[$70CC], BANK[59]
Song16_Pattern05:
    INCBIN "roms/magination.gbc", $EF0CC, $6

SECTION "ROM Bank 059 @$0EF0D2", ROMX[$70D2], BANK[59]
Song16_Pattern06:
    INCBIN "roms/magination.gbc", $EF0D2, $477

SECTION "ROM Bank 059 @$0EF549", ROMX[$7549], BANK[59]
Song16_Pattern07:
    INCBIN "roms/magination.gbc", $EF549, $8

SECTION "ROM Bank 059 @$0EF551", ROMX[$7551], BANK[59]
Song21:
    INCBIN "roms/magination.gbc", $EF551, $84

SECTION "ROM Bank 059 @$0EF5D5", ROMX[$75D5], BANK[59]
Song21_Table:
    INCBIN "roms/magination.gbc", $EF5D5, $6

SECTION "ROM Bank 059 @$0EF5DB", ROMX[$75DB], BANK[59]
Song21_Tracks:
    INCBIN "roms/magination.gbc", $EF5DB, $8

SECTION "ROM Bank 059 @$0EF5E3", ROMX[$75E3], BANK[59]
Song21_Track0:
    INCBIN "roms/magination.gbc", $EF5E3, $A

SECTION "ROM Bank 059 @$0EF5ED", ROMX[$75ED], BANK[59]
Song21_Track1:
    INCBIN "roms/magination.gbc", $EF5ED, $A

SECTION "ROM Bank 059 @$0EF5F7", ROMX[$75F7], BANK[59]
Song21_Track2:
    INCBIN "roms/magination.gbc", $EF5F7, $A

SECTION "ROM Bank 059 @$0EF601", ROMX[$7601], BANK[59]
Song21_Track3:
    INCBIN "roms/magination.gbc", $EF601, $A

SECTION "ROM Bank 059 @$0EF60B", ROMX[$760B], BANK[59]
Song21_Patterns:
    INCBIN "roms/magination.gbc", $EF60B, $8

SECTION "ROM Bank 059 @$0EF613", ROMX[$7613], BANK[59]
Song21_Pattern00:
    INCBIN "roms/magination.gbc", $EF613, $368

SECTION "ROM Bank 059 @$0EF97B", ROMX[$797B], BANK[59]
Song21_Pattern01:
    INCBIN "roms/magination.gbc", $EF97B, $1F4

SECTION "ROM Bank 059 @$0EFB6F", ROMX[$7B6F], BANK[59]
Song21_Pattern02:
    INCBIN "roms/magination.gbc", $EFB6F, $224

SECTION "ROM Bank 059 @$0EFD93", ROMX[$7D93], BANK[59]
Song21_Pattern03:
    INCBIN "roms/magination.gbc", $EFD93, $26D

SECTION "ROM Bank 060", ROMX[$4000], BANK[60]
; music_bank3c.asm: not published here (it assembles data copied from the ROM)
Song10:
    INCBIN "roms/magination.gbc", $F0000, $84

SECTION "ROM Bank 060 @$0F0084", ROMX[$4084], BANK[60]
Song10_Table:
    INCBIN "roms/magination.gbc", $F0084, $6

SECTION "ROM Bank 060 @$0F008A", ROMX[$408A], BANK[60]
Song10_Tracks:
    INCBIN "roms/magination.gbc", $F008A, $8

SECTION "ROM Bank 060 @$0F0092", ROMX[$4092], BANK[60]
Song10_Track0:
    INCBIN "roms/magination.gbc", $F0092, $A

SECTION "ROM Bank 060 @$0F009C", ROMX[$409C], BANK[60]
Song10_Track1:
    INCBIN "roms/magination.gbc", $F009C, $A

SECTION "ROM Bank 060 @$0F00A6", ROMX[$40A6], BANK[60]
Song10_Track2:
    INCBIN "roms/magination.gbc", $F00A6, $A

SECTION "ROM Bank 060 @$0F00B0", ROMX[$40B0], BANK[60]
Song10_Track3:
    INCBIN "roms/magination.gbc", $F00B0, $A

SECTION "ROM Bank 060 @$0F00BA", ROMX[$40BA], BANK[60]
Song10_Patterns:
    INCBIN "roms/magination.gbc", $F00BA, $8

SECTION "ROM Bank 060 @$0F00C2", ROMX[$40C2], BANK[60]
Song10_Pattern00:
    INCBIN "roms/magination.gbc", $F00C2, $2A0

SECTION "ROM Bank 060 @$0F0362", ROMX[$4362], BANK[60]
Song10_Pattern01:
    INCBIN "roms/magination.gbc", $F0362, $234

SECTION "ROM Bank 060 @$0F0596", ROMX[$4596], BANK[60]
Song10_Pattern02:
    INCBIN "roms/magination.gbc", $F0596, $194

SECTION "ROM Bank 060 @$0F072A", ROMX[$472A], BANK[60]
Song10_Pattern03:
    INCBIN "roms/magination.gbc", $F072A, $528

SECTION "ROM Bank 060 @$0F0C52", ROMX[$4C52], BANK[60]
Song26:
    INCBIN "roms/magination.gbc", $F0C52, $84

SECTION "ROM Bank 060 @$0F0CD6", ROMX[$4CD6], BANK[60]
Song26_Table:
    INCBIN "roms/magination.gbc", $F0CD6, $6

SECTION "ROM Bank 060 @$0F0CDC", ROMX[$4CDC], BANK[60]
Song26_Tracks:
    INCBIN "roms/magination.gbc", $F0CDC, $8

SECTION "ROM Bank 060 @$0F0CE4", ROMX[$4CE4], BANK[60]
Song26_Track0:
    INCBIN "roms/magination.gbc", $F0CE4, $A

SECTION "ROM Bank 060 @$0F0CEE", ROMX[$4CEE], BANK[60]
Song26_Track1:
    INCBIN "roms/magination.gbc", $F0CEE, $A

SECTION "ROM Bank 060 @$0F0CF8", ROMX[$4CF8], BANK[60]
Song26_Track2:
    INCBIN "roms/magination.gbc", $F0CF8, $A

SECTION "ROM Bank 060 @$0F0D02", ROMX[$4D02], BANK[60]
Song26_Patterns:
    INCBIN "roms/magination.gbc", $F0D02, $6

SECTION "ROM Bank 060 @$0F0D08", ROMX[$4D08], BANK[60]
Song26_Pattern00:
    INCBIN "roms/magination.gbc", $F0D08, $390

SECTION "ROM Bank 060 @$0F1098", ROMX[$5098], BANK[60]
Song26_Pattern01:
    INCBIN "roms/magination.gbc", $F1098, $1CF

SECTION "ROM Bank 060 @$0F1267", ROMX[$5267], BANK[60]
Song26_Pattern02:
    INCBIN "roms/magination.gbc", $F1267, $239

SECTION "ROM Bank 060 @$0F14A0", ROMX[$54A0], BANK[60]
Song29:
    INCBIN "roms/magination.gbc", $F14A0, $84

SECTION "ROM Bank 060 @$0F1524", ROMX[$5524], BANK[60]
Song29_Table:
    INCBIN "roms/magination.gbc", $F1524, $6

SECTION "ROM Bank 060 @$0F152A", ROMX[$552A], BANK[60]
Song29_Tracks:
    INCBIN "roms/magination.gbc", $F152A, $8

SECTION "ROM Bank 060 @$0F1532", ROMX[$5532], BANK[60]
Song29_Track0:
    INCBIN "roms/magination.gbc", $F1532, $D

SECTION "ROM Bank 060 @$0F153F", ROMX[$553F], BANK[60]
Song29_Track1:
    INCBIN "roms/magination.gbc", $F153F, $D

SECTION "ROM Bank 060 @$0F154C", ROMX[$554C], BANK[60]
Song29_Track2:
    INCBIN "roms/magination.gbc", $F154C, $D

SECTION "ROM Bank 060 @$0F1559", ROMX[$5559], BANK[60]
Song29_Track3:
    INCBIN "roms/magination.gbc", $F1559, $D

SECTION "ROM Bank 060 @$0F1566", ROMX[$5566], BANK[60]
Song29_Patterns:
    INCBIN "roms/magination.gbc", $F1566, $10

SECTION "ROM Bank 060 @$0F1576", ROMX[$5576], BANK[60]
Song29_Pattern00:
    INCBIN "roms/magination.gbc", $F1576, $1CB

SECTION "ROM Bank 060 @$0F1741", ROMX[$5741], BANK[60]
Song29_Pattern01:
    INCBIN "roms/magination.gbc", $F1741, $1C

SECTION "ROM Bank 060 @$0F175D", ROMX[$575D], BANK[60]
Song29_Pattern02:
    INCBIN "roms/magination.gbc", $F175D, $133

SECTION "ROM Bank 060 @$0F1890", ROMX[$5890], BANK[60]
Song29_Pattern03:
    INCBIN "roms/magination.gbc", $F1890, $14

SECTION "ROM Bank 060 @$0F18A4", ROMX[$58A4], BANK[60]
Song29_Pattern04:
    INCBIN "roms/magination.gbc", $F18A4, $16C

SECTION "ROM Bank 060 @$0F1A10", ROMX[$5A10], BANK[60]
Song29_Pattern05:
    INCBIN "roms/magination.gbc", $F1A10, $6

SECTION "ROM Bank 060 @$0F1A16", ROMX[$5A16], BANK[60]
Song29_Pattern06:
    INCBIN "roms/magination.gbc", $F1A16, $1AF

SECTION "ROM Bank 060 @$0F1BC5", ROMX[$5BC5], BANK[60]
Song29_Pattern07:
    INCBIN "roms/magination.gbc", $F1BC5, $18

SECTION "ROM Bank 060 @$0F1BDD", ROMX[$5BDD], BANK[60]
Song30:
    INCBIN "roms/magination.gbc", $F1BDD, $84

SECTION "ROM Bank 060 @$0F1C61", ROMX[$5C61], BANK[60]
Song30_Table:
    INCBIN "roms/magination.gbc", $F1C61, $6

SECTION "ROM Bank 060 @$0F1C67", ROMX[$5C67], BANK[60]
Song30_Tracks:
    INCBIN "roms/magination.gbc", $F1C67, $8

SECTION "ROM Bank 060 @$0F1C6F", ROMX[$5C6F], BANK[60]
Song30_Track0:
    INCBIN "roms/magination.gbc", $F1C6F, $A

SECTION "ROM Bank 060 @$0F1C79", ROMX[$5C79], BANK[60]
Song30_Track1:
    INCBIN "roms/magination.gbc", $F1C79, $A

SECTION "ROM Bank 060 @$0F1C83", ROMX[$5C83], BANK[60]
Song30_Track2:
    INCBIN "roms/magination.gbc", $F1C83, $A

SECTION "ROM Bank 060 @$0F1C8D", ROMX[$5C8D], BANK[60]
Song30_Track3:
    INCBIN "roms/magination.gbc", $F1C8D, $A

SECTION "ROM Bank 060 @$0F1C97", ROMX[$5C97], BANK[60]
Song30_Patterns:
    INCBIN "roms/magination.gbc", $F1C97, $8

SECTION "ROM Bank 060 @$0F1C9F", ROMX[$5C9F], BANK[60]
Song30_Pattern00:
    INCBIN "roms/magination.gbc", $F1C9F, $100

SECTION "ROM Bank 060 @$0F1D9F", ROMX[$5D9F], BANK[60]
Song30_Pattern01:
    INCBIN "roms/magination.gbc", $F1D9F, $164

SECTION "ROM Bank 060 @$0F1F03", ROMX[$5F03], BANK[60]
Song30_Pattern02:
    INCBIN "roms/magination.gbc", $F1F03, $25C

SECTION "ROM Bank 060 @$0F215F", ROMX[$615F], BANK[60]
Song30_Pattern03:
    INCBIN "roms/magination.gbc", $F215F, $174

SECTION "ROM Bank 060 @$0F22D3", ROMX[$62D3], BANK[60]
Song13:
    INCBIN "roms/magination.gbc", $F22D3, $84

SECTION "ROM Bank 060 @$0F2357", ROMX[$6357], BANK[60]
Song13_Table:
    INCBIN "roms/magination.gbc", $F2357, $6

SECTION "ROM Bank 060 @$0F235D", ROMX[$635D], BANK[60]
Song13_Tracks:
    INCBIN "roms/magination.gbc", $F235D, $8

SECTION "ROM Bank 060 @$0F2365", ROMX[$6365], BANK[60]
Song13_Track0:
    INCBIN "roms/magination.gbc", $F2365, $A

SECTION "ROM Bank 060 @$0F236F", ROMX[$636F], BANK[60]
Song13_Track1:
    INCBIN "roms/magination.gbc", $F236F, $A

SECTION "ROM Bank 060 @$0F2379", ROMX[$6379], BANK[60]
Song13_Track2:
    INCBIN "roms/magination.gbc", $F2379, $A

SECTION "ROM Bank 060 @$0F2383", ROMX[$6383], BANK[60]
Song13_Track3:
    INCBIN "roms/magination.gbc", $F2383, $A

SECTION "ROM Bank 060 @$0F238D", ROMX[$638D], BANK[60]
Song13_Patterns:
    INCBIN "roms/magination.gbc", $F238D, $8

SECTION "ROM Bank 060 @$0F2395", ROMX[$6395], BANK[60]
Song13_Pattern00:
    INCBIN "roms/magination.gbc", $F2395, $44

SECTION "ROM Bank 060 @$0F23D9", ROMX[$63D9], BANK[60]
Song13_Pattern01:
    INCBIN "roms/magination.gbc", $F23D9, $84

SECTION "ROM Bank 060 @$0F245D", ROMX[$645D], BANK[60]
Song13_Pattern02:
    INCBIN "roms/magination.gbc", $F245D, $DC

SECTION "ROM Bank 060 @$0F2539", ROMX[$6539], BANK[60]
Song13_Pattern03:
    INCBIN "roms/magination.gbc", $F2539, $2CB

SECTION "ROM Bank 060 @$0F2804", ROMX[$6804], BANK[60]
Song38:
    INCBIN "roms/magination.gbc", $F2804, $84

SECTION "ROM Bank 060 @$0F2888", ROMX[$6888], BANK[60]
Song38_Table:
    INCBIN "roms/magination.gbc", $F2888, $6

SECTION "ROM Bank 060 @$0F288E", ROMX[$688E], BANK[60]
Song38_Tracks:
    INCBIN "roms/magination.gbc", $F288E, $8

SECTION "ROM Bank 060 @$0F2896", ROMX[$6896], BANK[60]
Song38_Track0:
    INCBIN "roms/magination.gbc", $F2896, $D

SECTION "ROM Bank 060 @$0F28A3", ROMX[$68A3], BANK[60]
Song38_Track1:
    INCBIN "roms/magination.gbc", $F28A3, $D

SECTION "ROM Bank 060 @$0F28B0", ROMX[$68B0], BANK[60]
Song38_Track2:
    INCBIN "roms/magination.gbc", $F28B0, $D

SECTION "ROM Bank 060 @$0F28BD", ROMX[$68BD], BANK[60]
Song38_Patterns:
    INCBIN "roms/magination.gbc", $F28BD, $C

SECTION "ROM Bank 060 @$0F28C9", ROMX[$68C9], BANK[60]
Song38_Pattern00:
    INCBIN "roms/magination.gbc", $F28C9, $91

SECTION "ROM Bank 060 @$0F295A", ROMX[$695A], BANK[60]
Song38_Pattern01:
    INCBIN "roms/magination.gbc", $F295A, $4A

SECTION "ROM Bank 060 @$0F29A4", ROMX[$69A4], BANK[60]
Song38_Pattern02:
    INCBIN "roms/magination.gbc", $F29A4, $9D

SECTION "ROM Bank 060 @$0F2A41", ROMX[$6A41], BANK[60]
Song38_Pattern03:
    INCBIN "roms/magination.gbc", $F2A41, $1B

SECTION "ROM Bank 060 @$0F2A5C", ROMX[$6A5C], BANK[60]
Song38_Pattern04:
    INCBIN "roms/magination.gbc", $F2A5C, $1A3

SECTION "ROM Bank 060 @$0F2BFF", ROMX[$6BFF], BANK[60]
Song38_Pattern05:
    INCBIN "roms/magination.gbc", $F2BFF, $104

SECTION "ROM Bank 060 @$0F2D03", ROMX[$6D03], BANK[60]
Song37:
    INCBIN "roms/magination.gbc", $F2D03, $84

SECTION "ROM Bank 060 @$0F2D87", ROMX[$6D87], BANK[60]
Song37_Table:
    INCBIN "roms/magination.gbc", $F2D87, $6

SECTION "ROM Bank 060 @$0F2D8D", ROMX[$6D8D], BANK[60]
Song37_Tracks:
    INCBIN "roms/magination.gbc", $F2D8D, $8

SECTION "ROM Bank 060 @$0F2D95", ROMX[$6D95], BANK[60]
Song37_Track0:
    INCBIN "roms/magination.gbc", $F2D95, $A

SECTION "ROM Bank 060 @$0F2D9F", ROMX[$6D9F], BANK[60]
Song37_Track1:
    INCBIN "roms/magination.gbc", $F2D9F, $A

SECTION "ROM Bank 060 @$0F2DA9", ROMX[$6DA9], BANK[60]
Song37_Track2:
    INCBIN "roms/magination.gbc", $F2DA9, $A

SECTION "ROM Bank 060 @$0F2DB3", ROMX[$6DB3], BANK[60]
Song37_Track3:
    INCBIN "roms/magination.gbc", $F2DB3, $A

SECTION "ROM Bank 060 @$0F2DBD", ROMX[$6DBD], BANK[60]
Song37_Patterns:
    INCBIN "roms/magination.gbc", $F2DBD, $8

SECTION "ROM Bank 060 @$0F2DC5", ROMX[$6DC5], BANK[60]
Song37_Pattern00:
    INCBIN "roms/magination.gbc", $F2DC5, $54

SECTION "ROM Bank 060 @$0F2E19", ROMX[$6E19], BANK[60]
Song37_Pattern01:
    INCBIN "roms/magination.gbc", $F2E19, $44

SECTION "ROM Bank 060 @$0F2E5D", ROMX[$6E5D], BANK[60]
Song37_Pattern02:
    INCBIN "roms/magination.gbc", $F2E5D, $70

SECTION "ROM Bank 060 @$0F2ECD", ROMX[$6ECD], BANK[60]
Song37_Pattern03:
    INCBIN "roms/magination.gbc", $F2ECD, $104

SECTION "ROM Bank 060 @$0F2FD1", ROMX[$6FD1], BANK[60]
Song00:
    INCBIN "roms/magination.gbc", $F2FD1, $84

SECTION "ROM Bank 060 @$0F3055", ROMX[$7055], BANK[60]
Song00_Table:
    INCBIN "roms/magination.gbc", $F3055, $6

SECTION "ROM Bank 060 @$0F305B", ROMX[$705B], BANK[60]
Song00_Tracks:
    INCBIN "roms/magination.gbc", $F305B, $8

SECTION "ROM Bank 060 @$0F3063", ROMX[$7063], BANK[60]
Song00_Track0:
    INCBIN "roms/magination.gbc", $F3063, $A

SECTION "ROM Bank 060 @$0F306D", ROMX[$706D], BANK[60]
Song00_Track1:
    INCBIN "roms/magination.gbc", $F306D, $A

SECTION "ROM Bank 060 @$0F3077", ROMX[$7077], BANK[60]
Song00_Track2:
    INCBIN "roms/magination.gbc", $F3077, $A

SECTION "ROM Bank 060 @$0F3081", ROMX[$7081], BANK[60]
Song00_Patterns:
    INCBIN "roms/magination.gbc", $F3081, $6

SECTION "ROM Bank 060 @$0F3087", ROMX[$7087], BANK[60]
Song00_Pattern00:
    INCBIN "roms/magination.gbc", $F3087, $51

SECTION "ROM Bank 060 @$0F30D8", ROMX[$70D8], BANK[60]
Song00_Pattern01:
    INCBIN "roms/magination.gbc", $F30D8, $59

SECTION "ROM Bank 060 @$0F3131", ROMX[$7131], BANK[60]
Song00_Pattern02:
    INCBIN "roms/magination.gbc", $F3131, $158

SECTION "Zero padding from $0F3289", ROMX[$7289], BANK[60]
    ds $D77, $00 ; zero padding to the end of bank $3C

SECTION "ROM Bank 061", ROMX[$4000], BANK[61]
    ds $4000, $00 ; zero padding to the end of bank $3D

SECTION "ROM Bank 062", ROMX[$4000], BANK[62]
    ds $4000, $00 ; zero padding to the end of bank $3E

SECTION "ROM Bank 063", ROMX[$4000], BANK[63]
    ds $4000, $00 ; zero padding to the end of bank $3F

SECTION "bank64_tiles", ROMX[$4000], BANK[64]
; gfx/bank64_tiles.asm: not published here (it assembles data copied from the ROM)
Bank64Tiles:
    INCBIN "roms/magination.gbc", $100000, $2C0

SECTION "Palettes bank $40", ROMX[$42C0], BANK[64]
; palettes_bank40.asm: not published here (it assembles data copied from the ROM)
Bank64TilesEnd:
Palettes40_42C0:
    INCBIN "roms/magination.gbc", $1002C0, $40

SECTION "Palettes bank $40 @$100300", ROMX[$4300], BANK[64]
Palettes40_4300:
    INCBIN "roms/magination.gbc", $100300, $40

SECTION "Palettes bank $40 @$100340", ROMX[$4340], BANK[64]
Palettes40_4340:
    INCBIN "roms/magination.gbc", $100340, $40

SECTION "Palettes bank $40 @$100380", ROMX[$4380], BANK[64]
Palettes40_4380:
    INCBIN "roms/magination.gbc", $100380, $40

SECTION "Palettes bank $40 @$1003C0", ROMX[$43C0], BANK[64]
Palettes40_43C0:
    INCBIN "roms/magination.gbc", $1003C0, $40

SECTION "ROM from $100400", ROMX[$4400], BANK[64]
    INCBIN "roms/magination.gbc", $100400, $3C00

SECTION "bank65_gfx", ROMX[$4000], BANK[65]
; gfx/bank65_gfx.asm: not published here (it assembles data copied from the ROM)
Bank65Gfx:
    INCBIN "roms/magination.gbc", $104000, $2900

SECTION "Sprite lists bank $41", ROMX[$6900], BANK[65]
; sprite_lists_bank41.asm: not published here (it assembles data copied from the ROM)
Bank65GfxEnd:
SpriteList41_00:
    INCBIN "roms/magination.gbc", $106900, $11

SECTION "Sprite lists bank $41 @$106911", ROMX[$6911], BANK[65]
SpriteList41_01:
    INCBIN "roms/magination.gbc", $106911, $D

SECTION "Sprite lists bank $41 @$10691E", ROMX[$691E], BANK[65]
SpriteList41_02:
    INCBIN "roms/magination.gbc", $10691E, $11

SECTION "Sprite lists bank $41 @$10692F", ROMX[$692F], BANK[65]
SpriteList41_03:
    INCBIN "roms/magination.gbc", $10692F, $11

SECTION "Sprite lists bank $41 @$106940", ROMX[$6940], BANK[65]
SpriteList41_04:
    INCBIN "roms/magination.gbc", $106940, $11

SECTION "Sprite lists bank $41 @$106951", ROMX[$6951], BANK[65]
SpriteList41_05:
    INCBIN "roms/magination.gbc", $106951, $19

SECTION "Sprite lists bank $41 @$10696A", ROMX[$696A], BANK[65]
SpriteList41_06:
    INCBIN "roms/magination.gbc", $10696A, $19

SECTION "Sprite lists bank $41 @$106983", ROMX[$6983], BANK[65]
SpriteList41_07:
    INCBIN "roms/magination.gbc", $106983, $19

SECTION "Sprite lists bank $41 @$10699C", ROMX[$699C], BANK[65]
SpriteList41_08:
    INCBIN "roms/magination.gbc", $10699C, $D

SECTION "Sprite lists bank $41 @$1069A9", ROMX[$69A9], BANK[65]
SpriteList41_09:
    INCBIN "roms/magination.gbc", $1069A9, $11

SECTION "Sprite lists bank $41 @$1069BA", ROMX[$69BA], BANK[65]
SpriteList41_10:
    INCBIN "roms/magination.gbc", $1069BA, $21

SECTION "Sprite lists bank $41 @$1069DB", ROMX[$69DB], BANK[65]
SpriteList41_11:
    INCBIN "roms/magination.gbc", $1069DB, $21

SECTION "Sprite lists bank $41 @$1069FC", ROMX[$69FC], BANK[65]
SpriteList41_12:
    INCBIN "roms/magination.gbc", $1069FC, $21

SECTION "Sprite lists bank $41 @$106A1D", ROMX[$6A1D], BANK[65]
SpriteList41_13:
    INCBIN "roms/magination.gbc", $106A1D, $21

SECTION "Sprite lists bank $41 @$106A3E", ROMX[$6A3E], BANK[65]
SpriteList41_14:
    INCBIN "roms/magination.gbc", $106A3E, $21

SECTION "Sprite lists bank $41 @$106A5F", ROMX[$6A5F], BANK[65]
SpriteList41_15:
    INCBIN "roms/magination.gbc", $106A5F, $21

SECTION "Sprite lists bank $41 @$106A80", ROMX[$6A80], BANK[65]
SpriteList41_16:
    INCBIN "roms/magination.gbc", $106A80, $21

SECTION "Sprite lists bank $41 @$106AA1", ROMX[$6AA1], BANK[65]
SpriteList41_17:
    INCBIN "roms/magination.gbc", $106AA1, $21

SECTION "Sprite lists bank $41 @$106AC2", ROMX[$6AC2], BANK[65]
SpriteList41_18:
    INCBIN "roms/magination.gbc", $106AC2, $21

SECTION "Sprite lists bank $41 @$106AE3", ROMX[$6AE3], BANK[65]
SpriteList41_19:
    INCBIN "roms/magination.gbc", $106AE3, $21

SECTION "Sprite lists bank $41 @$106B04", ROMX[$6B04], BANK[65]
SpriteList41_20:
    INCBIN "roms/magination.gbc", $106B04, $21

SECTION "Sprite lists bank $41 @$106B25", ROMX[$6B25], BANK[65]
SpriteList41_21:
    INCBIN "roms/magination.gbc", $106B25, $21

SECTION "Sprite lists bank $41 @$106B46", ROMX[$6B46], BANK[65]
SpriteList41_22:
    INCBIN "roms/magination.gbc", $106B46, $25

SECTION "Sprite lists bank $41 @$106B6B", ROMX[$6B6B], BANK[65]
SpriteList41_23:
    INCBIN "roms/magination.gbc", $106B6B, $21

SECTION "Sprite lists bank $41 @$106B8C", ROMX[$6B8C], BANK[65]
SpriteList41_24:
    INCBIN "roms/magination.gbc", $106B8C, $21

SECTION "Sprite lists bank $41 @$106BAD", ROMX[$6BAD], BANK[65]
SpriteList41_25:
    INCBIN "roms/magination.gbc", $106BAD, $21

SECTION "Sprite lists bank $41 @$106BCE", ROMX[$6BCE], BANK[65]
SpriteList41_26:
    INCBIN "roms/magination.gbc", $106BCE, $11

SECTION "Sprite lists bank $41 @$106BDF", ROMX[$6BDF], BANK[65]
SpriteList41_27:
    INCBIN "roms/magination.gbc", $106BDF, $9

SECTION "Sprite lists bank $41 @$106BE8", ROMX[$6BE8], BANK[65]
SpriteList41_28:
    INCBIN "roms/magination.gbc", $106BE8, $11

SECTION "Sprite lists bank $41 @$106BF9", ROMX[$6BF9], BANK[65]
SpriteList41_29:
    INCBIN "roms/magination.gbc", $106BF9, $11

SECTION "Sprite lists bank $41 @$106C0A", ROMX[$6C0A], BANK[65]
SpriteList41_30:
    INCBIN "roms/magination.gbc", $106C0A, $5

SECTION "Sprite lists bank $41 @$106C0F", ROMX[$6C0F], BANK[65]
SpriteList41_31:
    INCBIN "roms/magination.gbc", $106C0F, $5

SECTION "Sprite lists bank $41 @$106C14", ROMX[$6C14], BANK[65]
SpriteList41_32:
    INCBIN "roms/magination.gbc", $106C14, $15

SECTION "Sprite lists bank $41 @$106C29", ROMX[$6C29], BANK[65]
SpriteList41_33:
    INCBIN "roms/magination.gbc", $106C29, $5

SECTION "Sprite lists bank $41 @$106C2E", ROMX[$6C2E], BANK[65]
SpriteList41_34:
    INCBIN "roms/magination.gbc", $106C2E, $9

SECTION "Sprite lists bank $41 @$106C37", ROMX[$6C37], BANK[65]
SpriteList41_35:
    INCBIN "roms/magination.gbc", $106C37, $9

SECTION "Sprite lists bank $41 @$106C40", ROMX[$6C40], BANK[65]
SpriteList41_36:
    INCBIN "roms/magination.gbc", $106C40, $11

SECTION "Sprite lists bank $41 @$106C51", ROMX[$6C51], BANK[65]
SpriteList41_37:
    INCBIN "roms/magination.gbc", $106C51, $19

SECTION "Sprite lists bank $41 @$106C6A", ROMX[$6C6A], BANK[65]
SpriteList41_38:
    INCBIN "roms/magination.gbc", $106C6A, $11

SECTION "Sprite lists bank $41 @$106C7B", ROMX[$6C7B], BANK[65]
SpriteList41_39:
    INCBIN "roms/magination.gbc", $106C7B, $11

SECTION "Sprite lists bank $41 @$106C8C", ROMX[$6C8C], BANK[65]
SpriteList41_40:
    INCBIN "roms/magination.gbc", $106C8C, $11

SECTION "Sprite lists bank $41 @$106C9D", ROMX[$6C9D], BANK[65]
SpriteList41_41:
    INCBIN "roms/magination.gbc", $106C9D, $11

SECTION "Sprite lists bank $41 @$106CAE", ROMX[$6CAE], BANK[65]
SpriteList41_42:
    INCBIN "roms/magination.gbc", $106CAE, $11

SECTION "Sprite lists bank $41 @$106CBF", ROMX[$6CBF], BANK[65]
SpriteList41_43:
    INCBIN "roms/magination.gbc", $106CBF, $11

SECTION "Sprite lists bank $41 @$106CD0", ROMX[$6CD0], BANK[65]
SpriteList41_44:
    INCBIN "roms/magination.gbc", $106CD0, $11

SECTION "Sprite lists bank $41 @$106CE1", ROMX[$6CE1], BANK[65]
SpriteList41_45:
    INCBIN "roms/magination.gbc", $106CE1, $11

SECTION "Sprite lists bank $41 @$106CF2", ROMX[$6CF2], BANK[65]
SpriteList41_46:
    INCBIN "roms/magination.gbc", $106CF2, $11

SECTION "Sprite lists bank $41 @$106D03", ROMX[$6D03], BANK[65]
SpriteList41_47:
    INCBIN "roms/magination.gbc", $106D03, $11

SECTION "Sprite lists bank $41 @$106D14", ROMX[$6D14], BANK[65]
SpriteList41_48:
    INCBIN "roms/magination.gbc", $106D14, $11

SECTION "Sprite lists bank $41 @$106D25", ROMX[$6D25], BANK[65]
SpriteList41_49:
    INCBIN "roms/magination.gbc", $106D25, $D

SECTION "Sprite lists bank $41 @$106D32", ROMX[$6D32], BANK[65]
SpriteList41_50:
    INCBIN "roms/magination.gbc", $106D32, $11

SECTION "Sprite lists bank $41 @$106D43", ROMX[$6D43], BANK[65]
SpriteList41_51:
    INCBIN "roms/magination.gbc", $106D43, $15

SECTION "Sprite lists bank $41 @$106D58", ROMX[$6D58], BANK[65]
SpriteList41_52:
    INCBIN "roms/magination.gbc", $106D58, $11

SECTION "Sprite lists bank $41 @$106D69", ROMX[$6D69], BANK[65]
SpriteList41_53:
    INCBIN "roms/magination.gbc", $106D69, $11

SECTION "Sprite lists bank $41 @$106D7A", ROMX[$6D7A], BANK[65]
SpriteList41_54:
    INCBIN "roms/magination.gbc", $106D7A, $11

SECTION "Sprite lists bank $41 @$106D8B", ROMX[$6D8B], BANK[65]
SpriteList41_55:
    INCBIN "roms/magination.gbc", $106D8B, $11

SECTION "Sprite lists bank $41 @$106D9C", ROMX[$6D9C], BANK[65]
SpriteList41_56:
    INCBIN "roms/magination.gbc", $106D9C, $11

SECTION "Sprite lists bank $41 @$106DAD", ROMX[$6DAD], BANK[65]
SpriteList41_57:
    INCBIN "roms/magination.gbc", $106DAD, $5

SECTION "Sprite lists bank $41 @$106DB2", ROMX[$6DB2], BANK[65]
SpriteList41_58:
    INCBIN "roms/magination.gbc", $106DB2, $5

SECTION "Sprite lists bank $41 @$106DB7", ROMX[$6DB7], BANK[65]
SpriteList41_59:
    INCBIN "roms/magination.gbc", $106DB7, $9

SECTION "Sprite lists bank $41 @$106DC0", ROMX[$6DC0], BANK[65]
SpriteList41_60:
    INCBIN "roms/magination.gbc", $106DC0, $9

SECTION "Sprite lists bank $41 @$106DC9", ROMX[$6DC9], BANK[65]
SpriteList41_61:
    INCBIN "roms/magination.gbc", $106DC9, $D

SECTION "Sprite lists bank $41 @$106DD6", ROMX[$6DD6], BANK[65]
SpriteList41_62:
    INCBIN "roms/magination.gbc", $106DD6, $D

SECTION "Sprite lists bank $41 @$106DE3", ROMX[$6DE3], BANK[65]
SpriteList41_63:
    INCBIN "roms/magination.gbc", $106DE3, $D

SECTION "Sprite lists bank $41 @$106DF0", ROMX[$6DF0], BANK[65]
SpriteList41_64:
    INCBIN "roms/magination.gbc", $106DF0, $D

SECTION "Sprite lists bank $41 @$106DFD", ROMX[$6DFD], BANK[65]
SpriteList41_65:
    INCBIN "roms/magination.gbc", $106DFD, $D

SECTION "Sprite lists bank $41 @$106E0A", ROMX[$6E0A], BANK[65]
SpriteList41_66:
    INCBIN "roms/magination.gbc", $106E0A, $D

SECTION "Sprite lists bank $41 @$106E17", ROMX[$6E17], BANK[65]
SpriteList41_67:
    INCBIN "roms/magination.gbc", $106E17, $D

SECTION "Sprite lists bank $41 @$106E24", ROMX[$6E24], BANK[65]
SpriteList41_68:
    INCBIN "roms/magination.gbc", $106E24, $D

SECTION "Sprite lists bank $41 @$106E31", ROMX[$6E31], BANK[65]
SpriteList41_69:
    INCBIN "roms/magination.gbc", $106E31, $D

SECTION "Sprite lists bank $41 @$106E3E", ROMX[$6E3E], BANK[65]
SpriteList41_70:
    INCBIN "roms/magination.gbc", $106E3E, $D

SECTION "Sprite lists bank $41 @$106E4B", ROMX[$6E4B], BANK[65]
SpriteList41_71:
    INCBIN "roms/magination.gbc", $106E4B, $D

SECTION "Sprite lists bank $41 @$106E58", ROMX[$6E58], BANK[65]
SpriteList41_72:
    INCBIN "roms/magination.gbc", $106E58, $D

SECTION "Sprite lists bank $41 @$106E65", ROMX[$6E65], BANK[65]
SpriteList41_73:
    INCBIN "roms/magination.gbc", $106E65, $19

SECTION "Sprite lists bank $41 @$106E7E", ROMX[$6E7E], BANK[65]
SpriteList41_74:
    INCBIN "roms/magination.gbc", $106E7E, $11

SECTION "Sprite lists bank $41 @$106E8F", ROMX[$6E8F], BANK[65]
SpriteList41_75:
    INCBIN "roms/magination.gbc", $106E8F, $11

SECTION "Sprite lists bank $41 @$106EA0", ROMX[$6EA0], BANK[65]
SpriteList41_76:
    INCBIN "roms/magination.gbc", $106EA0, $11

SECTION "Sprite lists bank $41 @$106EB1", ROMX[$6EB1], BANK[65]
SpriteList41_77:
    INCBIN "roms/magination.gbc", $106EB1, $11

SECTION "Sprite animation scripts bank $41", ROMX[$6EC2], BANK[65]
    INCBIN "roms/magination.gbc", $106EC2, $20D

SECTION "Zero padding from $1070CF", ROMX[$70CF], BANK[65]
    ds $F31, $00 ; zero padding to the end of bank $41

SECTION "ROM Bank 066", ROMX[$4000], BANK[66]
    INCBIN "roms/magination.gbc", $108000, $0FEF

SECTION "Zero padding from $108FEF", ROMX[$4FEF], BANK[66]
    ds $3011, $00 ; zero padding to the end of bank $42

SECTION "ROM Bank 067", ROMX[$4000], BANK[67]
    INCBIN "roms/magination.gbc", $10C000, $21FC

SECTION "Zero padding from $10E1FC", ROMX[$61FC], BANK[67]
    ds $1E04, $00 ; zero padding to the end of bank $43

SECTION "bank68_gfx", ROMX[$4000], BANK[68]
; gfx/bank68_gfx.asm: not published here (it assembles data copied from the ROM)
Bank68Gfx:
    INCBIN "roms/magination.gbc", $110000, $3FC0

SECTION "bank68_gfx @$113FC0", ROMX[$7FC0], BANK[68]
Bank68GfxEnd:
    INCBIN "roms/magination.gbc", $113FC0, $40

SECTION "bank69_gfx", ROMX[$4000], BANK[69]
; gfx/bank69_gfx.asm: not published here (it assembles data copied from the ROM)
Bank69Gfx:
    INCBIN "roms/magination.gbc", $114000, $3FC0

SECTION "bank69_gfx @$117FC0", ROMX[$7FC0], BANK[69]
Bank69GfxEnd:
    INCBIN "roms/magination.gbc", $117FC0, $40

SECTION "ROM Bank 070", ROMX[$4000], BANK[70]
    INCBIN "roms/magination.gbc", $118000, $266C

SECTION "Zero padding from $11A66C", ROMX[$666C], BANK[70]
    ds $1994, $00 ; zero padding to the end of bank $46

SECTION "ROM Bank 071", ROMX[$4000], BANK[71]
    ds $4000, $00 ; zero padding to the end of bank $47

SECTION "ROM Bank 072", ROMX[$4000], BANK[72]
; gfx/bank72_rle.asm: not published here (it assembles data copied from the ROM)
Bank72Rle_4000:
    INCBIN "roms/magination.gbc", $120000, $AE

SECTION "ROM Bank 072 @$1200AE", ROMX[$40AE], BANK[72]
Bank72Rle_40AE:
    INCBIN "roms/magination.gbc", $1200AE, $93

SECTION "ROM Bank 072 @$120141", ROMX[$4141], BANK[72]
Bank72Rle_4141:
    INCBIN "roms/magination.gbc", $120141, $88

SECTION "ROM Bank 072 @$1201C9", ROMX[$41C9], BANK[72]
Bank72Rle_41C9:
    INCBIN "roms/magination.gbc", $1201C9, $93

SECTION "ROM Bank 072 @$12025C", ROMX[$425C], BANK[72]
Bank72Rle_425C:
    INCBIN "roms/magination.gbc", $12025C, $5B4

SECTION "ROM Bank 072 @$120810", ROMX[$4810], BANK[72]
Bank72Rle_4810:
    INCBIN "roms/magination.gbc", $120810, $54E

SECTION "ROM Bank 072 @$120D5E", ROMX[$4D5E], BANK[72]
Bank72Rle_4D5E:
    INCBIN "roms/magination.gbc", $120D5E, $70C

SECTION "ROM Bank 072 @$12146A", ROMX[$546A], BANK[72]
Bank72Rle_546A:
    INCBIN "roms/magination.gbc", $12146A, $409

SECTION "ROM Bank 072 @$121873", ROMX[$5873], BANK[72]
Bank72Rle_5873:
    INCBIN "roms/magination.gbc", $121873, $454

SECTION "ROM Bank 072 @$121CC7", ROMX[$5CC7], BANK[72]
Bank72Rle_5CC7:
    INCBIN "roms/magination.gbc", $121CC7, $427

SECTION "ROM Bank 072 @$1220EE", ROMX[$60EE], BANK[72]
Bank72Rle_60EE:
    INCBIN "roms/magination.gbc", $1220EE, $4FA

SECTION "ROM Bank 072 @$1225E8", ROMX[$65E8], BANK[72]
Bank72Rle_65E8:
    INCBIN "roms/magination.gbc", $1225E8, $3C1

SECTION "ROM Bank 072 @$1229A9", ROMX[$69A9], BANK[72]
Bank72Rle_69A9:
    INCBIN "roms/magination.gbc", $1229A9, $562

SECTION "ROM Bank 072 @$122F0B", ROMX[$6F0B], BANK[72]
Bank72Rle_6F0B:
    INCBIN "roms/magination.gbc", $122F0B, $3CF

SECTION "Zero padding from $1232DA", ROMX[$72DA], BANK[72]
    ds $D26, $00 ; zero padding to the end of bank $48

SECTION "ROM Bank 073", ROMX[$4000], BANK[73]
    INCBIN "roms/magination.gbc", $124000, $3408

SECTION "Zero padding from $127408", ROMX[$7408], BANK[73]
    ds $BF8, $00 ; zero padding to the end of bank $49

SECTION "ROM Bank 074", ROMX[$4000], BANK[74]
    INCBIN "roms/magination.gbc", $128000, $3AD7

SECTION "Zero padding from $12BAD7", ROMX[$7AD7], BANK[74]
    ds $529, $00 ; zero padding to the end of bank $4A

SECTION "ROM Bank 075", ROMX[$4000], BANK[75]
    INCBIN "roms/magination.gbc", $12C000, $37DA

SECTION "Zero padding from $12F7DA", ROMX[$77DA], BANK[75]
    ds $826, $00 ; zero padding to the end of bank $4B

SECTION "ROM Bank 076", ROMX[$4000], BANK[76]
    INCBIN "roms/magination.gbc", $130000, $01E6

SECTION "You crashed the battle engine script", ROMX[$41E6], BANK[76]
; you_crashed_battle_engine_script_41e6.asm: not published here (it assembles data copied from the ROM)
YouCrashedBattleEngineScript41E6:
    INCBIN "roms/magination.gbc", $1301E6, $3D

YouCrashedBattleEngineScript41E6End:

SECTION "ROM from $130223", ROMX[$4223], BANK[76]
    INCBIN "roms/magination.gbc", $130223, $0028

SECTION "Is defending script", ROMX[$424B], BANK[76]
; is_defending_script_424b.asm: not published here (it assembles data copied from the ROM)
IsDefendingScript424B:
    INCBIN "roms/magination.gbc", $13024B, $14

IsDefendingScript424BEnd:

SECTION "ROM from $13025F", ROMX[$425F], BANK[76]
    INCBIN "roms/magination.gbc", $13025F, $0117

SECTION "Name focuses script", ROMX[$4376], BANK[76]
; name_focuses_script_4376.asm: not published here (it assembles data copied from the ROM)
NameFocusesScript4376:
    INCBIN "roms/magination.gbc", $130376, $10

NameFocusesScript4376End:

SECTION "Tony gains energy script", ROMX[$4386], BANK[76]
; tony_gains_energy_script_4386.asm: not published here (it assembles data copied from the ROM)
TonyGainsEnergyScript4386:
    INCBIN "roms/magination.gbc", $130386, $2A

TonyGainsEnergyScript4386End:

SECTION "ROM from $1303B0", ROMX[$43B0], BANK[76]
    INCBIN "roms/magination.gbc", $1303B0, $00BD

SECTION "Name uses script", ROMX[$446D], BANK[76]
; name_uses_script_446d.asm: not published here (it assembles data copied from the ROM)
NameUsesScript446D:
    INCBIN "roms/magination.gbc", $13046D, $D

NameUsesScript446DEnd:

SECTION "ROM from $13047A", ROMX[$447A], BANK[76]
    INCBIN "roms/magination.gbc", $13047A, $0148

SECTION "Defense is down script", ROMX[$45C2], BANK[76]
; defense_is_down_script_45c2.asm: not published here (it assembles data copied from the ROM)
DefenseIsDownScript45C2:
    INCBIN "roms/magination.gbc", $1305C2, $1A

DefenseIsDownScript45C2End:

SECTION "Resist is down script", ROMX[$45DC], BANK[76]
; resist_is_down_script_45dc.asm: not published here (it assembles data copied from the ROM)
ResistIsDownScript45DC:
    INCBIN "roms/magination.gbc", $1305DC, $19

SECTION "Skill is down script", ROMX[$45F5], BANK[76]
; skill_is_down_script_45f5.asm: not published here (it assembles data copied from the ROM)
SkillIsDownScript45F5:
    INCBIN "roms/magination.gbc", $1305F5, $18

SkillIsDownScript45F5End:

SECTION "Speed is down script", ROMX[$460D], BANK[76]
; speed_is_down_script_460d.asm: not published here (it assembles data copied from the ROM)
SpeedIsDownScript460D:
    INCBIN "roms/magination.gbc", $13060D, $18

SpeedIsDownScript460DEnd:

SECTION "ROM from $130625", ROMX[$4625], BANK[76]
    INCBIN "roms/magination.gbc", $130625, $028C

SECTION "Defense is up name script", ROMX[$48B1], BANK[76]
; defense_is_up_script_48b1.asm: not published here (it assembles data copied from the ROM)
DefenseIsUpScript48B1:
    INCBIN "roms/magination.gbc", $1308B1, $18

SECTION "Luck is up name script", ROMX[$48C9], BANK[76]
; luck_is_up_script_48c9.asm: not published here (it assembles data copied from the ROM)
DefenseIsUpScript48B1End:
LuckIsUpScript48C9:
    INCBIN "roms/magination.gbc", $1308C9, $15

SECTION "ROM from $1308DE", ROMX[$48DE], BANK[76]
    INCBIN "roms/magination.gbc", $1308DE, $0017

SECTION "Speed is up name script", ROMX[$48F5], BANK[76]
; speed_is_up_script_48f5.asm: not published here (it assembles data copied from the ROM)
SpeedIsUpScript48F5:
    INCBIN "roms/magination.gbc", $1308F5, $16

SECTION "Skill is up name script", ROMX[$490B], BANK[76]
; skill_is_up_script_490b.asm: not published here (it assembles data copied from the ROM)
SkillIsUpScript490B:
SpeedIsUpScript48F5End:
    INCBIN "roms/magination.gbc", $13090B, $16

SkillIsUpScript490BEnd:

SECTION "ROM from $130921", ROMX[$4921], BANK[76]
    INCBIN "roms/magination.gbc", $130921, $0108

SECTION "Tony can't escape script", ROMX[$4A29], BANK[76]
; tony_cant_escape_script_4a29.asm: not published here (it assembles data copied from the ROM)
TonyCantEscapeScript4A29:
    INCBIN "roms/magination.gbc", $130A29, $17

TonyCantEscapeScript4A29End:

SECTION "Casts name script", ROMX[$4A40], BANK[76]
; casts_script_4a40.asm: not published here (it assembles data copied from the ROM)
CastsScript4A40:
    INCBIN "roms/magination.gbc", $130A40, $E

CastsScript4A40End:

SECTION "ROM from $130A4E", ROMX[$4A4E], BANK[76]
    INCBIN "roms/magination.gbc", $130A4E, $0092

SECTION "Was summoned script", ROMX[$4AE0], BANK[76]
; was_summoned_script_4ae0.asm: not published here (it assembles data copied from the ROM)
WasSummonedScript4AE0:
    INCBIN "roms/magination.gbc", $130AE0, $15

WasSummonedScript4AE0End:

SECTION "Was summoned script 4AF5", ROMX[$4AF5], BANK[76]
; was_summoned_script_4af5.asm: not published here (it assembles data copied from the ROM)
WasSummonedScript4AF5:
    INCBIN "roms/magination.gbc", $130AF5, $15

WasSummonedScript4AF5End:

SECTION "Appears script 4B0A", ROMX[$4B0A], BANK[76]
; appears_script_4b0a.asm: not published here (it assembles data copied from the ROM)
AppearsScript4B0A:
    INCBIN "roms/magination.gbc", $130B0A, $10

AppearsScript4B0AEnd:

SECTION "ROM from $130B1A", ROMX[$4B1A], BANK[76]
    INCBIN "roms/magination.gbc", $130B1A, $00B2

SECTION "Script at $4BCC", ROMX[$4BCC], BANK[76]
; script_4bcc.asm: not published here (it assembles data copied from the ROM)
Script4BCC:
    INCBIN "roms/magination.gbc", $130BCC, $3F

Script4BCCEnd:

SECTION "ROM from $130C0B", ROMX[$4C0B], BANK[76]
    INCBIN "roms/magination.gbc", $130C0B, $0073

SECTION "Script at $4C7E", ROMX[$4C7E], BANK[76]
; script_4c7e.asm: not published here (it assembles data copied from the ROM)
Script4C7E:
    INCBIN "roms/magination.gbc", $130C7E, $1C

Script4C7EEnd:

SECTION "ROM from $130C9A", ROMX[$4C9A], BANK[76]
    INCBIN "roms/magination.gbc", $130C9A, $001E

SECTION "Script at $4CB8", ROMX[$4CB8], BANK[76]
; script_4cb8.asm: not published here (it assembles data copied from the ROM)
Script4CB8:
    INCBIN "roms/magination.gbc", $130CB8, $2E

Script4CB8End:

SECTION "ROM from $130CE6", ROMX[$4CE6], BANK[76]
    INCBIN "roms/magination.gbc", $130CE6, $0076

SECTION "Script at $4D5C", ROMX[$4D5C], BANK[76]
; script_4d5c.asm: not published here (it assembles data copied from the ROM)
Script4D5C:
    INCBIN "roms/magination.gbc", $130D5C, $7

Script4D5CEnd:

SECTION "ROM from $130D63", ROMX[$4D63], BANK[76]
    INCBIN "roms/magination.gbc", $130D63, $0024

SECTION "Fill C31E copy glyphs script", ROMX[$4D87], BANK[76]
; fill_c31e_copy_glyphs_script_4d87.asm: not published here (it assembles data copied from the ROM)
FillC31ECopyGlyphsScript4D87:
    INCBIN "roms/magination.gbc", $130D87, $1C

FillC31ECopyGlyphsScript4D87End:

SECTION "ROM from $130DA3", ROMX[$4DA3], BANK[76]
    INCBIN "roms/magination.gbc", $130DA3, $00A8

SECTION "Fill C354 copy glyphs script", ROMX[$4E4B], BANK[76]
; fill_c354_copy_glyphs_script_4e4b.asm: not published here (it assembles data copied from the ROM)
FillC354CopyGlyphsScript4E4B:
    INCBIN "roms/magination.gbc", $130E4B, $1C

FillC354CopyGlyphsScript4E4BEnd:

SECTION "ROM from $130E67", ROMX[$4E67], BANK[76]
    INCBIN "roms/magination.gbc", $130E67, $0019

SECTION "Script at $4E80", ROMX[$4E80], BANK[76]
; script_4e80.asm: not published here (it assembles data copied from the ROM)
Script4E80:
    INCBIN "roms/magination.gbc", $130E80, $2E

Script4E80End:

SECTION "ROM from $130EAE", ROMX[$4EAE], BANK[76]
    INCBIN "roms/magination.gbc", $130EAE, $006A

SECTION "Script at $4F18", ROMX[$4F18], BANK[76]
; script_4f18.asm: not published here (it assembles data copied from the ROM)
Script4F18:
    INCBIN "roms/magination.gbc", $130F18, $24

Script4F18End:

SECTION "ROM from $130F3C", ROMX[$4F3C], BANK[76]
    INCBIN "roms/magination.gbc", $130F3C, $0028

SECTION "Script at $4F64", ROMX[$4F64], BANK[76]
; script_4f64.asm: not published here (it assembles data copied from the ROM)
Script4F64:
    INCBIN "roms/magination.gbc", $130F64, $37

Script4F64End:

SECTION "ROM from $130F9B", ROMX[$4F9B], BANK[76]
    INCBIN "roms/magination.gbc", $130F9B, $003A

SECTION "Script at $4FD5", ROMX[$4FD5], BANK[76]
; script_4fd5.asm: not published here (it assembles data copied from the ROM)
Script4FD5:
    INCBIN "roms/magination.gbc", $130FD5, $3E

Script4FD5End:

SECTION "ROM from $131013", ROMX[$5013], BANK[76]
    INCBIN "roms/magination.gbc", $131013, $00F6

SECTION "Script at $5109", ROMX[$5109], BANK[76]
; script_5109.asm: not published here (it assembles data copied from the ROM)
Script5109:
    INCBIN "roms/magination.gbc", $131109, $3F

Script5109End:

SECTION "ROM from $131148", ROMX[$5148], BANK[76]
    INCBIN "roms/magination.gbc", $131148, $0088

SECTION "Script staged at 51D0", ROMX[$51D0], BANK[76]
; script_staged_51d0.asm: not published here (it assembles data copied from the ROM)
ScriptStaged51D0:
    INCBIN "roms/magination.gbc", $1311D0, $1C

ScriptStaged51D0End:

SECTION "ROM from $1311EC", ROMX[$51EC], BANK[76]
    INCBIN "roms/magination.gbc", $1311EC, $0019

SECTION "Script at $5205", ROMX[$5205], BANK[76]
; script_5205.asm: not published here (it assembles data copied from the ROM)
Script5205:
    INCBIN "roms/magination.gbc", $131205, $7

Script5205End:

SECTION "ROM from $13120C", ROMX[$520C], BANK[76]
    INCBIN "roms/magination.gbc", $13120C, $0019

SECTION "Script at $5225", ROMX[$5225], BANK[76]
; script_5225.asm: not published here (it assembles data copied from the ROM)
Script5225:
    INCBIN "roms/magination.gbc", $131225, $B

Script5225End:

SECTION "ROM from $131230", ROMX[$5230], BANK[76]
    INCBIN "roms/magination.gbc", $131230, $0015

SECTION "Script at $5245", ROMX[$5245], BANK[76]
; script_5245.asm: not published here (it assembles data copied from the ROM)
Script5245:
    INCBIN "roms/magination.gbc", $131245, $37

Script5245End:

SECTION "ROM from $13127C", ROMX[$527C], BANK[76]
    INCBIN "roms/magination.gbc", $13127C, $0032

SECTION "Script at $52AE", ROMX[$52AE], BANK[76]
; script_52ae.asm: not published here (it assembles data copied from the ROM)
Script52AE:
    INCBIN "roms/magination.gbc", $1312AE, $1C

Script52AEEnd:

SECTION "ROM from $1312CA", ROMX[$52CA], BANK[76]
    INCBIN "roms/magination.gbc", $1312CA, $0096

SECTION "Script at $5360", ROMX[$5360], BANK[76]
; script_5360.asm: not published here (it assembles data copied from the ROM)
Script5360:
    INCBIN "roms/magination.gbc", $131360, $2D

Script5360End:

SECTION "ROM from $13138D", ROMX[$538D], BANK[76]
    INCBIN "roms/magination.gbc", $13138D, $0026

SECTION "Script at $53B3", ROMX[$53B3], BANK[76]
; script_53b3.asm: not published here (it assembles data copied from the ROM)
Script53B3:
    INCBIN "roms/magination.gbc", $1313B3, $1C

Script53B3End:

SECTION "ROM from $1313CF", ROMX[$53CF], BANK[76]
    INCBIN "roms/magination.gbc", $1313CF, $001F

SECTION "Script at $53EE", ROMX[$53EE], BANK[76]
; script_53ee.asm: not published here (it assembles data copied from the ROM)
Script53EE:
    INCBIN "roms/magination.gbc", $1313EE, $1C

Script53EEEnd:

SECTION "ROM from $13140A", ROMX[$540A], BANK[76]
    INCBIN "roms/magination.gbc", $13140A, $001F

SECTION "Script at $5429", ROMX[$5429], BANK[76]
; script_5429.asm: not published here (it assembles data copied from the ROM)
Script5429:
    INCBIN "roms/magination.gbc", $131429, $3F

Script5429End:

SECTION "ROM from $131468", ROMX[$5468], BANK[76]
    INCBIN "roms/magination.gbc", $131468, $0155

SECTION "Script at $55BD", ROMX[$55BD], BANK[76]
; script_55bd.asm: not published here (it assembles data copied from the ROM)
Script55BD:
    INCBIN "roms/magination.gbc", $1315BD, $2D

Script55BDEnd:

SECTION "ROM from $1315EA", ROMX[$55EA], BANK[76]
    INCBIN "roms/magination.gbc", $1315EA, $0024

SECTION "Script at $560E", ROMX[$560E], BANK[76]
; script_560e.asm: not published here (it assembles data copied from the ROM)
Script560E:
    INCBIN "roms/magination.gbc", $13160E, $1A

Script560EEnd:

SECTION "ROM from $131628", ROMX[$5628], BANK[76]
    INCBIN "roms/magination.gbc", $131628, $0070

SECTION "Script at $5698", ROMX[$5698], BANK[76]
; script_5698.asm: not published here (it assembles data copied from the ROM)
Script5698:
    INCBIN "roms/magination.gbc", $131698, $1A

Script5698End:

SECTION "ROM from $1316B2", ROMX[$56B2], BANK[76]
    INCBIN "roms/magination.gbc", $1316B2, $0024

SECTION "Script at $56D6", ROMX[$56D6], BANK[76]
; script_56d6.asm: not published here (it assembles data copied from the ROM)
Script56D6:
    INCBIN "roms/magination.gbc", $1316D6, $3E

Script56D6End:

SECTION "ROM from $131714", ROMX[$5714], BANK[76]
    INCBIN "roms/magination.gbc", $131714, $0056

SECTION "Script at $576A", ROMX[$576A], BANK[76]
; script_576a.asm: not published here (it assembles data copied from the ROM)
Script576A:
    INCBIN "roms/magination.gbc", $13176A, $35

Script576AEnd:

SECTION "ROM from $13179F", ROMX[$579F], BANK[76]
    INCBIN "roms/magination.gbc", $13179F, $0031

SECTION "Script at $57D0", ROMX[$57D0], BANK[76]
; script_57d0.asm: not published here (it assembles data copied from the ROM)
Script57D0:
    INCBIN "roms/magination.gbc", $1317D0, $1A

Script57D0End:

SECTION "ROM from $1317EA", ROMX[$57EA], BANK[76]
    INCBIN "roms/magination.gbc", $1317EA, $001B

SECTION "Script at $5805", ROMX[$5805], BANK[76]
; script_5805.asm: not published here (it assembles data copied from the ROM)
Script5805:
    INCBIN "roms/magination.gbc", $131805, $1A

Script5805End:

SECTION "ROM from $13181F", ROMX[$581F], BANK[76]
    INCBIN "roms/magination.gbc", $13181F, $0035

SECTION "Script at $5854", ROMX[$5854], BANK[76]
; script_5854.asm: not published here (it assembles data copied from the ROM)
Script5854:
    INCBIN "roms/magination.gbc", $131854, $1A

Script5854End:

SECTION "ROM from $13186E", ROMX[$586E], BANK[76]
    INCBIN "roms/magination.gbc", $13186E, $001B

SECTION "Script at $5889", ROMX[$5889], BANK[76]
; script_5889.asm: not published here (it assembles data copied from the ROM)
Script5889:
    INCBIN "roms/magination.gbc", $131889, $1A

Script5889End:

SECTION "ROM from $1318A3", ROMX[$58A3], BANK[76]
    INCBIN "roms/magination.gbc", $1318A3, $002A

SECTION "Script at $58CD", ROMX[$58CD], BANK[76]
; script_58cd.asm: not published here (it assembles data copied from the ROM)
Script58CD:
    INCBIN "roms/magination.gbc", $1318CD, $1A

Script58CDEnd:

SECTION "ROM from $1318E7", ROMX[$58E7], BANK[76]
    INCBIN "roms/magination.gbc", $1318E7, $0024

SECTION "Script at $590B", ROMX[$590B], BANK[76]
; script_590b.asm: not published here (it assembles data copied from the ROM)
Script590B:
    INCBIN "roms/magination.gbc", $13190B, $1A

Script590BEnd:

SECTION "ROM from $131925", ROMX[$5925], BANK[76]
    INCBIN "roms/magination.gbc", $131925, $004A

SECTION "Script at $596F", ROMX[$596F], BANK[76]
; script_596f.asm: not published here (it assembles data copied from the ROM)
Script596F:
    INCBIN "roms/magination.gbc", $13196F, $2C

Script596FEnd:

SECTION "ROM from $13199B", ROMX[$599B], BANK[76]
    INCBIN "roms/magination.gbc", $13199B, $0037

SECTION "Script at $59D2", ROMX[$59D2], BANK[76]
; script_59d2.asm: not published here (it assembles data copied from the ROM)
Script59D2:
    INCBIN "roms/magination.gbc", $1319D2, $35

Script59D2End:

SECTION "ROM from $131A07", ROMX[$5A07], BANK[76]
    INCBIN "roms/magination.gbc", $131A07, $002B

SECTION "Script at $5A32", ROMX[$5A32], BANK[76]
; script_5a32.asm: not published here (it assembles data copied from the ROM)
Script5A32:
    INCBIN "roms/magination.gbc", $131A32, $2C

Script5A32End:

SECTION "ROM from $131A5E", ROMX[$5A5E], BANK[76]
    INCBIN "roms/magination.gbc", $131A5E, $00A3

SECTION "Script at $5B01", ROMX[$5B01], BANK[76]
; script_5b01.asm: not published here (it assembles data copied from the ROM)
Script5B01:
    INCBIN "roms/magination.gbc", $131B01, $1A

Script5B01End:

SECTION "ROM from $131B1B", ROMX[$5B1B], BANK[76]
    INCBIN "roms/magination.gbc", $131B1B, $005C

SECTION "Script at $5B77", ROMX[$5B77], BANK[76]
; script_5b77.asm: not published here (it assembles data copied from the ROM)
Script5B77:
    INCBIN "roms/magination.gbc", $131B77, $20

Script5B77End:

SECTION "ROM from $131B97", ROMX[$5B97], BANK[76]
    INCBIN "roms/magination.gbc", $131B97, $00D0

SECTION "Script at $5C67", ROMX[$5C67], BANK[76]
; script_5c67.asm: not published here (it assembles data copied from the ROM)
Script5C67:
    INCBIN "roms/magination.gbc", $131C67, $37

Script5C67End:

SECTION "ROM from $131C9E", ROMX[$5C9E], BANK[76]
    INCBIN "roms/magination.gbc", $131C9E, $8F

SECTION "Zero padding from $131D2D", ROMX[$5D2D], BANK[76]
    ds $22D3, $00 ; zero padding to the end of bank $4C

SECTION "ROM Bank 077", ROMX[$4000], BANK[77]
    INCBIN "roms/magination.gbc", $134000, $333F

SECTION "Zero padding from $13733F", ROMX[$733F], BANK[77]
    ds $CC1, $00 ; zero padding to the end of bank $4D

SECTION "ROM Bank 078", ROMX[$4000], BANK[78]
; gfx/bank78_rle.asm: not published here (it assembles data copied from the ROM)
Bank78Rle_4000:
    INCBIN "roms/magination.gbc", $138000, $2C6

SECTION "ROM Bank 078 @$1382C6", ROMX[$42C6], BANK[78]
Bank78Rle_42C6:
    INCBIN "roms/magination.gbc", $1382C6, $289

SECTION "ROM Bank 078 @$13854F", ROMX[$454F], BANK[78]
Bank78Rle_454F:
    INCBIN "roms/magination.gbc", $13854F, $2A0

SECTION "ROM Bank 078 @$1387EF", ROMX[$47EF], BANK[78]
Bank78Rle_47EF:
    INCBIN "roms/magination.gbc", $1387EF, $30C

SECTION "ROM Bank 078 @$138AFB", ROMX[$4AFB], BANK[78]
Bank78Rle_4AFB:
    INCBIN "roms/magination.gbc", $138AFB, $2A0

SECTION "ROM Bank 078 @$138D9B", ROMX[$4D9B], BANK[78]
Bank78Rle_4D9B:
    INCBIN "roms/magination.gbc", $138D9B, $1EB

SECTION "ROM Bank 078 @$138F86", ROMX[$4F86], BANK[78]
Bank78Rle_4F86:
    INCBIN "roms/magination.gbc", $138F86, $237

SECTION "ROM Bank 078 @$1391BD", ROMX[$51BD], BANK[78]
Bank78Rle_51BD:
    INCBIN "roms/magination.gbc", $1391BD, $20B

SECTION "ROM Bank 078 @$1393C8", ROMX[$53C8], BANK[78]
Bank78Rle_53C8:
    INCBIN "roms/magination.gbc", $1393C8, $1CA

SECTION "ROM Bank 078 @$139592", ROMX[$5592], BANK[78]
Bank78Rle_5592:
    INCBIN "roms/magination.gbc", $139592, $299

SECTION "ROM Bank 078 @$13982B", ROMX[$582B], BANK[78]
Bank78Rle_582B:
    INCBIN "roms/magination.gbc", $13982B, $2A5

SECTION "ROM Bank 078 @$139AD0", ROMX[$5AD0], BANK[78]
Bank78Rle_5AD0:
    INCBIN "roms/magination.gbc", $139AD0, $23F

SECTION "ROM Bank 078 @$139D0F", ROMX[$5D0F], BANK[78]
Bank78Rle_5D0F:
    INCBIN "roms/magination.gbc", $139D0F, $28C

SECTION "ROM Bank 078 @$139F9B", ROMX[$5F9B], BANK[78]
Bank78Rle_5F9B:
    INCBIN "roms/magination.gbc", $139F9B, $22D

SECTION "bank78_gfx", ROMX[$61C8], BANK[78]
; gfx/bank78_gfx.asm: not published here (it assembles data copied from the ROM)
Bank78Gfx:
Bank78RleEnd:
    INCBIN "roms/magination.gbc", $13A1C8, $B00

SECTION "Zero padding from $13ACC8", ROMX[$6CC8], BANK[78]
    ds $1338, $00 ; zero padding to the end of bank $4E

SECTION "ROM Bank 079", ROMX[$4000], BANK[79]
; map_sources_bank4f.asm: not published here (it assembles data copied from the ROM)
MapSources4F_000:
    INCBIN "roms/magination.gbc", $13C000, $F

SECTION "ROM Bank 079 @$13C00F", ROMX[$400F], BANK[79]
MapSources4F_001:
    INCBIN "roms/magination.gbc", $13C00F, $F

SECTION "ROM Bank 079 @$13C01E", ROMX[$401E], BANK[79]
MapSources4F_002:
    INCBIN "roms/magination.gbc", $13C01E, $F

SECTION "ROM Bank 079 @$13C02D", ROMX[$402D], BANK[79]
MapSources4F_003:
    INCBIN "roms/magination.gbc", $13C02D, $F

SECTION "ROM Bank 079 @$13C03C", ROMX[$403C], BANK[79]
MapSources4F_004:
    INCBIN "roms/magination.gbc", $13C03C, $F

SECTION "ROM Bank 079 @$13C04B", ROMX[$404B], BANK[79]
MapSources4F_005:
    INCBIN "roms/magination.gbc", $13C04B, $F

SECTION "ROM Bank 079 @$13C05A", ROMX[$405A], BANK[79]
MapSources4F_006:
    INCBIN "roms/magination.gbc", $13C05A, $F

SECTION "ROM Bank 079 @$13C069", ROMX[$4069], BANK[79]
MapSources4F_007:
    INCBIN "roms/magination.gbc", $13C069, $F

SECTION "ROM Bank 079 @$13C078", ROMX[$4078], BANK[79]
MapSources4F_008:
    INCBIN "roms/magination.gbc", $13C078, $F

SECTION "ROM Bank 079 @$13C087", ROMX[$4087], BANK[79]
MapSources4F_009:
    INCBIN "roms/magination.gbc", $13C087, $F

SECTION "ROM Bank 079 @$13C096", ROMX[$4096], BANK[79]
MapSources4F_010:
    INCBIN "roms/magination.gbc", $13C096, $F

SECTION "ROM Bank 079 @$13C0A5", ROMX[$40A5], BANK[79]
MapSources4F_011:
    INCBIN "roms/magination.gbc", $13C0A5, $F

SECTION "ROM Bank 079 @$13C0B4", ROMX[$40B4], BANK[79]
MapSources4F_012:
    INCBIN "roms/magination.gbc", $13C0B4, $F

SECTION "ROM Bank 079 @$13C0C3", ROMX[$40C3], BANK[79]
MapSources4F_013:
    INCBIN "roms/magination.gbc", $13C0C3, $F

SECTION "ROM Bank 079 @$13C0D2", ROMX[$40D2], BANK[79]
MapSources4F_014:
    INCBIN "roms/magination.gbc", $13C0D2, $F

SECTION "ROM Bank 079 @$13C0E1", ROMX[$40E1], BANK[79]
MapSources4F_015:
    INCBIN "roms/magination.gbc", $13C0E1, $F

SECTION "ROM Bank 079 @$13C0F0", ROMX[$40F0], BANK[79]
MapSources4F_016:
    INCBIN "roms/magination.gbc", $13C0F0, $F

SECTION "ROM Bank 079 @$13C0FF", ROMX[$40FF], BANK[79]
MapSources4F_017:
    INCBIN "roms/magination.gbc", $13C0FF, $F

SECTION "ROM Bank 079 @$13C10E", ROMX[$410E], BANK[79]
MapSources4F_018:
    INCBIN "roms/magination.gbc", $13C10E, $F

SECTION "ROM Bank 079 @$13C11D", ROMX[$411D], BANK[79]
MapSources4F_019:
    INCBIN "roms/magination.gbc", $13C11D, $F

SECTION "ROM Bank 079 @$13C12C", ROMX[$412C], BANK[79]
MapSources4F_020:
    INCBIN "roms/magination.gbc", $13C12C, $F

SECTION "ROM Bank 079 @$13C13B", ROMX[$413B], BANK[79]
MapSources4F_021:
    INCBIN "roms/magination.gbc", $13C13B, $F

SECTION "ROM Bank 079 @$13C14A", ROMX[$414A], BANK[79]
MapSources4F_022:
    INCBIN "roms/magination.gbc", $13C14A, $F

SECTION "ROM Bank 079 @$13C159", ROMX[$4159], BANK[79]
MapSources4F_023:
    INCBIN "roms/magination.gbc", $13C159, $F

SECTION "ROM Bank 079 @$13C168", ROMX[$4168], BANK[79]
MapSources4F_024:
    INCBIN "roms/magination.gbc", $13C168, $F

SECTION "ROM Bank 079 @$13C177", ROMX[$4177], BANK[79]
MapSources4F_025:
    INCBIN "roms/magination.gbc", $13C177, $F

SECTION "ROM Bank 079 @$13C186", ROMX[$4186], BANK[79]
MapSources4F_026:
    INCBIN "roms/magination.gbc", $13C186, $F

SECTION "ROM Bank 079 @$13C195", ROMX[$4195], BANK[79]
MapSources4F_027:
    INCBIN "roms/magination.gbc", $13C195, $F

SECTION "ROM Bank 079 @$13C1A4", ROMX[$41A4], BANK[79]
MapSources4F_028:
    INCBIN "roms/magination.gbc", $13C1A4, $F

SECTION "ROM Bank 079 @$13C1B3", ROMX[$41B3], BANK[79]
MapSources4F_029:
    INCBIN "roms/magination.gbc", $13C1B3, $F

SECTION "ROM Bank 079 @$13C1C2", ROMX[$41C2], BANK[79]
MapSources4F_030:
    INCBIN "roms/magination.gbc", $13C1C2, $F

SECTION "ROM Bank 079 @$13C1D1", ROMX[$41D1], BANK[79]
MapSources4F_031:
    INCBIN "roms/magination.gbc", $13C1D1, $F

SECTION "ROM Bank 079 @$13C1E0", ROMX[$41E0], BANK[79]
MapSources4F_032:
    INCBIN "roms/magination.gbc", $13C1E0, $F

SECTION "ROM Bank 079 @$13C1EF", ROMX[$41EF], BANK[79]
MapSources4F_033:
    INCBIN "roms/magination.gbc", $13C1EF, $F

SECTION "ROM Bank 079 @$13C1FE", ROMX[$41FE], BANK[79]
MapSources4F_034:
    INCBIN "roms/magination.gbc", $13C1FE, $F

SECTION "ROM Bank 079 @$13C20D", ROMX[$420D], BANK[79]
MapSources4F_035:
    INCBIN "roms/magination.gbc", $13C20D, $F

SECTION "ROM Bank 079 @$13C21C", ROMX[$421C], BANK[79]
MapSources4F_036:
    INCBIN "roms/magination.gbc", $13C21C, $F

SECTION "ROM Bank 079 @$13C22B", ROMX[$422B], BANK[79]
MapSources4F_037:
    INCBIN "roms/magination.gbc", $13C22B, $F

SECTION "ROM Bank 079 @$13C23A", ROMX[$423A], BANK[79]
MapSources4F_038:
    INCBIN "roms/magination.gbc", $13C23A, $F

SECTION "ROM Bank 079 @$13C249", ROMX[$4249], BANK[79]
MapSources4F_039:
    INCBIN "roms/magination.gbc", $13C249, $F

SECTION "ROM Bank 079 @$13C258", ROMX[$4258], BANK[79]
MapSources4F_040:
    INCBIN "roms/magination.gbc", $13C258, $F

SECTION "ROM Bank 079 @$13C267", ROMX[$4267], BANK[79]
MapSources4F_041:
    INCBIN "roms/magination.gbc", $13C267, $F

SECTION "ROM Bank 079 @$13C276", ROMX[$4276], BANK[79]
MapSources4F_042:
    INCBIN "roms/magination.gbc", $13C276, $F

SECTION "ROM Bank 079 @$13C285", ROMX[$4285], BANK[79]
MapSources4F_043:
    INCBIN "roms/magination.gbc", $13C285, $F

SECTION "ROM Bank 079 @$13C294", ROMX[$4294], BANK[79]
MapSources4F_044:
    INCBIN "roms/magination.gbc", $13C294, $F

SECTION "ROM Bank 079 @$13C2A3", ROMX[$42A3], BANK[79]
MapSources4F_045:
    INCBIN "roms/magination.gbc", $13C2A3, $F

SECTION "ROM Bank 079 @$13C2B2", ROMX[$42B2], BANK[79]
MapSources4F_046:
    INCBIN "roms/magination.gbc", $13C2B2, $F

SECTION "ROM Bank 079 @$13C2C1", ROMX[$42C1], BANK[79]
MapSources4F_047:
    INCBIN "roms/magination.gbc", $13C2C1, $F

SECTION "ROM Bank 079 @$13C2D0", ROMX[$42D0], BANK[79]
MapSources4F_048:
    INCBIN "roms/magination.gbc", $13C2D0, $F

SECTION "ROM Bank 079 @$13C2DF", ROMX[$42DF], BANK[79]
MapSources4F_049:
    INCBIN "roms/magination.gbc", $13C2DF, $F

SECTION "ROM Bank 079 @$13C2EE", ROMX[$42EE], BANK[79]
MapSources4F_050:
    INCBIN "roms/magination.gbc", $13C2EE, $F

SECTION "ROM Bank 079 @$13C2FD", ROMX[$42FD], BANK[79]
MapSources4F_051:
    INCBIN "roms/magination.gbc", $13C2FD, $F

SECTION "ROM Bank 079 @$13C30C", ROMX[$430C], BANK[79]
MapSources4F_052:
    INCBIN "roms/magination.gbc", $13C30C, $F

SECTION "ROM Bank 079 @$13C31B", ROMX[$431B], BANK[79]
MapSources4F_053:
    INCBIN "roms/magination.gbc", $13C31B, $F

SECTION "ROM Bank 079 @$13C32A", ROMX[$432A], BANK[79]
MapSources4F_054:
    INCBIN "roms/magination.gbc", $13C32A, $F

SECTION "ROM Bank 079 @$13C339", ROMX[$4339], BANK[79]
MapSources4F_055:
    INCBIN "roms/magination.gbc", $13C339, $F

SECTION "ROM Bank 079 @$13C348", ROMX[$4348], BANK[79]
MapSources4F_056:
    INCBIN "roms/magination.gbc", $13C348, $F

SECTION "ROM Bank 079 @$13C357", ROMX[$4357], BANK[79]
MapSources4F_057:
    INCBIN "roms/magination.gbc", $13C357, $F

SECTION "ROM Bank 079 @$13C366", ROMX[$4366], BANK[79]
MapSources4F_058:
    INCBIN "roms/magination.gbc", $13C366, $F

SECTION "ROM Bank 079 @$13C375", ROMX[$4375], BANK[79]
MapSources4F_059:
    INCBIN "roms/magination.gbc", $13C375, $F

SECTION "ROM Bank 079 @$13C384", ROMX[$4384], BANK[79]
MapSources4F_060:
    INCBIN "roms/magination.gbc", $13C384, $F

SECTION "ROM Bank 079 @$13C393", ROMX[$4393], BANK[79]
MapSources4F_061:
    INCBIN "roms/magination.gbc", $13C393, $F

SECTION "ROM Bank 079 @$13C3A2", ROMX[$43A2], BANK[79]
MapSources4F_062:
    INCBIN "roms/magination.gbc", $13C3A2, $F

SECTION "ROM Bank 079 @$13C3B1", ROMX[$43B1], BANK[79]
MapSources4F_063:
    INCBIN "roms/magination.gbc", $13C3B1, $F

SECTION "ROM Bank 079 @$13C3C0", ROMX[$43C0], BANK[79]
MapSources4F_064:
    INCBIN "roms/magination.gbc", $13C3C0, $F

SECTION "ROM Bank 079 @$13C3CF", ROMX[$43CF], BANK[79]
MapSources4F_065:
    INCBIN "roms/magination.gbc", $13C3CF, $F

SECTION "ROM Bank 079 @$13C3DE", ROMX[$43DE], BANK[79]
MapSources4F_066:
    INCBIN "roms/magination.gbc", $13C3DE, $F

SECTION "ROM Bank 079 @$13C3ED", ROMX[$43ED], BANK[79]
MapSources4F_067:
    INCBIN "roms/magination.gbc", $13C3ED, $F

SECTION "ROM Bank 079 @$13C3FC", ROMX[$43FC], BANK[79]
MapSources4F_068:
    INCBIN "roms/magination.gbc", $13C3FC, $F

SECTION "ROM Bank 079 @$13C40B", ROMX[$440B], BANK[79]
MapSources4F_069:
    INCBIN "roms/magination.gbc", $13C40B, $F

SECTION "ROM Bank 079 @$13C41A", ROMX[$441A], BANK[79]
MapSources4F_070:
    INCBIN "roms/magination.gbc", $13C41A, $F

SECTION "ROM Bank 079 @$13C429", ROMX[$4429], BANK[79]
MapSources4F_071:
    INCBIN "roms/magination.gbc", $13C429, $F

SECTION "ROM Bank 079 @$13C438", ROMX[$4438], BANK[79]
MapSources4F_072:
    INCBIN "roms/magination.gbc", $13C438, $F

SECTION "ROM Bank 079 @$13C447", ROMX[$4447], BANK[79]
MapSources4F_073:
    INCBIN "roms/magination.gbc", $13C447, $F

SECTION "ROM Bank 079 @$13C456", ROMX[$4456], BANK[79]
MapSources4F_074:
    INCBIN "roms/magination.gbc", $13C456, $F

SECTION "ROM Bank 079 @$13C465", ROMX[$4465], BANK[79]
MapSources4F_075:
    INCBIN "roms/magination.gbc", $13C465, $F

SECTION "ROM Bank 079 @$13C474", ROMX[$4474], BANK[79]
MapSources4F_076:
    INCBIN "roms/magination.gbc", $13C474, $F

SECTION "ROM Bank 079 @$13C483", ROMX[$4483], BANK[79]
MapSources4F_077:
    INCBIN "roms/magination.gbc", $13C483, $F

SECTION "ROM Bank 079 @$13C492", ROMX[$4492], BANK[79]
MapSources4F_078:
    INCBIN "roms/magination.gbc", $13C492, $F

SECTION "ROM Bank 079 @$13C4A1", ROMX[$44A1], BANK[79]
MapSources4F_079:
    INCBIN "roms/magination.gbc", $13C4A1, $F

SECTION "ROM Bank 079 @$13C4B0", ROMX[$44B0], BANK[79]
MapSources4F_080:
    INCBIN "roms/magination.gbc", $13C4B0, $F

SECTION "ROM Bank 079 @$13C4BF", ROMX[$44BF], BANK[79]
MapSources4F_081:
    INCBIN "roms/magination.gbc", $13C4BF, $F

SECTION "ROM Bank 079 @$13C4CE", ROMX[$44CE], BANK[79]
MapSources4F_082:
    INCBIN "roms/magination.gbc", $13C4CE, $F

SECTION "ROM Bank 079 @$13C4DD", ROMX[$44DD], BANK[79]
MapSources4F_083:
    INCBIN "roms/magination.gbc", $13C4DD, $F

SECTION "ROM Bank 079 @$13C4EC", ROMX[$44EC], BANK[79]
MapSources4F_084:
    INCBIN "roms/magination.gbc", $13C4EC, $F

SECTION "ROM Bank 079 @$13C4FB", ROMX[$44FB], BANK[79]
MapSources4F_085:
    INCBIN "roms/magination.gbc", $13C4FB, $F

SECTION "ROM Bank 079 @$13C50A", ROMX[$450A], BANK[79]
MapSources4F_086:
    INCBIN "roms/magination.gbc", $13C50A, $F

SECTION "ROM Bank 079 @$13C519", ROMX[$4519], BANK[79]
MapSources4F_087:
    INCBIN "roms/magination.gbc", $13C519, $F

SECTION "ROM Bank 079 @$13C528", ROMX[$4528], BANK[79]
MapSources4F_088:
    INCBIN "roms/magination.gbc", $13C528, $F

SECTION "ROM Bank 079 @$13C537", ROMX[$4537], BANK[79]
MapSources4F_089:
    INCBIN "roms/magination.gbc", $13C537, $F

SECTION "ROM Bank 079 @$13C546", ROMX[$4546], BANK[79]
MapSources4F_090:
    INCBIN "roms/magination.gbc", $13C546, $F

SECTION "ROM Bank 079 @$13C555", ROMX[$4555], BANK[79]
MapSources4F_091:
    INCBIN "roms/magination.gbc", $13C555, $F

SECTION "ROM Bank 079 @$13C564", ROMX[$4564], BANK[79]
MapSources4F_092:
    INCBIN "roms/magination.gbc", $13C564, $F

SECTION "ROM Bank 079 @$13C573", ROMX[$4573], BANK[79]
MapSources4F_093:
    INCBIN "roms/magination.gbc", $13C573, $F

SECTION "ROM Bank 079 @$13C582", ROMX[$4582], BANK[79]
MapSources4F_094:
    INCBIN "roms/magination.gbc", $13C582, $F

SECTION "ROM Bank 079 @$13C591", ROMX[$4591], BANK[79]
MapSources4F_095:
    INCBIN "roms/magination.gbc", $13C591, $F

SECTION "ROM Bank 079 @$13C5A0", ROMX[$45A0], BANK[79]
MapSources4F_096:
    INCBIN "roms/magination.gbc", $13C5A0, $F

SECTION "ROM Bank 079 @$13C5AF", ROMX[$45AF], BANK[79]
MapSources4F_097:
    INCBIN "roms/magination.gbc", $13C5AF, $F

SECTION "ROM Bank 079 @$13C5BE", ROMX[$45BE], BANK[79]
MapSources4F_098:
    INCBIN "roms/magination.gbc", $13C5BE, $F

SECTION "ROM Bank 079 @$13C5CD", ROMX[$45CD], BANK[79]
MapSources4F_099:
    INCBIN "roms/magination.gbc", $13C5CD, $F

SECTION "ROM Bank 079 @$13C5DC", ROMX[$45DC], BANK[79]
MapSources4F_100:
    INCBIN "roms/magination.gbc", $13C5DC, $F

SECTION "ROM Bank 079 @$13C5EB", ROMX[$45EB], BANK[79]
MapSources4F_101:
    INCBIN "roms/magination.gbc", $13C5EB, $F

SECTION "ROM Bank 079 @$13C5FA", ROMX[$45FA], BANK[79]
MapSources4F_102:
    INCBIN "roms/magination.gbc", $13C5FA, $F

SECTION "ROM Bank 079 @$13C609", ROMX[$4609], BANK[79]
MapSources4F_103:
    INCBIN "roms/magination.gbc", $13C609, $F

SECTION "ROM Bank 079 @$13C618", ROMX[$4618], BANK[79]
MapSources4F_104:
    INCBIN "roms/magination.gbc", $13C618, $F

SECTION "ROM Bank 079 @$13C627", ROMX[$4627], BANK[79]
MapSources4F_105:
    INCBIN "roms/magination.gbc", $13C627, $F

SECTION "ROM Bank 079 @$13C636", ROMX[$4636], BANK[79]
MapSources4F_106:
    INCBIN "roms/magination.gbc", $13C636, $F

SECTION "ROM Bank 079 @$13C645", ROMX[$4645], BANK[79]
MapSources4F_107:
    INCBIN "roms/magination.gbc", $13C645, $F

SECTION "ROM Bank 079 @$13C654", ROMX[$4654], BANK[79]
MapSources4F_108:
    INCBIN "roms/magination.gbc", $13C654, $F

SECTION "ROM Bank 079 @$13C663", ROMX[$4663], BANK[79]
MapSources4F_109:
    INCBIN "roms/magination.gbc", $13C663, $F

SECTION "ROM Bank 079 @$13C672", ROMX[$4672], BANK[79]
MapSources4F_110:
    INCBIN "roms/magination.gbc", $13C672, $F

SECTION "ROM Bank 079 @$13C681", ROMX[$4681], BANK[79]
MapSources4F_111:
    INCBIN "roms/magination.gbc", $13C681, $F

SECTION "ROM Bank 079 @$13C690", ROMX[$4690], BANK[79]
MapSources4F_112:
    INCBIN "roms/magination.gbc", $13C690, $F

SECTION "ROM Bank 079 @$13C69F", ROMX[$469F], BANK[79]
MapSources4F_113:
    INCBIN "roms/magination.gbc", $13C69F, $F

SECTION "ROM Bank 079 @$13C6AE", ROMX[$46AE], BANK[79]
MapSources4F_114:
    INCBIN "roms/magination.gbc", $13C6AE, $F

SECTION "ROM Bank 079 @$13C6BD", ROMX[$46BD], BANK[79]
MapSources4F_115:
    INCBIN "roms/magination.gbc", $13C6BD, $F

SECTION "ROM Bank 079 @$13C6CC", ROMX[$46CC], BANK[79]
MapSources4F_116:
    INCBIN "roms/magination.gbc", $13C6CC, $F

SECTION "ROM Bank 079 @$13C6DB", ROMX[$46DB], BANK[79]
MapSources4F_117:
    INCBIN "roms/magination.gbc", $13C6DB, $F

SECTION "ROM Bank 079 @$13C6EA", ROMX[$46EA], BANK[79]
MapSources4F_118:
    INCBIN "roms/magination.gbc", $13C6EA, $F

SECTION "ROM Bank 079 @$13C6F9", ROMX[$46F9], BANK[79]
MapSources4F_119:
    INCBIN "roms/magination.gbc", $13C6F9, $F

SECTION "ROM Bank 079 @$13C708", ROMX[$4708], BANK[79]
MapSources4F_120:
    INCBIN "roms/magination.gbc", $13C708, $F

SECTION "ROM Bank 079 @$13C717", ROMX[$4717], BANK[79]
MapSources4F_121:
    INCBIN "roms/magination.gbc", $13C717, $F

SECTION "ROM Bank 079 @$13C726", ROMX[$4726], BANK[79]
MapSources4F_122:
    INCBIN "roms/magination.gbc", $13C726, $F

SECTION "ROM Bank 079 @$13C735", ROMX[$4735], BANK[79]
MapSources4F_123:
    INCBIN "roms/magination.gbc", $13C735, $F

SECTION "ROM Bank 079 @$13C744", ROMX[$4744], BANK[79]
MapSources4F_124:
    INCBIN "roms/magination.gbc", $13C744, $F

SECTION "ROM Bank 079 @$13C753", ROMX[$4753], BANK[79]
MapSources4F_125:
    INCBIN "roms/magination.gbc", $13C753, $F

SECTION "ROM Bank 079 @$13C762", ROMX[$4762], BANK[79]
MapSources4F_126:
    INCBIN "roms/magination.gbc", $13C762, $F

SECTION "ROM Bank 079 @$13C771", ROMX[$4771], BANK[79]
MapSources4F_127:
    INCBIN "roms/magination.gbc", $13C771, $F

SECTION "ROM Bank 079 @$13C780", ROMX[$4780], BANK[79]
MapSources4F_128:
    INCBIN "roms/magination.gbc", $13C780, $F

SECTION "ROM Bank 079 @$13C78F", ROMX[$478F], BANK[79]
MapSources4F_129:
    INCBIN "roms/magination.gbc", $13C78F, $F

SECTION "ROM Bank 079 @$13C79E", ROMX[$479E], BANK[79]
MapSources4F_130:
    INCBIN "roms/magination.gbc", $13C79E, $F

SECTION "ROM Bank 079 @$13C7AD", ROMX[$47AD], BANK[79]
MapSources4F_131:
    INCBIN "roms/magination.gbc", $13C7AD, $F

SECTION "ROM Bank 079 @$13C7BC", ROMX[$47BC], BANK[79]
MapSources4F_132:
    INCBIN "roms/magination.gbc", $13C7BC, $F

SECTION "ROM Bank 079 @$13C7CB", ROMX[$47CB], BANK[79]
MapSources4F_133:
    INCBIN "roms/magination.gbc", $13C7CB, $F

SECTION "ROM Bank 079 @$13C7DA", ROMX[$47DA], BANK[79]
MapSources4F_134:
    INCBIN "roms/magination.gbc", $13C7DA, $F

SECTION "ROM Bank 079 @$13C7E9", ROMX[$47E9], BANK[79]
MapSources4F_135:
    INCBIN "roms/magination.gbc", $13C7E9, $F

SECTION "ROM Bank 079 @$13C7F8", ROMX[$47F8], BANK[79]
MapSources4F_136:
    INCBIN "roms/magination.gbc", $13C7F8, $F

SECTION "ROM Bank 079 @$13C807", ROMX[$4807], BANK[79]
MapSources4F_137:
    INCBIN "roms/magination.gbc", $13C807, $F

SECTION "ROM Bank 079 @$13C816", ROMX[$4816], BANK[79]
MapSources4F_138:
    INCBIN "roms/magination.gbc", $13C816, $F

SECTION "ROM Bank 079 @$13C825", ROMX[$4825], BANK[79]
MapSources4F_139:
    INCBIN "roms/magination.gbc", $13C825, $F

SECTION "ROM Bank 079 @$13C834", ROMX[$4834], BANK[79]
MapSources4F_140:
    INCBIN "roms/magination.gbc", $13C834, $F

SECTION "ROM Bank 079 @$13C843", ROMX[$4843], BANK[79]
MapSources4F_141:
    INCBIN "roms/magination.gbc", $13C843, $F

SECTION "ROM Bank 079 @$13C852", ROMX[$4852], BANK[79]
MapSources4F_142:
    INCBIN "roms/magination.gbc", $13C852, $F

SECTION "ROM Bank 079 @$13C861", ROMX[$4861], BANK[79]
MapSources4F_143:
    INCBIN "roms/magination.gbc", $13C861, $F

SECTION "ROM Bank 079 @$13C870", ROMX[$4870], BANK[79]
MapSources4F_144:
    INCBIN "roms/magination.gbc", $13C870, $F

SECTION "ROM Bank 079 @$13C87F", ROMX[$487F], BANK[79]
MapSources4F_145:
    INCBIN "roms/magination.gbc", $13C87F, $F

SECTION "ROM Bank 079 @$13C88E", ROMX[$488E], BANK[79]
MapSources4F_146:
    INCBIN "roms/magination.gbc", $13C88E, $F

SECTION "ROM Bank 079 @$13C89D", ROMX[$489D], BANK[79]
MapSources4F_147:
    INCBIN "roms/magination.gbc", $13C89D, $F

SECTION "ROM Bank 079 @$13C8AC", ROMX[$48AC], BANK[79]
MapSources4F_148:
    INCBIN "roms/magination.gbc", $13C8AC, $F

SECTION "ROM Bank 079 @$13C8BB", ROMX[$48BB], BANK[79]
MapSources4F_149:
    INCBIN "roms/magination.gbc", $13C8BB, $F

SECTION "ROM Bank 079 @$13C8CA", ROMX[$48CA], BANK[79]
MapSources4F_150:
    INCBIN "roms/magination.gbc", $13C8CA, $F

SECTION "ROM Bank 079 @$13C8D9", ROMX[$48D9], BANK[79]
MapSources4F_151:
    INCBIN "roms/magination.gbc", $13C8D9, $F

SECTION "ROM Bank 079 @$13C8E8", ROMX[$48E8], BANK[79]
MapSources4F_152:
    INCBIN "roms/magination.gbc", $13C8E8, $F

SECTION "ROM Bank 079 @$13C8F7", ROMX[$48F7], BANK[79]
MapSources4F_153:
    INCBIN "roms/magination.gbc", $13C8F7, $F

SECTION "ROM Bank 079 @$13C906", ROMX[$4906], BANK[79]
MapSources4F_154:
    INCBIN "roms/magination.gbc", $13C906, $F

SECTION "ROM Bank 079 @$13C915", ROMX[$4915], BANK[79]
MapSources4F_155:
    INCBIN "roms/magination.gbc", $13C915, $F

SECTION "ROM Bank 079 @$13C924", ROMX[$4924], BANK[79]
MapSources4F_156:
    INCBIN "roms/magination.gbc", $13C924, $F

SECTION "ROM Bank 079 @$13C933", ROMX[$4933], BANK[79]
MapSources4F_157:
    INCBIN "roms/magination.gbc", $13C933, $F

SECTION "ROM Bank 079 @$13C942", ROMX[$4942], BANK[79]
MapSources4F_158:
    INCBIN "roms/magination.gbc", $13C942, $F

SECTION "ROM Bank 079 @$13C951", ROMX[$4951], BANK[79]
MapSources4F_159:
    INCBIN "roms/magination.gbc", $13C951, $F

SECTION "ROM Bank 079 @$13C960", ROMX[$4960], BANK[79]
MapSources4F_160:
    INCBIN "roms/magination.gbc", $13C960, $F

SECTION "ROM Bank 079 @$13C96F", ROMX[$496F], BANK[79]
MapSources4F_161:
    INCBIN "roms/magination.gbc", $13C96F, $F

SECTION "ROM Bank 079 @$13C97E", ROMX[$497E], BANK[79]
MapSources4F_162:
    INCBIN "roms/magination.gbc", $13C97E, $F

SECTION "ROM Bank 079 @$13C98D", ROMX[$498D], BANK[79]
MapSources4F_163:
    INCBIN "roms/magination.gbc", $13C98D, $F

SECTION "ROM Bank 079 @$13C99C", ROMX[$499C], BANK[79]
MapSources4F_164:
    INCBIN "roms/magination.gbc", $13C99C, $F

SECTION "ROM Bank 079 @$13C9AB", ROMX[$49AB], BANK[79]
MapSources4F_165:
    INCBIN "roms/magination.gbc", $13C9AB, $F

SECTION "ROM Bank 079 @$13C9BA", ROMX[$49BA], BANK[79]
MapSources4F_166:
    INCBIN "roms/magination.gbc", $13C9BA, $F

SECTION "ROM Bank 079 @$13C9C9", ROMX[$49C9], BANK[79]
MapSources4F_167:
    INCBIN "roms/magination.gbc", $13C9C9, $F

SECTION "ROM Bank 079 @$13C9D8", ROMX[$49D8], BANK[79]
MapSources4F_168:
    INCBIN "roms/magination.gbc", $13C9D8, $F

SECTION "ROM Bank 079 @$13C9E7", ROMX[$49E7], BANK[79]
MapSources4F_169:
    INCBIN "roms/magination.gbc", $13C9E7, $F

SECTION "ROM Bank 079 @$13C9F6", ROMX[$49F6], BANK[79]
MapSources4F_170:
    INCBIN "roms/magination.gbc", $13C9F6, $F

SECTION "ROM Bank 079 @$13CA05", ROMX[$4A05], BANK[79]
MapSources4F_171:
    INCBIN "roms/magination.gbc", $13CA05, $F

SECTION "ROM Bank 079 @$13CA14", ROMX[$4A14], BANK[79]
MapSources4F_172:
    INCBIN "roms/magination.gbc", $13CA14, $F

SECTION "ROM Bank 079 @$13CA23", ROMX[$4A23], BANK[79]
MapSources4F_173:
    INCBIN "roms/magination.gbc", $13CA23, $F

SECTION "ROM Bank 079 @$13CA32", ROMX[$4A32], BANK[79]
MapSources4F_174:
    INCBIN "roms/magination.gbc", $13CA32, $F

SECTION "ROM Bank 079 @$13CA41", ROMX[$4A41], BANK[79]
MapSources4F_175:
    INCBIN "roms/magination.gbc", $13CA41, $F

SECTION "ROM Bank 079 @$13CA50", ROMX[$4A50], BANK[79]
MapSources4F_176:
    INCBIN "roms/magination.gbc", $13CA50, $F

SECTION "ROM Bank 079 @$13CA5F", ROMX[$4A5F], BANK[79]
MapSources4F_177:
    INCBIN "roms/magination.gbc", $13CA5F, $F

SECTION "ROM Bank 079 @$13CA6E", ROMX[$4A6E], BANK[79]
MapSources4F_178:
    INCBIN "roms/magination.gbc", $13CA6E, $F

SECTION "ROM Bank 079 @$13CA7D", ROMX[$4A7D], BANK[79]
MapSources4F_179:
    INCBIN "roms/magination.gbc", $13CA7D, $F

SECTION "ROM Bank 079 @$13CA8C", ROMX[$4A8C], BANK[79]
MapSources4F_180:
    INCBIN "roms/magination.gbc", $13CA8C, $F

SECTION "ROM Bank 079 @$13CA9B", ROMX[$4A9B], BANK[79]
MapSources4F_181:
    INCBIN "roms/magination.gbc", $13CA9B, $F

SECTION "ROM Bank 079 @$13CAAA", ROMX[$4AAA], BANK[79]
MapSources4F_182:
    INCBIN "roms/magination.gbc", $13CAAA, $F

SECTION "ROM Bank 079 @$13CAB9", ROMX[$4AB9], BANK[79]
MapSources4F_183:
    INCBIN "roms/magination.gbc", $13CAB9, $F

SECTION "ROM Bank 079 @$13CAC8", ROMX[$4AC8], BANK[79]
MapSources4F_184:
    INCBIN "roms/magination.gbc", $13CAC8, $F

SECTION "ROM Bank 079 @$13CAD7", ROMX[$4AD7], BANK[79]
MapSources4F_185:
    INCBIN "roms/magination.gbc", $13CAD7, $F

SECTION "ROM Bank 079 @$13CAE6", ROMX[$4AE6], BANK[79]
MapSources4F_186:
    INCBIN "roms/magination.gbc", $13CAE6, $F

SECTION "ROM Bank 079 @$13CAF5", ROMX[$4AF5], BANK[79]
MapSources4F_187:
    INCBIN "roms/magination.gbc", $13CAF5, $F

SECTION "ROM Bank 079 @$13CB04", ROMX[$4B04], BANK[79]
MapSources4F_188:
    INCBIN "roms/magination.gbc", $13CB04, $F

SECTION "ROM Bank 079 @$13CB13", ROMX[$4B13], BANK[79]
MapSources4F_189:
    INCBIN "roms/magination.gbc", $13CB13, $F

SECTION "ROM Bank 079 @$13CB22", ROMX[$4B22], BANK[79]
MapSources4F_190:
    INCBIN "roms/magination.gbc", $13CB22, $F

SECTION "ROM Bank 079 @$13CB31", ROMX[$4B31], BANK[79]
MapSources4F_191:
    INCBIN "roms/magination.gbc", $13CB31, $F

SECTION "ROM Bank 079 @$13CB40", ROMX[$4B40], BANK[79]
MapSources4F_192:
    INCBIN "roms/magination.gbc", $13CB40, $F

SECTION "ROM Bank 079 @$13CB4F", ROMX[$4B4F], BANK[79]
MapSources4F_193:
    INCBIN "roms/magination.gbc", $13CB4F, $F

SECTION "ROM Bank 079 @$13CB5E", ROMX[$4B5E], BANK[79]
MapSources4F_194:
    INCBIN "roms/magination.gbc", $13CB5E, $F

SECTION "ROM Bank 079 @$13CB6D", ROMX[$4B6D], BANK[79]
MapSources4F_195:
    INCBIN "roms/magination.gbc", $13CB6D, $F

SECTION "ROM Bank 079 @$13CB7C", ROMX[$4B7C], BANK[79]
MapSources4F_196:
    INCBIN "roms/magination.gbc", $13CB7C, $F

SECTION "ROM Bank 079 @$13CB8B", ROMX[$4B8B], BANK[79]
MapSources4F_197:
    INCBIN "roms/magination.gbc", $13CB8B, $F

SECTION "ROM Bank 079 @$13CB9A", ROMX[$4B9A], BANK[79]
MapSources4F_198:
    INCBIN "roms/magination.gbc", $13CB9A, $F

SECTION "ROM Bank 079 @$13CBA9", ROMX[$4BA9], BANK[79]
MapSources4F_199:
    INCBIN "roms/magination.gbc", $13CBA9, $F

SECTION "ROM Bank 079 @$13CBB8", ROMX[$4BB8], BANK[79]
MapSources4F_200:
    INCBIN "roms/magination.gbc", $13CBB8, $F

SECTION "ROM Bank 079 @$13CBC7", ROMX[$4BC7], BANK[79]
MapSources4F_201:
    INCBIN "roms/magination.gbc", $13CBC7, $F

SECTION "ROM Bank 079 @$13CBD6", ROMX[$4BD6], BANK[79]
MapSources4F_202:
    INCBIN "roms/magination.gbc", $13CBD6, $F

SECTION "ROM Bank 079 @$13CBE5", ROMX[$4BE5], BANK[79]
MapSources4F_203:
    INCBIN "roms/magination.gbc", $13CBE5, $F

SECTION "ROM Bank 079 @$13CBF4", ROMX[$4BF4], BANK[79]
MapSources4F_204:
    INCBIN "roms/magination.gbc", $13CBF4, $F

SECTION "ROM Bank 079 @$13CC03", ROMX[$4C03], BANK[79]
MapSources4F_205:
    INCBIN "roms/magination.gbc", $13CC03, $F

SECTION "ROM Bank 079 @$13CC12", ROMX[$4C12], BANK[79]
MapSources4F_206:
    INCBIN "roms/magination.gbc", $13CC12, $F

SECTION "ROM Bank 079 @$13CC21", ROMX[$4C21], BANK[79]
MapSources4F_207:
    INCBIN "roms/magination.gbc", $13CC21, $F

SECTION "ROM Bank 079 @$13CC30", ROMX[$4C30], BANK[79]
MapSources4F_208:
    INCBIN "roms/magination.gbc", $13CC30, $F

SECTION "ROM Bank 079 @$13CC3F", ROMX[$4C3F], BANK[79]
MapSources4F_209:
    INCBIN "roms/magination.gbc", $13CC3F, $F

SECTION "ROM Bank 079 @$13CC4E", ROMX[$4C4E], BANK[79]
MapSources4F_210:
    INCBIN "roms/magination.gbc", $13CC4E, $F

SECTION "ROM Bank 079 @$13CC5D", ROMX[$4C5D], BANK[79]
MapSources4F_211:
    INCBIN "roms/magination.gbc", $13CC5D, $F

SECTION "ROM Bank 079 @$13CC6C", ROMX[$4C6C], BANK[79]
MapSources4F_212:
    INCBIN "roms/magination.gbc", $13CC6C, $F

SECTION "ROM Bank 079 @$13CC7B", ROMX[$4C7B], BANK[79]
MapSources4F_213:
    INCBIN "roms/magination.gbc", $13CC7B, $F

SECTION "ROM Bank 079 @$13CC8A", ROMX[$4C8A], BANK[79]
MapSources4F_214:
    INCBIN "roms/magination.gbc", $13CC8A, $F

SECTION "ROM Bank 079 @$13CC99", ROMX[$4C99], BANK[79]
MapSources4F_215:
    INCBIN "roms/magination.gbc", $13CC99, $F

SECTION "ROM Bank 079 @$13CCA8", ROMX[$4CA8], BANK[79]
MapSources4F_216:
    INCBIN "roms/magination.gbc", $13CCA8, $F

SECTION "ROM Bank 079 @$13CCB7", ROMX[$4CB7], BANK[79]
MapSources4F_217:
    INCBIN "roms/magination.gbc", $13CCB7, $F

SECTION "ROM Bank 079 @$13CCC6", ROMX[$4CC6], BANK[79]
MapSources4F_218:
    INCBIN "roms/magination.gbc", $13CCC6, $F

SECTION "ROM Bank 079 @$13CCD5", ROMX[$4CD5], BANK[79]
MapSources4F_219:
    INCBIN "roms/magination.gbc", $13CCD5, $F

SECTION "ROM Bank 079 @$13CCE4", ROMX[$4CE4], BANK[79]
MapSources4F_220:
    INCBIN "roms/magination.gbc", $13CCE4, $F

SECTION "ROM Bank 079 @$13CCF3", ROMX[$4CF3], BANK[79]
MapSources4F_221:
    INCBIN "roms/magination.gbc", $13CCF3, $F

SECTION "ROM Bank 079 @$13CD02", ROMX[$4D02], BANK[79]
MapSources4F_222:
    INCBIN "roms/magination.gbc", $13CD02, $F

SECTION "ROM Bank 079 @$13CD11", ROMX[$4D11], BANK[79]
MapSources4F_223:
    INCBIN "roms/magination.gbc", $13CD11, $F

SECTION "ROM Bank 079 @$13CD20", ROMX[$4D20], BANK[79]
MapSources4F_224:
    INCBIN "roms/magination.gbc", $13CD20, $F

SECTION "ROM Bank 079 @$13CD2F", ROMX[$4D2F], BANK[79]
MapSources4F_225:
    INCBIN "roms/magination.gbc", $13CD2F, $F

SECTION "ROM Bank 079 @$13CD3E", ROMX[$4D3E], BANK[79]
MapSources4F_226:
    INCBIN "roms/magination.gbc", $13CD3E, $F

SECTION "ROM Bank 079 @$13CD4D", ROMX[$4D4D], BANK[79]
MapSources4F_227:
    INCBIN "roms/magination.gbc", $13CD4D, $F

SECTION "ROM Bank 079 @$13CD5C", ROMX[$4D5C], BANK[79]
MapSources4F_228:
    INCBIN "roms/magination.gbc", $13CD5C, $F

SECTION "ROM Bank 079 @$13CD6B", ROMX[$4D6B], BANK[79]
MapSources4F_229:
    INCBIN "roms/magination.gbc", $13CD6B, $F

SECTION "ROM Bank 079 @$13CD7A", ROMX[$4D7A], BANK[79]
MapSources4F_230:
    INCBIN "roms/magination.gbc", $13CD7A, $F

SECTION "ROM Bank 079 @$13CD89", ROMX[$4D89], BANK[79]
MapSources4F_231:
    INCBIN "roms/magination.gbc", $13CD89, $F

SECTION "ROM Bank 079 @$13CD98", ROMX[$4D98], BANK[79]
MapSources4F_232:
    INCBIN "roms/magination.gbc", $13CD98, $F

SECTION "ROM Bank 079 @$13CDA7", ROMX[$4DA7], BANK[79]
MapSources4F_233:
    INCBIN "roms/magination.gbc", $13CDA7, $F

SECTION "ROM Bank 079 @$13CDB6", ROMX[$4DB6], BANK[79]
MapSources4F_234:
    INCBIN "roms/magination.gbc", $13CDB6, $F

SECTION "ROM Bank 079 @$13CDC5", ROMX[$4DC5], BANK[79]
MapSources4F_235:
    INCBIN "roms/magination.gbc", $13CDC5, $F

SECTION "ROM Bank 079 @$13CDD4", ROMX[$4DD4], BANK[79]
MapSources4F_236:
    INCBIN "roms/magination.gbc", $13CDD4, $F

SECTION "ROM Bank 079 @$13CDE3", ROMX[$4DE3], BANK[79]
MapSources4F_237:
    INCBIN "roms/magination.gbc", $13CDE3, $F

SECTION "ROM Bank 079 @$13CDF2", ROMX[$4DF2], BANK[79]
MapSources4F_238:
    INCBIN "roms/magination.gbc", $13CDF2, $F

SECTION "ROM Bank 079 @$13CE01", ROMX[$4E01], BANK[79]
MapSources4F_239:
    INCBIN "roms/magination.gbc", $13CE01, $F

SECTION "ROM Bank 079 @$13CE10", ROMX[$4E10], BANK[79]
MapSources4F_240:
    INCBIN "roms/magination.gbc", $13CE10, $F

SECTION "ROM Bank 079 @$13CE1F", ROMX[$4E1F], BANK[79]
MapSources4F_241:
    INCBIN "roms/magination.gbc", $13CE1F, $F

SECTION "ROM Bank 079 @$13CE2E", ROMX[$4E2E], BANK[79]
MapSources4F_242:
    INCBIN "roms/magination.gbc", $13CE2E, $F

SECTION "ROM Bank 079 @$13CE3D", ROMX[$4E3D], BANK[79]
MapSources4F_243:
    INCBIN "roms/magination.gbc", $13CE3D, $F

SECTION "ROM Bank 079 @$13CE4C", ROMX[$4E4C], BANK[79]
MapSources4F_244:
    INCBIN "roms/magination.gbc", $13CE4C, $F

SECTION "ROM Bank 079 @$13CE5B", ROMX[$4E5B], BANK[79]
MapSources4F_245:
    INCBIN "roms/magination.gbc", $13CE5B, $F

SECTION "ROM Bank 079 @$13CE6A", ROMX[$4E6A], BANK[79]
MapSources4F_246:
    INCBIN "roms/magination.gbc", $13CE6A, $F

SECTION "ROM Bank 079 @$13CE79", ROMX[$4E79], BANK[79]
MapSources4F_247:
    INCBIN "roms/magination.gbc", $13CE79, $F

SECTION "ROM Bank 079 @$13CE88", ROMX[$4E88], BANK[79]
MapSources4F_248:
    INCBIN "roms/magination.gbc", $13CE88, $F

SECTION "ROM Bank 079 @$13CE97", ROMX[$4E97], BANK[79]
MapSources4F_249:
    INCBIN "roms/magination.gbc", $13CE97, $F

SECTION "ROM Bank 079 @$13CEA6", ROMX[$4EA6], BANK[79]
MapSources4F_250:
    INCBIN "roms/magination.gbc", $13CEA6, $F

SECTION "ROM Bank 079 @$13CEB5", ROMX[$4EB5], BANK[79]
MapSources4F_251:
    INCBIN "roms/magination.gbc", $13CEB5, $F

SECTION "ROM Bank 079 @$13CEC4", ROMX[$4EC4], BANK[79]
MapSources4F_252:
    INCBIN "roms/magination.gbc", $13CEC4, $F

SECTION "ROM Bank 079 @$13CED3", ROMX[$4ED3], BANK[79]
MapSources4F_253:
    INCBIN "roms/magination.gbc", $13CED3, $F

SECTION "ROM Bank 079 @$13CEE2", ROMX[$4EE2], BANK[79]
MapSources4F_254:
    INCBIN "roms/magination.gbc", $13CEE2, $F

SECTION "ROM Bank 079 @$13CEF1", ROMX[$4EF1], BANK[79]
MapSources4F_255:
    INCBIN "roms/magination.gbc", $13CEF1, $F

SECTION "ROM Bank 079 @$13CF00", ROMX[$4F00], BANK[79]
MapSources4F_256:
    INCBIN "roms/magination.gbc", $13CF00, $F

SECTION "ROM Bank 079 @$13CF0F", ROMX[$4F0F], BANK[79]
MapSources4F_257:
    INCBIN "roms/magination.gbc", $13CF0F, $F

SECTION "ROM Bank 079 @$13CF1E", ROMX[$4F1E], BANK[79]
MapSources4F_258:
    INCBIN "roms/magination.gbc", $13CF1E, $F

SECTION "ROM Bank 079 @$13CF2D", ROMX[$4F2D], BANK[79]
MapSources4F_259:
    INCBIN "roms/magination.gbc", $13CF2D, $F

SECTION "ROM Bank 079 @$13CF3C", ROMX[$4F3C], BANK[79]
MapSources4F_260:
    INCBIN "roms/magination.gbc", $13CF3C, $F

SECTION "ROM Bank 079 @$13CF4B", ROMX[$4F4B], BANK[79]
MapSources4F_261:
    INCBIN "roms/magination.gbc", $13CF4B, $F

SECTION "ROM Bank 079 @$13CF5A", ROMX[$4F5A], BANK[79]
MapSources4F_262:
    INCBIN "roms/magination.gbc", $13CF5A, $F

SECTION "ROM Bank 079 @$13CF69", ROMX[$4F69], BANK[79]
MapSources4F_263:
    INCBIN "roms/magination.gbc", $13CF69, $F

SECTION "ROM Bank 079 @$13CF78", ROMX[$4F78], BANK[79]
MapSources4F_264:
    INCBIN "roms/magination.gbc", $13CF78, $F

SECTION "ROM Bank 079 @$13CF87", ROMX[$4F87], BANK[79]
MapSources4F_265:
    INCBIN "roms/magination.gbc", $13CF87, $F

SECTION "ROM Bank 079 @$13CF96", ROMX[$4F96], BANK[79]
MapSources4F_266:
    INCBIN "roms/magination.gbc", $13CF96, $F

SECTION "ROM Bank 079 @$13CFA5", ROMX[$4FA5], BANK[79]
MapSources4F_267:
    INCBIN "roms/magination.gbc", $13CFA5, $F

SECTION "ROM Bank 079 @$13CFB4", ROMX[$4FB4], BANK[79]
MapSources4F_268:
    INCBIN "roms/magination.gbc", $13CFB4, $F

SECTION "ROM Bank 079 @$13CFC3", ROMX[$4FC3], BANK[79]
MapSources4F_269:
    INCBIN "roms/magination.gbc", $13CFC3, $F

SECTION "ROM Bank 079 @$13CFD2", ROMX[$4FD2], BANK[79]
MapSources4F_270:
    INCBIN "roms/magination.gbc", $13CFD2, $F

SECTION "ROM Bank 079 @$13CFE1", ROMX[$4FE1], BANK[79]
MapSources4F_271:
    INCBIN "roms/magination.gbc", $13CFE1, $F

SECTION "ROM Bank 079 @$13CFF0", ROMX[$4FF0], BANK[79]
MapSources4F_272:
    INCBIN "roms/magination.gbc", $13CFF0, $F

SECTION "ROM Bank 079 @$13CFFF", ROMX[$4FFF], BANK[79]
MapSources4F_273:
    INCBIN "roms/magination.gbc", $13CFFF, $F

SECTION "ROM Bank 079 @$13D00E", ROMX[$500E], BANK[79]
MapSources4F_274:
    INCBIN "roms/magination.gbc", $13D00E, $F

SECTION "ROM Bank 079 @$13D01D", ROMX[$501D], BANK[79]
MapSources4F_275:
    INCBIN "roms/magination.gbc", $13D01D, $F

SECTION "ROM Bank 079 @$13D02C", ROMX[$502C], BANK[79]
MapSources4F_276:
    INCBIN "roms/magination.gbc", $13D02C, $F

SECTION "ROM Bank 079 @$13D03B", ROMX[$503B], BANK[79]
MapSources4F_277:
    INCBIN "roms/magination.gbc", $13D03B, $F

SECTION "ROM Bank 079 @$13D04A", ROMX[$504A], BANK[79]
MapSources4F_278:
    INCBIN "roms/magination.gbc", $13D04A, $F

SECTION "ROM Bank 079 @$13D059", ROMX[$5059], BANK[79]
MapSources4F_279:
    INCBIN "roms/magination.gbc", $13D059, $F

SECTION "ROM Bank 079 @$13D068", ROMX[$5068], BANK[79]
MapSources4F_280:
    INCBIN "roms/magination.gbc", $13D068, $F

SECTION "ROM Bank 079 @$13D077", ROMX[$5077], BANK[79]
MapSources4F_281:
    INCBIN "roms/magination.gbc", $13D077, $F

SECTION "ROM Bank 079 @$13D086", ROMX[$5086], BANK[79]
MapSources4F_282:
    INCBIN "roms/magination.gbc", $13D086, $F

SECTION "ROM Bank 079 @$13D095", ROMX[$5095], BANK[79]
MapSources4F_283:
    INCBIN "roms/magination.gbc", $13D095, $F

SECTION "ROM Bank 079 @$13D0A4", ROMX[$50A4], BANK[79]
MapSources4F_284:
    INCBIN "roms/magination.gbc", $13D0A4, $F

SECTION "ROM Bank 079 @$13D0B3", ROMX[$50B3], BANK[79]
MapSources4F_285:
    INCBIN "roms/magination.gbc", $13D0B3, $F

SECTION "ROM Bank 079 @$13D0C2", ROMX[$50C2], BANK[79]
MapSources4F_286:
    INCBIN "roms/magination.gbc", $13D0C2, $F

SECTION "ROM Bank 079 @$13D0D1", ROMX[$50D1], BANK[79]
MapSources4F_287:
    INCBIN "roms/magination.gbc", $13D0D1, $F

SECTION "ROM Bank 079 @$13D0E0", ROMX[$50E0], BANK[79]
MapSources4F_288:
    INCBIN "roms/magination.gbc", $13D0E0, $F

SECTION "ROM Bank 079 @$13D0EF", ROMX[$50EF], BANK[79]
MapSources4F_289:
    INCBIN "roms/magination.gbc", $13D0EF, $F

SECTION "ROM Bank 079 @$13D0FE", ROMX[$50FE], BANK[79]
MapSources4F_290:
    INCBIN "roms/magination.gbc", $13D0FE, $F

SECTION "ROM Bank 079 @$13D10D", ROMX[$510D], BANK[79]
MapSources4F_291:
    INCBIN "roms/magination.gbc", $13D10D, $F

SECTION "ROM Bank 079 @$13D11C", ROMX[$511C], BANK[79]
MapSources4F_292:
    INCBIN "roms/magination.gbc", $13D11C, $F

SECTION "ROM Bank 079 @$13D12B", ROMX[$512B], BANK[79]
MapSources4F_293:
    INCBIN "roms/magination.gbc", $13D12B, $F

SECTION "ROM Bank 079 @$13D13A", ROMX[$513A], BANK[79]
MapSources4F_294:
    INCBIN "roms/magination.gbc", $13D13A, $F

SECTION "ROM Bank 079 @$13D149", ROMX[$5149], BANK[79]
MapSources4F_295:
    INCBIN "roms/magination.gbc", $13D149, $F

SECTION "ROM Bank 079 @$13D158", ROMX[$5158], BANK[79]
MapSources4F_296:
    INCBIN "roms/magination.gbc", $13D158, $F

SECTION "ROM Bank 079 @$13D167", ROMX[$5167], BANK[79]
MapSources4F_297:
    INCBIN "roms/magination.gbc", $13D167, $F

SECTION "ROM Bank 079 @$13D176", ROMX[$5176], BANK[79]
MapSources4F_298:
    INCBIN "roms/magination.gbc", $13D176, $F

SECTION "ROM Bank 079 @$13D185", ROMX[$5185], BANK[79]
MapSources4F_299:
    INCBIN "roms/magination.gbc", $13D185, $F

SECTION "ROM Bank 079 @$13D194", ROMX[$5194], BANK[79]
MapSources4F_300:
    INCBIN "roms/magination.gbc", $13D194, $F

SECTION "ROM Bank 079 @$13D1A3", ROMX[$51A3], BANK[79]
MapSources4F_301:
    INCBIN "roms/magination.gbc", $13D1A3, $F

SECTION "ROM Bank 079 @$13D1B2", ROMX[$51B2], BANK[79]
MapSources4F_302:
    INCBIN "roms/magination.gbc", $13D1B2, $F

SECTION "ROM Bank 079 @$13D1C1", ROMX[$51C1], BANK[79]
MapSources4F_303:
    INCBIN "roms/magination.gbc", $13D1C1, $F

SECTION "ROM Bank 079 @$13D1D0", ROMX[$51D0], BANK[79]
MapSources4F_304:
    INCBIN "roms/magination.gbc", $13D1D0, $F

SECTION "ROM Bank 079 @$13D1DF", ROMX[$51DF], BANK[79]
MapSources4F_305:
    INCBIN "roms/magination.gbc", $13D1DF, $F

SECTION "ROM Bank 079 @$13D1EE", ROMX[$51EE], BANK[79]
MapSources4F_306:
    INCBIN "roms/magination.gbc", $13D1EE, $F

SECTION "ROM Bank 079 @$13D1FD", ROMX[$51FD], BANK[79]
MapSources4F_307:
    INCBIN "roms/magination.gbc", $13D1FD, $F

SECTION "ROM Bank 079 @$13D20C", ROMX[$520C], BANK[79]
MapSources4F_308:
    INCBIN "roms/magination.gbc", $13D20C, $F

SECTION "ROM Bank 079 @$13D21B", ROMX[$521B], BANK[79]
MapSources4F_309:
    INCBIN "roms/magination.gbc", $13D21B, $F

SECTION "ROM Bank 079 @$13D22A", ROMX[$522A], BANK[79]
MapSources4F_310:
    INCBIN "roms/magination.gbc", $13D22A, $F

SECTION "ROM Bank 079 @$13D239", ROMX[$5239], BANK[79]
MapSources4F_311:
    INCBIN "roms/magination.gbc", $13D239, $F

SECTION "ROM Bank 079 @$13D248", ROMX[$5248], BANK[79]
MapSources4F_312:
    INCBIN "roms/magination.gbc", $13D248, $F

SECTION "ROM Bank 079 @$13D257", ROMX[$5257], BANK[79]
MapSources4F_313:
    INCBIN "roms/magination.gbc", $13D257, $F

SECTION "ROM Bank 079 @$13D266", ROMX[$5266], BANK[79]
MapSources4F_314:
    INCBIN "roms/magination.gbc", $13D266, $F

SECTION "ROM Bank 079 @$13D275", ROMX[$5275], BANK[79]
MapSources4F_315:
    INCBIN "roms/magination.gbc", $13D275, $F

SECTION "ROM Bank 079 @$13D284", ROMX[$5284], BANK[79]
MapSources4F_316:
    INCBIN "roms/magination.gbc", $13D284, $F

SECTION "ROM Bank 079 @$13D293", ROMX[$5293], BANK[79]
MapSources4F_317:
    INCBIN "roms/magination.gbc", $13D293, $F

SECTION "ROM Bank 079 @$13D2A2", ROMX[$52A2], BANK[79]
MapSources4F_318:
    INCBIN "roms/magination.gbc", $13D2A2, $F

SECTION "ROM Bank 079 @$13D2B1", ROMX[$52B1], BANK[79]
MapSources4F_319:
    INCBIN "roms/magination.gbc", $13D2B1, $F

SECTION "ROM Bank 079 @$13D2C0", ROMX[$52C0], BANK[79]
MapSources4F_320:
    INCBIN "roms/magination.gbc", $13D2C0, $F

SECTION "ROM Bank 079 @$13D2CF", ROMX[$52CF], BANK[79]
MapSources4F_321:
    INCBIN "roms/magination.gbc", $13D2CF, $F

SECTION "ROM Bank 079 @$13D2DE", ROMX[$52DE], BANK[79]
MapSources4F_322:
    INCBIN "roms/magination.gbc", $13D2DE, $F

SECTION "ROM Bank 079 @$13D2ED", ROMX[$52ED], BANK[79]
MapSources4F_323:
    INCBIN "roms/magination.gbc", $13D2ED, $F

SECTION "ROM Bank 079 @$13D2FC", ROMX[$52FC], BANK[79]
MapSources4F_324:
    INCBIN "roms/magination.gbc", $13D2FC, $F

SECTION "ROM Bank 079 @$13D30B", ROMX[$530B], BANK[79]
MapSources4F_325:
    INCBIN "roms/magination.gbc", $13D30B, $F

SECTION "ROM Bank 079 @$13D31A", ROMX[$531A], BANK[79]
MapSources4F_326:
    INCBIN "roms/magination.gbc", $13D31A, $F

SECTION "ROM Bank 079 @$13D329", ROMX[$5329], BANK[79]
MapSources4F_327:
    INCBIN "roms/magination.gbc", $13D329, $F

SECTION "ROM Bank 079 @$13D338", ROMX[$5338], BANK[79]
MapSources4F_328:
    INCBIN "roms/magination.gbc", $13D338, $F

SECTION "ROM Bank 079 @$13D347", ROMX[$5347], BANK[79]
MapSources4F_329:
    INCBIN "roms/magination.gbc", $13D347, $F

SECTION "ROM Bank 079 @$13D356", ROMX[$5356], BANK[79]
MapSources4F_330:
    INCBIN "roms/magination.gbc", $13D356, $F

SECTION "ROM Bank 079 @$13D365", ROMX[$5365], BANK[79]
MapSources4F_331:
    INCBIN "roms/magination.gbc", $13D365, $F

SECTION "ROM Bank 079 @$13D374", ROMX[$5374], BANK[79]
MapSources4F_332:
    INCBIN "roms/magination.gbc", $13D374, $F

SECTION "ROM Bank 079 @$13D383", ROMX[$5383], BANK[79]
MapSources4F_333:
    INCBIN "roms/magination.gbc", $13D383, $F

SECTION "ROM Bank 079 @$13D392", ROMX[$5392], BANK[79]
MapSources4F_334:
    INCBIN "roms/magination.gbc", $13D392, $F

SECTION "ROM Bank 079 @$13D3A1", ROMX[$53A1], BANK[79]
MapSources4F_335:
    INCBIN "roms/magination.gbc", $13D3A1, $F

SECTION "ROM Bank 079 @$13D3B0", ROMX[$53B0], BANK[79]
MapSources4F_336:
    INCBIN "roms/magination.gbc", $13D3B0, $F

SECTION "ROM Bank 079 @$13D3BF", ROMX[$53BF], BANK[79]
MapSources4F_337:
    INCBIN "roms/magination.gbc", $13D3BF, $F

SECTION "ROM Bank 079 @$13D3CE", ROMX[$53CE], BANK[79]
MapSources4F_338:
    INCBIN "roms/magination.gbc", $13D3CE, $F

SECTION "ROM Bank 079 @$13D3DD", ROMX[$53DD], BANK[79]
MapSources4F_339:
    INCBIN "roms/magination.gbc", $13D3DD, $F

SECTION "ROM Bank 079 @$13D3EC", ROMX[$53EC], BANK[79]
MapSources4F_340:
    INCBIN "roms/magination.gbc", $13D3EC, $F

SECTION "ROM Bank 079 @$13D3FB", ROMX[$53FB], BANK[79]
MapSources4F_341:
    INCBIN "roms/magination.gbc", $13D3FB, $F

SECTION "ROM Bank 079 @$13D40A", ROMX[$540A], BANK[79]
MapSources4F_342:
    INCBIN "roms/magination.gbc", $13D40A, $F

SECTION "ROM Bank 079 @$13D419", ROMX[$5419], BANK[79]
MapSources4F_343:
    INCBIN "roms/magination.gbc", $13D419, $F

SECTION "ROM Bank 079 @$13D428", ROMX[$5428], BANK[79]
MapSources4F_344:
    INCBIN "roms/magination.gbc", $13D428, $F

SECTION "ROM Bank 079 @$13D437", ROMX[$5437], BANK[79]
MapSources4F_345:
    INCBIN "roms/magination.gbc", $13D437, $F

SECTION "ROM Bank 079 @$13D446", ROMX[$5446], BANK[79]
MapSources4F_346:
    INCBIN "roms/magination.gbc", $13D446, $F

SECTION "ROM Bank 079 @$13D455", ROMX[$5455], BANK[79]
MapSources4F_347:
    INCBIN "roms/magination.gbc", $13D455, $F

SECTION "ROM Bank 079 @$13D464", ROMX[$5464], BANK[79]
MapSources4F_348:
    INCBIN "roms/magination.gbc", $13D464, $F

SECTION "ROM Bank 079 @$13D473", ROMX[$5473], BANK[79]
MapSources4F_349:
    INCBIN "roms/magination.gbc", $13D473, $F

SECTION "ROM Bank 079 @$13D482", ROMX[$5482], BANK[79]
MapSources4F_350:
    INCBIN "roms/magination.gbc", $13D482, $F

SECTION "ROM Bank 079 @$13D491", ROMX[$5491], BANK[79]
MapSources4F_351:
    INCBIN "roms/magination.gbc", $13D491, $F

SECTION "ROM Bank 079 @$13D4A0", ROMX[$54A0], BANK[79]
MapSources4F_352:
    INCBIN "roms/magination.gbc", $13D4A0, $F

SECTION "ROM Bank 079 @$13D4AF", ROMX[$54AF], BANK[79]
MapSources4F_353:
    INCBIN "roms/magination.gbc", $13D4AF, $F

SECTION "ROM Bank 079 @$13D4BE", ROMX[$54BE], BANK[79]
MapSources4F_354:
    INCBIN "roms/magination.gbc", $13D4BE, $F

SECTION "ROM Bank 079 @$13D4CD", ROMX[$54CD], BANK[79]
MapSources4F_355:
    INCBIN "roms/magination.gbc", $13D4CD, $F

SECTION "ROM Bank 079 @$13D4DC", ROMX[$54DC], BANK[79]
MapSources4F_356:
    INCBIN "roms/magination.gbc", $13D4DC, $F

SECTION "ROM Bank 079 @$13D4EB", ROMX[$54EB], BANK[79]
MapSources4F_357:
    INCBIN "roms/magination.gbc", $13D4EB, $F

SECTION "ROM Bank 079 @$13D4FA", ROMX[$54FA], BANK[79]
MapSources4F_358:
    INCBIN "roms/magination.gbc", $13D4FA, $F

SECTION "ROM Bank 079 @$13D509", ROMX[$5509], BANK[79]
MapSources4F_359:
    INCBIN "roms/magination.gbc", $13D509, $F

SECTION "ROM Bank 079 @$13D518", ROMX[$5518], BANK[79]
MapSources4F_360:
    INCBIN "roms/magination.gbc", $13D518, $F

SECTION "ROM Bank 079 @$13D527", ROMX[$5527], BANK[79]
MapSources4F_361:
    INCBIN "roms/magination.gbc", $13D527, $F

SECTION "ROM Bank 079 @$13D536", ROMX[$5536], BANK[79]
MapSources4F_362:
    INCBIN "roms/magination.gbc", $13D536, $F

SECTION "ROM Bank 079 @$13D545", ROMX[$5545], BANK[79]
MapSources4F_363:
    INCBIN "roms/magination.gbc", $13D545, $F

SECTION "ROM Bank 079 @$13D554", ROMX[$5554], BANK[79]
MapSources4F_364:
    INCBIN "roms/magination.gbc", $13D554, $F

SECTION "ROM Bank 079 @$13D563", ROMX[$5563], BANK[79]
MapSources4F_365:
    INCBIN "roms/magination.gbc", $13D563, $F

SECTION "ROM Bank 079 @$13D572", ROMX[$5572], BANK[79]
MapSources4F_366:
    INCBIN "roms/magination.gbc", $13D572, $F

SECTION "ROM Bank 079 @$13D581", ROMX[$5581], BANK[79]
MapSources4F_367:
    INCBIN "roms/magination.gbc", $13D581, $F

SECTION "ROM Bank 079 @$13D590", ROMX[$5590], BANK[79]
MapSources4F_368:
    INCBIN "roms/magination.gbc", $13D590, $F

SECTION "bank79_gfx", ROMX[$559F], BANK[79]
; gfx/bank79_gfx.asm: not published here (it assembles data copied from the ROM)
Bank79Gfx:
MapSources4FEnd:
    INCBIN "roms/magination.gbc", $13D59F, $2940

SECTION "Zero padding from $13FEDF", ROMX[$7EDF], BANK[79]
    ds $121, $00 ; zero padding to the end of bank $4F

SECTION "ROM Bank 080", ROMX[$4000], BANK[80]
    INCBIN "roms/magination.gbc", $140000, $2000

SECTION "Bank $50 maps", ROMX[$6000], BANK[80]
; out/gen/tilemaps/bank50_6000.asm: not published here (it assembles data copied from the ROM)
Tilemap_50_6000:
    INCBIN "roms/magination.gbc", $142000, $DEF

SECTION "Bank $50 maps @$142DEF", ROMX[$6DEF], BANK[80]
Tilemap_50_6DEF:
    INCBIN "roms/magination.gbc", $142DEF, $CDA

SECTION "ROM from $143AC9", ROMX[$7AC9], BANK[80]
    INCBIN "roms/magination.gbc", $143AC9, $537

SECTION "ROM Bank 081", ROMX[$4000], BANK[81]
    INCBIN "roms/magination.gbc", $144000, $4000

SECTION "ROM Bank 082", ROMX[$4000], BANK[82]
; out/gen/tilemaps/bank52_4000.asm: not published here (it assembles data copied from the ROM)
Tilemap_52_4000:
    INCBIN "roms/magination.gbc", $148000, $9EA

SECTION "ROM Bank 082 @$1489EA", ROMX[$49EA], BANK[82]
Tilemap_52_49EA:
    INCBIN "roms/magination.gbc", $1489EA, $958

SECTION "ROM Bank 082 @$149342", ROMX[$5342], BANK[82]
Tilemap_52_5342:
    INCBIN "roms/magination.gbc", $149342, $94C

SECTION "bank52_maptiles_5c8e", ROMX[$5C8E], BANK[82]
; gfx/bank52_maptiles_5c8e.asm: not published here (it assembles data copied from the ROM)
Bank52Maptiles5c8e:
    INCBIN "roms/magination.gbc", $149C8E, $900

SECTION "bank52_maptiles_658e", ROMX[$658E], BANK[82]
; gfx/bank52_maptiles_658e.asm: not published here (it assembles data copied from the ROM)
Bank52Maptiles5c8eEnd:
Bank52Maptiles658e:
    INCBIN "roms/magination.gbc", $14A58E, $900

SECTION "bank52_maptiles_6e8e", ROMX[$6E8E], BANK[82]
; gfx/bank52_maptiles_6e8e.asm: not published here (it assembles data copied from the ROM)
Bank52Maptiles658eEnd:
Bank52Maptiles6e8e:
    INCBIN "roms/magination.gbc", $14AE8E, $900

SECTION "ROM from $14B78E", ROMX[$778E], BANK[82]
; out/gen/tilemaps/bank52_778E.asm: not published here (it assembles data copied from the ROM)
Bank52Maptiles6e8eEnd:
Tilemap_52_778E:
    INCBIN "roms/magination.gbc", $14B78E, $832

SECTION "Bank52MapPalettes", ROMX[$7FC0], BANK[82]
; gfx/bank52_palettes.asm: not published here (it assembles data copied from the ROM)
Bank52MapPalettes:
    INCBIN "roms/magination.gbc", $14BFC0, $40

SECTION "bank53_maptiles_4000", ROMX[$4000], BANK[83]
; gfx/bank53_maptiles_4000.asm: not published here (it assembles data copied from the ROM)
Bank53Maptiles4000:
    INCBIN "roms/magination.gbc", $14C000, $900

SECTION "ROM from $14C900", ROMX[$4900], BANK[83]
; out/gen/tilemaps/bank53_4900.asm: not published here (it assembles data copied from the ROM)
Bank53Maptiles4000End:
Tilemap_53_4900:
    INCBIN "roms/magination.gbc", $14C900, $8E1

SECTION "ROM from $14C900 @$14D1E1", ROMX[$51E1], BANK[83]
Tilemap_53_51E1:
    INCBIN "roms/magination.gbc", $14D1E1, $8CD

SECTION "ROM from $14C900 @$14DAAE", ROMX[$5AAE], BANK[83]
Tilemap_53_5AAE:
    INCBIN "roms/magination.gbc", $14DAAE, $8A1

SECTION "ROM from $14C900 @$14E34F", ROMX[$634F], BANK[83]
Tilemap_53_634F:
    INCBIN "roms/magination.gbc", $14E34F, $88B

SECTION "ROM from $14C900 @$14EBDA", ROMX[$6BDA], BANK[83]
Tilemap_53_6BDA:
    INCBIN "roms/magination.gbc", $14EBDA, $803

SECTION "bank53_maptiles_73dd", ROMX[$73DD], BANK[83]
; gfx/bank53_maptiles_73dd.asm: not published here (it assembles data copied from the ROM)
Bank53Maptiles73dd:
    INCBIN "roms/magination.gbc", $14F3DD, $800

SECTION "ROM from $14FBDD", ROMX[$7BDD], BANK[83]
; out/gen/tilemaps/bank53_7BDD.asm: not published here (it assembles data copied from the ROM)
Bank53Maptiles73ddEnd:
Tilemap_53_7BDD:
    INCBIN "roms/magination.gbc", $14FBDD, $423

SECTION "ROM Bank 084", ROMX[$4000], BANK[84]
    INCBIN "roms/magination.gbc", $150000, $4000

SECTION "ROM Bank 085", ROMX[$4000], BANK[85]
    INCBIN "roms/magination.gbc", $154000, $4000

SECTION "ROM Bank 086", ROMX[$4000], BANK[86]
    INCBIN "roms/magination.gbc", $158000, $4000

SECTION "ROM Bank 087", ROMX[$4000], BANK[87]
    INCBIN "roms/magination.gbc", $15C000, $4000

SECTION "ROM Bank 088", ROMX[$4000], BANK[88]
    INCBIN "roms/magination.gbc", $160000, $4000

SECTION "ROM Bank 089", ROMX[$4000], BANK[89]
    INCBIN "roms/magination.gbc", $164000, $4000

SECTION "ROM Bank 090", ROMX[$4000], BANK[90]
    INCBIN "roms/magination.gbc", $168000, $4000

SECTION "ROM Bank 091", ROMX[$4000], BANK[91]
    INCBIN "roms/magination.gbc", $16C000, $4000

SECTION "ROM Bank 092", ROMX[$4000], BANK[92]
    INCBIN "roms/magination.gbc", $170000, $4000

SECTION "ROM Bank 093", ROMX[$4000], BANK[93]
    INCBIN "roms/magination.gbc", $174000, $4000

SECTION "ROM Bank 094", ROMX[$4000], BANK[94]
    INCBIN "roms/magination.gbc", $178000, $4000

SECTION "ROM Bank 095", ROMX[$4000], BANK[95]
    INCBIN "roms/magination.gbc", $17C000, $4000

SECTION "ROM Bank 096", ROMX[$4000], BANK[96]
    INCBIN "roms/magination.gbc", $180000, $3E50

SECTION "Zero padding from $183E50", ROMX[$7E50], BANK[96]
    ds $1B0, $00 ; zero padding to the end of bank $60

SECTION "ROM Bank 097", ROMX[$4000], BANK[97]
    INCBIN "roms/magination.gbc", $184000, $4000

SECTION "ROM Bank 098", ROMX[$4000], BANK[98]
    INCBIN "roms/magination.gbc", $188000, $4000

SECTION "ROM Bank 099", ROMX[$4000], BANK[99]
    INCBIN "roms/magination.gbc", $18C000, $4000

SECTION "ROM Bank 100", ROMX[$4000], BANK[100]
    INCBIN "roms/magination.gbc", $190000, $4000

SECTION "ROM Bank 101", ROMX[$4000], BANK[101]
    INCBIN "roms/magination.gbc", $194000, $4000

SECTION "ROM Bank 102", ROMX[$4000], BANK[102]
    INCBIN "roms/magination.gbc", $198000, $4000

SECTION "ROM Bank 103", ROMX[$4000], BANK[103]
    INCBIN "roms/magination.gbc", $19C000, $4000

SECTION "ROM Bank 104", ROMX[$4000], BANK[104]
    INCBIN "roms/magination.gbc", $1A0000, $4000

SECTION "ROM Bank 105", ROMX[$4000], BANK[105]
    INCBIN "roms/magination.gbc", $1A4000, $4000

SECTION "ROM Bank 106", ROMX[$4000], BANK[106]
    INCBIN "roms/magination.gbc", $1A8000, $4000

SECTION "ROM Bank 107", ROMX[$4000], BANK[107]
    INCBIN "roms/magination.gbc", $1AC000, $4000

SECTION "ROM Bank 108", ROMX[$4000], BANK[108]
    INCBIN "roms/magination.gbc", $1B0000, $4000

SECTION "ROM Bank 109", ROMX[$4000], BANK[109]
    INCBIN "roms/magination.gbc", $1B4000, $4000

SECTION "ROM Bank 110", ROMX[$4000], BANK[110]
    INCBIN "roms/magination.gbc", $1B8000, $4000

SECTION "ROM Bank 111", ROMX[$4000], BANK[111]
    INCBIN "roms/magination.gbc", $1BC000, $4000

SECTION "ROM Bank 112", ROMX[$4000], BANK[112]
    INCBIN "roms/magination.gbc", $1C0000, $4000

SECTION "ROM Bank 113", ROMX[$4000], BANK[113]
    INCBIN "roms/magination.gbc", $1C4000, $4000

SECTION "ROM Bank 114", ROMX[$4000], BANK[114]
    INCBIN "roms/magination.gbc", $1C8000, $4000

SECTION "ROM Bank 115", ROMX[$4000], BANK[115]
    INCBIN "roms/magination.gbc", $1CC000, $4000

SECTION "ROM Bank 116", ROMX[$4000], BANK[116]
    INCBIN "roms/magination.gbc", $1D0000, $4000

SECTION "ROM Bank 117", ROMX[$4000], BANK[117]
    INCBIN "roms/magination.gbc", $1D4000, $4000

SECTION "ROM Bank 118", ROMX[$4000], BANK[118]
    INCBIN "roms/magination.gbc", $1D8000, $4000

SECTION "ROM Bank 119", ROMX[$4000], BANK[119]
    INCBIN "roms/magination.gbc", $1DC000, $4000

SECTION "ROM Bank 120", ROMX[$4000], BANK[120]
    INCBIN "roms/magination.gbc", $1E0000, $4000

SECTION "ROM Bank 121", ROMX[$4000], BANK[121]
    INCBIN "roms/magination.gbc", $1E4000, $4000

SECTION "ROM Bank 122", ROMX[$4000], BANK[122]
    INCBIN "roms/magination.gbc", $1E8000, $4000

SECTION "ROM Bank 123", ROMX[$4000], BANK[123]
    INCBIN "roms/magination.gbc", $1EC000, $4000

SECTION "ROM Bank 124", ROMX[$4000], BANK[124]
    INCBIN "roms/magination.gbc", $1F0000, $3243

SECTION "Zero padding from $1F3243", ROMX[$7243], BANK[124]
    ds $DBD, $00 ; zero padding to the end of bank $7C

SECTION "ROM Bank 125", ROMX[$4000], BANK[125]
    ds $4000, $00 ; zero padding to the end of bank $7D

SECTION "ROM Bank 126", ROMX[$4000], BANK[126]
    ds $4000, $00 ; zero padding to the end of bank $7E

SECTION "ROM Bank 127", ROMX[$4000], BANK[127]
    ds $4000, $00 ; zero padding to the end of bank $7F
