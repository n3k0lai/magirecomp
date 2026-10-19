; VBlank interrupt vector. The CPU enters here at the start of vertical blank.
; The handler is still INCBIN.

VBlank::
    jp HandleVBlank
