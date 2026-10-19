; EnergyGemAdjustD110. Bank 7 at $6D1F (file $01ED1F).
;
; Second pointer of EnergyGemIndexedRecord. RunPairIdScripts calls it
; from $CD93. The word at $D119 is stored high byte first. This adds
; $0006, writes the sum back to $D119, and copies that same word to
; $D117. What those words count is still unknown.

EnergyGemAdjustD110::
    ld a, [$D119]
    ld h, a
    ld a, [$D11A]
    ld l, a
    ld c, $06
    ld b, $00
    add hl, bc
    ld a, h
    ld [$D119], a
    ld [$D117], a
    ld a, l
    ld [$D11A], a
    ld [$D118], a
    ret
