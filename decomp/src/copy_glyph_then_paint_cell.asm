; Bank 0 at $2B28. StepStripTextCell stores this at wCallback after a
; text byte has a glyph pointer ready.
;
; CopyGlyphBytes copies the 16 bytes at wGlyphSrc to wGlyphDest and
; leaves IdleCallback at wCallback. This then paints one map cell.
; The word at wStripMapCellPtr is that cell. VRAM bank 1 receives the
; attribute at STRIP_TILE_ATTR. VRAM bank 0 receives the tile id at
; $C944. That id is incremented, and the cell pointer advances by one.
;
; $2B2B loads the cell and continues. $2B32 takes its low byte in A.
; $2B40 writes the tile id. Who enters those points is unknown.
; The rVBK stores are the 3-byte form. rVBK is the name from
; setup_window.asm. wStripMapCellPtr and STRIP_TILE_ATTR are the names
; from paint_strip_map_cells.asm. CopyGlyphBytes is already source.
; $C944 is the same byte as wStripTileId in step_map_strip_glyph.asm.

; Tile id written into this map cell, then incremented.
DEF wStripCellTile EQU $C944

CopyGlyphThenPaintCell::
    call CopyGlyphBytes
.loadCell:
    ld a, [wStripMapCellPtr + 1]
    ld h, a
    ld a, [wStripMapCellPtr]
.withLow:
    ld l, a
    ld a, $01
    ld [rVBK], a
    ld a, [STRIP_TILE_ATTR]
    ld [hl], a
    xor a
    ld [rVBK], a
.writeTile:
    ld a, [wStripCellTile]
    ld [hl+], a
    inc a
    ld [wStripCellTile], a
    ld a, h
    ld [wStripMapCellPtr + 1], a
    ld a, l
    ld [wStripMapCellPtr], a
    ret
