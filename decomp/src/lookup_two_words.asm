; Look up two words through LookupWordAt1234 ($1397).
;
; Each lookup leaves its result in DE and advances BC. The first result is
; saved, the second stays in DE, and the first is restored into HL.
; Callers that AND, OR, add, subtract, or compare two looked-up words
; enter here and return to their own caller.

LookupTwoWords::
    call $1397
    push de
    call $1397
    pop hl
    ret
