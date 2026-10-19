; Bank 1 at $6600, the start of the $00 run that continues through
; $7FFF. Each byte is a nop. This slice covers $6600 through $66D1,
; up to the pad already lifted at $66D2. Nothing here calls or jumps.

NopPad6600::
    REPT 210
        nop
    ENDR
