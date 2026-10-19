; Index 6 of the word table at $1234.
;
; BC is the script pointer. DE is the next script word, little-endian.
; BC is left past that word. LookupWordAt1234 enters this with jp hl, so
; ret returns to its caller.

LookupIndex6::
    ld a, [bc]
    inc bc
    ld e, a
    ld a, [bc]
    inc bc
    ld d, a
    ret
