; Bank 2 at $7101. Callers pass the base of four records in HL. $D17E and
; $D25A are the two bases used from this bank.
;
; HL moves to offset 7. Each record holds two big-endian words there.
; Those words are BC and DE for ScaleCount. The count comes back in A
; and is stored at $D3C4 as a word whose high byte is that count and
; whose low byte is 0. Four bytes were consumed, then HL advances $33,
; so the stride is $37. $D074 counts the four records down to zero.

ScaleFourRecordsIntoD3C4::
    ld bc, $0007
    add hl, bc
    ld bc, $D3C4
    ld a, $04
    ld [$D074], a

.record:
    push bc
    ld a, [hl+]
    ld e, [hl]
    inc hl
    ld d, a
    ld a, [hl+]
    ld c, [hl]
    inc hl
    ld b, a
    push hl
    call ScaleCount
    pop hl
    pop bc
    ld [bc], a
    inc bc
    xor a
    ld [bc], a
    inc bc
    ld de, $0033
    add hl, de
    ld a, [$D074]
    dec a
    ld [$D074], a
    jr nz, .record
    ret
