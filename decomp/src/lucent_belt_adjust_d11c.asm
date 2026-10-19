; LucentBeltAdjustD11C. Bank 7 at $6DE7 (file $01EDE7).
;
; Second pointer of LucentBeltIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $0A to the byte at $D110+$0C ($D11C)
; and caps the sum at $63. What that byte counts is still unknown.

LucentBeltAdjustD11C::
    ld hl, $D110
    ld bc, $000C
    ld e, $63
    ld a, $0A
    call AddACapByteAtBc
    ret
