; Bank 5 at $5E45. FillAsciiSlotCounts stores a pointer at $CD8D and
; calls here with bank 5 still mapped. The little-endian word is the
; address of one byte. That byte comes back in D. This does not switch
; banks, and it does not change the pointer.

LoadPointedByteToD::
    ld hl, $CD8D
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld d, [hl]
    ret
