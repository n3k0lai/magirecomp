; Bank 0 at $2596. Sibling of PlantParkedHandlerWhenLCDOff. HL is 9.
; PlantScriptPtrReadSramByte returns DE as the record word, C as the
; SRAM byte at that word, and B as the record's third byte. wLCDC is
; the name from turn_off_lcd.asm.
;
; A nonzero wLCDC continues at $25AA, still INCBIN. When the LCD is
; off, B AND C zero jumps to InstallParkedScript. Any other value
; jumps to $2680, still INCBIN. That exit's job is still unknown.

; Still INCBIN. LCD on after this test.
; Still INCBIN. LCD off and B AND C is nonzero.

BranchParkedScriptWhenLCDOff::
    ld hl, $0009
    call PlantScriptPtrReadSramByte
    ld a, [wLCDC]
    and a
    jr nz, BranchParkedScriptWhenLCDOn
    ld a, b
    and c
    jp z, InstallParkedScript
    jp StageBytePastThree
