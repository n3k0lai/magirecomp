; Unused bytes between the LCDC status vector and the timer vector.
; The CPU does not enter here. Five nops keep the next vector at $0050.

LCDCStatusPad::
    nop
    nop
    nop
    nop
    nop
