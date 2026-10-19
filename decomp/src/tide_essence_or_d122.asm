; TideEssenceOrD122. Bank 7 at $6F4E (file $01EF4E).
;
; Second pointer of TideEssenceIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $10 into $D122 and $04 into $D123. What those bytes
; count is still unknown.

TideEssenceOrD122::
    ld hl, $D122
    ld a, $10
    or [hl]
    ld [hl], a
    ld hl, $D123
    ld a, $04
    or [hl]
    ld [hl], a
    ret
