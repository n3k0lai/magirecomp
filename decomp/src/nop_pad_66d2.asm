; Bank 1 at $66D2, inside the $00 run that starts at $6600 and
; continues through $7FFF. Each byte is a nop. This slice covers the
; first 1024 of those bytes, through $6AD1. Nothing here calls or jumps.

NopPad66D2::
    REPT 1024
        nop
    ENDR
