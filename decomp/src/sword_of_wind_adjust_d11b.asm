; SwordOfWindAdjustD11B. Bank 7 at $6F40 (file $01EF40).
;
; Second pointer of SwordOfWindIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $0F to the byte at $D110+$0B ($D11B)
; and caps the sum at $63. What that byte counts is still unknown.

SwordOfWindAdjustD11B::
    ld hl, $D110
    ld bc, $000B
    ld e, $63
    ld a, $0F
    call AddACapByteAtBc
    ret
