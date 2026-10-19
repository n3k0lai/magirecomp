; Sound command $06 from the word table at $4DA6.
; RunSoundStream calls it while ROM bank $30 stays mapped. BC is the
; stream cursor just past this command. The next tick resumes from the
; word at $DF9A.
;
; The two operand bytes are a high byte and a low byte. Added to $5A88,
; that sum is stored as the new cursor.

SoundCommand06:
    ld l, c
    ld h, b
    ld a, [hl+]
    ld e, [hl]
    ld d, a
    ld hl, $5A88
    add hl, de
    ld a, l
    ld d, h
    ld hl, $DF9A
    ld [hl+], a
    ld [hl], d
    ret
