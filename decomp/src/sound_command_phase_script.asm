; Sound command with a 1-byte operand at BC: a phase script index. The
; table of script offsets sits at $5A79 + [$5A79] (offsets relative to
; $5A79); entry operand*2 gives the script, which StartPhaseScript starts for
; the current slot. The stream cursor then advances by 1.

SoundCommandPhaseScript::
    ld hl, $5A79
    ld e, l
    ld d, h
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    push hl
    ld a, [bc]
    ld e, a
    ld d, $00
    sla e
    rl d
    add hl, de
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    pop hl
    add hl, de
    ld a, [wSlotStreamIndex]
    ld c, a
    call StartPhaseScript
    ld hl, wSoundStreamCursor
    inc [hl]
    ret nz
    inc hl
    inc [hl]
    ret
