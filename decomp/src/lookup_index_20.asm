; Index 20 of the word table at $1234.
;
; Calls $138E, which leaves the first looked-up word in HL and the second
; in DE. DE becomes $FFFF when the second word is greater than or equal to
; the first, otherwise 0. LookupWordAt1234 enters this with jp hl, so ret
; returns to its caller.

LookupIndex20::
    call $138E
    ld a, e
    sub l
    ld a, d
    sbc h
    jr nc, .secondNotBelow
    ld de, 0
    ret

.secondNotBelow:
    ld de, $FFFF
    ret
