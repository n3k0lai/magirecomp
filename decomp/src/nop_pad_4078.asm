; Bank 4 at $4078. Zero bytes after the $FF fill that ends at $4077.
; Each byte is a nop. The run stops at $40B8. The following bytes,
; still INCBIN, are a short table through $40EF. Nothing here calls
; or jumps.

NopPad4078::
    REPT 65
        nop
    ENDR
