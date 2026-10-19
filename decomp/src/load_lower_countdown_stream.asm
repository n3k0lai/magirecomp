; Lower-countdown slot N, with N in A, and that slot's action in C.
; StartLowerSoundCountdown calls this once at $3ED4 after clearing the
; 24-bit count. ROM bank $30 is mapped on entry.
;
; $DFA9 is mapped through MapRomBank so the table at $DFA7 can be read.
; The big-endian word two bytes into that table is an offset to a list
; of big-endian words. B is cleared and C is shifted left, so BC selects
; the word for the low 7 bits of the action. That word is an offset from
; the table base. The resulting address replaces the stream pointer at
; $DFCB + N * 2, stored little-endian.
;
; Control leaves through MapRomBank with A = [$DF00], which maps the bank
; saved there. It does not return to this routine.
;
; wCountdownTable ($DFA7), wCountdownBank ($DFA9), and
; wCountdownSavedBank ($DF00) are the names from
; step_indexed_countdown.asm.

DEF wLowerCountdownRecord EQU $DFCB

LoadLowerCountdownStream:
    sla a
    ld e, a
    ld d, $00
    push de
    ld b, $00
    sla c
    ld a, [wCountdownBank]
    push bc
    call MapRomBank
    pop bc
    ld a, [wCountdownTable]
    ld l, a
    ld a, [wCountdownTable + 1]
    ld h, a
    inc hl
    inc hl
    ld a, [hl+]
    ld d, a
    ld a, [hl-]
    ld e, a
    dec hl
    dec hl
    push hl
    add hl, de
    add hl, bc
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    pop bc
    add hl, bc
    ld c, l
    ld b, h
    pop de
    ld hl, wLowerCountdownRecord
    add hl, de
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [wCountdownSavedBank]
    jp MapRomBank
