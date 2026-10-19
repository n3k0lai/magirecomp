; Index 0 of the word table at $1234.
;
; BC is the script pointer. The next word is an address. The byte at that
; address is ANDed with the script byte after the word. DE is $FFFF when
; that result is nonzero, and 0 when it is zero. BC is left past the operand.
; LookupWordAt1234 enters this with jp hl, so ret returns to its caller.

LookupIndex0::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [hl]
    ld e, a
    ld a, [bc]
    inc bc
    and e
    jr z, .zero
    ld de, $ffff
    ret

.zero
    ld de, $0000
    ret
