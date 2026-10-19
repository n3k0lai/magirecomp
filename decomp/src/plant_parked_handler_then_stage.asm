; Bank 0 at $25B4. Sibling of BranchParkedScriptWhenLCDOff. HL is 9.
; PlantScriptPtrReadSramByte returns DE as the record word, C as the
; SRAM byte at that word, and B as the record's third byte. wLCDC is
; the name from turn_off_lcd.asm.
;
; A nonzero wLCDC continues at $25D0, still INCBIN. When the LCD is
; off, B AND C zero jumps to InstallParkedScript. Any other value
; plants that same handler ($1402) in hScriptHandler and jumps to
; StageBytePastThree.
;
; hScriptHandler is the name from reset.asm.

PlantParkedHandlerThenStage::
    ld hl, $0009
    call PlantScriptPtrReadSramByte
    ld a, [wLCDC]
    and a
    jr nz, LCDOnBCSplitAfterParkedHandler
    ld a, b
    and c
    jp z, InstallParkedScript
    ld a, LOW(InstallParkedScript)
    ldh [hScriptHandler], a
    ld a, HIGH(InstallParkedScript)
    ldh [hScriptHandler + 1], a
    jp StageBytePastThree
