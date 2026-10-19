; Bank 4 at $73AA. ApplyC9BCScrollThenFrame calls this twice with bank 4
; already mapped. This routine does not write rROMB0. A = 0 stores into
; $C9C0. Any other A stores into $C9C1.
;
; The shift helper compares D with zero. `cp $00` never sets carry, so the
; negate path is unused: C becomes E arithmetic-shifted right twice and D
; stays as the caller passed it. The unused path would replace D with -D
; and C with -(E >> 2).
;
; The multiply helper clears B and HL, then adds BC once for each remaining
; count in D. The stored byte is E plus L, the low byte of that sum. What
; $C9C0 and $C9C1 mean beyond this scale is still unknown.

ScaleEByDIntoC9C0::
    and a
    jr nz, .into_c9c1
    call ShiftEIntoC
    call MultiplyDByC
    ld a, e
    add l
    ld [$C9C0], a
    ret

.into_c9c1:
    call ShiftEIntoC
    call MultiplyDByC
    ld a, e
    add l
    ld [$C9C1], a
    ret

; B = 0, HL = D * C. D is counted down to 0 when it starts nonzero.
MultiplyDByC:
    ld b, $00
    ld h, b
    ld l, b

.add_loop:
    ld a, d
    and a
    ret z
    add hl, bc
    dec d
    jr .add_loop

; C = E >> 2. The jr c below does not fire: cp $00 leaves carry clear.
ShiftEIntoC:
    ld a, d
    cp $00
    jr c, .negate
    ld c, e
    sra c
    sra c
    ret

.negate:
    cpl
    inc a
    ld d, a
    ld a, e
    sra a
    sra a
    cpl
    inc a
    ld c, a
    ret

ScaleEByDIntoC9C0End:
