; $400 zero bytes from $72D2 through $76D1. This is the unused tail of
; bank 1, which stays zero from $6600 through $7FFF. Nothing in this
; bank enters the range. Each byte is a nop.

Bank1Padding72D2:
    rept $400
        nop
    endr
