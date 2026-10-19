; Bank 0 at $2507. AdvanceWindowYSlide plants this as hScriptHandler when
; the $FFA6 window-Y index reaches $0A.
;
; [$C6EE] becomes 2, the value RunD0B1MapStrips waits for before it paints
; the $9C00 strips. [$C6ED] becomes 1. What reads that byte is unknown.
; The word at $C93D becomes $C949, the list tail named wListTailDest in
; setup_command_4d.asm. [$C6EB] becomes 1. That byte is wStripFlag in
; run_d0b1_map_strips.asm.
;
; $C6E9 and its copy at $C941 become $8860, the address just past the six
; tiles SetupWindow copied to $8800. That is tile id $86 while LCDC bit 4
; is clear. $C93F becomes map cell $9C25 (window map row 1, column 5).
; $C944 and $C946 become $86. $C945 becomes $8F, the attribute the strip
; painter writes in VRAM bank 1. $C947 becomes $A4, the tile id past the
; end of that strip.
;
; Control leaves through DispatchScriptOpcode. Every store below is the
; 3-byte form. wUnknownC6EE, vWindowTiles, WINDOW_TILE_LEN, vWindowMap,
; and WINDOW_TILE are the names from setup_window.asm. wUnknownC6E9 is
; the name from indexed_tail_07.asm. The strip bytes are named in
; run_d0b1_map_strips.asm. Those later EQUs are not in scope here.

; Unknown flag. No other source names this byte yet.
DEF wUnknownC6ED EQU $C6ED

; wListTailDest. setup_command_4d.asm names $C949.
DEF SLIDE_LIST_TAIL EQU $C949
; wStripFlag. Stored as 1 before a strip.
DEF SLIDE_STRIP_FLAG EQU $C6EB
; wUnknownC6E9 and the echo at $C941 (wStripTileEcho).
DEF SLIDE_TILE_PTR EQU $C6E9
DEF SLIDE_TILE_ECHO EQU $C941
; wStripMapCell.
DEF SLIDE_MAP_CELL EQU $C93F
; wStripTileLo, wStripTileLoCopy, wStripTileMid, wStripTileHi.
DEF SLIDE_TILE_LO EQU $C944
DEF SLIDE_TILE_LO_COPY EQU $C946
DEF SLIDE_TILE_MID EQU $C945
DEF SLIDE_TILE_END EQU $C947
; Word the strip text pointer is planted in. wUnknownC93D.
DEF SLIDE_TEXT_PTR EQU $C93D

FinishWindowYSlide::
    ld a, $02
    ld [wUnknownC6EE], a
    ld a, $01
    ld [wUnknownC6ED], a
    ld a, LOW(SLIDE_LIST_TAIL)
    ld [SLIDE_TEXT_PTR], a
    ld a, HIGH(SLIDE_LIST_TAIL)
    ld [SLIDE_TEXT_PTR + 1], a
    ld a, $01
    ld [SLIDE_STRIP_FLAG], a
    ld a, LOW(vWindowTiles + WINDOW_TILE_LEN)
    ld [SLIDE_TILE_PTR], a
    ld [SLIDE_TILE_ECHO], a
    ld a, HIGH(vWindowTiles + WINDOW_TILE_LEN)
    ld [SLIDE_TILE_PTR + 1], a
    ld [SLIDE_TILE_ECHO + 1], a
    ld a, LOW(vWindowMap + $25)
    ld [SLIDE_MAP_CELL], a
    ld a, HIGH(vWindowMap + $25)
    ld [SLIDE_MAP_CELL + 1], a
    ld a, WINDOW_TILE + 6
    ld [SLIDE_TILE_LO], a
    ld [SLIDE_TILE_LO_COPY], a
    ld a, $8f
    ld [SLIDE_TILE_MID], a
    ld a, $a4
    ld [SLIDE_TILE_END], a
    jp DispatchScriptOpcode
