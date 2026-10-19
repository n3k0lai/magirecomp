; Unsigned divide of C by B.
;
; H is the quotient and L is the remainder. A is destroyed. B and C stay
; as they were. B = 0 never borrows, so this loop does not return.
;
; The borrow test sits at $04B1. Bank $58 contains the bytes of
; `jp nz, $04B1` inside a run that disassembles as data, so whether that
; is a real entry is still unknown.

DivideCByB::
    ld hl, $0000
    ld a, c
.loop:
    sub b
.testBorrow:
    jr c, .remainder
    inc h
    jr .loop
.remainder:
    add b
    ld l, a
    ret
