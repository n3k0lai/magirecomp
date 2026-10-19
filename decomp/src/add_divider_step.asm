; Add a divider-derived step to the byte at $FFA9.
;
; Both reads are ldh from rDIV ($FF04). The first sample is nibble-swapped
; and shifted right arithmetically, so original bit 3 becomes the sign.
; That value is added to a second sample. The low 3 bits of the sum, minus
; three, are the step: -3 through +4. The step is added to $FFA9 and stored
; back. A returns the new byte. Flags follow that add.
;
; E holds the step. B, C, D, H, and L are left alone. rDIV is defined in
; mask_div_by_c.asm. Callers still in INCBIN mask A with $0F.

; Running byte. Its other uses are still unknown.
DEF hDividerAccum EQU $FFA9

AddDividerStep::
    ldh a, [rDIV]
    swap a
    sra a
    ld e, a
    ldh a, [rDIV]
    add e
    and $07
    dec a
    dec a
    dec a
    ld e, a
    ldh a, [hDividerAccum]
    add e
    ldh [hDividerAccum], a
    ret
