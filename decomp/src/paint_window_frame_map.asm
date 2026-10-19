; Bank 4 at $557A. PaintWindowTilemap maps bank 4 and calls here before
; it paints window cells. StageCopiedBlockWindow calls here in this bank
; after clearing [$CD54].
;
; rVBK is cleared, so the first stores hit the tile map. $0233 bytes at
; $9C00 are filled with tile $80: seventeen rows of the 32-wide window
; map, plus the first nineteen cells of row 17 ($9C00 through $9E32).
;
; Tile $85 marks six corners: rows 0, 12, and 17, columns 0 and $13.
; Tile $83 fills the $12 cells between each pair. Tile $84 steps down
; columns 0 and $13 by one row ($20). Eleven steps cover rows 1-11.
; Four more cover rows 13-16. Row 12 keeps the $85 corners.
;
; When [$CD54] is 0, tile $93 is stored at $9C29, $9C2A, $9D69, and
; $9D6A. rVBK is cleared again. $54BA writes three runs of ten ascending
; tiles, each run one row lower and one column to the right. The calls
; start at $94 / $9C43, $B2 / $9CA3, and $D0 / $9D03. $92, $90, and $91
; mark cells beside those runs. A nonzero [$CD54] skips that block.
; PaintWindowTilemap sets the flag to 1, so that path leaves the inner
; cells as $80.
;
; rVBK is then 1. $0234 attribute bytes, $9C00 through $9E33, are written
; as $0F by counting BC down from $9BFF. Eighteen bytes at $9E21 become
; $4F. Column 0 of rows 1 through 16 is $2F, produced by shifting the row
; index left five times. $9C00, $9C2A, and $9DA0 are also $2F. $4F is
; stored at $9E33 and $9D69. $6F is stored at $9E20 and $9D6A.
;
; $C6F1 is cleared and $C6F0 is set to 7. Those are the window Y and X
; that StageCopiedBlockWindow writes to rWY and rWX. $54BA is still
; INCBIN. rVBK, wWindowX, wWindowY, and vWindowMap are the names from
; setup_window.asm. wWindowFlagCD54 is the name from
; paint_window_tilemap.asm.

DEF FRAME_TILE EQU $80
DEF FRAME_CORNER EQU $85
DEF FRAME_BAR EQU $83
DEF FRAME_SIDE EQU $84
DEF FRAME_MARK EQU $93
DEF FRAME_RUN_1 EQU $94
DEF FRAME_RUN_2 EQU $B2
DEF FRAME_RUN_3 EQU $D0
DEF FRAME_CAP_92 EQU $92
DEF FRAME_CAP_90 EQU $90
DEF FRAME_CAP_91 EQU $91
DEF FRAME_FILL_LEN EQU $0233
DEF FRAME_BAR_LEN EQU $12
DEF FRAME_SIDE_LONG EQU $0B
DEF FRAME_SIDE_SHORT EQU $04
DEF FRAME_ROW EQU $0020
DEF FRAME_ATTR EQU $0F
DEF FRAME_ATTR_LEN EQU $0234
DEF FRAME_ATTR_BASE EQU $9BFF
DEF FRAME_ATTR_4F EQU $4F
DEF FRAME_ATTR_ROW_LEN EQU $12
DEF FRAME_ATTR_2F EQU $2F
DEF FRAME_ATTR_6F EQU $6F
DEF FRAME_ROW_SHIFT EQU $05
DEF FRAME_COL_ROWS EQU $10
DEF FRAME_VRAM_BANK1 EQU $01
DEF FRAME_WINDOW_X EQU $07

DEF FRAME_CELL_9C13 EQU $9C13
DEF FRAME_CELL_9D80 EQU $9D80
DEF FRAME_CELL_9D93 EQU $9D93
DEF FRAME_CELL_9E20 EQU $9E20
DEF FRAME_CELL_9E33 EQU $9E33
DEF FRAME_CELL_9C01 EQU $9C01
DEF FRAME_CELL_9D81 EQU $9D81
DEF FRAME_CELL_9E21 EQU $9E21
DEF FRAME_CELL_9DA0 EQU $9DA0
DEF FRAME_CELL_9DB3 EQU $9DB3
DEF FRAME_CELL_9C20 EQU $9C20
DEF FRAME_CELL_9C33 EQU $9C33
DEF FRAME_CELL_9C29 EQU $9C29
DEF FRAME_CELL_9C2A EQU $9C2A
DEF FRAME_CELL_9D69 EQU $9D69
DEF FRAME_CELL_9D6A EQU $9D6A
DEF FRAME_CELL_9C43 EQU $9C43
DEF FRAME_CELL_9CA3 EQU $9CA3
DEF FRAME_CELL_9D03 EQU $9D03
DEF FRAME_CELL_9C42 EQU $9C42
DEF FRAME_CELL_9C4F EQU $9C4F
DEF FRAME_CELL_9DAF EQU $9DAF
DEF FRAME_CELL_9C6F EQU $9C6F
DEF FRAME_CELL_9DCF EQU $9DCF

