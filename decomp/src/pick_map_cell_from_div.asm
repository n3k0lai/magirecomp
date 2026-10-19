; Bank 1 body that MapBank1AndJump enters after opcode $11 maps this bank.
;
; The low nibble of rDIV, times three, indexes a 3-byte record at $639E.
; That table is still INCBIN in this bank. Its first byte is added to
; wMapRow and stored as hObjectCellY. The next two bytes are a pointer,
; and the little-endian word at that pointer is the base.
;
; The high nibble of rDIV indexes a byte at $638E, also still INCBIN.
; That byte is added to wMapColumn and stored as hObjectCellX. The same
; byte is then a 16-bit offset added to the base word and to wMapPointer.
; The sum is stored little-endian at $FF93. Those two stores use the
; 3-byte form. What the word names is still unknown.
;
; hScriptHandler is set to $0C9A with ldh. That is the byte after
; MapBank1AndJump, still INCBIN. This returns to the caller of the
; previous handler. The next pass through hScriptHandler starts at $0C9A.
;
; rDIV is the name from mask_div_by_c.asm. wMapColumn and wMapPointer are
; the names from draw_metatile_window.asm. wMapRow, hObjectCellX, and
; hObjectCellY are the names from queue_sprite_list.asm. hScriptHandler
; is the name from reset.asm.

; Little-endian word filled with the adjusted map pointer. 3-byte stores.
DEF hMapCellPointer EQU $FF93

PickMapCellFromDiv::
    ld a, [rDIV]
    and $0f
    ld b, a
    add a
    add b
    ld c, a
    ld b, $00
    ld hl, RdivLowNibbleRowRecords
    add hl, bc
    ld a, [hl+]
    ld b, a
    ld a, [wMapRow]
    add b
    ldh [hObjectCellY], a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    ld a, [rDIV]
    swap a
    and $0f
    ld c, a
    ld b, $00
    ld hl, RdivHighNibbleColumnAdds
    add hl, bc
    ld b, [hl]
    ld a, [wMapColumn]
    add b
    ldh [hObjectCellX], a
    ld l, b
    ld h, $00
    add hl, de
    ld a, [wMapPointer + 1]
    ld d, a
    ld a, [wMapPointer]
    ld e, a
    add hl, de
    ld a, h
    ld [hMapCellPointer + 1], a
    ld a, l
    ld [hMapCellPointer], a
    ld a, LOW($0C9A)
    ldh [hScriptHandler], a
    ld a, HIGH($0C9A)
    ldh [hScriptHandler + 1], a
    ret
