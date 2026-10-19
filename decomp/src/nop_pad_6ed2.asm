; Bank 1 at $6ED2, inside the $00 run that starts at $6600 and
; continues through $7FFF. Each byte is a nop. This slice covers
; 1024 of those bytes, through $72D1. Nothing here calls or jumps.

NopPad6ED2::
    REPT 1024
        nop
    ENDR
