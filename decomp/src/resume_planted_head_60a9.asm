; Bank 1 at $60A9. PlantUpFromPlantedHead writes this address as the
; record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs the script already in the record
; and points HL at the map cell. A then becomes the $c9a3 copy of
; wButtonsHeld that FinishFrame writes. Bit 4 is right, bit 5 is left,
; and bit 6 is up.
;
; Up clear jumps to PlantHeadWord60FD. Left jumps to
; PlantLeftWhileDownRecord. Right jumps to PlantRightWhileDownRecord.
;
; Up alone stores $FF, a one-pixel step up, at wClearedOnRecordLoad + 1
; ($C6D3). Bank 5 at $682D (SaveStepThenApplyOrDispatch) runs through
; CallBankedHL, then StageThirdScriptFromMarkedCell and
; NudgeCameraPastFollowEdge. A nonzero byte at $C6D3 jumps to
; CommitScriptAndRecordHead. A zero byte falls into
; FacingUpFromResume60DE.
;
; wButtonsHeld is the name from read_joypad.asm. $c9a3 has no name.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; PlantUpFromPlantedHead is the label in plant_up_from_planted_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.

ResumePlantedHead60A9::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 6, a
    jr nz, .upHeld
    jp PlantHeadWord60FD

.upHeld:
    bit 5, a
    jr z, .notLeft
    jp PlantLeftWhileDownRecord

.notLeft:
    bit 4, a
    jr z, .upOnly
    jp PlantRightWhileDownRecord

.upOnly:
    ld a, $ff
    ld [wClearedOnRecordLoad + 1], a
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [wClearedOnRecordLoad + 1]
    and a
    jp nz, CommitScriptAndRecordHead

ResumePlantedHead60A9End:
