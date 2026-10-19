; Bank 0 at $254F. The byte before this is the tail of FinishWindowYSlide.
;
; HL is 9. $2718 is still INCBIN. It returns with B and C set from the
; record it read. wLCDC is the name from turn_off_lcd.asm: 0 while the
; LCD is off, and callers only test that byte for zero.
;
; A nonzero wLCDC jumps to $2563, still INCBIN. When the LCD is off,
; B AND C picks the exit: zero goes to $26B7, any other value to $2695.
; Both of those are still INCBIN.

; Still INCBIN. Called with HL = 9.
; Still INCBIN. LCD-on continuation of this test.
; Still INCBIN. LCD off and B AND C is zero.
; Still INCBIN. LCD off and B AND C is nonzero.

BranchWhenLCDOff::
    ld hl, $0009
    call PlantScriptPtrReadSramByte
    ld a, [wLCDC]
    and a
    jr nz, BranchRecordBitsWhenLCDOn
    ld a, b
    and c
    jp z, StageBytePastFour
    jp PlantScriptPastRecord
