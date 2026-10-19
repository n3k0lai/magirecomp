; Bank 0 at $2680. BranchParkedScriptWhenLCDOff lands here when wLCDC
; is zero and B AND C is nonzero. PlantScriptPtrReadSramByte left HL
; three bytes past the record. The OR path at $2674 falls through here
; after it writes B OR C into the SRAM byte at DE. That path is still
; INCBIN.
;
; HL advances by 3. E takes the byte there, and HL steps past it. The
; jump to StoreEThroughWordInWram3 leaves this routine. That tail
; selects WRAM bank 3, reads the word at HL, and stores E there.
;
; $2684 is the load without the add. StoreEThroughWordInWram3 names
; that entry among its callers.

StageBytePastThree::
    ld de, $0003
    add hl, de

LoadEFromHL::
    ld a, [hl+]
    ld e, a
    jp StoreEThroughWordInWram3
