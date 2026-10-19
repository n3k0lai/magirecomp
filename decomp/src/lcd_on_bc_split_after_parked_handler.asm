; Bank 0 at $25D0. PlantParkedHandlerThenStage lands here when
; wLCDC is nonzero. PlantScriptPtrReadSramByte has just returned: DE is
; the record word, C is the SRAM byte at that word, B is the record's
; third byte, and HL is three bytes past the record. wLCDC is the name
; from turn_off_lcd.asm.
;
; B AND C picks the exit. Zero goes to OrBCIntoSramBeforeStage, which
; ORs B with C into the SRAM byte at DE and then continues at
; StageBytePastThree. Any other value copies HL into BC and jumps to
; EnterScriptFromLookup, so the bytes after the three-byte record are
; the script bank and pointer.
;
; OrBCIntoSramBeforeStage, StageBytePastThree, and
; EnterScriptFromLookup are the names from their own files.

LCDOnBCSplitAfterParkedHandler::
    ld a, b
    and c
    jp z, OrBCIntoSramBeforeStage
    ld b, h
    ld c, l
    jp EnterScriptFromLookup
