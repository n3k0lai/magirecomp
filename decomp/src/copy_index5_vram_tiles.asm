; Index-5 tile copy. DrawIndex5Tail calls this while bank 6 is mapped,
; then calls the eight-tile tail at $5145.
;
; This selects VRAM bank 1 and copies $2D0 bytes from $74D6 to $8CB0.
; Sixteen bytes per tile makes forty-five tiles. The source is still
; INCBIN in this bank. CopyHLToDE is the name from copy_bytes.asm.
; The store to rVBK is the 3-byte form. rVBK is the name from
; setup_window.asm.

DEF INDEX5_TILE_BYTES EQU $02D0
DEF vIndex5Tiles EQU $8CB0

CopyIndex5VRAMTiles::
    ld a, $01
    ld [rVBK], a
    ld bc, INDEX5_TILE_BYTES
    ld hl, Index5TilesAt74D6
    ld de, vIndex5Tiles
    call CopyHLToDE
    ret
