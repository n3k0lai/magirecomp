; Bank 3 at $5744. Called after $6400 and before TurnOnLCDIfOff.
;
; $CC89 is the row index, cleared with `xor a`. rVBK is cleared with the
; 3-byte form, so the map stores hit VRAM bank 0. Tile $80 is written at
; $9C29, $9C2A, $9D69, and $9D6A. A nonzero byte at $CC4D replaces the
; first pair with $91. A nonzero byte at $CC55 replaces the second pair
; with $91. Each pair is two `ld [hl+], a` stores.
;
; The loop runs while $CC89 is below 7. The word at $CD59 plus twice the
; index has its low byte stored at $CD8C. $CD8F is pointed at $CD91.
; CallBankedHL maps bank 6 and runs $5A60, which is still INCBIN. The
; destination is index * $A0 + $8970, the source is $CD91, and the count
; is $0A. CopyIndexedBlocks copies those indexes into VRAM bank 1 and
; leaves that bank selected, so rVBK is cleared again before the map
; stores.
;
; A $20 at [$CD91] writes tile $80 at index * $20 + $9C71 and at
; index * $20 + $9C62. The product is computed once. $C92E and $C92D
; are both set to $FA, so the later add of $86 wraps both cells to $80.
; DE is saved around that multiply. What DE held is still unknown.
;
; Any other first byte writes $90 at index * $20 + $9C62. B becomes
; [$CD57] + index + 1. SRAM bank $C727 is selected with `add a, $00`
; and SRAM is enabled. Ten bytes at $A118 are compared with B. A hit
; stores $0A at $CC4E + index and selects tile $96. A miss selects tile
; $80. SRAM is disabled, and that tile is written at index * $20 + $9C71.
; D is the tile, so it is pushed around the multiply. The high byte of
; the $CD59 word is passed to FormatStartDigits with D cleared.
;
; Both paths then write [$C92E] + $86 and [$C92D] + $86 at
; index * $20 + $9C6E and the next cell. $CC89 increments. The compare
; with 7 uses `jp nz`, so the loop is three bytes.
;
; Seven rows of $0A tiles end at $8DD0. The next copy sets that
; destination, source $52C0, and count $11. The count $0F copy sets the
; source to $52D1 and leaves the destination where the previous copy
; stopped. Both run CopyIndexedBlocks in bank 6. rVBK is cleared again.
; $65D2 writes $11 ascending tiles from $DD at $9DA1, stride 1, then $0F
; more at $9DC1. A and DE stay as the first call left them.
;
; rVBK is the name from setup_window.asm. rRAMG is the name from
; reset.asm. wStartDigitTens and wStartDigitOnes are the names from
; format_start_digits.asm. CallBankedHL, MulCByB, FormatStartDigits, and
; CopyIndexedBlocks are already source. $65D2 and $5A60 are still INCBIN.
; $CC42, $CC43, and $CC45 are named in handle_start_press.asm, which is
; included later, so this file uses the addresses.

; Row index. Seven passes, 0 through 6.
DEF WINDOW_ROW_INDEX EQU $CC89
DEF WINDOW_ROW_COUNT EQU $07

DEF WINDOW_PAIR_HI EQU $CC4D
DEF WINDOW_PAIR_LO EQU $CC55
DEF WINDOW_BLANK_TILE EQU $80
DEF WINDOW_PAIR_TILE EQU $91
DEF WINDOW_OPEN_TILE EQU $90
DEF WINDOW_MARK_TILE EQU $96
DEF ROW_MARK_BYTE EQU $0A

DEF WINDOW_CELL_HI EQU $9C29
DEF WINDOW_CELL_LO EQU $9D69
DEF WINDOW_ROW_BASE EQU $9C62
DEF WINDOW_MARK_BASE EQU $9C71
DEF WINDOW_DIGIT_BASE EQU $9C6E
DEF WINDOW_MAP_STRIDE EQU $20

