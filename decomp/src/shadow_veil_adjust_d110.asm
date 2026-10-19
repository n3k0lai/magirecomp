; ShadowVeilAdjustD110. Bank 7 at $6E9B (file $01EE9B).
;
; Second pointer of ShadowVeilIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $14 to the byte at $D110+$0F ($D11F)
; and $14 at $D110+$0E ($D11E), capping each sum at $63. Then $40 is
; ORed into $D126. What those bytes count is still unknown.

ShadowVeilAdjustD110::
    ld hl, $D110
    ld bc, $000F
    ld e, $63
    ld a, $14
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000E
    ld e, $63
    ld a, $14
    call AddACapByteAtBc
    ld hl, $D126
    ld a, $40
    or [hl]
    ld [hl], a
    ret
