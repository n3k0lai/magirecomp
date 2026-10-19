; HyrensClawAdjustD11B. Bank 7 at $6DC2 (file $01EDC2).
;
; Second pointer of HyrensClawIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $05 to the byte at $D110+$0B ($D11B)
; and caps the sum at $63. What that byte counts is still unknown.

HyrensClawAdjustD11B::
    ld hl, $D110
    ld bc, $000B
    ld e, $63
    ld a, $05
    call AddACapByteAtBc
    ret