DEF WINDOW_ROW_WORDS EQU $CD59
DEF WINDOW_ROW_ID EQU $CD8C
DEF WINDOW_ROW_PTR EQU $CD8F
DEF WINDOW_ROW_BUF EQU $CD91
DEF WINDOW_ROW_SENTINEL EQU $20
DEF WINDOW_BLANK_DIGIT EQU $FA
DEF WINDOW_DIGIT_BIAS EQU $86

; Index * $A0 is ten 16-byte tiles. Seven such rows end at $8DD0.
DEF WINDOW_TILE_STRIDE EQU $A0
DEF WINDOW_TILE_ORIGIN EQU $8970
DEF WINDOW_TILE_COUNT EQU $0A
DEF WINDOW_TAIL_DEST EQU $8DD0
DEF WINDOW_TAIL_SRC EQU $52C0
DEF WINDOW_TAIL_COUNT EQU $11
DEF WINDOW_TAIL_SRC_2 EQU $52D1
DEF WINDOW_TAIL_COUNT_2 EQU $0F
DEF WINDOW_INDEX_BANK EQU $06

; Bank 6. Still INCBIN. Reads the id at $CD8C through the pointer at $CD8F.
DEF Bank6_5A60 EQU $5A60

; Added to the row index, then incremented, before the SRAM compare.
DEF WINDOW_ROW_BIAS_BYTE EQU $CD57
DEF WINDOW_SRAM_LIST EQU $A118
DEF WINDOW_SRAM_LEN EQU $0A
DEF ROW_SRAM_BANK EQU $C727
DEF WINDOW_RAM_BANK EQU $4000
DEF WINDOW_SRAM_ENABLE EQU $0A
DEF WINDOW_ROW_MARKS EQU $CC4E

; Same bank. Writes C ascending bytes at HL with stride DE.
DEF WINDOW_STRIP_TILE EQU $DD
DEF WINDOW_STRIP_1 EQU $9DA1
DEF WINDOW_STRIP_LEN EQU $11
DEF WINDOW_STRIP_2 EQU $9DC1
DEF WINDOW_STRIP_LEN_2 EQU $0F
DEF WINDOW_STRIP_STRIDE EQU $0001

PaintWindowIndexedRows::
    xor a
    ld [WINDOW_ROW_INDEX], a
    xor a
    ld [rVBK], a
    ld a, WINDOW_BLANK_TILE
    ld [WINDOW_CELL_HI], a
    ld [WINDOW_CELL_HI + 1], a
    ld [WINDOW_CELL_LO], a
    ld [WINDOW_CELL_LO + 1], a
    ld a, [WINDOW_PAIR_HI]
    and a
    jr z, .checkLower
    ld a, WINDOW_PAIR_TILE
    ld hl, WINDOW_CELL_HI
    ld [hl+], a
    ld [hl+], a
.checkLower
    ld a, [WINDOW_PAIR_LO]
    and a
    jr z, .row
    ld a, WINDOW_PAIR_TILE
    ld hl, WINDOW_CELL_LO
    ld [hl+], a
    ld [hl+], a
.row
    ld hl, WINDOW_ROW_WORDS
    ld a, [WINDOW_ROW_INDEX]
    ld c, a
    ld b, $00
    sla c
    add hl, bc
    ld a, [hl]
    ld [WINDOW_ROW_ID], a
    ld bc, WINDOW_ROW_BUF
    ld hl, WINDOW_ROW_PTR
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, Bank6_5A60
    ld e, WINDOW_INDEX_BANK
    call CallBankedHL
    ld b, WINDOW_TILE_STRIDE
    ld a, [WINDOW_ROW_INDEX]
    ld c, a
    call MulCByB
    ld bc, WINDOW_TILE_ORIGIN
    add hl, bc
    ld a, h
    ld [$CC46], a
    ld a, l
    ld [$CC45], a
    ld bc, WINDOW_ROW_BUF
    ld hl, $CC43
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, WINDOW_TILE_COUNT
    ld [$CC42], a
    ld hl, CopyIndexedBlocks
    ld e, WINDOW_INDEX_BANK
    call CallBankedHL
    xor a
    ld [rVBK], a
    ld a, [WINDOW_ROW_BUF]
    cp WINDOW_ROW_SENTINEL
    jr nz, .openRow
    ld a, [WINDOW_ROW_INDEX]
    ld b, a
    ld c, WINDOW_MAP_STRIDE
    push de
    call MulCByB
    pop de
    push hl
    ld bc, WINDOW_MARK_BASE
    add hl, bc
    ld [hl], WINDOW_BLANK_TILE
    pop bc
    ld hl, WINDOW_ROW_BASE
    add hl, bc
    ld [hl], WINDOW_BLANK_TILE
    ld a, WINDOW_BLANK_DIGIT
    ld [wStartDigitTens], a
    ld [wStartDigitOnes], a
    jr .paintDigits
