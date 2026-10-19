; Bank 0 at $26B7. BranchWhenLCDOff lands here when wLCDC is zero
; and B AND C is zero. HL is the record pointer that path left behind.
; hScriptPtr is the name from reset.asm.
;
; HL advances by 4. E takes the byte there, then HL steps over the
; following word. That address, just past the word, is planted as
; hScriptPtr. Two decrements put HL back on the word.
;
; The jump to $26CC leaves this routine. That tail is still INCBIN.
; It selects WRAM bank 3, reads the word at HL, and stores E there.

; Still INCBIN. Shared store of E through the word at HL.
DEF StoreEThroughWord EQU $26CC

StageBytePastFour::
    ld de, $0004
    add hl, de
    ld a, [hl+]
    ld e, a
    inc hl
    inc hl
    ld a, h
    ld [hScriptPtr + 1], a
    ld a, l
    ld [hScriptPtr], a
    dec hl
    dec hl
    jp StoreEThroughWord
