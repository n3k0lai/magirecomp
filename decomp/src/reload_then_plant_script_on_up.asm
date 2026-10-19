; Bank 1 at $50ED. What reaches this address is still unknown. It is
; not fallen into from PlantBit6PastTwoCellRunScript, which jumps away.
; rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs the script already in the record
; and points HL at the map cell. Control then falls into
; PlantScriptOnUpPressed, which plants the up-pressed script and commits
; the record head.
;
; ReloadRecordRunScriptPointCell is the routine at $5DE1.
; PlantScriptOnUpPressed is the label in plant_script_on_up_pressed.asm.

ReloadThenPlantScriptOnUpPressed::
    call ReloadRecordRunScriptPointCell
