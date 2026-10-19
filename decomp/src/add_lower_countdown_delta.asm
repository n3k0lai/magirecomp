; Lower-countdown slot N, with N in A. Bank $30 at $599D calls this at
; $3F7D while that slot's 24-bit count is still expired (it returned Z).
;
; $DFA9 is mapped through MapRomBank so the pointer at $DFCB + N * 2 can
; be read. The two bytes there are a delta: the second byte is the low
; 8 bits, and the low nibble of the first byte is the high 4 bits. The
; high nibble of the first byte is ignored. That 12-bit value is added
; into the upper 16 bits of the 24-bit count at $DFD4 + N * 3, whose
; middle byte is $DFD5 + N * 3. The low byte of the count is left
; alone, and the pointer is not advanced.
;
; Control leaves through MapRomBank with A = [$DF00], which maps the
; bank saved there. It does not return to this routine.

AddLowerCountdownDelta:
    sla a
    ld e, a
    ld d, $00
    ld a, [$dfa9]
    call MapRomBank
    ld hl, $dfcb
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld hl, $dfd5
    push de
    ld a, e
    srl a
    add e
    ld e, a
    add hl, de
    pop de
    ld a, [hl]
    add c
    ld [hl+], a
    push af
    ld a, b
    and $0f
    ld c, a
    pop af
    ld a, [hl]
    adc c
    ld [hl], a
    ld a, [$df00]
    jp MapRomBank
