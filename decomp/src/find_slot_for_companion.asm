; Find the slot (0-3) whose wStreamCompanion byte equals A. A = 0 returns
; at once with Z set. On a hit wSlotStreamIndex = slot and A = slot * 2
; (nonzero result for slots 1-3); on a miss A = 0.

FindSlotForCompanion::
    and a
    ret z
    ld hl, wStreamCompanion
    ld c, $00
    ld b, a
.loop:
    ld a, [hl+]
    cp b
    jr z, .found
    inc c
    bit 2, c
    jr z, .loop
    xor a
    ret
.found:
    ld a, c
    ld [wSlotStreamIndex], a
    rlca
    ret
