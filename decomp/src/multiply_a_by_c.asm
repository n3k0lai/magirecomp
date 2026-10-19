; Multiply the byte in A by the byte in C. The product is returned in HL.
; The entry at $4002 keeps B, so the multiplicand is the full BC word.
;
; A is rotated eight times and comes back unchanged. Each set bit adds the
; current BC into HL, then BC shifts left. After eight shifts the original C
; sits in B and C is zero. A product that does not fit in 16 bits wraps.

MultiplyAByC:
    ld b, $00

MultiplyAByBc:
    ld hl, $0000
REPT 7
    rrca
    jr nc, .skip\@
    add hl, bc
.skip\@
    sla c
    rl b
ENDR
    rrca
    ret nc

    add hl, bc
    ret
