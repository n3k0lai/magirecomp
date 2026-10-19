; Bank 1 at $6081. ResumePlantedHead60FD jumps here when no direction
; bit of the $c9a3 byte is set and the low two bits of hRecordHead are
; $02 (facing right). rROMB0 is left alone.
;
; PointAtCellOneColumnRight leaves HL on the map cell one column right,
; in WRAM bank 5. PlantBank22ScriptOnZeroByte returns when bit 0 of
; $C932 is clear or that cell is not $00. On a hit it pops this return
; address, plants bank $22 script $40AD, and jumps to CommitScriptRecord,
; so the jump below does not run.
;
; Otherwise control jumps to CommitScriptAndRecordHead at $5D9B, which
; copies the script bytes and writes the record head.
;
; PointAtCellOneColumnRight is the label in
; point_at_cell_one_column_right.asm. PlantBank22ScriptOnZeroByte is the
; label in plant_bank22_script_on_zero_byte.asm. CommitScriptAndRecordHead
; is the EQU in plant_handler_and_head_word.asm. hRecordHead is the name
; from write_record_head.asm. ResumePlantedHead60FD is the label in
; resume_planted_head_60fd.asm.

FacingRightFromPlantedHead::
    call PointAtCellOneColumnRight
    call PlantBank22ScriptOnZeroByte
    jp CommitScriptAndRecordHead
