; Bank 4 at $554E. StampWindowChoiceMarks calls this three times per
; pass. The caller has already stored the tile destination at $CC45.
;
; The byte at HL is the name id. It is stored at $CD8C, and $CD8F is
; pointed at $CD91. CopyIndexedName, in bank 6, writes that name's ten
; bytes there. Those bytes are the tile indexes. The source at $CC43
; becomes $CD91 and the count at $CC42 becomes ten. CopyIndexedBlocks
; copies the ten tiles into VRAM bank 1 at the destination already in
; $CC45, and leaves that VRAM bank selected.
;
; wUnknownCD8C, wUnknownCD8F, and wUnknownCD91 are the names from
; indexed_tail_07.asm. wBlockCount and wBlockSrc are the names from
; handle_start_press.asm. Both files are included later. CopyIndexedName,
; CopyIndexedBlocks, and CallBankedHL are already source.

DEF NAME_TILE_COUNT EQU $0A
DEF NAME_TILE_BANK EQU $06

CopyIndexedNameTiles::
    ld a, [hl]
    ld [wUnknownCD8C], a
    ld bc, wUnknownCD91
    ld hl, wUnknownCD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyIndexedName
    ld e, NAME_TILE_BANK
    call CallBankedHL
    ld bc, wUnknownCD91
    ld hl, wBlockSrc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, NAME_TILE_COUNT
    ld [wBlockCount], a
    ld hl, CopyIndexedBlocks
    ld e, NAME_TILE_BANK
    call CallBankedHL
    ret
