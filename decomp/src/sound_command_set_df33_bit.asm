; Sound command with a 1-byte operand: an index into the bit-mask table at
; $4AE1 (right after this routine). That mask is ORed into $DF33 and the
; cursor is saved past the operand.

SoundCommandSetDf33Bit::
    ld a, [bc]
    inc bc
    ld e, a
    ld d, $00
    ld hl, $4AE1
    add hl, de
    ld a, [$DF33]
    or [hl]
    ld [$DF33], a
    ld hl, wSoundStreamCursor
    ld a, c
    ld [hl+], a
    ld [hl], b
    ret
