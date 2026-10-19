; $1D4 zero bytes from $7E2C through $7FFF. This is the unused tail of
; bank 2. Nothing in this range calls or jumps. Each byte is a nop.

Bank2Padding7E2C:
    rept $1D4
        nop
    endr
