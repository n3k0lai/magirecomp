; Index 16 of the word table at $1234.
;
; Calls $138E, which leaves the first looked-up word in HL and the second
; in DE. DE becomes 0 when the two words match, otherwise $FFFF.
; LookupWordAt1234 enters this with jp hl, so ret returns to its caller.

LookupIndex16::
    call $138E
    ld a, e
    cp l
    jr nz, .wordsDiffer
    ld a, d
    cp h
    jr nz, .wordsDiffer
    ld de, 0
    ret

.wordsDiffer:
    ld de, $FFFF
    ret
