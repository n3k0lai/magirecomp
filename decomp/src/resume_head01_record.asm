; Bank 1 at $4FB7. The routine at $4F7E plants this address as the
; record-head word. rROMB0 is left alone. $4FCD, planted as hScriptPtr
; by PlantScriptOnYStepBit1Clear, is the high byte of `jp nz, $50F0`
; below (bit 6 of the pressed-button copy).
;
; hRecordHead ($FF8C) becomes $01. $5DE1, still INCBIN, runs next.
; $4ECB, still INCBIN, clears $C12C and stores $FF at $C12A.
;
; A is the pressed-button copy FinishFrame writes to $C9A4 from
; wButtonsPressed. Bit 4 is right, bit 6 is up, and bit 7 is down.
; Those three jumps go to $5046, $50F0, and $4EF2, all still INCBIN.
; Left (bit 5) and no direction fall through.
;
; AddCellDirectionStep folds the map cell into the step bytes. A zero
; X step at wClearedOnRecordLoad jumps to CommitScriptRecord. Otherwise
; bank 5 at $682D runs through CallBankedHL, the third script is staged
; from the marked cell, and the camera is nudged past the follow edge.
; A zero copy of that X step at $C6D0, or a still-nonzero live X step,
; takes the same commit exit.
;
; $4CDD, still INCBIN, points HL at the cell one column left (X minus
; one, map pointer minus one) and selects WRAM bank 5. Cell $02 commits.
; Any cell other than $00 jumps to $5015, still INCBIN. Cell $00 calls
; $4EC2, still INCBIN, which clears $C12A and stores $FF at $C12C.
; hScriptPtr becomes $59E7 (low at $FFA2, the 2-byte form) and control
; jumps to PlantHandlerAndHeadWord. $59E7 is still INCBIN.
;
; hRecordHead is the name from write_record_head.asm. hScriptPtr is the
; name from reset.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. The button bits are the names from
; read_joypad.asm. CallBankedHL, AddCellDirectionStep,
; SaveStepThenApplyOrDispatch, StageThirdScriptFromMarkedCell, and
; NudgeCameraPastFollowEdge are already source.

; Planted as hScriptPtr when the cell one column left is $00.
DEF LeftCellScript EQU $59E7

ResumeHead01Record::
    ld a, $01
    ldh [hRecordHead], a
    call $5de1
    call $4ecb
    ld a, [$c9a4]
    bit 4, a
    jp nz, $5046
    bit 6, a
    jp nz, $50f0
    bit 7, a
    jp nz, $4ef2
    call AddCellDirectionStep
    ld a, [wClearedOnRecordLoad]
    and a
    jp z, CommitScriptRecord
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [$c6d0]
    and a
    jp z, CommitScriptRecord
    ld a, [wClearedOnRecordLoad]
    and a
    jp nz, CommitScriptRecord
    call $4cdd
    ld a, [hl]
    cp $02
    jp z, CommitScriptRecord
    cp $00
    jp nz, $5015
    call $4ec2
    ld a, LOW(LeftCellScript)
    ldh [hScriptPtr], a
    ld a, HIGH(LeftCellScript)
    ldh [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