.openRow
    ld a, [WINDOW_ROW_INDEX]
    ld b, a
    ld c, WINDOW_MAP_STRIDE
    call MulCByB
    ld bc, WINDOW_ROW_BASE
    add hl, bc
    ld [hl], WINDOW_OPEN_TILE
    ld a, [WINDOW_ROW_BIAS_BYTE]
    ld hl, WINDOW_ROW_INDEX
    add [hl]
    ld b, a
    inc b
    ld hl, WINDOW_SRAM_LIST
    ld d, WINDOW_SRAM_LEN
    ld a, [ROW_SRAM_BANK]
    add a, $00
    ld [WINDOW_RAM_BANK], a
    ld a, WINDOW_SRAM_ENABLE
    ld [rRAMG], a
.scan
    ld a, [hl+]
    cp b
    jr z, .hit
    dec d
    jr nz, .scan
    ld a, WINDOW_BLANK_TILE
    jr .choseTile
.hit
    ld a, [WINDOW_ROW_INDEX]
    ld c, a
    ld b, $00
    ld hl, WINDOW_ROW_MARKS
    add hl, bc
    ld [hl], ROW_MARK_BYTE
    ld a, WINDOW_MARK_TILE
.choseTile
    ld d, a
    xor a
    ld [rRAMG], a
    ld a, [WINDOW_ROW_INDEX]
    ld b, a
    ld c, WINDOW_MAP_STRIDE
    push de
    call MulCByB
    pop de
    ld bc, WINDOW_MARK_BASE
    add hl, bc
    ld [hl], d
    ld hl, WINDOW_ROW_WORDS
    ld a, [WINDOW_ROW_INDEX]
    ld c, a
    ld b, $00
    sla c
    add hl, bc
    inc hl
    ld e, [hl]
    ld d, $00
    call FormatStartDigits
.paintDigits
    ld a, [WINDOW_ROW_INDEX]
    ld b, a
    ld c, WINDOW_MAP_STRIDE
    call MulCByB
    ld bc, WINDOW_DIGIT_BASE
    add hl, bc
    ld a, [wStartDigitTens]
    add WINDOW_DIGIT_BIAS
    ld [hl+], a
    ld a, [wStartDigitOnes]
    add WINDOW_DIGIT_BIAS
    ld [hl], a
    ld hl, WINDOW_ROW_INDEX
    inc [hl]
    ld a, WINDOW_ROW_COUNT
    cp [hl]
    jp nz, .row
    ld bc, WINDOW_TAIL_SRC
    ld hl, $CC43
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, WINDOW_TAIL_DEST
    ld hl, $CC45
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, WINDOW_TAIL_COUNT
    ld [$CC42], a
    ld hl, CopyIndexedBlocks
    ld e, WINDOW_INDEX_BANK
    call CallBankedHL
    ld bc, WINDOW_TAIL_SRC_2
    ld hl, $CC43
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, WINDOW_TAIL_COUNT_2
    ld [$CC42], a
    ld hl, CopyIndexedBlocks
    ld e, WINDOW_INDEX_BANK
    call CallBankedHL
    xor a
    ld [rVBK], a
    ld a, WINDOW_STRIP_TILE
    ld hl, WINDOW_STRIP_1
    ld de, WINDOW_STRIP_STRIDE
    ld c, WINDOW_STRIP_LEN
    call WriteAscendingTiles
    ld hl, WINDOW_STRIP_2
    ld c, WINDOW_STRIP_LEN_2
    call WriteAscendingTiles
    ret
