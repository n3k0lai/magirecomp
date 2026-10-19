; OmborsAmuletAdjustD11F. Bank 7 at $6E03 (file $01EE03).
;
; Second pointer of OmborsAmuletIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $0A to the byte at $D110+$0F ($D11F)
; and caps the sum at $63. What that byte counts is still unknown.

OmborsAmuletAdjustD11F::
    ld hl, $D110
    ld bc, $000F
    ld e, $63
    ld a, $0A
    call AddACapByteAtBc
    ret
