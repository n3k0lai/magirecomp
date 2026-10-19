; Bank 1 at $5332. PlantScriptOnLeftWhileDownBit1 stores this address
; as the record-head word. rROMB0 is left alone. HL is the cell the
; caller left; this routine does not set it.
;
; ReloadRecordRunScriptPointCell runs first. A is the $c9a3 byte, the
; copy of wButtonsHeld FinishFrame writes. Bit 5 is left, bit 6 is up,
; and bit 7 is down, from the high nibble ReadJoypad stores. What bit 1
; means is still unknown.
;
; Left clear plants hScriptPtr with $50FB (3-byte absolute stores, low
; at $FFA2) and jumps to PlantDownClearRecordHead. $50FB is still
; INCBIN in this bank. ScriptPtr50FB is the EQU in
; resume_left_while_down_record.asm.
;
; Left held tests bit 6 (up) and bit 7 (down). Up stores $FF at the Y
; step, wClearedOnRecordLoad + 1. Down stores $01 there. Neither leaves
; that byte alone.
;
; The cell at HL then biases that Y step: $AC adds 2 and $AD subtracts
; 2. Any other cell leaves it. What those two cells are is still
; unknown.
;
; SaveStepThenApplyOrDispatch in bank 5 runs through CallBankedHL, then
; StageThirdScriptFromMarkedCell and NudgeCameraPastFollowEdge. A zero
; X step at wClearedOnRecordLoad calls DispatchCellLeftOnButtonA,
; $51F2, and $5728. $51F2 and $5728 are still INCBIN. A nonzero X step
; calls StepCell82OnEvenPass. Bit 1 of $c9a3 clear jumps to
; PlantScriptOnLeftWhileDown. Bit 1 set jumps to
; CommitScriptAndRecordHead.
;
; hScriptPtr is the name from reset.asm. wButtonsHeld is the name from
; read_joypad.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. CallBankedHL is the name from call_hl_in_bank.asm.
; ReloadRecordRunScriptPointCell is the name from
; reload_record_run_script_point_cell.asm. PlantDownClearRecordHead is
; the name from plant_down_clear_record_head.asm.
; PlantScriptOnLeftWhileDown is the name from
; plant_script_on_left_while_down.asm. CommitScriptAndRecordHead is
; the EQU in plant_handler_and_head_word.asm.

ResumeLeftWhileDownBit1Record::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 5, a
    jr nz, .leftHeld
    ld a, LOW(ScriptPtr50FB)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr50FB)
    ld [hScriptPtr + 1], a
    jp PlantDownClearRecordHead

.leftHeld:
    bit 6, a
    jr z, .notUp
    ld a, $ff
    ld [wClearedOnRecordLoad + 1], a
    jr .cellBias

.notUp:
    bit 7, a
    jr z, .cellBias
    ld a, $01
    ld [wClearedOnRecordLoad + 1], a

.cellBias:
    ld a, [hl]
    cp $ac
    jr z, .cellAC
    cp $ad
    jr nz, .afterBias
    ld a, [wClearedOnRecordLoad + 1]
    dec a
    dec a
    ld [wClearedOnRecordLoad + 1], a
    jr .afterBias

.cellAC:
    ld a, [wClearedOnRecordLoad + 1]
    inc a
    inc a
    ld [wClearedOnRecordLoad + 1], a

.afterBias:
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [wClearedOnRecordLoad]
    and a
    jr nz, .xStep
    call DispatchCellLeftOnButtonA
    call $51f2
    call $5728
    jr .buttons

.xStep:
    call StepCell82OnEvenPass

.buttons:
    ld a, [$c9a3]
    bit 1, a
    jp z, PlantScriptOnLeftWhileDown
    jp CommitScriptAndRecordHead
