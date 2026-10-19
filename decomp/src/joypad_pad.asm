; Unused bytes between the joypad vector and the cartridge header at $0100.
; The CPU does not enter here. One hundred fifty-nine nops fill $0061-$00FF.

JoypadPad::
    REPT $0100 - $0061
        nop
    ENDR
