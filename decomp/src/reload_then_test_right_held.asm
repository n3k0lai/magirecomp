; Bank 1 at $53C4. PlantScriptOnRightWhileDownBit1 stores this address
; as the record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs the script already in the record
; and points HL at the map cell. A then becomes the $c9a3 copy of
; wButtonsHeld that FinishFrame writes. Bit 4 is right, from the high
; nibble ReadJoypad stores. Control falls into RightHeldFromBit4, which
; branches on that bit.
;
; ReloadRecordRunScriptPointCell is the routine at $5DE1.
; RightHeldFromBit4 is the label in right_held_from_bit4.asm.
; wButtonsHeld is the name from read_joypad.asm.

ReloadThenTestRightHeld::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 4, a
