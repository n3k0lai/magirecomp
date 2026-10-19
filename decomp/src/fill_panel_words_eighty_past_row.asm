; Bank 7 at $4837. PresentInstalledScriptEntries calls this through
; CallBankedHL after storing $07 at wUnknownC9D8 and $7FFF at wUnknownC9DA.
; Bank 7 is mapped for the call and restored on the way back.
;
; $C831 is cleared. PanelRowFromHighNibble returns HL = $C72B plus eight
; times the high nibble of wUnknownC9D8. HL is then moved $80 bytes past
; that row. PanelQuadFromLowNibble returns the low byte of four times one
; more than the low nibble; that byte is the word count. BC is the
; little-endian word at wUnknownC9DA. Control joins
; FillPanelWordsFromC9DA.storeWord, which writes that word once per count
; and sets $C831 to $01.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. wUnknownC9DA and
; wUnknownC9DB are the names from dispatch_nonzero_d016.asm. $C831 and
; $C72B are still unnamed.

FillPanelWordsEightyPastRow::
    xor a
    ld [$C831], a
    call PanelRowFromHighNibble
    ld bc, $0080
    add hl, bc
    call PanelQuadFromLowNibble
    ld e, a
    ld a, [wUnknownC9DB]
    ld b, a
    ld a, [wUnknownC9DA]
    ld c, a
    jr FillPanelWordsFromC9DA.storeWord
