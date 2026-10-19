; Bank 7 at $5CB9. FillMapPanelTiles maps this bank and calls here.
;
; $C831 is cleared. BC is the word at $C9E5 (low byte) and $C9E6 (high
; byte). $4774, still INCBIN, writes that word once at $C72B plus twice
; $18. BC is then zero, and $4774 writes that word once at $C72B plus
; twice $19, the next slot. $C831 is set to $01 before the return.
;
; $C831, $C72B, $C9E5, and $C9E6 are still unnamed. $4774 takes HL as the
; table, E as the slot, A as the write count, and BC as the word.

WritePanelWordThenZero::
    xor a
    ld [$C831], a
    ld a, [$C9E6]
    ld b, a
    ld a, [$C9E5]
    ld c, a
    ld hl, $C72B
    ld e, $18
    ld a, $01
    call WriteWordAtTwiceEStride8
    ld bc, $0000
    ld hl, $C72B
    ld e, $19
    ld a, $01
    call WriteWordAtTwiceEStride8
    ld a, $01
    ld [$C831], a
    ret
