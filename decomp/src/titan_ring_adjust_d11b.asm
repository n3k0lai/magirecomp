; TitanRingAdjustD11B. Bank 7 at $6F65 (file $01EF65).
;
; Second pointer of TitanRingIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $08 to the byte at $D110+$0B ($D11B)
; and caps the sum at $63. What that byte counts is still unknown.

TitanRingAdjustD11B::
    ld hl, $D110
    ld bc, $000B
    ld e, $63
    ld a, $08
    call AddACapByteAtBc
    ret
