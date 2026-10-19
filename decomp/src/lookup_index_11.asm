; Index 11 of the word table at $1234.
;
; Calls $138E, which leaves the first looked-up word in HL and the second
; in DE. DE becomes the sum of those words. LookupWordAt1234 enters this
; with jp hl, so ret returns to its caller.

LookupIndex11::
    call $138E
    ld a, e
    add a, l
    ld e, a
    ld a, d
    adc a, h
    ld d, a
    ret
