; Bank 1 at $510B. PlantBit6PastTwoCellRunScript and
; PlantScriptOnUpPressed write this address as the record-head word.
; rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $00. ReloadRecordRunScriptPointCell runs
; next. ClearC12CAndSetC12A then clears $C12C and stores $FF at $C12A.
;
; A is the pressed-button copy FinishFrame writes to $C9A4 from
; wButtonsPressed. Bit 7 is down, bit 4 is right, and bit 5 is left.
; Those jumps go to PlantScriptOnDownPressed, PlantRightPressedHead01Script,
; and $4F9C. $4F9C is still INCBIN. Up (bit 6) and no direction fall
; through.
;
; AddCellDirectionStep folds the map cell into the step bytes. A zero
; live Y step at wClearedOnRecordLoad + 1 jumps to CommitScriptRecord.
; Otherwise bank 5 at SaveStepThenApplyOrDispatch runs through
; CallBankedHL, the third script is staged from the marked cell, and
; the camera is nudged past the follow edge. A zero copy of the Y step
; at $C6D1, or a still-nonzero live Y step, takes the same commit exit.
; $C6D1 is the Y step copied by SaveStepThenApplyOrDispatch.
;
; PointAtCellOneRowUp points HL at the cell one row up and selects WRAM
; bank 5. Cell $02 commits. Any other cell other than $00 plants
; hScriptHandler with INITIAL_SCRIPT_HANDLER ($0A66) and hScriptPtr with
; $5C48, then jumps to CommitScriptRecord. $5C48 is still INCBIN. Cell
; $00 calls ClearC12AAndSetC12C, plants hScriptPtr with $5A5B (low at
; $FFA2), and jumps to PlantHandlerAndHeadWord. $5A5B is still INCBIN.
;
; hRecordHead is the name from write_record_head.asm. hScriptPtr,
; hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names from
; reset.asm. wClearedOnRecordLoad is the name from load_record_head.asm.
; The button bits are the names from read_joypad.asm. CallBankedHL is
; the name from call_hl_in_bank.asm. ScriptPtr5A5B is the name from
; resume_up_idle_record.asm.

; Planted as hScriptPtr when the cell one row up is neither $00 nor $02.
; Still INCBIN.
DEF ScriptPtr5C48 EQU $5C48

ResumeHead00Record::
    ld a, $00
    ldh [hRecordHead], a
    call ReloadRecordRunScriptPointCell
    call ClearC12CAndSetC12A
    ld a, [$c9a4]
    bit 7, a
    jp nz, PlantScriptOnDownPressed
    bit 4, a
    jp nz, PlantRightPressedHead01Script
    bit 5, a
    jp nz, $4f9c
    call AddCellDirectionStep
    ld a, [wClearedOnRecordLoad + 1]
    and a
    jp z, CommitScriptRecord
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [$c6d1]
    and a
    jp z, CommitScriptRecord
    ld a, [wClearedOnRecordLoad + 1]
    and a
    jp nz, CommitScriptRecord
    call PointAtCellOneRowUp
    ld a, [hl]
    cp $02
    jp z, CommitScriptRecord
    cp $00
    jp nz, .otherCell
    call ClearC12AAndSetC12C
    ld a, LOW(ScriptPtr5A5B)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5A5B)
    ldh [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord

.otherCell:
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr5C48)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5C48)
    ldh [hScriptPtr + 1], a
    jp CommitScriptRecord
