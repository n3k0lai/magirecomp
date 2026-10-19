; Bank 0 at $2B51. StageStripTextFromScript stores this at the strip
; routine pointer, $C939.
;
; $2C7B, still INCBIN, rewinds the tile id to the saved start and copies
; the saved pointer at $C941 back to wGlyphDest when the id has reached
; the end. LoadNextStripTextByte then reads one text byte. A nonzero D
; is a control or stop byte, and this returns with that D.
;
; A text byte continues with LoadStripGlyphPointer, which stores the
; bank-6 glyph at wGlyphSrc. wCallback becomes $2B28, still INCBIN: that
; callback copies the glyph and paints one map cell. $C948 is set to 2
; and the strip routine becomes .gap. Falling into .gap decrements the
; count to 1. The next pass enters at .gap, decrements to 0, and points
; the strip routine back here. Both of those exits return with D = 0.
;
; $2B71 is the store of .gap's high byte. Who enters there is unknown.
; wCallback is the name from default_state.asm. wGlyphDest is the name
; from draw_cgb_notice.asm. LoadNextStripTextByte and
; LoadStripGlyphPointer are already source. The strip pointer is named
; wStripRoutine later, in run_d0b1_map_strips.asm.

; Same word as wStripRoutine. Defined later.
DEF wStripRoutinePtr EQU $C939
; Passes left before the strip routine returns to this entry.
DEF wStripGap EQU $C948

; Copies the prepared glyph, then paints one map cell. Still INCBIN.
DEF CopyGlyphAndPaintCell EQU $2B28

; Rewinds the tile id and glyph destination at the end of the range.
; Still INCBIN.
DEF RewindStripTiles EQU $2C7B

StepStripTextCell::
    call RewindStripTiles
    call LoadNextStripTextByte
    ld a, d
    and a
    ret nz
    call LoadStripGlyphPointer
    ld a, LOW(CopyGlyphAndPaintCell)
    ld [wCallback], a
    ld a, HIGH(CopyGlyphAndPaintCell)
    ld [wCallback + 1], a
    ld a, $02
    ld [wStripGap], a
    ld a, LOW(.gap)
    ld [wStripRoutinePtr], a
.storeGapHigh:
    ld a, HIGH(.gap)
    ld [wStripRoutinePtr + 1], a
.gap:
    ld a, [wStripGap]
    dec a
    ld [wStripGap], a
    jr nz, .clear
    ld a, LOW(StepStripTextCell)
    ld [wStripRoutinePtr], a
    ld a, HIGH(StepStripTextCell)
    ld [wStripRoutinePtr + 1], a
.clear:
    ld d, $00
    ret
