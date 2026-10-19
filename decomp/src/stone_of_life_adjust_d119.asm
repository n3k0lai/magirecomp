; StoneOfLifeAdjustD119. Bank 7 at $6F1D (file $01EF1D).
;
; Second pointer of StoneOfLifeIndexedRecord. RunPairIdScripts calls it
; from $CD93. The word at $D119 is stored high byte first. This adds
; $0008, writes the sum back to $D119, copies that same word to $D117,
; then ORs $FF into $D124. What those bytes count is still unknown.

StoneOfLifeAdjustD119::
    ld a, [$D119]
    ld h, a
    ld a, [$D11A]
    ld l, a
    ld c, $08
    ld b, $00
    add hl, bc
    ld a, h
    ld [$D119], a
    ld [$D117], a
    ld a, l
    ld [$D11A], a
    ld [$D118], a
    ld hl, $D124
    ld a, $FF
    or [hl]
    ld [hl], a
    ret
