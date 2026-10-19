; Sound command $05 from the word table at $4DA6.
; RunSoundStream calls it while ROM bank $30 stays mapped. BC is the
; stream cursor just past this command, and $DF9C is the stream index.
; The next tick resumes from the word at $DF9A.
;
; $DF8E, indexed by the stream, is a counter. Operand 0 is the limit.
; When that limit is nonzero and already equals the counter, the counter
; is cleared and $DF9A moves three bytes ahead, past the operands.
; Otherwise the counter is incremented. Operands 1 and 2 are a high byte
; and a low byte. Added to the address just past those three operands,
; that sum is stored as the new cursor.

SoundCommand05:
    ld a, [$DF9C]
    ld e, a
    ld d, $00
    ld hl, $DF8E
    add hl, de
    ld a, [bc]
    and a
    jr z, .branch

    cp [hl]
    jr nz, .branch

    ld [hl], $00
    ld hl, $DF9A
    inc bc
    inc bc
    inc bc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ret

.branch:
    inc [hl]
    inc bc
    ld l, c
    ld h, b
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    add hl, de
    ld a, l
    ld d, h
    ld hl, $DF9A
    ld [hl+], a
    ld [hl], d
    ret
