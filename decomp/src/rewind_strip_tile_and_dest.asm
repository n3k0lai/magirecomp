; Bank 0 at $2C7B. StepStripTextCell calls this before each strip character.
;
; wStripTileId is the next tile id and wStripTileEnd is the id that ends
; the range. While they differ, this returns. When they match, the saved
; start at $C946 is written back to the tile id, and the pointer saved at
; $C941 is copied back to wGlyphDest.
;
; wStripTileId and wStripTileEnd are the names from step_map_strip_glyph.asm.
; wGlyphDest is the name from draw_cgb_notice.asm. The caller names this
; address RewindStripTiles.

; Tile id stored with the start of the strip.
DEF wStripTileStart EQU $C946
; Glyph destination saved for the start of the strip. Low byte, then high.
DEF wStripGlyphDestSave EQU $C941

RewindStripTileAndDest::
    ld a, [wStripTileId]
    ld d, a
    ld a, [wStripTileEnd]
    cp d
    ret nz
    ld a, [wStripTileStart]
    ld [wStripTileId], a
    ld a, [wStripGlyphDestSave]
    ld [wGlyphDest], a
    ld a, [wStripGlyphDestSave + 1]
    ld [wGlyphDest + 1], a
    ret
