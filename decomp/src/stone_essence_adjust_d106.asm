; StoneEssenceAdjustD106. Bank 7 at $6F15 (file $01EF15).
;
; Third pointer of StoneEssenceIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $01 into the byte at $D106. What that byte counts is
; still unknown.

StoneEssenceAdjustD106::
    ld hl, $D106
    ld a, $01
    or [hl]
    ld [hl], a
    ret
