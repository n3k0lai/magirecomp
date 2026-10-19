; Word-table handler at $42E3 (table entry 3 at $42A9).
;
; Turns the LCD off, spins BC down from $4FFF, then turns it back on.
; The masked-action dispatcher at $41E3 reaches this through JumpHL at $0789.
; TurnOffLCD and TurnOnLCDIfOff live in bank 0.

HoldLcdOff::
    call TurnOffLCD
    ld bc, $4fff

.spin
    dec bc
    ld a, c
    or b
    jr nz, .spin

    call TurnOnLCDIfOff
    ret
