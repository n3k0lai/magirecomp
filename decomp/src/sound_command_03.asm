; Sound command $03 from the word table at $4DA6.
; RunSoundStream calls it while ROM bank $30 stays mapped. BC is the
; stream cursor just past this command, and $DF9C is the stream index.
;
; Reads four operand bytes into B, C, D, and E. Stream index $03 and
; above skip the call. A lower index is ORed with the fifth operand and
; passed to $539C, which still owns what BC and DE mean. Either way the
; cursor word at $DF9A moves five bytes ahead, past those operands.

SoundCommand03:
    ld l, c
    ld h, b
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    ld a, [$DF9C]
    cp $03
    jr nc, SoundCommand03Advance
    or [hl]
    call $539C

SoundCommand03Advance:
    ld hl, $DF9A
    ld a, [hl]
    add $05
    ld [hl+], a
    ld a, [hl]
    adc $00
    ld [hl], a
    ret
