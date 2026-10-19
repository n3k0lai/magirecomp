; Bank 1 at $5CF5. PlantScriptForHead01 stores this address as
; hScriptPtr. rROMB0 is left alone. The bytes just before this address
; are still INCBIN. They leave A as the $c9a3 copy of wButtonsHeld and,
; when bit 6 (up) is set, store $FF at the Y step and fall into the
; `jr` here.
;
; That `jr` is the planted entry, so the script skips the down test and
; runs the shared tail. The bytes under the jump are the bit-6-clear
; path: bit 7 (down) stores $01 at the Y step, wClearedOnRecordLoad + 1.
; Bit 7 clear leaves that byte alone. Both paths meet at the tail.
;
; The tail calls AddCellDirectionStep, then SaveStepThenApplyOrDispatch
; in bank 5 through CallBankedHL, StageThirdScriptFromMarkedCell, and
; NudgeCameraPastFollowEdge. A zero X step at wClearedOnRecordLoad
; calls DispatchCellRightOnButtonA. Control then jumps to
; CommitScriptAndRecordHead.
;
; hScriptPtr is the name from reset.asm. wButtonsHeld is the name from
; read_joypad.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. CallBankedHL is the name from call_hl_in_bank.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; PlantScriptForHead01 is the name from resume_head03_record.asm.

Head01ScriptSkipToStep::
    jr .step
    bit 7, a
    jr z, .step
    ld a, $01
    ld [wClearedOnRecordLoad + 1], a

.step:
    call AddCellDirectionStep
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [wClearedOnRecordLoad]
    and a
    call z, DispatchCellRightOnButtonA
    jp CommitScriptAndRecordHead
