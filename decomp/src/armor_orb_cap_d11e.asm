; ArmorOrbCapD11E. Bank 7 at $6BE4 (file $01EBE4).
;
; Second pointer of ArmorOrbIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $0C to the byte at $D110+$0E ($D11E)
; and caps the sum at $63. What that byte counts is still unknown.

ArmorOrbCapD11E::
    ld hl, $D110
    ld bc, $000E
    ld e, $63
    ld a, $0C
    call AddACapByteAtBc
    ret
