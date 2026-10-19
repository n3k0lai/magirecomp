; Bank 1 at $5043. rROMB0 is left alone. Nothing in the ROM stores or
; jumps to this address; how control arrives is still unknown.
;
; ReloadRecordRunScriptPointCell ($5DE1) copies the record head and the
; script bytes, runs the handler, sets bit 1 of $FFAA, selects WRAM bank
; 5, and returns the map-cell pointer in HL. Control then falls into
; PlantRightPressedHead01Script at $5046, which plants handler $0A66,
; script $5DA9, and record word $5061, then jumps to
; CommitScriptAndRecordHead.
;
; ReloadRecordRunScriptPointCell is the name from
; reload_record_run_script_point_cell.asm.
; PlantRightPressedHead01Script is the name from
; plant_right_pressed_head01_script.asm.

ReloadThenPlantRightPressedHead01::
    call ReloadRecordRunScriptPointCell
