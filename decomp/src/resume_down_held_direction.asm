; Bank 1 at $5C06. ResumeDownBit7Record jumps here when bit 7 of
; $c9a3 is set. A is still that copy of wButtonsHeld. Bit 7 is down,
; bit 5 is left, and bit 4 is right. rROMB0 is left alone.
;
; Left jumps to PlantLeftRecordAndBank. Right jumps to
; PlantRightRecordAndBank. Down alone calls AddCellDirectionStep, calls
; SaveStepThenApplyOrDispatch in bank 5 through CallBankedHL, stages the
; third script from the marked cell, and nudges the camera past the
; follow edge. A zero Y step at $C6D3 calls DispatchCellBelowOnButtonA.
; Either way control jumps to CommitScriptRecord.
;
; wButtonsHeld is the name from read_joypad.asm. $C6D3 is the signed
; vertical step named in nudge_camera_past_follow_edge.asm.

ResumeDownHeldDirection::
    bit 5, a
    jr z, .not_left
    jp PlantLeftRecordAndBank

.not_left:
    bit 4, a
    jr z, .down_only
    jp PlantRightRecordAndBank

.down_only:
    call AddCellDirectionStep
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [$c6d3]
    and a
    call z, DispatchCellBelowOnButtonA
    jp CommitScriptRecord
