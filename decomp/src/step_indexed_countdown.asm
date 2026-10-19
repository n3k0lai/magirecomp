; Countdown slot N, with N in A. StepSoundCountdowns calls this at $3E78
; when the slot's action byte is $FE.
;
; $DFA9 is mapped through $3AB0, still INCBIN, so the pointer at
; $DFB3 + N * 2 can be read. That pointer is advanced by 3. The four
; bytes there are two big-endian words: an address addend, then a
; delta. The delta is added into the upper 16 bits of the 24-bit count
; at $DFBF + N * 3 (middle byte $DFC0 + N * 3). The low byte of the
; count is left alone.
;
; $DFA7 is a table base. Its first big-endian word is an offset from
; that base to a list of big-endian words, one per slot. The new
; pointer is base + that slot's word + the record addend. It replaces
; $DFB3 + N * 2. The byte two past the new pointer replaces the action
; at $DFBB + N.
;
; Control leaves through $3AB0 with A = [$DF00], which maps the bank
; saved there. It does not return to this routine.
;
; wCountdownAction ($DFBB) and wCountdownValue ($DFBF) are the names
; from step_sound_countdowns.asm.

DEF wCountdownRecord EQU $DFB3
DEF wCountdownTable EQU $DFA7
DEF wCountdownBank EQU $DFA9
DEF wCountdownSavedBank EQU $DF00

StepIndexedCountdown:
    sla a
    ld e, a
    ld d, $00
    ld a, [wCountdownBank]
    call MapRomBank
    ld hl, wCountdownRecord
    add hl, de
    push hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld bc, $0003
    add hl, bc
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    push bc
    ld a, [hl+]
    ld b, a
    ld c, [hl]
    push de
    ld a, e
    srl a
    add e
    ld e, a
    ld hl, wCountdownValue + 1
    add hl, de
    ld a, [hl]
    add c
    ld [hl+], a
    ld a, [hl]
    adc b
    ld [hl], a
    pop de
    ld a, [wCountdownTable]
    ld l, a
    ld a, [wCountdownTable + 1]
    ld h, a
    ld a, [hl+]
    ld b, a
    ld a, [hl-]
    ld c, a
    push hl
    add hl, bc
    add hl, de
    ld a, [hl+]
    ld b, a
    ld c, [hl]
    pop hl
    add hl, bc
    pop bc
    add hl, bc
    pop bc
    ld a, l
    ld [bc], a
    inc bc
    ld a, h
    ld [bc], a
    inc hl
    inc hl
    ld a, [hl]
    ld hl, wCountdownAction
    srl e
    add hl, de
    ld [hl], a
    ld a, [wCountdownSavedBank]
    jp MapRomBank
