; Bank 1 at $54C3. PlantScriptOnYStepBit1Clear stores this address as
; the record-head word. rROMB0 is left alone.
;
; StepCell82EveryFourthFrame runs first, then $5DE1, still INCBIN. A is
; the $c9a3 byte, the copy of wButtonsHeld FinishFrame writes. Bit 7 is
; down, bit 5 is left, and bit 4 is right, from the high nibble
; ReadJoypad stores. What bit 1 means is still unknown.
;
; Down clear plants hScriptPtr with $50B5 (3-byte form, low at $FFA2)
; and jumps to $5DFD. Left while down is held jumps to $5515. Right
; while down is held jumps to $55AE. Bit 1 set jumps to $52A6. Those
; four addresses are still INCBIN. $50B5 is still INCBIN in this bank.
;
; Otherwise this calls bank 5 at $682D through CallBankedHL, stages the
; third script from the marked cell, and nudges the camera past the
; follow edge. A nonzero live Y step at wClearedOnRecordLoad + 1
; ($C6D3) calls StepCell82EveryFourthFrame again. A zero step calls
; DispatchCellBelowOnButtonA. Control then jumps to
; CommitScriptAndRecordHead.
;
; hScriptPtr is the name from reset.asm. wButtonsHeld is the name from
; read_joypad.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. CallBankedHL is the name from call_hl_in_bank.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.

; Script planted when down is no longer held. Still INCBIN.
DEF ScriptPtr50B5 EQU $50B5

ResumeYStepBit1ClearRecord::
    call StepCell82EveryFourthFrame
    call $5de1
    ld a, [$c9a3]
    bit 7, a
    jp nz, .downHeld
    ld a, LOW(ScriptPtr50B5)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr50B5)
    ld [hScriptPtr + 1], a
    jp $5dfd

.downHeld:
    bit 5, a
    jr z, .notLeft
    jp $5515

.notLeft:
    bit 4, a
    jr z, .downOnly
    jp $55ae

.downOnly:
    ld a, [$c9a3]
    bit 1, a
    jp nz, $52a6
    ld hl, $682d
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
    call z, DispatchCellBelowOnButtonA
    jp CommitScriptAndRecordHead
