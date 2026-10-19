; Sound command $01 from the word table at $4DA6.
; RunSoundStream calls it while ROM bank $30 stays mapped. BC is the
; stream cursor just past this command, and $DF9C is the stream index.
;
; Reads a word into DE and one more byte into B, then stores the cursor
; three bytes ahead at $DF9A. Stream index $03 returns here. A lower
; index continues at $536D, which writes those three bytes into the
; channel's sweep state. What each field counts is still in that routine.

SoundCommand01:
    ld l, c
    ld h, b
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld b, a
    ld a, l
    ld [$DF9A], a
    ld a, h
    ld [$DF9B], a
    ld a, [$DF9C]
    ld c, a
    cp $03
    jp c, $536D
    ret
