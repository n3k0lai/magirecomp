; LeafEssenceAdjustD106. Bank 7 at $6DDF (file $01EDDF).
;
; Third pointer of LeafEssenceIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $10 into the byte at $D106. What that byte counts is
; still unknown.

LeafEssenceAdjustD106::
    ld hl, $D106
    ld a, $10
    or [hl]
    ld [hl], a
    ret
