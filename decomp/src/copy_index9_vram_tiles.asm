; First step of the index 9 map paint. Copy seventy tiles into VRAM bank 1.
;
; DrawIndex9Map calls this while bank 6 is still mapped, then selects
; VRAM bank 0. This selects VRAM bank 1 and copies $460 bytes from $79A6
; to $9000. Sixteen bytes per tile makes seventy tiles. The source is
; still INCBIN in this bank. CopyHLToDE is the name from copy_bytes.asm.
; The store to rVBK is the 3-byte form. rVBK is the name from
; setup_window.asm.

DEF INDEX9_TILE_BYTES EQU $0460
DEF INDEX9_TILE_SRC EQU $79A6
DEF vIndex9Tiles EQU $9000

CopyIndex9VRAMTiles::
    ld a, $01
    ld [rVBK], a
    ld bc, INDEX9_TILE_BYTES
    ld hl, INDEX9_TILE_SRC
    ld de, vIndex9Tiles
    call CopyHLToDE
    ret
