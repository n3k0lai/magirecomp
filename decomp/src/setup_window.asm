; Set the window position and fill the $9C00 tilemap.
;
; default_state.asm calls this address as SetupWindow, through CallHLInBank,
; with ROM bank 0 mapped. This routine maps bank 6 for the tile copy and
; leaves that bank mapped. CallHLInBank maps the previous bank again on
; return.
;
; $C6EC and $C6EE are cleared. Their roles are still unknown. A is loaded
; with 7 and stored at $C6F0 and rWX. $90 is stored at $C6F1 and rWY. Those
; WRAM bytes take the same values as the window registers. WX 7 is the left
; edge of the screen. WY $90 is the first line below the picture, so the
; window sits just off screen.
;
; VRAM bank 1 is selected, then $60 bytes are copied from bank 6's $50B0 to
; $8800. That is six tiles. $A0 bytes at $9C00, five rows of the 32-wide
; window map, are filled in VRAM bank 1 with $8F: palette 7, tile data from
; VRAM bank 1, and BG-to-OAM priority. VRAM bank 0 is selected and the same
; $A0 bytes are filled with tile index $80, the first tile of that copy
; while LCDC bit 4 is clear.
;
; The fill byte is loaded into A, then moved to E. FillBytes reads E.
; On return A is $80, BC is 0, DE is $8860, HL is $9CA0, VRAM bank 0 is
; selected, and ROM bank 6 is mapped. Every store to a high address below
; is the 3-byte form.
; wCurrentROMBank and rROMB0 are the names from reset.asm. FillBytes is the
; name from fill_bytes.asm.

DEF rWX EQU $FF4B
DEF rWY EQU $FF4A
DEF rVBK EQU $FF4F

; Written with the same values as rWX and rWY.
DEF wWindowX EQU $C6F0
DEF wWindowY EQU $C6F1

; Cleared here. Their roles are still unknown.
DEF wUnknownC6EC EQU $C6EC
DEF wUnknownC6EE EQU $C6EE

DEF BANK_WINDOW_TILES EQU $06
DEF WindowTileSrc EQU $50B0
DEF vWindowTiles EQU $8800
DEF vWindowMap EQU $9C00
DEF WINDOW_TILE_LEN EQU $0060
DEF WINDOW_MAP_LEN EQU $00A0
DEF WINDOW_X EQU $07
DEF WINDOW_Y EQU $90
; Palette 7, tile VRAM bank 1, BG-to-OAM priority.
DEF WINDOW_ATTR EQU $8F
DEF WINDOW_TILE EQU $80

; Bank 0, still INCBIN. Copies BC bytes from HL to DE.
DEF CopyBytes EQU $07A0

SetupWindowTilemap::
    xor a
    ld [wUnknownC6EC], a
    ld [wUnknownC6EE], a
    ld a, WINDOW_X
    ld [wWindowX], a
    ld [rWX], a
    ld a, WINDOW_Y
    ld [wWindowY], a
    ld [rWY], a
    ld a, BANK_WINDOW_TILES
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, $01
    ld [rVBK], a
    ld hl, WindowTileSrc
    ld de, vWindowTiles
    ld bc, WINDOW_TILE_LEN
    call CopyBytes
    ld hl, vWindowMap
    ld bc, WINDOW_MAP_LEN
    ld a, WINDOW_ATTR
    ld e, a
    call FillBytes
    xor a
    ld [rVBK], a
    ld hl, vWindowMap
    ld bc, WINDOW_MAP_LEN
    ld a, WINDOW_TILE
    ld e, a
    call FillBytes
    ret
