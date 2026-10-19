; MaelstromAdjustD11B. Bank 7 at $6DF5 (file $01EDF5).
;
; Second pointer of MaelstromIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $0C to the byte at $D110+$0B ($D11B)
; and caps the sum at $63. What that byte counts is still unknown.

MaelstromAdjustD11B::
    ld hl, $D110
    ld bc, $000B
    ld e, $63
    ld a, $0C
    call AddACapByteAtBc
    ret
