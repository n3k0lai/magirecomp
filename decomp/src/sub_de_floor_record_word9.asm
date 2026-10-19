; SubDeFloorRecordWord9. Bank 0 at $3863.
;
; HL is a record. DE is a subtrahend. The big-endian word at record+9 is
; loaded and DE is subtracted. An underflow is floored at zero. That word
; is written back at record+9. HL returns on the low byte of the stored
; word. A is the high byte and C is the low byte. There is no call. What
; the word counts is still unknown.

SubDeFloorRecordWord9::
    ld bc, $0009
    add hl, bc
    push hl
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    add hl, de
    jr nc, .store

    ld hl, $0000

.store:
    ld a, h
    ld c, l
    pop hl
    ld [hl+], a
    ld [hl], c
    ret
