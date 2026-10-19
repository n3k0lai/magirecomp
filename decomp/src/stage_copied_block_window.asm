; Bank 4 at $5926. CallBank4_5494ThenEnterScript maps bank 4 and calls
; here after CopyPrefixedBlockToD000 has copied a length-prefixed block
; to $D000.
;
; The shadow-OAM cursors at $C728 and $C729 are cleared with the immediate
; form, then ParkSprites hides every sprite and TurnOffLCD runs. $C726,
; the operand byte saved by AddSRAMEntryForOperand, is set to $FF. rWY is 0
; and rWX is 7, so the window covers the picture from the left edge. Both
; stores are the 3-byte form. rWX and rWY are the names from
; setup_window.asm. wShadowOAMCursor and wShadowOAMPrevEnd are the names
; from hide_leftover_sprites.asm.
;
; CallBankedHL maps bank 6 and runs CopyVRAMBank1Tiles, then maps bank 4
; and runs CopyVRAM9000ToWRAM4. Ten tile indexes at $5275 are copied, as
; 16-byte blocks, to $8860 in VRAM bank 1. That list is read while bank 6
; is mapped. wGlyphVRAMBank is 1, wGlyphSrc is $4120, and wGlyphDest is
; $8900. CallBankedHL maps bank 6 and runs CopyGlyph. CopyGlyph leaves E
; alone, so the next three calls still use bank 6. Only the source is
; reloaded, to $4110, then $4100, then $41D0.
;
; WRAM bank 6 is stored at wCurrentWRAMBank and selected with ldh [rSVBK].
; [$D000] minus 1 is stored at $CD20. $CD3B, $CD49, and $CD54 are cleared.
; The six bytes at $CC4D are 0 followed by five 1s. The caller reads $CD49
; after this path returns; clearing it is what sends the caller into the
; script.
;
; The armed slot uses table index 5 and mark $F3. wCurrentWRAMBank is
; copied to $CCB8, which is 6 on this path. $CCB6 points at $CC4D. $CCB0
; and $CCB2 both hold $42E3. $CD81 is 1. $CCB9 and $CCBA are 0, written
; with the immediate form, so LoadArmedSlotRecord returns before
; ReloadSlotPosition. CallBankedHL maps bank 3 and runs that routine.
; $CCA7 is then $FF. $557A, $5F1A, and $569E run in this bank.
;
; The SRAM bank at $C727 is stored to $4000 with `add a, $00` in between,
; which leaves that bank number in A. SRAM is enabled. A is 1, HL is
; $A3A5, and DE is $9DB0 for $551A. SRAM is disabled, TurnOnLCDIfOff runs,
; and control leaves through $582C.
;
; $5275 is a bank 6 index list. $557A, $5F1A, $569E, $551A, and $582C are
; still INCBIN. $CC42, $CC43, and $CC45 are named in
; handle_start_press.asm, which is included later, so this file uses the
; addresses. wGlyphSrc, wGlyphDest, wGlyphVRAMBank, and CopyGlyph are the
; names from draw_cgb_notice.asm. wCurrentWRAMBank and rSVBK are the names
; from timer_overflow.asm. rRAMG is the name from reset.asm. wUnknownCD49
; is the name from call_bank4_5494_then_enter_script.asm. wWindowFlagCD54
; is the name from paint_window_tilemap.asm. ParkSprites, TurnOffLCD,
; CallBankedHL, CopyVRAMBank1Tiles, CopyVRAM9000ToWRAM4, CopyIndexedBlocks,
; LoadArmedSlotRecord, and TurnOnLCDIfOff are already source.

; Tile-index list in bank 6, read by CopyIndexedBlocks.
DEF COPIED_INDEX_LIST EQU $5275
DEF COPIED_INDEX_COUNT EQU $0A
DEF COPIED_INDEX_DEST EQU $8860

; Glyphs in bank 6. Later copies keep the bank in E.
DEF COPIED_GLYPH_1 EQU $4120
DEF COPIED_GLYPH_2 EQU $4110
DEF COPIED_GLYPH_3 EQU $4100
DEF COPIED_GLYPH_4 EQU $41D0
DEF COPIED_GLYPH_DEST EQU $8900
DEF COPIED_FONT_BANK EQU $06
DEF COPIED_GLYPH_VRAM EQU $01

; WRAM bank selected before [$D000] is read.
DEF COPIED_WRAM_BANK EQU $06
DEF COPIED_WINDOW_D000 EQU $D000
DEF wCopiedBlockMinus1 EQU $CD20
DEF wUnknownCD3B EQU $CD3B

