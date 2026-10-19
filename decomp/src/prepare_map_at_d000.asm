; Bank 0 at $2D8C. UnpackMapIntoWRAM6AndCopyBoth calls this, and so
; does the still-included copy at $2DC3.
;
; HL is the BG-map address and is restored. DE is the rectangle size,
; D rows by E columns, and is restored. BC is a packed map source in the
; WRAM bank the caller selected. The first packed stream is expanded to
; $D000 + (D * E), which is the second rectangle CopyMapRect reads.
; The next packed stream is expanded to $D000, the first rectangle.
; BC returns as $D000. MulCByB and UnpackBytes are the names from
; multiply.asm and unpack_bytes.asm.

PrepareMapPlanesAtD000::
    push hl
    push de
    push bc
    ld b, d
    ld c, e
    call MulCByB
    ld de, $d000
    add hl, de
    ld d, h
    ld e, l
    pop hl
    call UnpackBytes
    ld de, $d000
    call UnpackBytes
    ld bc, $d000
    pop de
    pop hl
    ret
