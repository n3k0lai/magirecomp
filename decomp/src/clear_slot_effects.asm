; Clear the current slot's effect bits: keep only bits 7-5 and 1 of its
; wChannelFlagBase byte, then set bit 5. For the wave slot (2) bit 0 of
; wSoundFlags is cleared first.

ClearSlotEffects::
    ld a, [wSlotStreamIndex]
    ld e, a
    ld d, $00
    cp $02
    jr nz, .flags
    ld a, [wSoundFlags]
    and $FE
    ld [wSoundFlags], a
.flags:
    ld hl, wChannelFlagBase
    add hl, de
    ld a, [hl]
    and $E2
    or $20
    ld [hl], a
    ret
