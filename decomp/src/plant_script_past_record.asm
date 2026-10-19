; Bank 0 at $2695. BranchWhenLCDOff lands here when wLCDC is zero
; and B AND C is nonzero. The OR path at $2689 also falls through
; after it writes B OR C into the SRAM byte at DE.
;
; PlantScriptPtrReadSramByte left HL just past the 3-byte record.
; The next byte is hScriptBank. The word after that is hScriptPtr,
; low byte then high. Those stores are the 3-byte form. E takes the
; byte after the pointer, and HL skips one more byte.
;
; The jump to $26CC leaves this routine. StoreEThroughWord is the
; name in stage_byte_past_four.asm. That tail is still INCBIN. It
; selects WRAM bank 3, reads the word at HL, and stores E there.
;
; hScriptBank and hScriptPtr are the names from reset.asm.

PlantScriptPastRecord::
    ld a, [hl+]
    ld [hScriptBank], a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld b, a
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, [hl+]
    ld e, a
    inc hl
    jp $26CC
