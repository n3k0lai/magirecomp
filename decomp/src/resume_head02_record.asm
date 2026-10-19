; Bank 1 at $5061. PlantRightPressedHead01Script and
; PlantRightPastTwoCellRunScript write this address as the record-head
; word. rROMB0 is left alone. $5077, planted as hScriptPtr by
; PlantScriptOnLeftWhileDownBit1, is the high byte of
; `jp nz, PlantScriptOnDownPressed` below. Entered there, the first
; byte is `ld c, [hl]`, then the up test that follows.
;
; hRecordHead ($FF8C) becomes $02. ReloadRecordRunScriptPointCell runs
; the script already in the record, then ClearC12CAndSetC12A stores $FF
; at $C12A and $00 at $C12C.
;
; A is the pressed-button copy FinishFrame writes to $C9A4 from
; wButtonsPressed. Bit 5 is left, bit 7 is down, and bit 6 is up.
; Left jumps to PlantLeftIntoHead01, down to PlantScriptOnDownPressed,
; and up to PlantScriptOnUpPressed. Right and no direction fall through.
;
; AddCellDirectionStep folds the map cell into the step bytes. A zero
; X step at wClearedOnRecordLoad jumps to CommitScriptRecord. Otherwise
; bank 5 at SaveStepThenApplyOrDispatch runs through CallBankedHL, the
; third script is staged from the marked cell, and the camera is nudged
; past the follow edge. A zero copy of that X step at $C6D0, or a
; still-nonzero live X step, takes the same commit exit.
;
; PointAtCellOneColumnRight points HL at the cell one column right and
; selects WRAM bank 5. Cell $02 commits. Any cell other than $00 jumps
; to $50BF, still INCBIN. Cell $00 calls ClearC12AAndSetC12C, plants
; hScriptPtr with $5A21 (low at $FFA2, the 2-byte form), and jumps to
; PlantHandlerAndHeadWord. $5A21 is the same address RightCellScript
; names from the right record head.
;
; hRecordHead is the name from write_record_head.asm. hScriptPtr is the
; name from reset.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. The button bits are the names from
; read_joypad.asm. CallBankedHL is the name from call_hl_in_bank.asm.

; Planted as hScriptPtr when the cell one column right is $00.
; Same address as RightCellScript. Still INCBIN.
DEF Head02ZeroCellScript EQU $5A21

ResumeHead02Record::
    ld a, $02
    ldh [hRecordHead], a
    call ReloadRecordRunScriptPointCell
    call ClearC12CAndSetC12A
    ld a, [$c9a4]
    bit 5, a
    jp nz, PlantLeftIntoHead01
    bit 7, a
    jp nz, PlantScriptOnDownPressed
    bit 6, a
    jp nz, PlantScriptOnUpPressed
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
    call PointAtCellOneColumnRight
    ld a, [hl]
    cp $02
    jp z, CommitScriptRecord
    cp $00
    jp nz, $50bf
    call ClearC12AAndSetC12C
    ld a, LOW(Head02ZeroCellScript)
    ldh [hScriptPtr], a
    ld a, HIGH(Head02ZeroCellScript)
    ldh [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
