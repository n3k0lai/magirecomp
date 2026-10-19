; Bank 7 at $5D9B. The word at $CD8F is the destination and the word
; at $CD8D is the source. Both are little-endian. Two bytes are copied,
; and BC is left one past the last byte written. Nothing is called.
; wByteSrcPtr and wByteDestPtr name these words in
; copy_three_from_cd8d_ptr.asm.

CopyTwoFromCD8DPtr::
    ld hl, wByteDestPtr
    ld a, [hli]
    ld b, [hl]
    ld c, a
    ld hl, wByteSrcPtr
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [hli]
    ld [bc], a
    inc bc
    ld a, [hli]
    ld [bc], a
    inc bc
    ret
