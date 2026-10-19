; Index 9 of IndexedSetup. Paint start-screen map tiles from sMapFlag.
;
; $5110 runs first, while this bank is still mapped. VRAM bank 0 is
; selected with the 3-byte store. SRAM is enabled in the bank at $C727.
; `add a, $00` keeps that bank byte and its flags; nothing reads them.
; Byte $A3A4 (sMapFlag) is taken into D, then SRAM is disabled.
;
; Each higher value writes the next tile or pair and returns on a match.
; A value other than 1 through 5 also calls $65FD with BC = $6F92, which
; copies five rows of four tiles. The `inc bc` after a one-byte copy is
; unused. The sources sit in this bank:
;   1             return
;   >= 2          two bytes at $6FA6 to $9CC9
;   >= 3          one byte at $6FA8 to $9CE9
;   >= 4          one byte at $6FA9 to $9CEA
;   >= 5          two bytes at $6FAA to $9D09
;
; rVBK is the name from setup_window.asm. rRAMG is the name from reset.asm.
; rRAMB, wSRAMBank, and SRAM_ENABLE are the names from handle_start_press.asm.
; sMapFlag is the name from draw_start_screen_map.asm. MAP_FLAG_MARK_2,
; MAP_FLAG_MARK_4, MAP_FLAG_MARK_5, and Bank6_65FD are the names from
; stamp_setup_attributes.asm. $5110 and $65FD are still INCBIN.

DEF MAP_FLAG_STOP_1 EQU $01
DEF MAP_FLAG_STOP_3 EQU $03

; Tile sources in this bank, just before the attribute block at $6FAC.
DEF Index9TileAt3 EQU $6FA8
DEF Index9TileAt4 EQU $6FA9
DEF Index9TilesAt5 EQU $6FAA

; BG-map cells. $9CEA is the same address as the attribute cell vAttr9CEA.
DEF vIndex9Map9CC9 EQU $9CC9
DEF vIndex9Map9CE9 EQU $9CE9
DEF vIndex9Map9CEA EQU $9CEA
DEF vIndex9Map9D09 EQU $9D09

DrawIndex9Map::
    call $5110
    xor a
    ld [rVBK], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [sMapFlag]
    ld d, a
    xor a
    ld [rRAMG], a
    ld a, d
    cp MAP_FLAG_STOP_1
    ret z

    ld hl, vIndex9Map9CC9
    ld bc, Index9StampTiles
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, d
    cp MAP_FLAG_MARK_2
    ret z

    ld hl, vIndex9Map9CE9
    ld bc, Index9TileAt3
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, d
    cp MAP_FLAG_STOP_3
    ret z

    ld hl, vIndex9Map9CEA
    ld bc, Index9TileAt4
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, d
    cp MAP_FLAG_MARK_4
    ret z

    ld hl, vIndex9Map9D09
    ld bc, Index9TilesAt5
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, d
    cp MAP_FLAG_MARK_5
    ret z

    ld bc, Index9RowStrip
    call Bank6_65FD
    ret
