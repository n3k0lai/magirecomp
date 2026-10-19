; Index 8 of IndexedSetup. Draw up to four slots from one SRAM record.
;
; VRAM bank 0 is selected with the 3-byte store. SRAM is enabled and the
; bank at $C727 is mapped. `add a, $00` keeps that bank byte. The byte at
; $A118 plus $CC4C is an id. Times $25, plus $A016, is a 12-byte field in
; the next SRAM bank. Those bytes are copied to $CC94, then SRAM is disabled.
;
; From $CC9C, each $FF increments $CCA2. The following `cp $04` still sees
; that $FF, so it does not stop the scan. The first other byte does.
; $CDD3 is set to $CD91 and $CC89 is cleared.
;
; Each pass loads the word at $CC94 + $CC89 * 2 into $CDD1 and sets $CDD5
; to 1. Bank 5's $5E62 runs. What it writes at $CD91 is still unknown.
; Seven indexes there are copied through CopyIndexedBlocks into VRAM bank 1
; at $8B90 + $CC89 * $F0. A zero byte at $CD99 stores three $DF blanks at
; $C92D. Any other byte is formatted by FormatStartDigits. WriteDigitTiles
; adds $A1 and stores the three tiles back at $CD91. Those three are then
; written at $9C90 + $CC89 * $40. $CC89 advances. The pass repeats until
; $CC89 equals $CCA2.
;
; When that count is 4, the routine returns. Otherwise VRAM bank 0 stays
; selected and each remaining index through 3 gets seven $80 tiles at
; $9C82 + index * $40.
;
; rVBK is the name from setup_window.asm. rRAMG is the name from reset.asm.
; rRAMB, wSRAMBank, SRAM_ENABLE, wUnknownCC4C, wBlockCount, wBlockSrc, and
; wBlockDest are the names from handle_start_press.asm. wUnknownCC89 is the
; name from stamp_setup_attributes.asm. sEntryIds and ENTRY_STRIDE are the
; names from indexed_tail_07.asm. wDigitLow and DIGIT_BLANK are the names
; from write_digit_tiles.asm and write_group_row_digits.asm. TILE_DIGIT_BASE
; is the name from draw_start_screen_map.asm. CopyIndexedBlocks, MulCByB,
; CallBankedHL, FormatStartDigits, and WriteDigitTiles are already source.
; $5E62 is still INCBIN.

; Count of $FF bytes from $CC9C until a different byte.
DEF wUnknownCCA2 EQU $CCA2

; Twelve bytes copied from the record. Six words, scanned from the fifth.
DEF wIndexedWords EQU $CC94
DEF wIndexedWordTail EQU $CC9C
DEF INDEXED_WORD_BYTES EQU $0C

; Field at offset $16 of the $25-byte record in the next SRAM bank.
DEF sIndexedField EQU $A016

; Buffer $5E62 fills. Its first three bytes are replaced with digit tiles.
DEF wIndexedTiles EQU $CD91

; Byte formatted for those three tiles. Zero means blanks.
DEF wIndexedValue EQU $CD99

; Pointer and flag passed to bank 5. Low byte of the pointer is stored first.
DEF wIndexedWordLow EQU $CDD1
DEF wIndexedWordHigh EQU $CDD2
DEF wIndexedTilePtr EQU $CDD3
DEF wIndexedCallFlag EQU $CDD5

DEF INDEXED_TILE_COUNT EQU $07
DEF INDEXED_TILE_SPAN EQU $F0
DEF vIndexedTileBase EQU $8B90

DEF INDEXED_MAP_SPAN EQU $40
DEF vIndexedDigits EQU $9C90
DEF vIndexedBlank EQU $9C82
DEF INDEXED_BLANK_LEN EQU $07
DEF INDEXED_BLANK_TILE EQU $80
DEF INDEXED_SLOT_MAX EQU $04

DEF FAR_BANK_5E62 EQU $05
DEF Far_5E62 EQU $5E62

DrawIndexedSlots::
    xor a
    ld [rVBK], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wUnknownCC4C]
    ld c, a
    ld b, $00
    ld hl, sEntryIds
    add hl, bc
    ld a, [hl]
    ld c, a
    ld b, ENTRY_STRIDE
    call MulCByB
    ld bc, sIndexedField
    add hl, bc
    ld bc, wIndexedWords
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld d, INDEXED_WORD_BYTES
.copyField:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copyField

    xor a
    ld [rRAMG], a
    ld hl, wIndexedWordTail
    ld d, $00
.countFf:
    ld a, [hl+]
    cp $ff
    jr nz, .counted

    inc d
    cp $04
    jr nz, .countFf

.counted:
    ld a, d
    ld [wUnknownCCA2], a
    ld bc, wIndexedTiles
    ld hl, wIndexedTilePtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    xor a
    ld [wUnknownCC89], a

.slot:
    ld hl, wIndexedWords
    ld a, [wUnknownCC89]
    add a
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    ld [wIndexedWordHigh], a
    ld a, l
    ld [wIndexedWordLow], a
    ld a, $01
    ld [wIndexedCallFlag], a
    ld hl, Far_5E62
    ld e, FAR_BANK_5E62
    call CallBankedHL
    ld bc, wIndexedTiles
    ld hl, wBlockSrc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, INDEXED_TILE_COUNT
    ld [wBlockCount], a
    ld b, INDEXED_TILE_SPAN
    ld a, [wUnknownCC89]
    ld c, a
    call MulCByB
    ld bc, vIndexedTileBase
    add hl, bc
    ld a, h
    ld [wBlockDest + 1], a
    ld a, l
    ld [wBlockDest], a
    call CopyIndexedBlocks
    ld hl, wIndexedValue
    xor a
    ld e, [hl]
    cp e
    jr z, .blankDigits

    ld d, $00
    call FormatStartDigits
    jr .writeDigits

.blankDigits:
    ld a, DIGIT_BLANK
    ld hl, wDigitLow
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a

.writeDigits:
    xor a
    ld [rVBK], a
    ld hl, wIndexedTiles
    ld d, TILE_DIGIT_BASE
    call WriteDigitTiles
    ld c, INDEXED_MAP_SPAN
    ld a, [wUnknownCC89]
    ld b, a
    call MulCByB
    ld bc, vIndexedDigits
    add hl, bc
    ld bc, wIndexedTiles
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld hl, wUnknownCC89
    inc [hl]
    ld a, [wUnknownCCA2]
    cp [hl]
    jp nz, .slot

    ld a, [hl]
    cp INDEXED_SLOT_MAX
    ret z

    xor a
    ld [rVBK], a

.blankRow:
    ld a, [wUnknownCC89]
    ld c, a
    ld b, INDEXED_MAP_SPAN
    call MulCByB
    ld bc, vIndexedBlank
    add hl, bc
    ld d, INDEXED_BLANK_LEN
    ld a, INDEXED_BLANK_TILE
.fillBlank:
    ld [hl+], a
    dec d
    jr nz, .fillBlank

    ld hl, wUnknownCC89
    inc [hl]
    ld a, INDEXED_SLOT_MAX
    cp [hl]
    jp nz, .blankRow

    ret
