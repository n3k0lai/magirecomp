; Unused bytes between the serial vector ($0058) and the joypad vector
; ($0060). The vector itself is a one-byte reti, so the rest of the
; eight-byte slot is nop. The CPU does not enter here.

SerialPad::
    nop
    nop
    nop
    nop
    nop
    nop
    nop
