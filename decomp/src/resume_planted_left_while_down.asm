; Bank 1 at $5FE3. PlantLeftWhileDownRecord writes this address as the
; record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs the script already in the record
; and points HL at the map cell. A then becomes the $c9a3 copy of
; wButtonsHeld that FinishFrame writes. Bit 5 is left, bit 6 is up, and
; bit 7 is down.
;
; Left clear jumps to PlantHeadWord60FD. Left held stores $FF at
; wClearedOnRecordLoad, the signed X step one column left. Up stores
; $FF at the Y step, down stores $01, and neither stores $00.
;
; SaveStepThenApplyOrDispatch in bank 5 runs through CallBankedHL, then
; StageThirdScriptFromMarkedCell and NudgeCameraPastFollowEdge. A
; nonzero Y step jumps to CommitScriptAndRecordHead. A zero Y step
; falls into FacingLeftFromPlantedHead.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; wButtonsHeld is the name from read_joypad.asm. $c9a3 has no name.
; CallBankedHL is the name from call_hl_in_bank.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; PlantLeftWhileDownRecord is the label in plant_left_while_down_record.asm.
; PlantHeadWord60FD is the label in plant_head_word_60fd.asm.
; FacingLeftFromPlantedHead is the label in facing_left_from_planted_head.asm.

ResumePlantedLeftWhileDown::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 5, a
    jr nz, .leftHeld
    jp PlantHeadWord60FD

.leftHeld:
    ld e, $00
    bit 6, a
    jr z, .notUp
    ld e, $ff
    jr .storeStep

.notUp:
    bit 7, a
    jr z, .storeStep
    ld e, $01

.storeStep:
    ld a, $ff
    ld [wClearedOnRecordLoad], a
    ld a, e
    ld [wClearedOnRecordLoad + 1], a
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [wClearedOnRecordLoad + 1]
    and a
    jp nz, CommitScriptAndRecordHead

ResumePlantedLeftWhileDownEnd:
