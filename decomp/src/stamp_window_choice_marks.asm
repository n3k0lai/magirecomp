; Bank 4 at $569E. StageCopiedBlockWindow calls this after the window
; frame is painted. rVBK is cleared with the 3-byte form, so every map
; store hits VRAM bank 0.
;
; Tile $80 is written into the marker cells the three passes below can
; replace, plus $9DEF and the two pairs at $9C29 and $9D69. A nonzero
; byte at $CC4D replaces the $9C29 pair with $93. A nonzero byte at
; $CC51 replaces the $9D69 pair with $93. Each pair is two `ld [hl+]`.
; $CC51 is four bytes after $CC4D. On the copied-block path those bytes
; are 0 and 1, so only the lower pair becomes $93.
;
; $CC89 is the pass, cleared with `xor a`. The words at $CD3C and $CD3E
; start at 0. The loop runs while $CC89 is below 3. MulCByB computes
; pass * 8, and $CD22 plus that is the eight-byte record for the pass.
;
; Pass 0 leaves both words at 0. Pass 1 stores map offset $0060 and tile
; offset $01E0. Pass 2 shifts each of those once (the shift count is the
; immediate 1) and stores $00C0 and $03C0. $01E0 is three blocks of $A0.
;
; Each pass calls $554E three times, on record bytes 0, 1, and 3. Before
; each call the tile destination at $CC45 is $8940, $89E0, or $8A80 plus
; the tile offset. $554E is still INCBIN. It reads the byte at HL.
;
; After byte 0, a value other than $20 at [$CD91] writes tile $92 at
; $9C42 plus the map offset. rVBK is cleared again first. CopyIndexedBlocks
; inside $554E leaves VRAM bank 1 selected.
;
; Byte 2 is painted with PaintSRAMWordDigits, A = 0, at $9C70 plus the
; map offset. A left in A other than blank tile $80 writes $91 at $9C6F
; plus the offset. Byte 4 is the same pair one row lower, at $9C90 and
; $9C8F. Bytes 5 and 6 are painted as a word, A = 1, at $9C50 plus the
; offset, and a non-blank result writes $90 at $9C4F plus the offset.
;
; $CC89 then increments. `cp` against 3 returns when the third pass just
; finished. Otherwise `jp` returns to the pass head.
;
; rVBK is the name from setup_window.asm. MulCByB and PaintSRAMWordDigits
; are already source. $CC45 is named in handle_start_press.asm, which is
; included later, so this file uses the address. What $554E copies, and
; what byte 7 of each record is for, are still unknown.

DEF WINDOW_MARK_BLANK EQU $80
DEF WINDOW_MARK_PAIR EQU $93
DEF WINDOW_MARK_OPEN EQU $92
DEF WINDOW_MARK_SIDE EQU $91
DEF WINDOW_MARK_WORD EQU $90
DEF WINDOW_ROW_EMPTY EQU $20

DEF WINDOW_MARK_PASS EQU $CC89
DEF WINDOW_MARK_PASSES EQU $03

; First byte of the six-byte record. $CC51 is the fifth byte.
DEF WINDOW_MARK_HI_FLAG EQU $CC4D
DEF WINDOW_MARK_LO_FLAG EQU $CC51

DEF WINDOW_MARK_PAIR_HI EQU $9C29
DEF WINDOW_MARK_PAIR_LO EQU $9D69

; Map offset for this pass, then the tile-block offset.
DEF WINDOW_MARK_MAP_OFF EQU $CD3C
DEF WINDOW_MARK_TILE_OFF EQU $CD3E

; Eight-byte records. Pass n uses the record at $CD22 + n * 8.
DEF WINDOW_MARK_RECORDS EQU $CD22
DEF WINDOW_MARK_RECORD_STRIDE EQU $08

; Pass 1 offsets. Pass 2 shifts each once.
DEF WINDOW_MARK_MAP_STEP EQU $0060
DEF WINDOW_MARK_TILE_STEP EQU $01E0
DEF WINDOW_MARK_SHIFT_ONCE EQU $01

; Tile destinations. $A0 apart, plus the tile offset.
DEF WINDOW_MARK_TILE_0 EQU $8940
DEF WINDOW_MARK_TILE_1 EQU $89E0
DEF WINDOW_MARK_TILE_2 EQU $8A80

; Cells written relative to the map offset.
DEF WINDOW_MARK_OPEN_CELL EQU $9C42
DEF WINDOW_MARK_WORD_CELL EQU $9C4F
DEF WINDOW_MARK_WORD_DIGITS EQU $9C50
DEF WINDOW_MARK_SIDE_A EQU $9C6F
DEF WINDOW_MARK_DIGITS_A EQU $9C70
DEF WINDOW_MARK_SIDE_B EQU $9C8F
DEF WINDOW_MARK_DIGITS_B EQU $9C90

; Filled by $554E. $20 means the $92 cell stays blank.
DEF WINDOW_MARK_BUF EQU $CD91

StampWindowChoiceMarks::
    xor a
    ld [rVBK], a
    ld a, WINDOW_MARK_BLANK
    ld [WINDOW_MARK_OPEN_CELL], a
    ld [WINDOW_MARK_WORD_CELL], a
    ld [WINDOW_MARK_SIDE_A], a
    ld [WINDOW_MARK_SIDE_B], a
    ld [$9CA2], a
    ld [$9CAF], a
    ld [$9CCF], a
    ld [$9CEF], a
    ld [$9D02], a
    ld [$9D0F], a
    ld [$9D2F], a
    ld [$9D4F], a
    ld [$9DEF], a
    ld [WINDOW_MARK_PAIR_HI], a
    ld [WINDOW_MARK_PAIR_HI + 1], a
    ld [WINDOW_MARK_PAIR_LO], a
    ld [WINDOW_MARK_PAIR_LO + 1], a
    ld a, [WINDOW_MARK_HI_FLAG]
    and a
    jr z, .checkLower

    ld a, WINDOW_MARK_PAIR
    ld hl, WINDOW_MARK_PAIR_HI
    ld [hl+], a
    ld [hl+], a

.checkLower:
    ld a, [WINDOW_MARK_LO_FLAG]
    and a
    jr z, .clearPass

    ld a, WINDOW_MARK_PAIR
    ld hl, WINDOW_MARK_PAIR_LO
    ld [hl+], a
    ld [hl+], a

.clearPass:
    xor a
    ld [WINDOW_MARK_PASS], a
    ld bc, $0000
    ld hl, WINDOW_MARK_MAP_OFF
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, WINDOW_MARK_TILE_OFF
    ld a, c
    ld [hl+], a
    ld [hl], b

.pass:
    ld a, [WINDOW_MARK_PASS]
    ld b, a
    ld c, WINDOW_MARK_RECORD_STRIDE
    call MulCByB
    ld bc, WINDOW_MARK_RECORDS
    add hl, bc
    push hl
    ld bc, WINDOW_MARK_TILE_STEP
    ld hl, WINDOW_MARK_MAP_STEP
    ld a, [WINDOW_MARK_PASS]
    and a
    jr z, .placeBlock0

    cp $01
    jr z, .storeOffsets

    ld a, WINDOW_MARK_SHIFT_ONCE

.shiftTile:
    sla c
    rl b
    dec a
    jr nz, .shiftTile

    ld a, WINDOW_MARK_SHIFT_ONCE

.shiftMap:
    sla l
    rl h
    dec a
    jr nz, .shiftMap

.storeOffsets:
    ld a, h
    ld [WINDOW_MARK_MAP_OFF + 1], a
    ld a, l
    ld [WINDOW_MARK_MAP_OFF], a
    ld hl, WINDOW_MARK_TILE_OFF
    ld a, c
    ld [hl+], a
    ld [hl], b

.placeBlock0:
    ld bc, WINDOW_MARK_TILE_0
    ld hl, WINDOW_MARK_TILE_OFF
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, h
    ld [$CC46], a
    ld a, l
    ld [$CC45], a
    pop hl
    push hl
    call CopyIndexedNameTiles
    ld a, [WINDOW_MARK_BUF]
    cp WINDOW_ROW_EMPTY
    jr z, .afterOpen

    xor a
    ld [rVBK], a
    ld hl, WINDOW_MARK_MAP_OFF
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, WINDOW_MARK_OPEN_CELL
    add hl, bc
    ld a, WINDOW_MARK_OPEN
    ld [hl], a

.afterOpen:
    pop hl
    inc hl
    push hl
    ld bc, WINDOW_MARK_TILE_1
    ld hl, WINDOW_MARK_TILE_OFF
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, h
    ld [$CC46], a
    ld a, l
    ld [$CC45], a
    pop hl
    push hl
    call CopyIndexedNameTiles
    pop hl
    inc hl
    push hl
    ld de, WINDOW_MARK_DIGITS_A
    ld hl, WINDOW_MARK_MAP_OFF
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld d, h
    ld e, l
    pop hl
    push hl
    xor a
    call PaintSRAMWordDigits
    cp WINDOW_MARK_BLANK
    jr z, .afterSideA

    xor a
    ld [rVBK], a
    ld hl, WINDOW_MARK_MAP_OFF
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, WINDOW_MARK_SIDE_A
    add hl, bc
    ld a, WINDOW_MARK_SIDE
    ld [hl], a

.afterSideA:
    pop hl
    inc hl
    push hl
    ld bc, WINDOW_MARK_TILE_2
    ld hl, WINDOW_MARK_TILE_OFF
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, h
    ld [$CC46], a
    ld a, l
    ld [$CC45], a
    pop hl
    push hl
    call CopyIndexedNameTiles
    pop hl
    inc hl
    push hl
    ld de, WINDOW_MARK_DIGITS_B
    ld hl, WINDOW_MARK_MAP_OFF
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld d, h
    ld e, l
    pop hl
    push hl
    xor a
    call PaintSRAMWordDigits
    cp WINDOW_MARK_BLANK
    jr z, .paintWord

    xor a
    ld [rVBK], a
    ld hl, WINDOW_MARK_MAP_OFF
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, WINDOW_MARK_SIDE_B
    add hl, bc
    ld a, WINDOW_MARK_SIDE
    ld [hl], a

.paintWord:
    ld de, WINDOW_MARK_WORD_DIGITS
    ld hl, WINDOW_MARK_MAP_OFF
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld d, h
    ld e, l
    pop hl
    inc hl
    ld a, $01
    call PaintSRAMWordDigits
    cp WINDOW_MARK_BLANK
    jr z, .nextPass

    xor a
    ld [rVBK], a
    ld hl, WINDOW_MARK_MAP_OFF
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, WINDOW_MARK_WORD_CELL
    add hl, bc
    ld a, WINDOW_MARK_WORD
    ld [hl], a

.nextPass:
    ld hl, WINDOW_MARK_PASS
    inc [hl]
    ld a, WINDOW_MARK_PASSES
    cp [hl]
    ret z

    jp .pass
