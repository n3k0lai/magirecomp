; Unsigned HL = C * B.
;
; B is copied into E and D is cleared, then each set bit of C adds the
; corresponding shift of that value. Bits 0 through 6 shift DE left after
; the add. Bit 7 adds DE and returns, or returns with no add when it is
; clear, so DE is left shifted seven times. The sum wraps in 16 bits.
; A, B, and C are unchanged.
;
; Entering at .fromE skips the copy from B and multiplies C by E.
; Entering at .fromDE multiplies C by the 16-bit value already in DE.
; DrawCGBNotice calls the $04CA entry as MultiplyCByB.

MulCByB::
    ld e, b
.fromE:
    ld hl, $0000
    ld d, $00
.fromDE:
    bit 0, c
    jr z, .shift0
    add hl, de
.shift0:
    sla e
    rl d
    bit 1, c
    jr z, .shift1
    add hl, de
.shift1:
    sla e
    rl d
    bit 2, c
    jr z, .shift2
    add hl, de
.shift2:
    sla e
    rl d
    bit 3, c
    jr z, .shift3
    add hl, de
.shift3:
    sla e
    rl d
    bit 4, c
    jr z, .shift4
    add hl, de
.shift4:
    sla e
    rl d
    bit 5, c
    jr z, .shift5
    add hl, de
.shift5:
    sla e
    rl d
    bit 6, c
    jr z, .shift6
    add hl, de
.shift6:
    sla e
    rl d
    bit 7, c
    ret z
    add hl, de
    ret
