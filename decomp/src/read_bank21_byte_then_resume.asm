; Entry at $17FA. BC is the script pointer. The next two script bytes are
; a pointer (low, then high). ROM bank $21 is stored in wCurrentROMBank
; and mapped through rROMB0. The byte at that pointer is stored at $C6E1,
; and the pointer one byte past it is stored at $C6DF (low) and $C6E0
; (high). hScriptBank is written back to wCurrentROMBank and rROMB0, and
; control jumps to INITIAL_SCRIPT_HANDLER ($0A66).
;
; $17FF is the same path with HL already holding the pointer and BC still
; pointing at its high byte. $1800 skips the script read and forces bank
; $21. $1802 maps the bank already in A. Nothing in this routine calls
; out. What $C6DF-$C6E1 are for is still unknown.
;
; wCurrentROMBank, rROMB0, hScriptBank, and INITIAL_SCRIPT_HANDLER are
; the names from reset.asm. The bank stores and the hScriptBank load are
; the 3-byte form.

; $C6DF low, $C6E0 high: pointer one past the byte read from bank $21.
DEF wBank21PtrLow EQU $C6DF
DEF wBank21PtrHigh EQU $C6E0
; Byte read from that pointer before it was advanced. Role still unknown.
DEF wBank21Byte EQU $C6E1

ReadBank21ByteThenResume::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a

ReadBank21ByteThenResumeSkipHigh::
    inc bc

ReadBank21ByteThenResumeFixedBank::
    ld a, $21

ReadBank21ByteThenResumeMapped::
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [hl+]
    ld [wBank21Byte], a
    ld a, h
    ld [wBank21PtrHigh], a
    ld a, l
    ld [wBank21PtrLow], a
    ld a, [hScriptBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp INITIAL_SCRIPT_HANDLER
