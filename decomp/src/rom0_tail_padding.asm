; $31 zero bytes from $3FCF through $3FFF, after ReadIndexedCountdownByte
; returns at $3FCE. Nothing in bank 0 enters this range. The addresses
; mgbdis marked inside it ($3FDF, $3FE3, $3FF0, $3FFC) only appear as
; bytes inside tile data in other banks.

ROM0TailPadding:
    rept $31
        nop
    endr
