; Entry at $1D3D. L is set to $FB (-5). E plus that bias is stored at
; wMapColumn ($C85F), and D plus the same bias is stored at wMapRow
; ($C860). Control then jumps to DispatchScriptOpcode ($0A66).
;
; $1D3F is a second entry that keeps whatever bias is already in L.
; $1D44 stores only the row and then takes the same jump. What loads D
; and E is still outside this slice.
;
; wMapColumn is the name from draw_metatile_window.asm. wMapRow is the
; name from queue_sprite_list.asm. DispatchScriptOpcode is the name
; from dispatch_script_opcode.asm.

DEF MAP_CELL_BIAS EQU $FB

StoreMapCellFromDEMinus5::
    ld l, MAP_CELL_BIAS

StoreMapCellFromL::
    ld a, l
    add e
    ld [wMapColumn], a

StoreMapRowFromL::
    ld a, l
    add d
    ld [wMapRow], a
    jp DispatchScriptOpcode
