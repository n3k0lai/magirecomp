; Index 7 of the word table at $1234.
;
; Calls $138E, which leaves the first looked-up word in HL and the second
; in DE. DE becomes the bitwise AND of those two words. LookupWordAt1234
; enters this with jp hl, so ret returns to its caller.

LookupIndex7::
    call $138E
    ld a, e
    and l
    ld e, a
    ld a, d
    and h
    ld d, a
    ret
