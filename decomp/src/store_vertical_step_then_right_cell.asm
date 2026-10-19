; Bank 1 at $62D2. The previous byte, still INCBIN, is `bit 6, a`.
; A is the $c9a3 copy of wButtonsHeld. Bit 6 is up and bit 7 is down.
; rROMB0 is left alone.
;
; Up held stores $FF at the Y step, wClearedOnRecordLoad + 1. Up clear
; tests down and stores $01 when that bit is set. Neither leaves the
; Y step as it was.
;
; SaveStepThenApplyOrDispatch in bank 5 runs through CallBankedHL, then
; StageThirdScriptFromMarkedCell and NudgeCameraPastFollowEdge. A zero
; X step at wClearedOnRecordLoad calls DispatchCellRightOnButtonA.
; Control then jumps to CommitScriptRecord.
;
; wButtonsHeld is the name from read_joypad.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; CallBankedHL is the name from call_hl_in_bank.asm.

StoreVerticalStepThenRightCell::
    jr z, .notUp
    ld a, $ff
    ld [wClearedOnRecordLoad + 1], a
    jr .apply

.notUp:
    bit 7, a
    jr z, .apply
    ld a, $01
    ld [wClearedOnRecordLoad + 1], a

.apply:
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [wClearedOnRecordLoad]
    and a
    call z, DispatchCellRightOnButtonA
    jp CommitScriptRecord

StoreVerticalStepThenRightCellEnd:
