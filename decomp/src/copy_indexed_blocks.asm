; Copy wBlockCount 16-byte blocks from this bank into VRAM bank 1.
;
; HandleStartPress calls this twice. wBlockSrc ($CC43) is a pointer to a
; list of tile indexes. Each index is shifted left four times and added to
; $4000, and those 16 bytes are written through wBlockDest ($CC45). The
; source pointer advances by one index and the destination by 16. wBlockCount
; ($CC42) is decremented after each block. A zero count returns; otherwise
; the loop reads the next index. The VRAM bank select is outside that loop.
;
; Those three names are defined in handle_start_press.asm, which is included
; later, so this file uses the addresses. rVBK is the name from
; setup_window.asm. The store is the 3-byte form.

DEF TILE_BYTES EQU 16
DEF INDEX_SHIFT EQU 4

CopyIndexedBlocks::
    ld a, $01
    ld [rVBK], a
.loop:
    ld hl, $CC43
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hl+]
    ld e, a
    ld a, h
    ld [$CC44], a
    ld a, l
    ld [$CC43], a
    ld d, $00
    ld a, INDEX_SHIFT
.shift:
    sla e
    rl d
    dec a
    jr nz, .shift
    ld hl, $CC45
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $4000
    add hl, de
    ld d, TILE_BYTES
.copy:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copy
    ld hl, $CC45
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $CC42
    dec [hl]
    ret z
    jr .loop

CopyIndexedBlocksEnd:
