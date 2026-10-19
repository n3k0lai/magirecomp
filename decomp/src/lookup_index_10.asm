; Index 10 of the word table at $1234.
;
; Calls LookupWordAt1234 ($1397), which leaves a word in DE. DE becomes
; $FFFF when that word is 0, otherwise 0. This handler is entered with
; jp hl, so ret returns to LookupWordAt1234's caller.

LookupIndex10::
    call $1397
    ld a, d
    or e
    jr z, .lookupWasZero
    ld de, 0
    ret

.lookupWasZero:
    ld de, $FFFF
    ret
