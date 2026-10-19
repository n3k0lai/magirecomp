; Bank 1 at $6046. PlantRightWhileDownRecord writes this address as the
; record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs the script already in the record
; and points HL at the map cell. A then becomes the $c9a3 copy of
; wButtonsHeld that FinishFrame writes. Bit 4 is right, bit 6 is up,
; and bit 7 is down, from the high nibble ReadJoypad stores.
;
; Right clear jumps to PlantHeadWord60FD, which plants head word $60FD.
; Right still held stores a signed pixel step: $01 at wClearedOnRecordLoad
; (one step right) and a Y step at the next byte. Up stores $FF there.
; Down stores $01. Neither leaves Y at $00. Up wins when both are set.
;
; SaveStepThenApplyOrDispatch in bank 5 then runs through CallBankedHL,
; followed by StageThirdScriptFromMarkedCell and
; NudgeCameraPastFollowEdge. A Y step that is still nonzero jumps to
; CommitScriptAndRecordHead. A zero Y step falls into
; FacingRightFromPlantedHead.
;
; wButtonsHeld is the name from read_joypad.asm. $c9a3 has no name.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; CallBankedHL is the name from call_hl_in_bank.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; PlantRightWhileDownRecord is the label in
; plant_right_while_down_record.asm. PlantHeadWord60FD is the label in
; plant_head_word_60fd.asm. FacingRightFromPlantedHead is the label in
; facing_right_from_planted_head.asm.

ResumePlantedRightWhileDown::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 4, a
    jr nz, .rightHeld
    jp PlantHeadWord60FD

.rightHeld:
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
    ld a, $01
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

ResumePlantedRightWhileDownEnd:
