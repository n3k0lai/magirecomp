; Set the low nibble of wSlotMix to A (clamped to $0F). Returns the old low
; nibble in A. BC is preserved.

SetSlotMixLow::
    push bc
    cp $0F
    jr c, .clamped
    ld a, $0F
.clamped:
    and $0F
    ld b, a
    ld a, [wSlotMix]
    ld c, a
    and $F0
    or b
    ld [wSlotMix], a
    ld a, c
    and $0F
    pop bc
    ret
