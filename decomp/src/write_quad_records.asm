; Write 00 00 02 14 at $C70E and at $C71C, then clear six bytes near $C6F5.
;
; finish_startup.asm calls this through InitQuadRecords, after default
; state is installed. It then writes the same four bytes at wQuadC715.
; Three other callers are still INCBIN. Each of the eight stores here
; reloads A from an immediate, including the zeros. The pattern's role
; is still unknown. $C70E, wQuadC715, and $C71C are seven bytes apart.
;
; xor a runs once. The stores then go to $C6F6, $C6F5, $C6F7, $C6F8,
; $C6FA, and $C6FC, skipping $C6F9 and $C6FB. $28E5, still INCBIN, adds
; $C6F5 to $C6F6 and counts a carry in $C6F7, then shifts $C6F8, $C6FA,
; and $C6FC one byte forward into the bytes left untouched here.
; On return A is 0. wQuadC715 is the name from finish_startup.asm.

; 00 00 02 14. Same bytes as wQuadC715. Role is still unknown.
DEF wQuadC70E EQU $C70E
DEF wQuadC71C EQU $C71C

; Cleared here, in the order in the comment above.
DEF wUnknownC6F5 EQU $C6F5

WriteQuadRecords::
    ld a, $00
    ld [wQuadC70E], a
    ld a, $00
    ld [wQuadC70E + 1], a
    ld a, $02
    ld [wQuadC70E + 2], a
    ld a, $14
    ld [wQuadC70E + 3], a
    ld a, $00
    ld [wQuadC71C], a
    ld a, $00
    ld [wQuadC71C + 1], a
    ld a, $02
    ld [wQuadC71C + 2], a
    ld a, $14
    ld [wQuadC71C + 3], a
    xor a
    ld [wUnknownC6F5 + 1], a
    ld [wUnknownC6F5], a
    ld [wUnknownC6F5 + 2], a
    ld [wUnknownC6F5 + 3], a
    ld [wUnknownC6F5 + 5], a
    ld [wUnknownC6F5 + 7], a
    ret
