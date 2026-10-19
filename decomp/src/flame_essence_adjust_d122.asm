; FlameEssenceAdjustD122. Bank 7 at $6D73 (file $01ED73).
;
; Second pointer of FlameEssenceIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $01 into the byte at $D122 and $20 into the byte at
; $D123. What those bytes count is still unknown.

FlameEssenceAdjustD122::
    ld hl, $D122
    ld a, $01
    or [hl]
    ld [hl], a
    ld hl, $D123
    ld a, $20
    or [hl]
    ld [hl], a
    ret
