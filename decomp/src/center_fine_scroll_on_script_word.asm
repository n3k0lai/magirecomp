; Script step at $1E8E. The next two script bytes are a little-endian
; word, copied into DE, and BC moves past them. Both fine-scroll bytes
; are set to 8, the middle of a 0-15 tile: $C85D is fine X and $C85E is
; fine Y. A is loaded once and stored to both. Control then jumps to
; StoreMapCellFromDEMinus5, which stores DE minus 5 as the map column
; and row and leaves through DispatchScriptOpcode. This step does not
; write BC back to the script pointer.
;
; The fine bytes are the ones StepHorizontalScroll and StepVerticalScroll
; step. FINE_SCROLL_CENTER is the constant from
; center_fine_scroll_on_script_base.asm. StoreMapCellFromDEMinus5 is the
; name from store_map_cell_from_de_minus5.asm. Nothing here calls or
; jumps into an INCBIN.

CenterFineScrollOnScriptWord::
    ld a, [bc]
    ld e, a
    inc bc
    ld a, [bc]
    ld d, a
    inc bc
    ld a, FINE_SCROLL_CENTER
    ld [$c85d], a
    ld [$c85e], a
    jp StoreMapCellFromDEMinus5
