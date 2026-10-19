; Set the high nibble of wSlotMix to A (clamped to $0F). Returns the old
; high nibble in A. BC is preserved.

SetSlotMixHigh::
    push bc
    cp $0F
    jr c, .clamped
    ld a, $0F
.clamped:
    and $0F
    swap a
    ld b, a
    ld a, [wSlotMix]
    ld c, a
    and $0F
    or b
    ld [wSlotMix], a
    ld a, c
    swap a
    and $0F
    pop bc
    ret
