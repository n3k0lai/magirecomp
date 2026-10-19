; GoldenCloverAdjustD120. Bank 7 at $6D98 (file $01ED98).
;
; Second pointer of GoldenCloverIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $0F to the byte at $D110+$10 ($D120)
; and caps the sum at $63. What that byte counts is still unknown.

GoldenCloverAdjustD120::
    ld hl, $D110
    ld bc, $0010
    ld e, $63
    ld a, $0F
    call AddACapByteAtBc
    ret
