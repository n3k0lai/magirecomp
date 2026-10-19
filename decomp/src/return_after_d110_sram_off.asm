; Bank 2 at $5C1D. LoadD110Record calls here right after it writes zero
; to rRAMG and disables SRAM. The call returns at once, leaving A, BC,
; and HL as the caller set them for the copy from $D119 onto $D117.

ReturnAfterD110SramOff::
    ret
