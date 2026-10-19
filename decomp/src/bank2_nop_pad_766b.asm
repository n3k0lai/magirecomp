; $3C1 nop bytes from bank 2 $766B through $7A2B. The last live byte
; before this hole is the menu record that ends at $766A. From $766B
; through the bank end the ROM is zero, and nothing in this range is a
; call target. The next lifted pad begins at $7A2C.

Bank2NopPad766B:
    rept $3C1
        nop
    endr
