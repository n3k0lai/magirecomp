; Scan two SRAM spans, then copy five tile groups.
;
; IndexedSetup stores an SRAM address at $CC82 and calls this for indexes
; 3, 4, 6, and $0B. SRAM is enabled and the bank at $C727 is selected.
; `add a, $00` keeps that bank byte and its flags. Nothing reads them.
; $6911 runs before the scan. What it changes is still unknown.
;
; $CC78 and $CC80 are the first and fifth words of wGroupPointers. Each
; low byte of (pointer - SRAM address) is an offset. The first walk steps
; down from the offset below that start and stops on a nonzero SRAM byte
; or when the offset wraps to $FF. The second walk steps up, and an offset
; of zero is an immediate miss. A hit leaves the $01 bytes stored at the
; start. A miss clears one pair and writes two blank tiles: $CC58/$CC64
; with $9C29, or $CC59/$CC65 with $9D29. What the two bytes of a pair mean
; apart from each other is still unknown. The offset that hit is discarded.
;
; A zero at $CDD7 returns after SRAM is disabled. Otherwise SRAM is
; disabled again and C walks the five pointers at $CC78, two bytes at a
; time. The low byte of (pointer - SRAM address) is multiplied by the byte
; at $CC88. Indexes other than $0B add the word at $CC84, store that sum
; at $CD8D, and point $CD8F at $CD91. Index 6 then calls $68E1 in bank 7.
; Indexes 3 and 4 call $5DAE in bank 7. Index $0B stores the low byte at
; $CD8C, points $CD8F at $CD91, and calls $5A60 in this bank. What those
; calls write is still unknown.
;
; The destination is $8AB0 plus the pointer index times $D0 (13 tiles of
; 16 bytes). CopyIndexedBlocks copies 13 indexes from $CD97 for index 6,
; from $CD91 for index $0B, and from $CD9D otherwise.
;
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, SRAM_ENABLE,
; wBlockCount, wBlockSrc, and wBlockDest are the names from
; handle_start_press.asm. wGroupPointers is the name from
; write_group_row_digits.asm. MulCByB, CallBankedHL, and CopyIndexedBlocks
; are already source.

; SRAM address stored by IndexedSetup. Callers pass $A3A7, $A5A5, $A019,
; or $A4A6.
DEF wGroupSRAM EQU $CC82

; Added to the scaled offset for every index except $0B.
DEF wGroupAddend EQU $CC84

; Multiplier stored beside the flag offset at $CC87.
DEF wGroupScale EQU $CC88

; Zero skips the five tile copies. What sets it is still unknown.
DEF wGroupCopyGate EQU $CDD7

; Cleared together when the downward walk misses.
DEF wGroupDownMark EQU $CC58
DEF wGroupDownMark2 EQU $CC64

; Cleared together when the upward walk misses.
DEF wGroupUpMark EQU $CC59
DEF wGroupUpMark2 EQU $CC65

; Column 9 of BG-map rows 1 and 9. Two bytes each.
DEF vGroupDownTiles EQU $9C29
DEF vGroupUpTiles EQU $9D29
DEF GROUP_BLANK_TILE EQU $80

; Filled just before the banked call. The call's use of them is unknown.
DEF wGroupLowOffset EQU $CD8C
DEF wGroupScaled EQU $CD8D
DEF wGroupListPtr EQU $CD8F
DEF wGroupList0B EQU $CD91
DEF wGroupList6 EQU $CD97
DEF wGroupListOther EQU $CD9D

; First of the five 13-tile runs in VRAM.
DEF vGroupTiles EQU $8AB0

; 13 tiles times 16 bytes. Also the block count passed to CopyIndexedBlocks.
DEF GROUP_STRIDE EQU $D0
DEF GROUP_BLOCK_COUNT EQU $0D

; Stop once the pointer index has stepped 0, 2, 4, 6, 8.
DEF GROUP_INDEX_DONE EQU $0A

