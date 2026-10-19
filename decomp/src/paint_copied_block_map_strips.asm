; Bank 3 at $5627. StageCopiedBlockArmSlot calls this after
; CopyIndexedBlocks and before TurnOnLCDIfOff.
;
; rVBK is cleared with the 3-byte store, so the writes land in VRAM
; bank 0. Three runs on the $9C00 map get rising tile ids, and one run
; gets the blank tile $80. The first run starts at $EE and the next two
; continue through the wrap at $00. What the pictures are is still
; unknown.
;
; $9DC2 is row 14, column 2: $0D tiles, $EE through $FA.
; $9DE2 is row 15, column 2: $09 tiles, $FB through $03.
; $9E02 is row 16, column 2: $07 tiles, $04 through $0A.
; $9DEE is row 15, column 14: $04 copies of $80, with A left unchanged.
;
; On return HL is $9DF2, A is $80, and B is 0. rVBK is the name from
; setup_window.asm. The blank tile is the same $80 as TILE_MAP_FILL in
; draw_start_screen_map.asm, which is included later.

DEF MAP_STRIP_9DC2 EQU $9DC2
DEF MAP_STRIP_9DE2 EQU $9DE2
DEF MAP_STRIP_9E02 EQU $9E02
DEF MAP_BLANK_9DEE EQU $9DEE

DEF STRIP_9DC2_TILE EQU $EE
DEF STRIP_9DC2_LEN EQU $0D
DEF STRIP_9DE2_TILE EQU $FB
DEF STRIP_9DE2_LEN EQU $09
DEF STRIP_9E02_TILE EQU $04
DEF STRIP_9E02_LEN EQU $07
DEF STRIP_9DEE_LEN EQU $04
DEF STRIP_BLANK_TILE EQU $80

PaintCopiedBlockMapStrips::
    xor a
    ld [rVBK], a
    ld hl, MAP_STRIP_9DC2
    ld a, STRIP_9DC2_TILE
    ld b, STRIP_9DC2_LEN
.row9DC2:
    ld [hl+], a
    inc a
    dec b
    jr nz, .row9DC2

    ld hl, MAP_STRIP_9DE2
    ld a, STRIP_9DE2_TILE
    ld b, STRIP_9DE2_LEN
.row9DE2:
    ld [hl+], a
    inc a
    dec b
    jr nz, .row9DE2

    ld hl, MAP_STRIP_9E02
    ld a, STRIP_9E02_TILE
    ld b, STRIP_9E02_LEN
.row9E02:
    ld [hl+], a
    inc a
    dec b
    jr nz, .row9E02

    ld hl, MAP_BLANK_9DEE
    ld a, STRIP_BLANK_TILE
    ld b, STRIP_9DEE_LEN
.blank9DEE:
    ld [hl+], a
    dec b
    jr nz, .blank9DEE

    ret
