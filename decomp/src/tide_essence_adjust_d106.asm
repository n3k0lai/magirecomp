; TideEssenceAdjustD106. Bank 7 at $6F5D (file $01EF5D).
;
; Third pointer of TideEssenceIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $08 into the byte at $D106. What that byte counts is
; still unknown.

TideEssenceAdjustD106::
    ld hl, $D106
    ld a, $08
    or [hl]
    ld [hl], a
    ret
