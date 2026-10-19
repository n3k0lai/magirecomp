; BarkThimbleCapD11E. Bank 7 at $6C00 (file $01EC00).
;
; Second pointer of BarkThimbleIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $04 to the byte at $D110+$0E ($D11E)
; and caps the sum at $63. What that byte counts is still unknown.

BarkThimbleCapD11E::
    ld hl, $D110
    ld bc, $000E
    ld e, $63
    ld a, $04
    call AddACapByteAtBc
    ret
