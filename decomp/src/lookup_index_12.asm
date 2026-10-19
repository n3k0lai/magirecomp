; Index 12 of the word table at $1234.
;
; Calls $138E, which leaves the first looked-up word in HL and the second
; in DE. DE becomes the first word minus the second. LookupWordAt1234
; enters this with jp hl, so ret returns to its caller.

LookupIndex12::
    call $138E
    ld a, l
    sub a, e
    ld e, a
    ld a, h
    sbc a, d
    ld d, a
    ret
