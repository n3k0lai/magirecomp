; Finish startup and enter the loop at $02E6.
;
; Reset reaches here with a script bank, pointer, and handler already in
; HRAM. Bank 2 reaches here the same way after installing a different script.
; This path turns the LCD off, arms the timer, forces the handler to $0A66,
; and copies the seven HRAM bytes at $FFA1 to $C706. It leaves the bank and
; pointer alone, and it also copies $FFA6 and $FFA7 unchanged.
;
; $CCA5 is cleared, default state is installed again, and $28A9 writes its
; two 00 00 02 14 records. $C715-$C718 get that same pattern. Each of those
; four stores reloads A with an immediate. The stack returns to $CED8, then
; $1F1A runs the saved script. Bank 7's $4A55 is called, the stack is reset
; again, $C6F3 is set to 1, the LCD turns on, and control jumps to $02E6.
;
; The stores to $FF9F, $FFA0, $FFA4, and $FFA5 are the 3-byte form.
; hScriptHandler, INITIAL_SCRIPT_HANDLER, wStackTop, wCurrentROMBank,
; rROMB0, and BANK_INIT are the names from reset.asm. ArmTimer is the name
; from turn_off_lcd.asm.

; Little-endian destination. Both bytes are written with the 3-byte form.
DEF hScriptDest EQU $FF9F

; Saved copy of the seven-byte record. The loop at $1F1A reads it back.
DEF wScriptRecord EQU $C706

; Cleared here. Its role is still unknown. Default state clears the next byte.
DEF wUnknownCCA5 EQU $CCA5

; 00 00 02 14, the same bytes $28A9 writes at $C70E and $C71C.
; Their role is still unknown.
DEF wQuadC715 EQU $C715

; Set to 1 after the bank 7 call. Default state had cleared it.
; Its role is still unknown.
DEF wFlagC6F3 EQU $C6F3

; Bank 0, still INCBIN. Copies $FFA1-$FFA7 to the pointer at hScriptDest.
; The pointer is read with the 3-byte form; the seven bytes are ldh.
DEF CopyScriptRecord EQU $290A

; Bank 0, still INCBIN. Writes 00 00 02 14 at $C70E and at $C71C, then
; clears $C6F5, $C6F6, $C6F7, $C6F8, $C6FA, and $C6FC.
DEF InitQuadRecords EQU $28A9

; Bank 0, still INCBIN. Saves the ROM bank, clears $C705, and loops: reload
; the record at wScriptRecord into HRAM, call $0A3A, store the record back,
; and call the pointer at $C6E4 in the bank at $C6E6. Restores the ROM bank
; and returns once $C705 is nonzero.
DEF RunScriptLoop EQU $1F1A

; Bank 7, still INCBIN. CPU address while BANK_INIT is mapped.
; Its role is still unknown.

; Bank 0, still INCBIN. Returns if wLCDC is already nonzero. Otherwise sets
; STAT to $40, clears IF and $FF9E, enables VBlank and STAT, stores LCDC $E3
; in rLCDC and wLCDC, and enables interrupts.
DEF TurnOnLCD EQU $07EA

; Bank 0, still INCBIN. Increments $FFA8. When bit 3 of $C932 is set, maps
; ROM bank 6 and calls $6783. Then calls $08BB and jumps back to itself.
DEF MainLoop EQU $02E6

FinishStartup::
    call TurnOffLCD
    call ArmTimer
    ld a, LOW(wScriptRecord)
    ld [hScriptDest], a
    ld a, HIGH(wScriptRecord)
    ld [hScriptDest + 1], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    call CopyScriptRecord
    xor a
    ld [wUnknownCCA5], a
    call SetupDefaultState
    call InitQuadRecords
    ld a, $00
    ld [wQuadC715], a
    ld a, $00
    ld [wQuadC715 + 1], a
    ld a, $02
    ld [wQuadC715 + 2], a
    ld a, $14
    ld [wQuadC715 + 3], a
    ld sp, wStackTop
    call RunScriptLoop
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call DrawMetatileWindow
    ld sp, wStackTop
    ld a, $01
    ld [wFlagC6F3], a
    call TurnOnLCD
    jp MainLoop
