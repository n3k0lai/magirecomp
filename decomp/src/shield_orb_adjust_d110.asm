; ShieldOrbAdjustD110. Bank 7 at $6EBD (file $01EEBD).
;
; Second pointer of ShieldOrbIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $0F to the byte at $D110+$0E ($D11E),
; capping the sum at $63. What that byte counts is still unknown.

ShieldOrbAdjustD110::
    ld hl, $D110
    ld bc, $000E
    ld e, $63
    ld a, $0F
    call AddACapByteAtBc
    ret
