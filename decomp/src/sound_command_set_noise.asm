; Sound command with a 1-byte operand: written straight to rNR43 ($FF22),
; the noise channel's polynomial counter. The cursor is saved past it.

SoundCommandSetNoise::
    ld a, [bc]
    inc bc
    ld e, a
    ld hl, wSoundStreamCursor
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, e
    ldh [$FF22], a
    ret
