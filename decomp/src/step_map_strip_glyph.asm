; Bank 0 at $2B8F. JumpHL calls this once per map-strip pass, through the
; pointer stored at $C939.
;
; [$C944] is the next map tile id and [$C947] is the id that ends the strip.
; While they differ, the id is incremented, $2BE4 reads the next text byte
; into E, and $2BC8 turns that byte into a bank-6 glyph pointer at wGlyphSrc
; with wCallbackBank set to 6. wCallback becomes CopyGlyph. The caller then
; runs FinishFrame, which copies those 16 bytes into the tile at wGlyphDest.
;
; When the ids match, wCallback becomes $2AF8 and this jumps to $2BBB.
; $2AF8 paints the strip's map cells from the saved tile range. $2BBB stores
; its own address at $C939 and returns with D = 0, so later passes park.
;
; wCallback is the name from default_state.asm. wGlyphSrc and wGlyphDest are
; the names from draw_cgb_notice.asm. CopyGlyph is already source. $2BE4,
; $2BC8, $2AF8, and $2BBB are still INCBIN.

; Next byte of the strip text at $C93B. A byte below $F7 returns in E with
; D cleared. $FC and $FB switch or scan the saved pointer at $C93D.
DEF NextStripTextByte EQU $2BE4

; E is a character. High nibble selects a $100-byte row and low nibble a
; 16-byte glyph at $4000 in bank 6. The pointer is stored at wGlyphSrc and
; the bank at wCallbackBank.
DEF StripGlyphPointer EQU $2BC8

; Paints the finished strip into the $9C00 map, then returns wCallback to
; IdleCallback. Still INCBIN.
DEF PaintStripMap EQU $2AF8

; Writes this address to $C939 and returns with D = 0. Still INCBIN.
DEF ParkStripRoutine EQU $2BBB

; Tile id advanced once per glyph. Strip setup stores the first id here.
DEF wStripTileId EQU $C944
; Tile id that ends this strip.
DEF wStripTileEnd EQU $C947

StepMapStripGlyph::
    ld a, [wStripTileEnd]
    ld d, a
    ld a, [wStripTileId]
    cp d
    jr z, .paintMap
    inc a
    ld [wStripTileId], a
    call NextStripTextByte
    call StripGlyphPointer
    ld a, LOW(CopyGlyph)
    ld [wCallback], a
    ld a, HIGH(CopyGlyph)
    ld [wCallback + 1], a
    ret

.paintMap:
    ld a, LOW(PaintStripMap)
    ld [wCallback], a
    ld a, HIGH(PaintStripMap)
    ld [wCallback + 1], a
    jp ParkStripRoutine
