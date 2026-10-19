; Bank 3 at $772F. Called with A holding how many copies of tile index
; $20 to stage. StageTilesArmSlot and StageCopiedBlockArmSlot pass
; A = $68 after the block destination is stored at $CC45 and before
; they replace this source and count with the real tile list.
;
; A is saved at $CC42. That many bytes of $20 are written at $CD91.
; $CC43 is pointed at that list. CallBankedHL maps bank 6 and runs
; CopyIndexedBlocks, which expands each index into a 16-byte tile at
; the destination already in $CC45. The compare in the fill is against
; C, which is 0, so the loop stops when A reaches 0.
;
; $CC42 and $CC43 are named in handle_start_press.asm, which is
; included later, so this file uses the addresses. CopyIndexedBlocks
; and CallBankedHL are already source.

DEF TILE_INDEX_20 EQU $20
DEF INDEX_LIST EQU $CD91
DEF INDEX_LIST_BANK EQU $06

CopyRepeatedTileIndex::
    ld hl, INDEX_LIST
    ld b, TILE_INDEX_20
    ld c, $00
    ld [$CC42], a
.fill:
    ld [hl], b
    inc hl
    dec a
    cp c
    jr nz, .fill
    ld bc, INDEX_LIST
    ld hl, $CC43
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyIndexedBlocks
    ld e, INDEX_LIST_BANK
    call CallBankedHL
    ret

CopyRepeatedTileIndexEnd:
