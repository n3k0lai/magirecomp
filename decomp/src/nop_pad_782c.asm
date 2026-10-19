; Bank 3 at $782C, the start of the $00 run that continues through
; $7FFF. Each byte is a nop. This slice covers 1024 of those bytes,
; through $7C2B. Nothing here calls or jumps.

NopPad782C::
    REPT 1024
        nop
    ENDR
