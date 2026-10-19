; Bank 1 at $5F85. PlantDownRecordHead5F85 writes this address as the
; record-head word for the down path. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs the script already in the record
; and points HL at the map cell. A then becomes the $c9a3 copy of
; wButtonsHeld that FinishFrame writes. Bit 7 is down, from the high
; nibble ReadJoypad stores.
;
; Down still held jumps to $5F93. Down clear jumps to $60F2. Both are
; still INCBIN in this bank.
;
; ReloadRecordRunScriptPointCell is the routine at $5DE1.
; wButtonsHeld is the name from read_joypad.asm. $c9a3 has no name.
; PlantDownRecordHead5F85 is the label in plant_down_record_head_5f85.asm.

ResumePlantedDownRecord::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 7, a
    jp nz, $5f93
    jp $60f2

ResumePlantedDownRecordEnd:
