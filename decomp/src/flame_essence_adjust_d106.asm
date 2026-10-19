; FlameEssenceAdjustD106. Bank 7 at $6D82 (file $01ED82).
;
; Third pointer of FlameEssenceIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $02 into the byte at $D106. What that byte counts is
; still unknown.

FlameEssenceAdjustD106::
    ld hl, $D106
    ld a, $02
    or [hl]
    ld [hl], a
    ret
