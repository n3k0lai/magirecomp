; WishboneAdjustD120. Bank 7 at $6FC1 (file $01EFC1).
;
; Second pointer of WishboneIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $05 to the byte at $D110+$10 ($D120)
; and caps the sum at $63. What that byte counts is still unknown.

WishboneAdjustD120::
    ld hl, $D110
    ld bc, $0010
    ld e, $63
    ld a, $05
    call AddACapByteAtBc
    ret
