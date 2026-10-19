IF !DEF(PALETTE_MACROS_INC)
DEF PALETTE_MACROS_INC EQU 1
; rgb r, g, b[, r, g, b ...]: GBC RGB555 colors, 0-31 per channel.
MACRO rgb
    ASSERT _NARG % 3 == 0, "rgb takes r, g, b triples"
    REPT _NARG / 3
        dw (\1) | (\2) << 5 | (\3) << 10
        SHIFT 3
    ENDR
ENDM
ENDC
