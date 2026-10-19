; CopyEightWordPairsAtIndex18. Bank 0 at $35CC.
;
; Clears $C831. $2EB6, still INCBIN, doubles E and adds that byte
; offset to HL, then copies A words from BC. Here HL is $C72B, E is
; $18, and A is $08, so eight word pairs land at $C72B+$30. $C831 is
; set to $01 before the return. BC is the source pointer from the
; caller. $C831 and $C72B are still unnamed.

CopyEightWordPairsAtIndex18::
    xor a
    ld [$C831], a
    ld hl, $C72B
    ld e, $18
    ld a, $08
    call $2EB6
    ld a, $01
    ld [$C831], a
    ret
