; Bank 0 at $256B. Sibling of BranchWhenLCDOff. HL is 9.
; PlantScriptPtrReadSramByte returns DE as the record word, C as the
; SRAM byte at that word, and B as the record's third byte. HL comes
; back as BC + 3. wLCDC is the name from turn_off_lcd.asm.
;
; A nonzero wLCDC skips the plant and continues at $258E, still INCBIN.
; That tail is the same B AND C split as BranchRecordBitsWhenLCDOn.
; When the LCD is off, hScriptHandler becomes InstallParkedScript
; ($1402). The flag test is the earlier `and c`: A is then overwritten
; with the handler bytes. B AND C zero jumps to StageBytePastFour.
; Any other value advances HL by 3, loads E from the byte there, steps
; over the next byte, and jumps to StoreEThroughWordInWram3.
;
; hScriptHandler is the name from reset.asm. InstallParkedScript is the
; name from install_parked_script.asm.

PlantParkedHandlerWhenLCDOff::
    ld hl, $0009
    call PlantScriptPtrReadSramByte
    ld a, [wLCDC]
    and a
    jr nz, BranchRecordBitsAfterParkedPlant
    ld a, b
    and c
    ld a, LOW(InstallParkedScript)
    ldh [hScriptHandler], a
    ld a, HIGH(InstallParkedScript)
    ldh [hScriptHandler + 1], a
    jp z, StageBytePastFour
    ld de, $0003
    add hl, de
    ld a, [hl+]
    ld e, a
    inc hl
    jp StoreEThroughWordInWram3
