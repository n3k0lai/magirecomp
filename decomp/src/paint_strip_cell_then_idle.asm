; Bank 0 at $2AC8.
;
; The word at wStripMapCellPtr is one map cell. VRAM bank 1 receives the
; attribute at STRIP_TILE_ATTR. VRAM bank 0 receives the tile id at
; wStripCellTile. That id is incremented, and the cell pointer advances
; by one. wCallback then becomes IdleCallback.
;
; $2ACB continues with the cell's high byte already in A. Who enters there
; is still unknown. The rVBK stores are the 3-byte form. rVBK is the name
; from setup_window.asm. wStripMapCellPtr and STRIP_TILE_ATTR are the names
; from paint_strip_map_cells.asm. wStripCellTile is the name from
; copy_glyph_then_paint_cell.asm. wCallback and IdleCallback are the names
; from default_state.asm.

PaintStripCellThenIdle::
    ld a, [wStripMapCellPtr + 1]
.withHigh:
    ld h, a
    ld a, [wStripMapCellPtr]
    ld l, a
    ld a, $01
    ld [rVBK], a
    ld a, [STRIP_TILE_ATTR]
    ld [hl], a
    xor a
    ld [rVBK], a
    ld a, [wStripCellTile]
    ld [hl+], a
    inc a
    ld [wStripCellTile], a
    ld a, h
    ld [wStripMapCellPtr + 1], a
    ld a, l
    ld [wStripMapCellPtr], a
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
