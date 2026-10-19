; Read one byte at BC, advance BC, and jump through the word table at $1234.
;
; The byte is doubled into DE (D is cleared) and added to $1234. The word
; there is loaded into HL and entered with jp hl, so the table target
; returns to this routine's caller. DE on entry to the target is the
; doubled index. The table itself is still INCBIN.
;
; Callers name this address LookupWordAt1234.

LookupWordAt1234Body::
    ld a, [bc]
    inc bc
    add a
    ld e, a
    ld d, $00
    ld hl, $1234
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp hl
