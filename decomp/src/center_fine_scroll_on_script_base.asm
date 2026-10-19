; Script step at $1E30. The word at $C18E is copied into DE. Both fine
; scroll bytes are set to 8, the middle of a 0-15 tile: $C85D is fine X
; and $C85E is fine Y. Control then jumps to StoreMapCellFromDEMinus5,
; which stores DE minus 5 as the map column and row and leaves through
; DispatchScriptOpcode.
;
; $C18E and $C18F are the script base from opcode_02.asm. The fine bytes
; are the ones StepHorizontalScroll and StepVerticalScroll step.
; StoreMapCellFromDEMinus5 is the name from
; store_map_cell_from_de_minus5.asm. Nothing here calls or jumps into
; an INCBIN.

DEF FINE_SCROLL_CENTER EQU $08

CenterFineScrollOnScriptBase::
    ld a, [$c18e]
    ld e, a
    ld a, [$c18f]
    ld d, a
    ld a, FINE_SCROLL_CENTER
    ld [$c85d], a
    ld a, FINE_SCROLL_CENTER
    ld [$c85e], a
    jp StoreMapCellFromDEMinus5
