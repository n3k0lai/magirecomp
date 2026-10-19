; Bank 2 at $463F. The caller's A is the bit mask, kept in E.
; HL is advanced by $14, then the next two bytes are tested against E.
; If either byte already has one of those bits set, A is cleared and the
; pair is left alone. Otherwise the mask is added into the second byte
; (the same as ORing it in, because the bits do not overlap) and A is 1.
;
; What the pair records is still unknown. Nothing here is called.

TrySetBitPairAtPlus14::
    ld e, a
    ld bc, $0014
    add hl, bc
    ld a, [hl+]
    and e
    jr nz, .alreadySet
    ld a, [hl]
    and e
    jr nz, .alreadySet
    add e
    ld [hl], a
    ld a, $01
    ret

.alreadySet:
    xor a
    ret
