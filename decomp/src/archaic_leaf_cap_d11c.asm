; ArchaicLeafCapD11C. Bank 7 at $6BD6 (file $01EBD6).
;
; Second pointer of ArchaicLeafIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $0A to the byte at $D110+$0C ($D11C)
; and caps the sum at $63. What that byte counts is still unknown.

ArchaicLeafCapD11C::
    ld hl, $D110
    ld bc, $000C
    ld e, $63
    ld a, $0A
    call AddACapByteAtBc
    ret