PaintWindowFrameMap::
    xor a
    ld [rVBK], a
    ld bc, FRAME_FILL_LEN
    ld hl, vWindowMap
.fill80
    ld a, FRAME_TILE
    ld [hl+], a
    dec bc
    ld a, c
    or b
    jr nz, .fill80

    ld a, FRAME_CORNER
    ld [vWindowMap], a
    ld [FRAME_CELL_9C13], a
    ld [FRAME_CELL_9D80], a
    ld [FRAME_CELL_9D93], a
    ld [FRAME_CELL_9E20], a
    ld [FRAME_CELL_9E33], a
    ld a, FRAME_BAR
    ld hl, FRAME_CELL_9C01
    ld c, FRAME_BAR_LEN
.bar0
    ld [hl+], a
    dec c
    jr nz, .bar0

    ld a, FRAME_BAR
    ld hl, FRAME_CELL_9D81
    ld c, FRAME_BAR_LEN
.bar12
    ld [hl+], a
    dec c
    jr nz, .bar12

    ld a, FRAME_BAR
    ld hl, FRAME_CELL_9E21
    ld c, FRAME_BAR_LEN
.bar17
    ld [hl+], a
    dec c
    jr nz, .bar17

    ld a, FRAME_SIDE
    ld hl, FRAME_CELL_9DA0
    ld c, FRAME_SIDE_SHORT
    ld de, FRAME_ROW
.sideLeftLower
    ld [hl], a
    add hl, de
    dec c
    jr nz, .sideLeftLower

    ld a, FRAME_SIDE
    ld hl, FRAME_CELL_9DB3
    ld c, FRAME_SIDE_SHORT
    ld de, FRAME_ROW
.sideRightLower
    ld [hl], a
    add hl, de
    dec c
    jr nz, .sideRightLower

    ld a, FRAME_SIDE
    ld hl, FRAME_CELL_9C20
    ld c, FRAME_SIDE_LONG
    ld de, FRAME_ROW
.sideLeftUpper
    ld [hl], a
    add hl, de
    dec c
    jr nz, .sideLeftUpper

    ld a, FRAME_SIDE
    ld hl, FRAME_CELL_9C33
    ld c, FRAME_SIDE_LONG
    ld de, FRAME_ROW
.sideRightUpper
    ld [hl], a
    add hl, de
    dec c
    jr nz, .sideRightUpper

    ld a, [wWindowFlagCD54]
    and a
    jr nz, .attributes

    ld a, FRAME_MARK
    ld [FRAME_CELL_9C29], a
    ld [FRAME_CELL_9C2A], a
    ld [FRAME_CELL_9D69], a
    ld [FRAME_CELL_9D6A], a
    xor a
    ld [rVBK], a
    ld a, FRAME_RUN_1
    ld hl, FRAME_CELL_9C43
    call WriteThreeAscendingRunsFromA
    ld a, FRAME_RUN_2
    ld hl, FRAME_CELL_9CA3
    call WriteThreeAscendingRunsFromA
    ld a, FRAME_RUN_3
    ld hl, FRAME_CELL_9D03
    call WriteThreeAscendingRunsFromA
    ld a, FRAME_CAP_92
    ld [FRAME_CELL_9C42], a
    ld a, FRAME_CAP_90
    ld [FRAME_CELL_9C4F], a
    ld [FRAME_CELL_9DAF], a
    ld a, FRAME_CAP_91
    ld [FRAME_CELL_9C6F], a
    ld [FRAME_CELL_9DCF], a

.attributes
    ld a, FRAME_VRAM_BANK1
    ld [rVBK], a
    ld d, FRAME_ATTR
    ld bc, FRAME_ATTR_LEN
.attrFill
    ld hl, FRAME_ATTR_BASE
    add hl, bc
    ld [hl], d
    dec bc
    ld a, c
    or b
    jr nz, .attrFill

    ld a, FRAME_ATTR_4F
    ld d, FRAME_ATTR_ROW_LEN
    ld hl, FRAME_CELL_9E21
.attrRow17
    ld [hl+], a
    dec d
    jr nz, .attrRow17

    ld bc, FRAME_COL_ROWS
.attrCol
    ld hl, vWindowMap
    push bc
    ld a, FRAME_ROW_SHIFT
.shiftRow
    sla c
    rl b
    dec a
    jr nz, .shiftRow
    add hl, bc
    ld a, FRAME_ATTR_2F
    ld [hl+], a
    pop bc
    dec c
    jr nz, .attrCol

    ld a, FRAME_ATTR_2F
    ld [vWindowMap], a
    ld [FRAME_CELL_9C2A], a
    ld [FRAME_CELL_9DA0], a
    ld a, FRAME_ATTR_4F
    ld [FRAME_CELL_9E33], a
    ld [FRAME_CELL_9D69], a
    ld a, FRAME_ATTR_6F
    ld [FRAME_CELL_9E20], a
    ld [FRAME_CELL_9D6A], a
    xor a
    ld [wWindowY], a
    ld a, FRAME_WINDOW_X
    ld [wWindowX], a
    ret
