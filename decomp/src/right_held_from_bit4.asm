; Bank 1 at $53CC. The instruction just before this address, still
; INCBIN, is `bit 4, a` on the $c9a3 copy of wButtonsHeld. Bit 4 is
; right, from the high nibble ReadJoypad stores. PlantRightRecordHead
; also stores this address as hScriptPtr. rROMB0 is left alone. HL is
; the cell the caller left; this routine does not set it.
;
; Right clear plants hScriptPtr with $5131 (3-byte absolute stores, low
; at $FFA2) and jumps to PlantDownClearRecordHead. $5131 is still
; INCBIN. Right set tests bit 6 (up) and bit 7 (down). Up stores $FF
; at the Y step, wClearedOnRecordLoad + 1. Down stores $01 there.
; Neither leaves that byte alone.
;
; The cell at HL then biases that Y step: $AD adds 2 and $AC subtracts
; 2. Any other cell leaves it. What those two cells are is still
; unknown.
;
; SaveStepThenApplyOrDispatch in bank 5 runs through CallBankedHL, then
; StageThirdScriptFromMarkedCell and NudgeCameraPastFollowEdge. A zero
; X step at wClearedOnRecordLoad calls $4C1D, $522E, and $5743, all
; still INCBIN. A nonzero X step calls StepCell82OnEvenPass. Bit 1 of
; $c9a3 clear jumps to PlantScriptOnRightWhileDown. Bit 1 set jumps to
; CommitScriptAndRecordHead. What bit 1 means is still unknown.
;
; hScriptPtr is the name from reset.asm. wButtonsHeld is the name from
; read_joypad.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. CallBankedHL is the name from call_hl_in_bank.asm.
; PlantDownClearRecordHead is the name from plant_down_clear_record_head.asm.
; PlantScriptOnRightWhileDown is the name from
; plant_script_on_right_while_down.asm. CommitScriptAndRecordHead is
; the EQU in plant_handler_and_head_word.asm.

; Planted as hScriptPtr when right is clear. Still INCBIN.
DEF ScriptPtr5131 EQU $5131

RightHeldFromBit4::
    jr nz, .rightHeld
    ld a, LOW(ScriptPtr5131)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr5131)
    ld [hScriptPtr + 1], a
    jp PlantDownClearRecordHead

.rightHeld:
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
    inc a
    inc a
    ld [wClearedOnRecordLoad + 1], a
    jr .afterBias

.cellAC:
    ld a, [wClearedOnRecordLoad + 1]
    dec a
    dec a
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
    call $4c1d
    call $522e
    call $5743
    jr .buttons

.xStep:
    call StepCell82OnEvenPass

.buttons:
    ld a, [$c9a3]
    bit 1, a
    jp z, PlantScriptOnRightWhileDown
    jp CommitScriptAndRecordHead
