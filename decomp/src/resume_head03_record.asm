; Bank 1 at $4F0D. PlantScriptOnDownPressed and PlantPastTwoCellRunScript
; write this address as the record-head word. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $03. ReloadRecordRunScriptPointCell runs
; the script already in the record, then ClearC12CAndSetC12A stores $FF
; at $C12A and $00 at $C12C.
;
; A is the pressed-button copy FinishFrame writes to $C9A4 from
; wButtonsPressed. Bit 6 is up, bit 5 is left, and bit 4 is right.
; Up jumps to $50F0 and right jumps to $5046, both still INCBIN. Left
; jumps to PlantLeftIntoHead01 below. Down and no direction fall through.
;
; AddCellDirectionStep folds the map cell into the step bytes. A zero
; Y step at wClearedOnRecordLoad + 1 jumps to CommitScriptRecord.
; Otherwise bank 5 at $682D runs through CallBankedHL, the third script
; is staged from the marked cell, and the camera is nudged past the
; follow edge. A zero copy of that Y step at $C6D1, or a still-nonzero
; live Y step, takes the same commit exit.
;
; PointAtCellOneRowDown points HL at the cell one row down (Y plus one,
; map pointer plus one row) and selects WRAM bank 5. Cell $02 commits.
; Any other cell except $00 plants hScriptHandler with
; INITIAL_SCRIPT_HANDLER and hScriptPtr with $5CC3 (3-byte form, low at
; $FFA2), then commits. $5CC3 is still INCBIN. Cell $00 calls
; ClearC12AAndSetC12C, plants hScriptPtr with $5A9A, and jumps to
; PlantHandlerAndHeadWord. $5A9A is still INCBIN.
;
; PlantScriptForHead01 does not fall in from the cell path. That entry
; plants the same handler, hScriptPtr $5CF5, and the record-head word
; ResumeHead01Record ($4FB7), then commits. What reaches $4F7E is still
; unknown. $5CF5 is still INCBIN.
;
; $4F99 calls ReloadRecordRunScriptPointCell and falls into
; PlantLeftIntoHead01. What jumps to $4F99 is still unknown.
; PlantLeftIntoHead01 is the bit-5 path, also taken from $5124. It
; plants the same handler, hScriptPtr $5D2E, and the head-01 word,
; then commits. $5D2E is still INCBIN.
;
; hRecordHead is the name from write_record_head.asm. hScriptPtr,
; hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names from
; reset.asm. wClearedOnRecordLoad is the name from load_record_head.asm.
; The button bits are the names from read_joypad.asm. CommitScriptRecord
; is the label in commit_script_and_record_head.asm.

; Planted as hScriptPtr when the cell one row down is $00. Same address
; as ScriptPtr5A9A in resume_down_record_head.asm. Still INCBIN.
DEF Head03ZeroCellScript EQU $5A9A

; Planted as hScriptPtr when that cell is neither $00 nor $02.
DEF ScriptPtr5CC3 EQU $5CC3

; Planted as hScriptPtr by the entry at $4F7E. Still INCBIN.
DEF ScriptPtr5CF5 EQU $5CF5

; Planted as hScriptPtr when left is pressed. Still INCBIN.
DEF ScriptPtr5D2E EQU $5D2E

ResumeHead03Record::
    ld a, $03
    ldh [hRecordHead], a
    call ReloadRecordRunScriptPointCell
    call ClearC12CAndSetC12A
    ld a, [$c9a4]
    bit 6, a
    jp nz, $50f0
    bit 5, a
    jp nz, PlantLeftIntoHead01
    bit 4, a
    jp nz, $5046
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
    call PointAtCellOneRowDown
    ld a, [hl]
    cp $02
    jp z, CommitScriptRecord
    cp $00
    jp nz, PlantHead03OtherCellScript
    call ClearC12AAndSetC12C
    ld a, LOW(Head03ZeroCellScript)
    ldh [hScriptPtr], a
    ld a, HIGH(Head03ZeroCellScript)
    ldh [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord

PlantHead03OtherCellScript:
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr5CC3)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5CC3)
    ldh [hScriptPtr + 1], a
    jp CommitScriptRecord

PlantScriptForHead01::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr5CF5)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5CF5)
    ldh [hScriptPtr + 1], a
    ld a, LOW(ResumeHead01Record)
    ldh [hRecordHead + 1], a
    ld a, HIGH(ResumeHead01Record)
    ldh [hRecordHead + 2], a
    jp CommitScriptRecord

ReloadThenPlantLeftIntoHead01::
    call ReloadRecordRunScriptPointCell

PlantLeftIntoHead01::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr5D2E)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5D2E)
    ldh [hScriptPtr + 1], a
    ld a, LOW(ResumeHead01Record)
    ldh [hRecordHead + 1], a
    ld a, HIGH(ResumeHead01Record)
    ldh [hRecordHead + 2], a
    jp CommitScriptRecord
