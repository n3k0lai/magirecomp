; Index 22 of the word table at $1234.
;
; Saves wCurrentWRAMBank, then takes the next byte at BC as a WRAM bank.
; That byte is stored in the shadow and selected with ldh [rSVBK], a, and
; BC advances past it. LookupWordAt1234 then reads the following byte and
; jumps through the same table. Its target returns here, so the saved bank
; is written back (the 3-byte form for rSVBK) before this returns to the
; outer lookup's caller. DE from the inner lookup is left alone.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.

LookupIndex22::
    ld a, [wCurrentWRAMBank]
    push af
    ld a, [bc]
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    inc bc
    call LookupWordAt1234Body
    pop af
    ld [wCurrentWRAMBank], a
    ld [rSVBK], a
    ret
