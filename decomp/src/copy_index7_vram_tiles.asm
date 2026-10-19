; Copy the index-7 tile block into VRAM bank 1, then the eight-tile tail.
;
; Indexed tail 7 calls this after the ten blocks land at $8AB0. This bank
; stays mapped. VRAM bank 1 is selected, then CopyHLToDE copies $180 bytes
; from $77A6 to $9150. Those are twenty-four tiles. Control falls into the
; tail below, which copies the next $80 bytes.
;
; The tail is also an entry. The index-5 path calls it after $5122, which
; is still INCBIN. It selects VRAM bank 1 again and copies eight tiles
; from $7926 to $92D0. $77A6 + $180 is $7926, and $9150 + $180 is $92D0,
; so a full call writes $200 bytes as one run of thirty-two tiles. The
; sources are still INCBIN in this bank.
;
; The stores to rVBK are the 3-byte form. rVBK is the name from
; setup_window.asm. CopyHLToDE is the name from copy_bytes.asm.

; Twenty-four tiles, then the eight-tile tail. 16 bytes per tile.
DEF INDEX7_TILE_BYTES EQU $0180
DEF INDEX7_TAIL_BYTES EQU $0080
DEF INDEX7_TILE_SRC EQU $77A6
DEF INDEX7_TAIL_SRC EQU $7926
DEF vIndex7Tiles EQU $9150
DEF vIndex7TileTail EQU $92D0

CopyIndex7VRAMTiles::
    ld a, $01
    ld [rVBK], a
    ld bc, INDEX7_TILE_BYTES
    ld hl, INDEX7_TILE_SRC
    ld de, vIndex7Tiles
    call CopyHLToDE

CopyIndex7VRAMTail::
    ld a, $01
    ld [rVBK], a
    ld bc, INDEX7_TAIL_BYTES
    ld hl, INDEX7_TAIL_SRC
    ld de, vIndex7TileTail
    call CopyHLToDE
    ret
