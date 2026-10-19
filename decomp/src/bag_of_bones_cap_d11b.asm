; BagOfBonesCapD11B. Bank 7 at $6BF2 (file $01EBF2).
;
; Second pointer of the Bag of Bones indexed name record at file $01E94F.
; RunPairIdScripts calls it from $CD93. AddACapByteAtBc adds $08 to the
; byte at $D110+$0B ($D11B) and caps the sum at $63. What that byte
; counts is still unknown.

BagOfBonesCapD11B::
    ld hl, $D110
    ld bc, $000B
    ld e, $63
    ld a, $08
    call AddACapByteAtBc
    ret
