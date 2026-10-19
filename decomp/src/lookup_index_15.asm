; Index 15 of the word table at $1234.
;
; Calls $138E, which leaves the first looked-up word in HL and the second
; in DE. DE becomes $FFFF when the two words match, otherwise 0.
; LookupWordAt1234 enters this with jp hl, so ret returns to its caller.

LookupIndex15::
    call $138E
    ld a, e
    cp l
    jr nz, .wordsDiffer
    ld a, d
    cp h
    jr nz, .wordsDiffer
    ld de, $FFFF
    ret

.wordsDiffer:
    ld de, 0
    ret
