; Index 8 of the word table at $1234.
;
; Calls $138E, which leaves the first looked-up word in HL and the second
; in DE. DE becomes $FFFF when both words are nonzero, otherwise 0.
; LookupWordAt1234 enters this with jp hl, so ret returns to its caller.

LookupIndex8::
    call $138E
    ld a, e
    or d
    ld de, 0
    ret z
    ld a, l
    or h
    ret z
    ld de, $FFFF
    ret
