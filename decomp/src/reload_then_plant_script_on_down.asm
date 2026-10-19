; Bank 1 at $4EEF. rROMB0 is left alone. What reaches this address
; is still unknown. It is not fallen into from PlantPastTwoCellRunScript,
; which jumps away.
;
; ReloadRecordRunScriptPointCell runs the script already in the record
; and points HL at the map cell. Control then falls into
; PlantScriptOnDownPressed, which plants the down-pressed script and
; commits the record head.
;
; ReloadRecordRunScriptPointCell is the routine at $5DE1.
; PlantScriptOnDownPressed is the label in plant_script_on_down_pressed.asm.

ReloadThenPlantScriptOnDownPressed::
    call ReloadRecordRunScriptPointCell
