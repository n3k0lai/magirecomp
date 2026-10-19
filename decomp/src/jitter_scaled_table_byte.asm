; Bank 2 at $53FB.
;
; B indexes the byte table at $40DC in this bank. A is a scale: $0A from
; RankEightD092Slots and the callers at $539D and $53CC, or $12 from
; ClearMarksAndWalkSlots when bit 2 of $D0EE is set.
;
; HL becomes scale * table[B]. DivideHLByA divides that product by $63
; (99). E keeps that quotient. C becomes twice the quotient plus one.
; rDIV, read with the 3-byte form, is multiplied by C and divided by $FF.
; A returns that second quotient minus the first, a signed offset about
; one quotient wide.
;
; MulCByB and DivideHLByA are the names from multiply.asm and
; divide_hl_by_a.asm. rDIV is $FF04, as in mask_div_by_c.asm. The table
; at $40DC stays in the surrounding INCBIN. rDIV is defined in
; mask_div_by_c.asm.

JitterScaledTableByte::
    ld hl, $40DC
    ld c, b
    ld b, $00
    add hl, bc
    ld b, [hl]
    ld c, a
    call MulCByB
    ld a, $63
    call DivideHLByA
    ld e, a
    add a, a
    ld c, a
    inc c
    push de
    ld a, [rDIV]
    ld b, a
    call MulCByB
    ld a, $FF
    call DivideHLByA
    pop de
    sub e
    ret
