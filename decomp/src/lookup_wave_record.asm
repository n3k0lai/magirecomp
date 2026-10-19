; Look up the 6-byte wave record A in the bank's wave table. The table base
; is $5A79 plus the word at $5A7E; the record is base + A * 6. Returns HL =
; record word 0, BC = word 1, E = byte 4, and A = byte 5 + wScaleSavedBank.

LookupWaveRecord::
    ld hl, $5A7E
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $5A79
    add hl, de
    ld d, $00
    ld e, a
    sla e
    rl d
    ld c, e
    ld b, d
    sla e
    rl d
    add hl, de
    add hl, bc
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    push de
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld e, a
    ld a, [wScaleSavedBank]
    add a, [hl]
    pop hl
    ret
