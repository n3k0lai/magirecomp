; SpiceOfLifeAdjustD119. Bank 7 at $6EE2 (file $01EEE2).
;
; Second pointer of SpiceOfLifeIndexedRecord. RunPairIdScripts calls it
; from $CD93. The word at $D119 is stored high byte first. This adds
; $0008, writes the sum back to $D119, and copies that same word to
; $D117. What those words count is still unknown.

SpiceOfLifeAdjustD119::
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
    ret
