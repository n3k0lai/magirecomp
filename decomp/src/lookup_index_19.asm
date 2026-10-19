; Index 19 of the word table at $1234.
;
; Calls $138E, which leaves the first looked-up word in HL and the second
; in DE. DE becomes $FFFF when the first word is below the second, else 0.
; LookupWordAt1234 enters this with jp hl, so ret returns to its caller.

LookupIndex19::
    call $138E
    ld a, l
    sub e
    ld a, h
    sbc d
    jr nc, .firstNotBelow
    ld de, $FFFF
    ret

.firstNotBelow:
    ld de, 0
    ret
