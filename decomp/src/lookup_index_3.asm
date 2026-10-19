; Index 3 of the word table at $1234.
;
; DE is the complement of the flag byte at $C189, masked with 3 and
; zero-extended. LookupWordAt1234 enters this with jp hl, so ret returns
; to its caller.

LookupIndex3::
    ld a, [$c189]
    cpl
    and $03
    ld e, a
    ld d, $00
    ret
