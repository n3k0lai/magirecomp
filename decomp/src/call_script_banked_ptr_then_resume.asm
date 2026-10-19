; Script step at $1820. BC is the script pointer. The next two bytes are a
; pointer (low, then high) and the byte after that is a ROM bank.
;
; That bank is stored in wCurrentROMBank and mapped through rROMB0. The
; previous bank is saved and restored around the call. $2E15, still
; INCBIN, is called with BC set to the script pointer while that bank is
; mapped. Control then jumps to INITIAL_SCRIPT_HANDLER ($0A66).
;
; $1824 enters with L already the low byte and A the high byte, and with
; BC still on that high byte. $1825 enters with HL already the pointer
; and BC still on the high byte. What $2E15 does with the pointer is
; still unknown.
;
; wCurrentROMBank, rROMB0, and INITIAL_SCRIPT_HANDLER are the names from
; reset.asm. The bank stores are the 3-byte form.

CallScriptBankedPtrThenResume::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]

CallScriptBankedPtrHighInA::
    ld h, a

CallScriptBankedPtrInHL::
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
    call LoadFiveBankedMapSources
    pop bc
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp INITIAL_SCRIPT_HANDLER
