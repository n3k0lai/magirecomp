; Bank 1 at $5F93. ResumePlantedDownRecord jumps here when bit 7 of
; $c9a3 is set. A is still that copy of wButtonsHeld. Bit 7 is down,
; bit 5 is left, and bit 4 is right. rROMB0 is left alone.
;
; Left jumps to $5FC4. Right jumps to $6027. Both planters are still
; INCBIN in this bank.
;
; Down alone stores $01 at $C6D3, the signed vertical step
; NudgeCameraPastFollowEdge reads. It calls $682D in bank 5 through
; CallBankedHL, stages the third script from the marked cell, and
; nudges the camera past the follow edge. A nonzero byte still at
; $C6D3 jumps to CommitScriptAndRecordHead.
;
; A zero byte points HL at the map cell one row down and calls
; PlantBank22ScriptOnZeroByte. That routine commits on its own when
; the cell is $00. Either way control then jumps to
; CommitScriptAndRecordHead.
;
; wButtonsHeld is the name from read_joypad.asm. $c9a3 has no name.
; $C6D3 is the signed vertical step named in
; nudge_camera_past_follow_edge.asm. CallBankedHL is the name from
; call_hl_in_bank.asm. CommitScriptAndRecordHead is the EQU in
; plant_handler_and_head_word.asm.

DownHeldFromPlantedRecord::
    bit 5, a
    jr z, .notLeft
    jp $5fc4

.notLeft:
    bit 4, a
    jr z, .downOnly
    jp $6027

.downOnly:
    ld a, $01
    ld [$c6d3], a
    ld hl, $682d
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [$c6d3]
    and a
    jp nz, CommitScriptAndRecordHead
    call PointAtCellOneRowDown
    call PlantBank22ScriptOnZeroByte
    jp CommitScriptAndRecordHead

DownHeldFromPlantedRecordEnd:
