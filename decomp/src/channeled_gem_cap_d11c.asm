; ChanneledGemCapD11C. Bank 7 at $6C0E (file $01EC0E).
;
; Second pointer of ChanneledGemIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $06 to the byte at $D110+$0C ($D11C)
; and caps the sum at $63. What that byte counts is still unknown.

ChanneledGemCapD11C::
    ld hl, $D110
    ld bc, $000C
    ld e, $63
    ld a, $06
    call AddACapByteAtBc
    ret
