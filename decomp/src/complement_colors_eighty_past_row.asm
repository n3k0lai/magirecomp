; Bank 7 at $48DC. StoreScriptByteCall48DC stores the next script byte at
; wUnknownC9D8, maps this bank, and calls here.
;
; $C831 is cleared. PanelRowFromHighNibble returns HL = $C72B plus eight
; times the high nibble of wUnknownC9D8. HL is then moved $80 bytes past
; that row. BC is four times one more than the low nibble of wUnknownC9D8,
; the word count ComplementColorWords inverts at HL. $C831 is set to $01
; before the return.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. PanelRowFromHighNibble
; and ComplementColorWords are already source. $C831 and $C72B are still
; unnamed.

ComplementColorsEightyPastRow::
    xor a
    ld [$C831], a
    call PanelRowFromHighNibble
    ld bc, $0080
    add hl, bc
    ld a, [wUnknownC9D8]
    and $0F
    inc a
    sla a
    sla a
    ld c, a
    ld b, $00
    call ComplementColorWords
    ld a, $01
    ld [$C831], a
    ret
