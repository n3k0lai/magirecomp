; Bank 3 at $7C2C, the rest of the $00 run that began at $782C and
; continues through $7FFF. Each byte is a nop. This slice covers the
; remaining 980 bytes. Nothing here calls or jumps.

NopPad7C2C::
    REPT 980
        nop
    ENDR
