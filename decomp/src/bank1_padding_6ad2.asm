; $400 zero bytes from $6AD2 through $6ED1. This is the middle of the
; unused tail of bank 1, which stays zero from $6600 through $7FFF.
; Nothing in this bank enters the range. Each byte is a nop.

Bank1Padding6AD2:
    rept $400
        nop
    endr