; Banks passed to CallBankedHL.
DEF GROUP_BUILD_BANK_0B EQU $06
DEF GroupBuildOther EQU $5DAE
DEF GroupBuild6 EQU $68E1
DEF GROUP_BUILD_BANK EQU $07

ScanGroupBytes::
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    call FillGroupPointers
    ld a, $01
    ld [wGroupDownMark], a
    ld [wGroupUpMark], a
    ld [wGroupDownMark2], a
    ld [wGroupUpMark2], a
    ld hl, wGroupSRAM
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    ld hl, wGroupPointers
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld b, $00
    ld c, l
.down:
    ld hl, wGroupSRAM
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    dec bc
    ld a, $FF
    cp c
    jr z, .down_miss

    add hl, bc
    ld a, [hl]
    and a
    jr z, .down

    jr .up_setup

.down_miss:
    xor a
    ld [wGroupDownMark], a
    ld [wGroupDownMark2], a
    ld a, GROUP_BLANK_TILE
    ld hl, vGroupDownTiles
    ld [hl+], a
    ld [hl+], a
.up_setup:
    ld hl, wGroupSRAM
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    ld hl, wGroupPointers + 8
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld b, $00
    ld c, l
    ld a, c
    and c
    jr z, .up_miss

.up:
    ld hl, wGroupSRAM
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    inc bc
    ld a, $FF
    cp c
    jr z, .up_miss

    add hl, bc
    ld a, [hl]
    and a
    jr z, .up

    jr .gate

.up_miss:
    xor a
    ld [wGroupUpMark], a
    ld [wGroupUpMark2], a
    ld a, GROUP_BLANK_TILE
    ld hl, vGroupUpTiles
    ld [hl+], a
    ld [hl+], a
.gate:
    xor a
    ld [rRAMG], a
    ld a, [wGroupCopyGate]
    and a
    ret z

    xor a
    ld [rRAMG], a
    ld bc, $0000
.slot:
    ld b, $00
    ld hl, wGroupPointers
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push bc
    ld a, [wGroupSRAM + 1]
    ld b, a
    ld a, [wGroupSRAM]
    ld c, a
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld c, l
    ld a, [wGroupScale]
    ld b, a
    ld a, [wUnknownCC47]
    cp $0B
    jr z, .index0B

    call MulCByB
    ld a, [wGroupAddend + 1]
    ld b, a
    ld a, [wGroupAddend]
    ld c, a
    add hl, bc
    ld a, h
    ld [wGroupScaled + 1], a
    ld a, l
    ld [wGroupScaled], a
    ld bc, wGroupList0B
    ld hl, wGroupListPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [wUnknownCC47]
    cp $06
    jr z, .index6

    ld hl, GroupBuildOther
    ld e, GROUP_BUILD_BANK
    call CallBankedHL
    jr .place

.index0B:
    ld a, c
    ld [wGroupLowOffset], a
    ld bc, wGroupList0B
    ld hl, wGroupListPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyIndexedName
    ld e, GROUP_BUILD_BANK_0B
    call CallBankedHL
    jr .place

.index6:
    ld hl, GroupBuild6
    ld e, GROUP_BUILD_BANK
    call CallBankedHL
.place:
    pop bc
    push bc
    srl c
    ld b, GROUP_STRIDE
    call MulCByB
    ld bc, vGroupTiles
    add hl, bc
    ld a, [wUnknownCC47]
    cp $06
    jr nz, .not6

    ld bc, wGroupList6
    jr .copy

.not6:
    cp $0B
    jr z, .use0B

    ld bc, wGroupListOther
    jr .copy

.use0B:
    ld bc, wGroupList0B
.copy:
    ld a, GROUP_BLOCK_COUNT
    ld [wBlockCount], a
    ld a, h
    ld [wBlockDest + 1], a
    ld a, l
    ld [wBlockDest], a
    ld hl, wBlockSrc
    ld a, c
    ld [hl+], a
    ld [hl], b
    call CopyIndexedBlocks
    pop bc
    inc bc
    inc bc
    ld a, c
    cp GROUP_INDEX_DONE
    jp nz, .slot

    ret
