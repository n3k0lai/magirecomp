; Return A = rDIV & C after a short spin derived from rDIV.
;
; rDIV is $FF04. Both reads are the 3-byte form. The first sample is
; rotated right through the incoming carry. If the new bit 0 is clear,
; the nibbles are swapped. The low 6 bits, plus one, are the spin count
; (1–64). The spin counts A down to 0, which gives rDIV time to tick.
; The second sample is masked with C. Z follows that result.
; B, C, D, E, H, and L are left alone.

DEF rDIV EQU $FF04

MaskDivByC::
    ld a, [rDIV]
    rra
    bit 0, a
    jr nz, .mask
    swap a
.mask:
    and $3f
    inc a
.spin:
    dec a
    jr nz, .spin
    ld a, [rDIV]
    and c
    ret
