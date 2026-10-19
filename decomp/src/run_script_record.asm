; Run the script record at wScriptRecord until $C705 is nonzero.
;
; Finish startup calls this through RunScriptLoop after copying the seven
; HRAM script bytes to $C706. $10EB calls it the same way after installing
; a different record. The ROM bank in wCurrentROMBank is pushed and restored.
;
; Each pass reloads the record into HRAM, calls $0A3A, and stores the HRAM
; bytes back through the pointer $2928 left at hScriptDest. $0A3A maps the
; script bank, or bank 1 when bit 7 of that bank byte is set, and calls the
; handler pointer. This loop then maps wCallbackBank and calls wCallback.
; A zero at $C705 repeats the pass.
;
; wScriptRecord and hScriptDest are the names from finish_startup.asm.
; wCallback and wCallbackBank are the names from default_state.asm.
; wCurrentROMBank and rROMB0 are the names from reset.asm. CopyScriptBytes
; and JumpHL are the routines at $290A and $0789.

; Cleared on entry. The handler or the callback stores a nonzero value to stop.
DEF wScriptDone EQU $C705

; Bank 0, still INCBIN. Stores HL at hScriptDest, then copies seven bytes
; from HL into $FFA1-$FFA7. BC receives the script pointer from that record.
DEF LoadScriptRecord EQU $2928

; Bank 0, still INCBIN. Saves the ROM bank, maps the script bank (bank 1
; when bit 7 of the bank byte is set), calls hScriptHandler, and restores
; the ROM bank.
DEF RunScriptHandler EQU $0A3A

RunScriptRecord::
    ld a, [wCurrentROMBank]
    push af
    xor a
    ld [wScriptDone], a
.loop:
    ld hl, wScriptRecord
    call LoadScriptRecord
    call RunScriptHandler
    call CopyScriptBytes
    ld a, [wCallbackBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [wCallback + 1]
    ld h, a
    ld a, [wCallback]
    ld l, a
    call JumpHL
    ld a, [wScriptDone]
    and a
    jr z, .loop
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
