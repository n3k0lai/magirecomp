; Bank 1 at $5D3E. PlantScriptOnOtherLeftCell stores this address as
; hScriptPtr when the cell one column left is neither $00 nor $02.
; The planter at $5D1B, still INCBIN, also writes $5D3E as the
; record-head word. rROMB0 is left alone.
;
; StepCell82EveryFourthFrame runs, then ReloadRecordRunScriptPointCell.
; A is the $c9a3 byte, the copy of wButtonsHeld FinishFrame writes.
; Bit 6 is up, bit 5 is left, and bit 4 is right.
;
; Up clear plants hScriptPtr with $5BBF (3-byte form, low at $FFA2) and
; jumps to PlantHeadAfterDownClear. $5BBF is still INCBIN. Up with left
; jumps to $5C2F, still INCBIN. Up with right jumps to
; PlantRightRecordAndBank.
;
; Otherwise AddCellDirectionStep runs, bank 5 at
; SaveStepThenApplyOrDispatch runs through CallBankedHL, the third
; script is staged, and the camera is nudged past the follow edge. A
; zero Y step at wClearedOnRecordLoad + 1 calls $4C6E, still INCBIN.
; Control then jumps to CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. wButtonsHeld is the name from
; read_joypad.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. StepCell82EveryFourthFrame,
; ReloadRecordRunScriptPointCell, AddCellDirectionStep,
; SaveStepThenApplyOrDispatch, CallBankedHL,
; StageThirdScriptFromMarkedCell, NudgeCameraPastFollowEdge, and
; CommitScriptRecord are already source. PlantHeadAfterDownClear is
; the EQU in resume_down_bit7_record.asm. PlantScriptOnOtherLeftCell
; is the name from plant_script_on_other_left_cell.asm.

; Planted as hScriptPtr when up is clear. Still INCBIN.
DEF ScriptPtr5BBF EQU $5BBF

ResumeOtherLeftCellScript::
    call StepCell82EveryFourthFrame
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 6, a
    jr nz, .upHeld
    ld a, LOW(ScriptPtr5BBF)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr5BBF)
    ld [hScriptPtr + 1], a
    jp PlantHeadAfterDownClear

.upHeld:
    bit 5, a
    jr z, .notLeft
    jp $5c2f

.notLeft:
    bit 4, a
    jr z, .noSide
    jp PlantRightRecordAndBank

.noSide:
    call AddCellDirectionStep
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [wClearedOnRecordLoad + 1]
    and a
    call z, $4c6e
    jp CommitScriptRecord
