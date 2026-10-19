; Bank 3 at $77DF. RefreshFrameWindowPair plants this as wCallback
; for one RefreshFrame, with wCallbackBank set to 3.
;
; Both cells of the pair at $9C29 (column 9 of BG-map row 1) become
; tile $80, the blank tile. The second cell is the next byte.
; This routine does not write rROMB0 and does not call out.
;
; vGroupDownTiles and GROUP_BLANK_TILE are the names from
; scan_group_bytes.asm. wCallback is the name from default_state.asm.

PaintWindowPairCells::
    ld hl, vGroupDownTiles
    ld a, GROUP_BLANK_TILE
    ld [hl+], a
    ld [hl], a
    ret
