; Bank 7 at $480C. StagePairSourceThenCopyWords maps this bank and calls
; here after a script byte is stored at wUnknownC9D8.
;
; PanelRowFromHighNibble returns HL = $C72B plus eight times the high
; nibble of that byte. The pointer is stored little-endian at
; wUnknownC9DA. PanelQuadFromLowNibble returns A as four times one more
; than the low nibble (its high byte stays in E and is unused). That
; count is stored at wPanelSlot. The caller then copies that many word
; pairs into the stored pointer, with no stride skip.
;
; PanelRowFromHighNibble is the name from panel_row_from_high_nibble.asm.
; PanelQuadFromLowNibble is the name from panel_quad_from_low_nibble.asm.
; wUnknownC9D8 is the name from indexed_tail_07.asm. wUnknownC9DA and
; wUnknownC9DB are the names from dispatch_nonzero_d016.asm. wPanelSlot
; is the name from stage_panel_glyph_dest.asm.

StagePanelRowPtrAndPairCount::
    call PanelRowFromHighNibble
    ld a, h
    ld [wUnknownC9DB], a
    ld a, l
    ld [wUnknownC9DA], a
    call PanelQuadFromLowNibble
    ld [wPanelSlot], a
    ret
