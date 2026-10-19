; Unsigned divide of HL by A.
;
; A returns the quotient. The divisor is zero-extended, negated into BC,
; and added to HL until that add does not carry. Each carry increments
; the quotient and leaves HL reduced by the divisor. The add that does
; not carry is the one that passes below zero, so HL is left at
; (remainder - divisor), in the range -divisor through -1. A divisor of
; 0 becomes BC = 0, the add does not carry, and this returns quotient 0
; with HL unchanged.
;
; The final ret sits after a jr that always goes back to the add. The
; only exit that runs is `ret nc`.

DivideHLByA::
    ld c, a
    ld b, $00
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    xor a
.subtract:
    add hl, bc
    ret nc
    inc a
    jr .subtract
    ret
