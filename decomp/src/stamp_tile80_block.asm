; Write a 3x3 of tile $80 with its top-left at HL.
;
; HL is a cell on a 32-column tilemap. Each row stores three tiles, and
; DE ($001D) steps from the cell after those three to the next row. A is
; the tile. DrawIndex5Tail calls this for the open slots.

DEF TILE_BLOCK_80 EQU $80
DEF TILEMAP_STRIDE_AFTER_3 EQU $001D

StampTile80Block::
    ld a, TILE_BLOCK_80
    ld de, TILEMAP_STRIDE_AFTER_3
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    add hl, de
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    add hl, de
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ret
