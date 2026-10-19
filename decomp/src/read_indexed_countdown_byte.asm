; Index in A. ServiceLowerCountdownExpiry calls this at $3FB0 when
; bit 7 of the value from $3F0E is set. A is that value with bit 7
; already cleared, so it is below $80.
;
; The little-endian pointer at $DFB1 is the base. A is added to it.
; $DFA9 is mapped through MapRomBank, one byte is read there, and
; $DF00 is mapped back through MapRomBank. That byte is returned in A.
; BC, DE, and HL are preserved.
;
; wCountdownBank ($DFA9) and wCountdownSavedBank ($DF00) are the names
; from step_indexed_countdown.asm.

DEF wCountdownByteList EQU $DFB1

ReadIndexedCountdownByte:
    push de
    push hl
    push bc
    ld e, a
    ld d, $00
    ld hl, wCountdownByteList
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld a, [wCountdownBank]
    call MapRomBank
    ld e, [hl]
    ld a, [wCountdownSavedBank]
    call MapRomBank
    ld a, e
    pop bc
    pop hl
    pop de
    ret
