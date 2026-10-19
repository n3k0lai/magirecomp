; Index 14 of the word table at $1234.
;
; Calls LookupWordAt1234 ($1397), which leaves a word in DE, then
; decrements that word. LookupWordAt1234 enters this with jp hl, so ret
; returns to its caller.

LookupIndex14::
    call $1397
    dec de
    ret
