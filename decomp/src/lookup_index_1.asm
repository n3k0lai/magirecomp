; Index 1 of the word table at $1234.
;
; BC is the script pointer. The next word is an address. DE is that byte
; zero-extended. BC is left past the operand. LookupWordAt1234 enters this
; with jp hl, so ret returns to its caller.

LookupIndex1::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld e, [hl]
    ld d, $00
    ret
