; Sound command $00 from the word table at $4DA6.
; RunSoundStream calls it while ROM bank $30 stays mapped. The stream
; index is already in $DF9C, and $DF9A holds the byte after this command.
;
; Zeros the indexed byte at $DF9D, the indexed byte at $DFA1, and the
; cursor word at $DF9A. A zero cursor makes RunSoundStream stop. What
; the two indexed bytes count is still in the following commands.

SoundCommand00:
    ld a, [$DF9C]
    ld e, a
    ld d, $00
    ld hl, $DF9D
    add hl, de
    xor a
    ld [hl], a
    ld hl, $DFA1
    add hl, de
    ld [hl], a
    ld hl, $DF9A
    ld [hl+], a
    ld [hl], a
    ret
