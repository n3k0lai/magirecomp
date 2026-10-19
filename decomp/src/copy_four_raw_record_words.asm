; Bank 2 at $712F. Callers pass the base of four records in HL.
; $D17E and $D25A are the two bases used from this bank.
;
; HL moves to offset 7. Each record's first word is copied raw, in
; memory order, into consecutive bytes at $D3C4. Two bytes were
; consumed, then HL advances $35, so the stride is $37. $D074 counts
; the four records down to zero. Unlike $7101, the word is not passed
; through ScaleCount.

CopyFourRawRecordWords::
    ld de, $0035
    ld bc, $0007
    add hl, bc
    ld bc, $D3C4
    ld a, $04
    ld [$D074], a

.record:
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    inc bc
    add hl, de
    ld a, [$D074]
    dec a
    ld [$D074], a
    jr nz, .record
    ret
