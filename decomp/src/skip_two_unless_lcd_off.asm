; Script step from the bank 1 handler table. BC is the script pointer.
;
; wLCDC is only tested for zero. The turn-off path clears it, so a dark
; screen leaves through $147B, still INCBIN. That path reads a
; little-endian pointer at BC into BC and jumps to DispatchScriptOpcode.
;
; A nonzero wLCDC means the LCD has been turned on. The two bytes at BC
; are skipped, and DispatchScriptOpcode reads the opcode at the new BC.
;
; wLCDC is the name from turn_off_lcd.asm. DispatchScriptOpcode is the
; name from reset.asm.

SkipTwoUnlessLcdOff::
    ld a, [wLCDC]
    and a
    jp z, FollowScriptWord
    inc bc
    inc bc
    jp DispatchScriptOpcode