; Six bytes at $CC4D: one 0, then five 1s.
DEF COPIED_RECORD EQU $CC4D
DEF COPIED_RECORD_MARK EQU $01

DEF COPIED_SLOT_INDEX EQU $05
DEF COPIED_SLOT_MARK EQU $F3
DEF COPIED_SLOT_WORD EQU $42E3
DEF COPIED_SLOT_ID EQU $01
DEF COPIED_CHOICE_WAIT EQU $FF
DEF COPIED_RECORD_BANK EQU $03

; SRAM bank number lives at $C727. $4000 selects that cartridge RAM bank.
; $0A enables SRAM. $551A reads the word at $A3A5. DE is $9DB0.
DEF COPIED_SRAM_BANK EQU $C727
DEF COPIED_RAMB EQU $4000
DEF COPIED_SRAM_ON EQU $0A
DEF COPIED_SRAM_WORD EQU $A3A5
DEF COPIED_MAP_DEST EQU $9DB0
DEF COPIED_SRAM_FLAG EQU $01

; WX 7 is the left edge. WY is cleared with xor a, the first picture line.
DEF COPIED_X_LEFT EQU $07

StageCopiedBlockWindow::
    ld a, $00
    ld [wShadowOAMCursor], a
    ld [wShadowOAMPrevEnd], a
    call ParkSprites
    call TurnOffLCD
    ld a, $FF
    ld [$C726], a
    xor a
    ld [rWY], a
    ld a, COPIED_X_LEFT
    ld [rWX], a
    ld hl, CopyVRAMBank1Tiles
    ld e, COPIED_FONT_BANK
    call CallBankedHL
    ld hl, CopyVRAM9000ToWRAM4
    ld e, $04
    call CallBankedHL
    ld bc, COPIED_INDEX_LIST
    ld hl, $CC43
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, COPIED_INDEX_DEST
    ld hl, $CC45
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, COPIED_INDEX_COUNT
    ld [$CC42], a
    ld hl, CopyIndexedBlocks
    ld e, COPIED_FONT_BANK
    call CallBankedHL
    ld a, COPIED_GLYPH_VRAM
    ld [wGlyphVRAMBank], a
    ld bc, COPIED_GLYPH_1
    ld hl, wGlyphSrc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, COPIED_GLYPH_DEST
    ld hl, wGlyphDest
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld e, COPIED_FONT_BANK
    ld hl, CopyGlyph
    call CallBankedHL
    ld bc, COPIED_GLYPH_2
    ld hl, wGlyphSrc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyGlyph
    call CallBankedHL
    ld bc, COPIED_GLYPH_3
    ld hl, wGlyphSrc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyGlyph
    call CallBankedHL
    ld bc, COPIED_GLYPH_4
    ld hl, wGlyphSrc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyGlyph
    call CallBankedHL
    ld a, COPIED_WRAM_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [COPIED_WINDOW_D000]
    dec a
    ld [wCopiedBlockMinus1], a
    xor a
    ld [wUnknownCD3B], a
    ld [wUnknownCD49], a
    ld [wWindowFlagCD54], a
    ld hl, COPIED_RECORD
    ld [hl+], a
    ld a, COPIED_RECORD_MARK
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, COPIED_SLOT_INDEX
    ld [$CCB4], a
    ld a, COPIED_SLOT_MARK
    ld [$CCA9], a
    ld a, [wCurrentWRAMBank]
    ld [$CCB8], a
    ld bc, COPIED_RECORD
    ld hl, $CCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, COPIED_SLOT_WORD
    ld hl, $CCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, COPIED_SLOT_WORD
    ld hl, $CCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, COPIED_SLOT_ID
    ld [$CD81], a
    ld a, $00
    ld [$CCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, COPIED_RECORD_BANK
    call CallBankedHL
    ld a, COPIED_CHOICE_WAIT
    ld [$CCA7], a
    call PaintWindowFrameMap
    call LoadWRAM6ChoiceRows
    call StampWindowChoiceMarks
    ld a, [COPIED_SRAM_BANK]
    add a, $00
    ld [COPIED_RAMB], a
    ld a, COPIED_SRAM_ON
    ld [rRAMG], a
    ld a, COPIED_SRAM_FLAG
    ld hl, COPIED_SRAM_WORD
    ld de, COPIED_MAP_DEST
    call PaintSRAMWordDigits
    xor a
    ld [rRAMG], a
    call TurnOnLCDIfOff
    jp CopiedBlockWindowChoice
