; Index 17 of the word table at $1234.
;
; Calls $138E, which leaves the first looked-up word in HL and the second
; in DE. DE becomes $FFFF when the second word is below the first, else 0.
; LookupWordAt1234 enters this with jp hl, so ret returns to its caller.

LookupIndex17::
    call $138E
    ld a, e
    sub l
    ld a, d
    sbc h
    jr nc, .secondNotBelow
    ld de, $FFFF
    ret

.secondNotBelow:
    ld de, 0
    ret
