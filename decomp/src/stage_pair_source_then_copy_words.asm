; Script entry at $1C6E. Copies the next three script bytes to
; wPairSourcePtr and wPairSourceBank. $1C7A is the store of that bank
; byte when A already holds it. StoreScriptByteAtC9D8 copies the next
; script byte to wUnknownC9D8. BC is saved as hScriptPtr.
;
; Bank 7 is mapped, then $480C in that bank is called. The saved bank
; is pushed, wPairSourceBank is mapped, and CopyWordPairs runs with
; BC from wPairSourcePtr, HL from the word at wUnknownC9DA, E = $00,
; and A = wPanelSlot. The saved bank is restored. hScriptHandler
; becomes INITIAL_SCRIPT_HANDLER ($0A66). The pointer and handler
; stores are the 3-byte form.
;
; wPairSourcePtr and wPairSourceBank are the names from
; load_c9_record_picture.asm. StoreScriptByteAtC9D8 is the name from
; store_script_byte_at_c9d8.asm. wUnknownC9D8 is the name from
; indexed_tail_07.asm. wUnknownC9DA and wUnknownC9DB are the names from
; dispatch_nonzero_d016.asm. wPanelSlot is the name from
; stage_panel_glyph_dest.asm. CopyWordPairs is the name from
; copy_word_pairs.asm. hScriptPtr, hScriptHandler,
; INITIAL_SCRIPT_HANDLER, wCurrentROMBank, and rROMB0 are the names
; from reset.asm. $480C is still INCBIN. Its file address is $01C80C.

StagePairSourceThenCopyWords::
    ld a, [bc]
    inc bc
    ld [wPairSourcePtr], a
    ld a, [bc]
    inc bc
    ld [wPairSourcePtr + 1], a
    ld a, [bc]
    inc bc

StorePairBankThenCopyWords::
    ld [wPairSourceBank], a
    call StoreScriptByteAtC9D8
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call StagePanelRowPtrAndPairCount
    ld a, [wCurrentROMBank]
    push af
    ld a, [wPairSourceBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [wUnknownC9DB]
    ld h, a
    ld a, [wUnknownC9DA]
    ld l, a
    ld a, [wPairSourcePtr + 1]
    ld b, a
    ld a, [wPairSourcePtr]
    ld c, a
    ld e, $00
    ld a, [wPanelSlot]
    call CopyWordPairs
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret
