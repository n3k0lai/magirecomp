; Index 4 of the word table at $1234.
;
; DE is the little-endian word stored at $A123. $A123 is SRAM.
; LookupWordAt1234 enters this with jp hl, so ret returns to its caller.

LookupIndex4::
    ld a, [$a123]
    ld e, a
    ld a, [$a124]
    ld d, a
    ret
