; Bank 3 at $5AAE. Called after bank 3 is stored to wCurrentROMBank and
; rROMB0. $5B41 is the shared tail: another entry reaches it by jumping
; here after its own setup.
;
; The shadow-OAM cursors at $C728 and $C729 are cleared with the immediate
; form, then ParkSprites hides every sprite and TurnOffLCD runs. rWY is 0
; and rWX is 7, so the window covers the picture from the left edge. Both
; stores are the 3-byte form. rWX and rWY are the names from
; setup_window.asm. wShadowOAMCursor and wShadowOAMPrevEnd are the names
; from hide_leftover_sprites.asm.
;
; CallBankedHL maps bank 6 and runs CopyVRAMBank1Tiles, then maps bank 4
; and runs CopyVRAM9000ToWRAM4. Ten tile indexes at $5275 are copied, as
; 16-byte blocks, to $8860 in VRAM bank 1. That list is read while bank 6
; is mapped. wGlyphVRAMBank is 1, wGlyphSrc is $4100, and wGlyphDest is
; $8900. CallBankedHL maps bank 6 and runs CopyGlyph. CopyGlyph leaves E
; alone, so the next call still uses bank 6. Only the source is reloaded,
; to $41D0; the destination continues where the first glyph ended. Five
; more indexes at $52E0 are then copied to $8920 the same way as the ten.
;
; $5B41 reads SRAM. The bank at $C727 is stored to the RAM-bank register
; with `add a, $00` in between, which leaves that bank number in A. SRAM
; is enabled, [$A122] is saved at $CD58, and SRAM is disabled. $CC4E and
; the four bytes at $CC56 are set to 1.
;
; The armed slot uses table index 7 and mark $F3. wCurrentWRAMBank is
; copied to $CCB8. $CCB6 points at $CC4D. $CCB0 and $CCB2 both hold $42E3.
; $CD81 is 1. $CCB9 and $CCBA are 0, written with the immediate form, so
; LoadArmedSlotRecord returns before ReloadSlotPosition. CallBankedHL maps
; bank 3 and runs that routine. $CCA7 is then $FF. $56FA, $6400, and $5744
; run, then TurnOnLCDIfOff. Control leaves through $58CB.
;
; $5275 and $52E0 are bank 6 index lists. $56FA, $6400, $5744, and $58CB
; are still INCBIN. $CC42, $CC43, and $CC45 are named in
; handle_start_press.asm, which is included later, so this file uses the
; addresses. wGlyphSrc, wGlyphDest, wGlyphVRAMBank, and CopyGlyph are the
; names from draw_cgb_notice.asm. wCurrentWRAMBank is the name from
; timer_overflow.asm. rRAMG is the name from reset.asm. ParkSprites,
; TurnOffLCD, CallBankedHL, CopyVRAMBank1Tiles, CopyVRAM9000ToWRAM4,
; CopyIndexedBlocks, LoadArmedSlotRecord, and TurnOnLCDIfOff are already
; source.

; Tile-index lists in bank 6, read by CopyIndexedBlocks.
DEF WINDOW_INDEX_LIST EQU $5275
DEF WINDOW_INDEX_COUNT EQU $0A
DEF WINDOW_INDEX_DEST EQU $8860
DEF WINDOW_INDEX_LIST_2 EQU $52E0
DEF WINDOW_INDEX_COUNT_2 EQU $05
DEF WINDOW_INDEX_DEST_2 EQU $8920

; Glyphs in bank 6. The second copy keeps the bank in E.
DEF WINDOW_GLYPH_DEST EQU $8900
DEF WINDOW_GLYPH_2 EQU $41D0
DEF WINDOW_FONT_BANK EQU $06
DEF WINDOW_GLYPH_VRAM EQU $01

; SRAM bank number lives at $C727. $4000 selects that cartridge RAM bank.
; $0A enables SRAM. The saved byte is [$A122].
DEF WINDOW_SRAM_BANK EQU $C727
DEF WINDOW_RAMB EQU $4000
DEF WINDOW_SRAM_ON EQU $0A
DEF WINDOW_SRAM_BYTE EQU $A122
DEF WINDOW_SAVED_MARK EQU $CD58

