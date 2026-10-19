; SkyEssenceAdjustD106. Bank 7 at $6EDA (file $01EEDA).
;
; Third pointer of SkyEssenceIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $04 into the byte at $D106. What that byte counts is
; still unknown.

SkyEssenceAdjustD106::
    ld hl, $D106
    ld a, $04
    or [hl]
    ld [hl], a
    ret
