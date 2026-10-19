; StoneOfDoomOrD126. Bank 7 at $6EFE (file $01EEFE).
;
; Second pointer of StoneOfDoomIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $01 into $D126. What that byte counts is still unknown.

StoneOfDoomOrD126::
    ld hl, $D126
    ld a, $01
    or [hl]
    ld [hl], a
    ret
