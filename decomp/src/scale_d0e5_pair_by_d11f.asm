; Bank 2 at $53CC. Called from FinishLowD103Refresh when the word at
; $D100 is not $517D and bit 7 of $D105 is clear. The sibling at $539D
; does the same with $D0E4 and $D11E.
;
; $D0E9 indexes the jitter table. JitterScaledTableByte with scale $0A
; returns a signed offset. Adding that offset to $D0E5 selects a word
; in the table at $4000 in this bank (still INCBIN). The first byte is
; the low end. The second byte minus the first is the span.
;
; B becomes $63 minus $D11F. MulCByB times DivideHLByA by $64 is
; span * (99 - $D11F) / 100. A returns that quotient plus the low end,
; so $D11F = 0 sits near the high byte and $D11F = 99 returns the low
; byte.
;
; JitterScaledTableByte, MulCByB, and DivideHLByA are already source.

ScaleD0E5PairByD11F::
    ld a, [$D0E9]
    ld b, a
    ld a, $0A
    call JitterScaledTableByte
    ld b, a
    ld a, [$D0E5]
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
    ld a, [$D11F]
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
