; LeafEssenceAdjustD122. Bank 7 at $6DD0 (file $01EDD0).
;
; Second pointer of LeafEssenceIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $20 into the byte at $D122 and $08 into the byte at
; $D123. What those bytes count is still unknown.

LeafEssenceAdjustD122::
    ld hl, $D122
    ld a, $20
    or [hl]
    ld [hl], a
    ld hl, $D123
    ld a, $08
    or [hl]
    ld [hl], a
    ret