DEF WINDOW_MARK_CC4E EQU $CC4E
DEF WINDOW_MARK_CC56 EQU $CC56
DEF WINDOW_MARK_VALUE EQU $01

DEF WINDOW_SLOT_INDEX EQU $07
DEF WINDOW_SLOT_MARK EQU $F3
DEF WINDOW_SLOT_PTR EQU $CC4D
DEF WINDOW_SLOT_ID EQU $01
DEF WINDOW_CHOICE_WAIT EQU $FF
DEF WINDOW_RECORD_BANK EQU $03

; WX 7 is the left edge. WY is cleared with xor a, the first picture line.
DEF WINDOW_X_LEFT EQU $07

StageWindowTilesArmSlot::
    ld a, $00
    ld [wShadowOAMCursor], a
    ld [wShadowOAMPrevEnd], a
    call ParkSprites
    call TurnOffLCD
    xor a
    ld [rWY], a
    ld a, WINDOW_X_LEFT
    ld [rWX], a
    ld hl, CopyVRAMBank1Tiles
    ld e, WINDOW_FONT_BANK
    call CallBankedHL
    ld hl, CopyVRAM9000ToWRAM4
    ld e, $04
    call CallBankedHL
    ld bc, WINDOW_INDEX_LIST
    ld hl, $CC43
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, WINDOW_INDEX_DEST
    ld hl, $CC45
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, WINDOW_INDEX_COUNT
    ld [$CC42], a
    ld hl, CopyIndexedBlocks
    ld e, WINDOW_FONT_BANK
    call CallBankedHL
    ld a, WINDOW_GLYPH_VRAM
    ld [wGlyphVRAMBank], a
    ld bc, QueueBlinkSprite
    ld hl, wGlyphSrc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, WINDOW_GLYPH_DEST
    ld hl, wGlyphDest
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld e, WINDOW_FONT_BANK
    ld hl, CopyGlyph
    call CallBankedHL
    ld bc, WINDOW_GLYPH_2
    ld hl, wGlyphSrc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyGlyph
    call CallBankedHL
    ld bc, WINDOW_INDEX_LIST_2
    ld hl, $CC43
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, WINDOW_INDEX_DEST_2
    ld hl, $CC45
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, WINDOW_INDEX_COUNT_2
    ld [$CC42], a
    ld hl, CopyIndexedBlocks
    ld e, WINDOW_FONT_BANK
    call CallBankedHL
; $5B41. SRAM bank is already in the byte at $C727.
LoadSRAMMarkArmSlot::
    ld a, [WINDOW_SRAM_BANK]
    add a, $00
    ld [WINDOW_RAMB], a
    ld a, WINDOW_SRAM_ON
    ld [rRAMG], a
    ld a, [WINDOW_SRAM_BYTE]
    ld [WINDOW_SAVED_MARK], a
    xor a
    ld [rRAMG], a
    ld a, WINDOW_MARK_VALUE
    ld [WINDOW_MARK_CC4E], a
    ld hl, WINDOW_MARK_CC56
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, WINDOW_SLOT_INDEX
    ld [$CCB4], a
    ld a, WINDOW_SLOT_MARK
    ld [$CCA9], a
    ld a, [wCurrentWRAMBank]
    ld [$CCB8], a
    ld bc, WINDOW_SLOT_PTR
    ld hl, $CCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, HoldLcdOff
    ld hl, $CCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, HoldLcdOff
    ld hl, $CCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, WINDOW_SLOT_ID
    ld [$CD81], a
    ld a, $00
    ld [$CCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, WINDOW_RECORD_BANK
    call CallBankedHL
    ld a, WINDOW_CHOICE_WAIT
    ld [$CCA7], a
    call PaintWindowTilemap
    call LoadPagedSRAMChoicePairs
    call PaintWindowIndexedRows
    call TurnOnLCDIfOff
    jp ServiceWindowChoice
