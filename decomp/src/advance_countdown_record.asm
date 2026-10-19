; Countdown slot N, with N in A. StepSoundCountdowns calls this at $3E3A
; when the slot's action byte is neither $FE nor $FF.
;
; $DFA9 is mapped through $3AB0, still INCBIN, so the pointer at
; $DFB3 + N * 2 can be read. That pointer moves forward by 3 and is
; stored back. The three bytes there are a 16-bit delta, high byte
; first, and the next action byte. The action replaces $DFBB + N.
; The delta is added into the upper 16 bits of the 24-bit count at
; $DFBF + N * 3, whose middle byte is $DFC0 + N * 3. The low byte of
; the count is left alone.
;
; Control leaves through $3AB0 with A = [$DF00], which maps the bank
; saved there. It does not return to this routine.
;
; wCountdownAction ($DFBB) and wCountdownValue ($DFBF) are the names
; from step_sound_countdowns.asm.

AdvanceCountdownRecord:
    sla a
    ld e, a
    ld d, $00
    ld a, [$dfa9]
    call $3ab0
    ld hl, $dfb3
    add hl, de
    push hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld bc, $0003
    add hl, bc
    pop bc
    ld a, l
    ld [bc], a
    inc bc
    ld a, h
    ld [bc], a
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl]
    ld hl, $dfbb
    srl e
    add hl, de
    ld [hl], a
    ld a, e
    sla e
    add e
    ld e, a
    ld hl, $dfc0
    add hl, de
    ld a, [hl]
    add c
    ld [hl+], a
    ld a, [hl]
    adc b
    ld [hl], a
    ld a, [$df00]
    jp $3ab0
