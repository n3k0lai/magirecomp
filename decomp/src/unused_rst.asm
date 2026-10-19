; Unused bytes from the tail of the RST $00 slot through RST $38.
; Each interrupt slot is eight bytes. RST $00 already used three for its
; jump, so five nops remain. RST $08, $10, $18, $20, $28, $30, and $38
; are eight nops each. The CPU does not enter any of these. VBlank is next,
; at $0040.

RST00Pad::
    nop
    nop
    nop
    nop
    nop

RST_08::
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

RST_10::
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

RST_18::
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

RST_20::
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

RST_28::
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

RST_30::
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

RST_38::
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
