; $400 nop bytes from bank 2 $7A2C through $7E2B. The last live byte
; before this hole is the record table that ends at $766A. From $766B
; to the bank end at $8000 the ROM is zero, and nothing in this range
; is a call target. This slice stops at max_bytes, short of a ret.

Bank2NopPad7A2C:
    rept $400
        nop
    endr
