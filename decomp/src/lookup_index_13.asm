; Index 13 of the word table at $1234.
;
; Calls LookupWordAt1234 ($1397), which leaves a word in DE, then
; increments that word. LookupWordAt1234 enters this with jp hl, so ret
; returns to its caller.

LookupIndex13::
    call $1397
    inc de
    ret
