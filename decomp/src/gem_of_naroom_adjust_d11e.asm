; GemOfNaroomAdjustD11E. Bank 7 at $6D8A (file $01ED8A).
;
; Second pointer of GemOfNaroomIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $05 to the byte at $D110+$0E ($D11E)
; and caps the sum at $63. What that byte counts is still unknown.

GemOfNaroomAdjustD11E::
    ld hl, $D110
    ld bc, $000E
    ld e, $63
    ld a, $05
    call AddACapByteAtBc
    ret
