; Script step at $1843. BC is the script pointer. The next two bytes are a
; pointer (low, then high) and the byte after that is a ROM bank.
;
; That bank is stored in wCurrentROMBank and mapped through rROMB0. The
; previous bank is saved and restored around the call. $2EE9, still
; INCBIN, is called with BC set to the script pointer while that bank is
; mapped. Control then jumps to INITIAL_SCRIPT_HANDLER ($0A66).
;
; $1847 enters with L already the low byte and A the high byte, and with
; BC still on that high byte. What $2EE9 does with the pointer is still
; unknown.
;
; wCurrentROMBank, rROMB0, and INITIAL_SCRIPT_HANDLER are the names from
; reset.asm. The bank stores are the 3-byte form.

CallScriptBankedPtrThenCall2EE9::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]

CallScriptBankedPtr2EE9HighInA::
    ld h, a
    inc bc
    ld a, [wCurrentROMBank]
    push af
    ld a, [bc]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    inc bc
    push bc
    ld c, l
    ld b, h
    call FillC76BFromBCThenOBJPalettes
    pop bc
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp INITIAL_SCRIPT_HANDLER
