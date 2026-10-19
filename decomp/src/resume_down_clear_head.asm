; Bank 1 at $5B6E. PlantDownBit7ClearHead writes this address as the
; record-head word. rROMB0 is left alone. $5B6F is the low byte of
; `call StepCell82EveryFourthFrame`. PlantLeftRecordAndBank stores that
; address as hScriptPtr (low at $FFA2, high at $FFA3). What the script
; engine does with a pointer into this call is still unknown.
;
; StepCell82EveryFourthFrame runs, then ReloadRecordRunScriptPointCell.
; A is the copy of wButtonsHeld at $c9a3. Bit 4 is right, bit 5 is left,
; bit 6 is up, and bit 7 is down.
;
; Right jumps to PlantRightRecordAndBank. Left jumps to
; PlantLeftRecordAndBank. Up jumps to $5D1B, still INCBIN. Down jumps
; to the planter at $5BC8, still INCBIN.
;
; No direction calls AddCellDirectionStep, calls
; SaveStepThenApplyOrDispatch in bank 5 through CallBankedHL, stages
; the third script from the marked cell, and nudges the camera past
; the follow edge. Control then falls into ResumeRightScriptOnA, which
; dispatches on A and jumps to CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. wButtonsHeld is the name from
; read_joypad.asm. CallBankedHL is the name from call_hl_in_bank.asm.

ResumeDownClearHead::
    call StepCell82EveryFourthFrame
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 4, a
    jp nz, PlantRightRecordAndBank
    bit 5, a
    jp nz, PlantLeftRecordAndBank
    bit 6, a
    jp nz, $5d1b
    bit 7, a
    jp nz, $5bc8
    call AddCellDirectionStep
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
