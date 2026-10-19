; StoneEssenceOrD122. Bank 7 at $6F06 (file $01EF06).
;
; Second pointer of StoneEssenceIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $04 into $D122 and $02 into $D123. What those bytes
; count is still unknown.

StoneEssenceOrD122::
    ld hl, $D122
    ld a, $04
    or [hl]
    ld [hl], a
    ld hl, $D123
    ld a, $02
    or [hl]
    ld [hl], a
    ret
