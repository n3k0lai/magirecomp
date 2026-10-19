; Index 9 of the word table at $1234.
;
; Calls $138E, which leaves the first looked-up word in HL and the second
; in DE. DE becomes $FFFF when either word is nonzero, otherwise 0.
; LookupWordAt1234 enters this with jp hl, so ret returns to its caller.

LookupIndex9::
    call $138E
    ld a, e
    or l
    jr nz, .eitherNonzero
    ld a, d
    or h
    jr nz, .eitherNonzero
    ld de, 0
    ret

.eitherNonzero:
    ld de, $FFFF
    ret
