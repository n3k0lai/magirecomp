; Index 5 of the word table at $1234.
;
; BC is the script pointer. DE is the next script byte, zero-extended.
; BC is left past that byte. LookupWordAt1234 enters this with jp hl, so
; ret returns to its caller.

LookupIndex5::
    ld a, [bc]
    inc bc
    ld e, a
    ld d, $00
    ret
