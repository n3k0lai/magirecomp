; Unused bytes between the VBlank vector ($0040) and the LCDC status
; vector ($0048). The vector itself is a three-byte jump, so the rest
; of the eight-byte slot is nop.

VBlankVectorPad::
    nop
    nop
    nop
    nop
    nop
