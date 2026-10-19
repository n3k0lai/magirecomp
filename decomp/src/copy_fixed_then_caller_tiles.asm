; Bank 3 at $77F3. SetupPrefixedBlockChoice calls here with A = $0D
; and BC = $52E5, after CopyRepeatedTileIndex has staged tile $20.
;
; A and BC are saved. $CD91 is filled with indexes $30 through $3F.
; The block source at $CC43 is that buffer and the count at $CC42 is
; $0A, so the first ten of those indexes are copied. CallBankedHL maps
; bank 6 and runs CopyIndexedBlocks, which reads each index as a
; 16-byte block in that bank and writes it through the destination
; already stored at $CC45.
;
; BC is then stored as the block source and the saved A as the count,
; and CopyIndexedBlocks runs again. The bank in effect on entry is
; restored by CallBankedHL.
;
; wBlockCount and wBlockSrc are the names from handle_start_press.asm,
; which is included later, so this file uses those addresses.
; CallBankedHL and CopyIndexedBlocks are already source.

DEF TILE_INDEX_30 EQU $30
DEF TILE_INDEX_STOP EQU $40
DEF FIXED_TILE_COUNT EQU $0A
DEF TILE_INDEX_BUF EQU $CD91
DEF INDEXED_BLOCK_BANK EQU $06

CopyFixedThenCallerTiles::
    push af
    push bc
    ld a, TILE_INDEX_30
    ld d, TILE_INDEX_STOP
    ld bc, TILE_INDEX_BUF
.fill:
    ld [bc], a
    inc bc
    inc a
    cp d
    jr nz, .fill
    ld bc, TILE_INDEX_BUF
    ld hl, $CC43
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, FIXED_TILE_COUNT
    ld [$CC42], a
    ld hl, CopyIndexedBlocks
    ld e, INDEXED_BLOCK_BANK
    call CallBankedHL
    pop bc
    ld hl, $CC43
    ld a, c
    ld [hl+], a
    ld [hl], b
    pop af
    ld [$CC42], a
    ld hl, CopyIndexedBlocks
    ld e, INDEXED_BLOCK_BANK
    call CallBankedHL
    ret

CopyFixedThenCallerTilesEnd:
