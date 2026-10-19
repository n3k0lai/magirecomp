; Bank 1 at $601E. ResumePlantedHead60FD jumps here when no direction
; is held and the low two bits of hRecordHead are $01 (facing left).
; The still-INCBIN code at $5FE3 also falls in here when the byte at
; $C6D3 is zero. rROMB0 is left alone.
;
; PointAtCellOneColumnLeft points HL at the map cell one column left
; and selects WRAM bank 5. PlantBank22ScriptOnZeroByte returns unless
; bit 0 of $C932 is set and that cell is $00. On a hit it plants bank
; $22, script $40AD, and record-head word $6405, pops this return, and
; jumps to CommitScriptRecord itself. Either way this tail then jumps
; to CommitScriptAndRecordHead at $5D9B, which copies the seven HRAM
; script bytes and writes the record head.
;
; PointAtCellOneColumnLeft is the label in
; point_at_cell_one_column_left.asm. PlantBank22ScriptOnZeroByte is
; the label in plant_bank22_script_on_zero_byte.asm.
; CommitScriptAndRecordHead is the EQU in
; plant_handler_and_head_word.asm. hRecordHead is the name from
; write_record_head.asm. ResumePlantedHead60FD is the label in
; resume_planted_head_60fd.asm.

FacingLeftFromPlantedHead::
    call PointAtCellOneColumnLeft
    call PlantBank22ScriptOnZeroByte
    jp CommitScriptAndRecordHead

FacingLeftFromPlantedHeadEnd:
