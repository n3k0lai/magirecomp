; Bank 1 at $5666. PlantScriptLowFromA stores this address as the
; record-head word. rROMB0 is left alone.
;
; StepCell82EveryFourthFrame runs first, then
; ReloadRecordRunScriptPointCell. A is the $c9a3 byte, the copy of
; wButtonsHeld FinishFrame writes. Bit 6 is up, bit 5 is left, and
; bit 4 is right, from the high nibble ReadJoypad stores. What bit 1
; means is still unknown.
;
; Up clear plants hScriptPtr with $50AB (3-byte form, low at $FFA2)
; and jumps to PlantDownClearRecordHead. Left while up is held jumps
; to PlantScriptOnLeftWhileDown. Right while up is held jumps to
; PlantScriptOnRightWhileDown. Bit 1 set jumps to $5437, still INCBIN.
; $50AB is still INCBIN in this bank.
;
; Otherwise this calls bank 5 at $682D through CallBankedHL, stages the
; third script from the marked cell, and nudges the camera past the
; follow edge. A nonzero live Y step at wClearedOnRecordLoad + 1
; ($C6D3) calls StepCell82EveryFourthFrame again. A zero step calls
; DispatchCellAboveOnButtonA. Control then jumps to
; CommitScriptAndRecordHead.
;
; hScriptPtr is the name from reset.asm. wButtonsHeld is the name from
; read_joypad.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. CallBankedHL is the name from call_hl_in_bank.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.

; Script planted when up is no longer held. Still INCBIN.
DEF ScriptPtr50AB EQU $50AB

ResumeScriptLowFromARecord::
    call StepCell82EveryFourthFrame
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 6, a
    jr nz, .upHeld
    ld a, LOW(ScriptPtr50AB)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr50AB)
    ld [hScriptPtr + 1], a
    jp PlantDownClearRecordHead

.upHeld:
    bit 5, a
    jr z, .notLeft
    jp PlantScriptOnLeftWhileDown

.notLeft:
    bit 4, a
    jr z, .upOnly
    jp PlantScriptOnRightWhileDown

.upOnly:
    ld a, [$c9a3]
    bit 1, a
    jp nz, $5437
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [wClearedOnRecordLoad + 1]
    and a
    jr z, .yStepZero
    call StepCell82EveryFourthFrame

.yStepZero:
    ld a, [wClearedOnRecordLoad + 1]
    and a
    call z, DispatchCellAboveOnButtonA
    jp CommitScriptAndRecordHead
