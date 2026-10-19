; Set master volume (rNR50) to A on both sides, clamped to 7. Returns the
; old left/right-1 volume (low 3 bits) in A. HL and BC are preserved.

SetMasterVolume::
    push hl
    push bc
    cp $07
    jr nc, .clamp
    ld a, $07
.clamp:
    and $07
    ld b, a
    swap b
    or b
    ld hl, $FF24
    ld c, [hl]
    ld [hl], a
    ld a, c
    and $07
    pop bc
    pop hl
    ret
