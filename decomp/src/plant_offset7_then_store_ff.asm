; Bank 0 at $25DA. Sibling of PlantParkedHandlerThenStage. HL is 7.
; PlantScriptPtrReadSramByte returns DE as the record word, C as the
; SRAM byte at that word, B as the record's third byte, and HL as
; BC + 3. wLCDC is the name from turn_off_lcd.asm.
;
; A nonzero wLCDC continues at $25FA, still INCBIN. When the LCD is
; off, HL skips the two bytes after the record. B AND C zero jumps to
; InstallParkedScript. Any other value plants that same handler
; ($1402) in hScriptHandler, sets E to $FF, and jumps to
; StoreEThroughWordInWram3, which stores E through the word now at HL.
;
; $25E6 is the skip-two entry. $25ED is the plant-and-store entry.
; hScriptHandler is the name from reset.asm.

PlantOffset7ThenStoreFF::
    ld hl, $0007
    call PlantScriptPtrReadSramByte
    ld a, [wLCDC]
    and a
    jr nz, LCDOnAfterOffset7Record

SkipTwoThenSplitRecord7::
    inc hl
    inc hl
    ld a, b
    and c
    jp z, InstallParkedScript

PlantHandlerThenStoreFF::
    ld a, LOW(InstallParkedScript)
    ldh [hScriptHandler], a
    ld a, HIGH(InstallParkedScript)
    ldh [hScriptHandler + 1], a
    ld e, $ff
    jp StoreEThroughWordInWram3
