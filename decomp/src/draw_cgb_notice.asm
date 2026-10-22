; Draw the Game Boy Color notice and turn the LCD on.
;
; NonCGBLockup calls here through DrawCGBNotice. Reset has already turned
; the LCD off. The notice is 105 ASCII bytes at $01D3 in the player's ROM.
;
; Bank 6 holds one 16-byte glyph per byte value, at $4000 plus that value
; times 16. The loop copies indexes $00 through $6A to $8860 upward. $6B
; is two past the notice, so the last two glyphs are the call opcode and
; the low byte of DrawCGBNotice in the lockup that follows the text.
;
; Six runs on the $9C00 map place the lines on every third row. LCDC $E1
; shows that map in the window: the window is on, its map is $9C00, and
; the background map stays $9800. Bit 4 is clear, so tile $86 is the glyph
; at $8860. WX and WY stay as they were on entry. Index $10, a space, is
; left off the map. Index $43, a space, is drawn at the end of
; one line and again at the start of the next. The last notice space and
; the two lockup bytes stay off the map.
;
; The copy routine selects VRAM bank 1. Reset reaches this screen with
; hCGB clear, on hardware where that register is unused, so the tiles and
; the map land in the one VRAM. The copy also stores the idle callback at
; wCallback. IF and $FF9E are cleared, VBlank and STAT are enabled, LCDC
; $E1 turns the picture on, and IE is cleared. IME is left alone. The
; caller then spins with the notice on screen.
;
; The one-byte no-ops at $0242 and $0245 leave B and A unchanged. A is
; still the font bank when it is stored. Their purpose is still unknown.
; ld a, $00 is the immediate form. Every store to a high address below
; is the 3-byte form.
; wCurrentROMBank and rROMB0 are the names from reset.asm. rIF, rIE, and
; rLCDC are the names from turn_off_lcd.asm. CallHLInBank, wCallback, and
; IdleCallback are the names from default_state.asm.

; Bank 0, still INCBIN. Unsigned HL = C * B.
DEF MultiplyCByB EQU $04CA

; Bank 0, still INCBIN. Copies 16 bytes from wGlyphSrc to wGlyphDest with
; the VRAM bank in wGlyphVRAMBank, then stores IdleCallback at wCallback.
DEF CopyGlyph EQU $2949

; Bank 0, still INCBIN. Writes B ascending bytes at HL, starting from A.
DEF WriteTileRun EQU $02E0

DEF FONT_BANK EQU $06
DEF FONT_BASE EQU $4000
DEF GLYPH_BYTES EQU $10

; One past the last index. Indexes $00-$6A are copied.
DEF GLYPH_INDEX_END EQU $6B

; Pointers and VRAM bank consumed by CopyGlyph.
DEF wGlyphSrc EQU $C6E7
DEF wGlyphDest EQU $C6E9
DEF wGlyphVRAMBank EQU $C6EB

; Passed to CopyGlyph. Unused as a bank select on this path.
DEF NOTICE_VRAM_BANK EQU $01

; First destination tile. Tile id $86 in the $8800 tile set.
DEF NOTICE_TILES EQU $8860
DEF NOTICE_FIRST_TILE EQU $86

; Cleared here. The default VBlank routine reads it: bit 0 turns the LCD
; on and runs OAM DMA, and bit 1 calls wCallback.
DEF hVBlankFlags EQU $FF9E

DEF IEF_VBLANK EQU $01
DEF IEF_STAT EQU $02

; LCD on, background on, window on. Window map $9C00, background map
; $9800, tiles at $8800. Objects stay off.
DEF NOTICE_LCDC EQU $E1

ShowCGBNotice::
    ld b, b
    ld a, FONT_BANK
    ld a, a
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, $00
    ld hl, NOTICE_TILES
.glyph:
    push af
    push hl
    ld hl, NoticeText
    ld c, a
    ld b, $00
    add hl, bc
    ld c, [hl]
    ld b, GLYPH_BYTES
    call MultiplyCByB
    ld a, NOTICE_VRAM_BANK
    ld [wGlyphVRAMBank], a
    ld bc, FONT_BASE
    add hl, bc
    ld a, h
    ld [wGlyphSrc + 1], a
    ld a, l
    ld [wGlyphSrc], a
    pop de
    ld a, d
    ld [wGlyphDest + 1], a
    ld a, e
    ld [wGlyphDest], a
    push de
    ld e, FONT_BANK
    ld hl, CopyGlyph
    call CallHLInBank
    pop hl
    ld bc, GLYPH_BYTES
    add hl, bc
    pop af
    inc a
    cp GLYPH_INDEX_END
    jr nz, .glyph
; Row 1, column 2.
    ld b, $10
    ld a, NOTICE_FIRST_TILE
    ld hl, $9C22
    call WriteTileRun
; Row 4, column 1.
    ld b, $12
    ld a, $97
    ld hl, $9C81
    call WriteTileRun
; Row 7, column 0.
    ld b, $14
    ld a, $A9
    ld hl, $9CE0
    call WriteTileRun
; Row 10, column 4.
    ld b, $0D
    ld a, $BD
    ld hl, $9D44
    call WriteTileRun
; Row 13, column 1.
    ld b, $13
    ld a, $C9
    ld hl, $9DA1
    call WriteTileRun
; Row 16, column 1.
    ld b, $12
    ld a, $DC
    ld hl, $9E01
    call WriteTileRun
    xor a
    ld [rIF], a
    ld [hVBlankFlags], a
    ld a, IEF_VBLANK | IEF_STAT
    ld [rIE], a
    ld a, NOTICE_LCDC
    ld [rLCDC], a
    xor a
    ld [rIE], a
    ret
