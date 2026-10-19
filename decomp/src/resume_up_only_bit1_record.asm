; Bank 1 at $5456. PlantScriptOnUpOnlyBit1 stores this address as the
; record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs first. A is the $c9a3 byte, the
; copy of wButtonsHeld FinishFrame writes. Bit 6 is up, bit 5 is left,
; and bit 4 is right, from the high nibble ReadJoypad stores. What bit 1
; means is still unknown.
;
; Up clear plants hScriptPtr with $50AB (3-byte form, low at $FFA2) and
; jumps to PlantDownClearRecordHead. $50AB is still INCBIN in this bank.
; ScriptPtr50AB is the EQU in resume_script_low_from_a_record.asm.
;
; Left while up is held jumps to PlantScriptOnLeftWhileDownBit1. Right
; while up is held jumps to PlantScriptOnRightWhileDownBit1.
;
; Otherwise this calls bank 5 at $682D through CallBankedHL, stages the
; third script from the marked cell, and nudges the camera past the
; follow edge. A nonzero live Y step at wClearedOnRecordLoad + 1
; ($C6D3) calls StepCell82OnEvenPass. A zero step calls
; DispatchCellAboveOnButtonA, DispatchBit6ZeroStepCellRun, and $575E.
; $575E is still INCBIN. Bit 1 of $c9a3 clear jumps to $5647, still
; INCBIN. Bit 1 set jumps to CommitScriptAndRecordHead.
;
; hScriptPtr is the name from reset.asm. wButtonsHeld is the name from
; read_joypad.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. CallBankedHL is the name from call_hl_in_bank.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.

ResumeUpOnlyBit1Record::
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
    jp nz, PlantScriptOnLeftWhileDownBit1
    bit 4, a
    jp nz, PlantScriptOnRightWhileDownBit1
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [wClearedOnRecordLoad + 1]
    and a
    jr nz, .yStep
    call DispatchCellAboveOnButtonA
    call DispatchBit6ZeroStepCellRun
    call $575e
    jr .buttons

.yStep:
    call StepCell82OnEvenPass

.buttons:
    ld a, [$c9a3]
    bit 1, a
    jp z, $5647
    jp CommitScriptAndRecordHead
