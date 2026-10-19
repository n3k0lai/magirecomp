; Bank 2 at $539D. Called from $4202 when the word at $D100 equals
; $517D, and again when bit 7 of $D105 is set. The sibling at $53CC
; does the same with $D0E5 and $D11F.
;
; $D0E9 indexes the jitter table. JitterScaledTableByte with scale $0A
; returns a signed offset. Adding that offset to $D0E4 selects a word
; in the table at $4000 in this bank (still INCBIN). The first byte is
; the low end. The second byte minus the first is the span.
;
; B becomes $63 minus $D11E. MulCByB times DivideHLByA by $64 is
; span * (99 - $D11E) / 100. A returns that quotient plus the low end,
; so $D11E = 0 sits near the high byte and $D11E = 99 returns the low
; byte.
;
; JitterScaledTableByte, MulCByB, and DivideHLByA are already source.

ScaleD0E4PairByD11E::
    ld a, [$D0E9]
    ld b, a
    ld a, $0A
    call JitterScaledTableByte
    ld b, a
    ld a, [$D0E4]
    add b
    ld hl, $4000
    add a, a
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl+]
    ld d, a
    ld a, [hl]
    sub d
    ld c, a
    ld a, [$D11E]
    ld b, a
    ld a, $63
    sub b
    ld b, a
    push de
    call MulCByB
    ld a, $64
    call DivideHLByA
    pop de
    add d
    ret
