; Bank 1 at $59C9. ResumeDownHeldRecord jumps here when bit 7 of the
; $c9a3 byte is set. That bit is down on the copy of wButtonsHeld
; written by FinishFrame. A is still that byte. rROMB0 is left alone.
;
; Bit 5 is left and jumps to PlantLeftFromDirectionRecord. Bit 4 is
; right and jumps to PlantRightFromDirectionRecord. Neither stores $01
; at the Y step wClearedOnRecordLoad + 1 ($C6D3). ResumeDownHeldRecord
; also enters at DownHeldApply on an even hMainLoopCounter, so that
; pass leaves the step bytes as they are.
;
; SaveStepThenApplyOrDispatch in bank 5 runs through CallBankedHL.
; StageThirdScriptFromMarkedCell follows. Control then falls into
; RunLeftZeroCellScript.
;
; wButtonsHeld is the name from read_joypad.asm. wClearedOnRecordLoad
; is the name from load_record_head.asm. CallBankedHL is the name from
; call_hl_in_bank.asm. PlantLeftFromDirectionRecord,
; PlantRightFromDirectionRecord, SaveStepThenApplyOrDispatch,
; StageThirdScriptFromMarkedCell, and RunLeftZeroCellScript are already
; source. Nothing here calls or jumps into an INCBIN.

DownHeldLeftOrRight::
    bit 5, a
    jr z, .notLeft
    jp PlantLeftFromDirectionRecord

.notLeft:
    bit 4, a
    jr z, .storeDownStep
    jp PlantRightFromDirectionRecord

.storeDownStep:
    ld a, $01
    ld [wClearedOnRecordLoad + 1], a

DownHeldApply::
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
