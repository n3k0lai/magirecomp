; Fill C bytes of an ascending run at a fixed stride.
;
; Writes A at HL, then adds DE to HL and increments A. Repeats until C
; reaches zero. The caller supplies the start value, the destination, the
; stride, and the count.

WriteAscendingAtStride::
    ld [hl], a
    add hl, de
    inc a
    dec c
    jr nz, WriteAscendingAtStride
    ret
