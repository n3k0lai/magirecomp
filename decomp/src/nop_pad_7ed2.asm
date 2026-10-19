; Bank 1 at $7ED2, the last $00 run of this bank. Each byte is a nop.
; This slice covers the 302 bytes through $7FFF. Nothing here calls
; or jumps.

NopPad7ED2::
    REPT 302
        nop
    ENDR
