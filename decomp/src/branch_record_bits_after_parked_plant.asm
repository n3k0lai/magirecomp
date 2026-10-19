; Bank 0 at $258E. PlantParkedHandlerWhenLCDOff lands here when
; wLCDC is nonzero. PlantScriptPtrReadSramByte has just returned: DE is
; the record word, C is the SRAM byte at that word, and B is the
; record's third byte. wLCDC is the name from turn_off_lcd.asm.
;
; B AND C picks the exit, the same split as BranchRecordBitsWhenLCDOn.
; Zero goes to OrBCIntoSramByte at $2689. Any other value goes to
; $26AB, which is still INCBIN.

BranchRecordBitsAfterParkedPlant::
    ld a, b
    and c
    jp z, OrBCIntoSramByte
    jp XorRecordByteIntoSram
