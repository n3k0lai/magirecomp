; Index 5 of IndexedSetup. Copy its tiles and stamp the open slots.
;
; $7078 packs a source: the low nibble is ROM bank 8 and the high
; nibbles are $7070. Twenty-five calls through CallBankedHL run
; CopyGlyphBytes, so $190 bytes land at VRAM $8AB0 in bank 1.
;
; SRAM bank $C727+1 supplies two numbers. Byte $A002 becomes the tens
; and ones tiles at $9C4B and $9C4C. The word at $A003 (high byte
; first) becomes the three tiles at $9C6B. Both go through
; FormatStartDigits, and $A1 is the digit tile base. $5122 and $5145
; then copy two more blocks into VRAM bank 1.
;
; SRAM bank $C727, unchanged by `add a, $00`, copies $A3A3 into $CC89.
; Each of $9CE1, $9CE6, $9CEB, and $9CF0 is a 3x3 of tile $80 written
; by $615F. A zero count stamps that cell and every cell after it. A
; nonzero count decrements and skips the cell. After those four, a
; nonzero count returns. Zero also stamps $9C30.
;
; The stores to rVBK and rRAMG are the 3-byte form. rVBK is the name
; from setup_window.asm. rRAMG is the name from reset.asm. rRAMB,
; wSRAMBank, and SRAM_ENABLE are the names from handle_start_press.asm.
; wGlyphSrc, wGlyphDest, and wGlyphVRAMBank are the names from
; draw_cgb_notice.asm. wStartDigitTens and wStartDigitOnes are the
; names from format_start_digits.asm. TILE_DIGIT_BASE is the name from
; draw_start_screen_map.asm. wUnknownCC89 is the name from
; stamp_setup_attributes.asm. CopyGlyphBytes, CallBankedHL,
; FormatStartDigits, and WriteDigitTiles are already source.
; $5122, $5145, and $615F are still INCBIN.

; Packed bank and source. Low nibble is the bank; the rest is $7070.
DEF Index5GlyphPacked EQU $7078

; Twenty-five 16-byte glyphs, written to VRAM bank 1.
DEF INDEX5_GLYPH_COUNT EQU $19
DEF Index5GlyphDest EQU $8AB0
DEF INDEX5_VRAM_BANK EQU $01

; Next SRAM bank. $A002 is one byte. $A003 is the high byte of a word.
DEF sIndex5Byte EQU $A002
DEF sIndex5Word EQU $A003

; Map cells for those two numbers.
DEF vIndex5Tens EQU $9C4B
DEF vIndex5Ones EQU $9C4C
DEF vIndex5Word EQU $9C6B

; Count of slots to leave alone. Lives in the SRAM bank at $C727.
DEF sIndex5Slots EQU $A3A3

; 3x3 tile-$80 stamps. The four slots step by 5. $9C30 is the last.
DEF vIndex5Slot0 EQU $9CE1
DEF vIndex5Slot1 EQU $9CE6
DEF vIndex5Slot2 EQU $9CEB
DEF vIndex5Slot3 EQU $9CF0
DEF vIndex5SlotLast EQU $9C30

DrawIndex5Tail::
    ld hl, Index5GlyphPacked
    ld a, l
    and $0f
    ld e, a
    ld a, l
    and $f0
    ld l, a
    ld a, h
    ld [wGlyphSrc + 1], a
    ld a, l
    ld [wGlyphSrc], a
    ld bc, Index5GlyphDest
    ld hl, wGlyphDest
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, INDEX5_VRAM_BANK
    ld [wGlyphVRAMBank], a
    ld d, INDEX5_GLYPH_COUNT
.glyph:
    ld hl, CopyGlyphBytes
    call CallBankedHL
    dec d
    jr nz, .glyph

    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [sIndex5Byte]
    ld e, a
    ld d, $00
    xor a
    ld [rRAMG], a
    call FormatStartDigits
    xor a
    ld [rVBK], a
    ld a, [wStartDigitTens]
    add a, TILE_DIGIT_BASE
    ld [vIndex5Tens], a
    ld a, [wStartDigitOnes]
    add a, TILE_DIGIT_BASE
    ld [vIndex5Ones], a
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld hl, sIndex5Word
    ld a, [hl+]
    ld e, [hl]
    ld d, a
    xor a
    ld [rRAMG], a
    call FormatStartDigits
    ld hl, vIndex5Word
    ld d, TILE_DIGIT_BASE
    call WriteDigitTiles
    call CopyIndex5VRAMTiles
    call CopyIndex7VRAMTail
    xor a
    ld [rVBK], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [sIndex5Slots]
    ld [wUnknownCC89], a
    xor a
    ld [rRAMG], a
    xor a
    ld hl, wUnknownCC89
    or [hl]
    jr z, .stamp0

    dec [hl]
    jr .test1

.stamp0:
    ld hl, vIndex5Slot0
    call StampTile80Block
    jr .stamp1

.test1:
    xor a
    ld hl, wUnknownCC89
    or [hl]
    jr z, .stamp1

    dec [hl]
    jr .test2

.stamp1:
    ld hl, vIndex5Slot1
    call StampTile80Block
    jr .stamp2

.test2:
    xor a
    ld hl, wUnknownCC89
    or [hl]
    jr z, .stamp2

    dec [hl]
    jr .test3

.stamp2:
    ld hl, vIndex5Slot2
    call StampTile80Block
    jr .stamp3

.test3:
    xor a
    ld hl, wUnknownCC89
    or [hl]
    jr z, .stamp3

    dec [hl]
    jr .testLast

.stamp3:
    ld hl, vIndex5Slot3
    call StampTile80Block
    jr .stampLast

.testLast:
    xor a
    ld hl, wUnknownCC89
    or [hl]
    ret nz

.stampLast:
    ld hl, vIndex5SlotLast
    call StampTile80Block
    ret
