; FormatFixedWord0172. Bank 2 at $5487. Nothing in source calls this yet.
;
; A, B, and DE start at 0 and C is $63. Bank 2 at $54B3, still INCBIN,
; returns a table byte in A. This caller never uses that byte, B, or C.
;
; DE is then $0172. FormatStartDigits stores the decimal places of that
; word at $C92F, $C92E, and $C92D. The hundreds and tens reads are
; discarded. A returns the ones place.
;
; FormatStartDigits is already source. wStartDigitHundreds,
; wStartDigitTens, and wStartDigitOnes are the names from
; format_start_digits.asm.

FormatFixedWord0172::
    ld a, $00
    ld b, $00
    ld c, $63
    ld de, $0000
    call $54B3
    ld de, $0172
    call FormatStartDigits
    ld a, [wStartDigitHundreds]
    ld a, [wStartDigitTens]
    ld a, [wStartDigitOnes]
    ret
