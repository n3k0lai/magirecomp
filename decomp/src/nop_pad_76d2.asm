; Bank 1 at $76D2, inside the $00 run that starts at $6600 and
; continues through $7FFF. Each byte is a nop. This slice covers
; 1024 of those bytes, through $7AD1. Nothing here calls or jumps.

NopPad76D2::
    REPT 1024
        nop
    ENDR
