; Bank 0 at $2563. BranchWhenLCDOff lands here when wLCDC is nonzero.
; PlantScriptPtrReadSramByte has just returned: DE is the record word,
; C is the SRAM byte at that word, and B is the record's third byte.
; wLCDC is the name from turn_off_lcd.asm. A nonzero value means the LCD
; has been turned on.
;
; B AND C picks the exit. Zero goes to $2689, which ORs B with C and
; stores that byte at DE with SRAM enabled, then falls into $2695.
; Any other value goes to $26AB, which XORs B with C into that same
; SRAM byte, then falls into $26B7. Both exits are still INCBIN.
;
; Still INCBIN. LCD on and B AND C is zero.
; Still INCBIN. LCD on and B AND C is nonzero.

BranchRecordBitsWhenLCDOn::
    ld a, b
    and c
    jp z, OrBCIntoSramByte
    jp XorRecordByteIntoSram
