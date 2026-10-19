; SkyEssenceOrD122. Bank 7 at $6ECB (file $01EECB).
;
; Second pointer of SkyEssenceIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $08 into $D122 and $01 into $D123. What those bytes
; count is still unknown.

SkyEssenceOrD122::
    ld hl, $D122
    ld a, $08
    or [hl]
    ld [hl], a
    ld hl, $D123
    ld a, $01
    or [hl]
    ld [hl], a
    ret
