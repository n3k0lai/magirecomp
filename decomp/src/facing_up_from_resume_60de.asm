; Bank 1 at $60DE. ResumePlantedHead60FD jumps here when no direction
; bit of the $c9a3 copy of wButtonsHeld is set and the low two bits of
; hRecordHead are $00 (facing up). The block at $60A9 also falls in
; when its $C6D3 step byte is zero. rROMB0 is left alone.
;
; PointAtCellOneRowUp leaves HL on the map cell one row up.
; PlantBank22ScriptOnZeroByte commits on its own when bit 0 of $C932
; is set and that cell byte is $00. Either way control then jumps to
; CommitScriptAndRecordHead.
;
; PointAtCellOneRowUp is the label in point_at_cell_one_row_up.asm.
; PlantBank22ScriptOnZeroByte is the label in
; plant_bank22_script_on_zero_byte.asm. CommitScriptAndRecordHead is
; the EQU in plant_handler_and_head_word.asm. hRecordHead is the name
; from write_record_head.asm. wButtonsHeld is the name from
; read_joypad.asm. ResumePlantedHead60FD is the label in
; resume_planted_head_60fd.asm. $C6D3 is the signed vertical step
; named in nudge_camera_past_follow_edge.asm.

FacingUpFromResume60DE::
    call PointAtCellOneRowUp
    call PlantBank22ScriptOnZeroByte
    jp CommitScriptAndRecordHead

FacingUpFromResume60DEEnd:
