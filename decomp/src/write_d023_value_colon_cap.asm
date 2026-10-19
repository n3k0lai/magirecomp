; Bank 5 at $4B05. RunD0B1MapStrips calls this immediately before
; FillAsciiSlotCounts, with bank 5 still mapped.
;
; The word at $D0E0 is a high byte then a low byte, the order
; DispatchIfD0E0AboveD102 and ClearMarksAndWalkSlots use. FormatStartDigits
; turns that word into three decimal places. Each place plus $30 is stored
; at $D023, and $3A (':') follows at $D026.
;
; The word at $D0E2 is the cap that clamps the $D0E0 pair. It is formatted
; the same way into $D027. The seven bytes at $D023 read "NNN:NNN".
;
; wStartDigitHundreds, wStartDigitTens, wStartDigitOnes, and
; FormatStartDigits are already source. ASCII_ZERO is the name from
; fill_ascii_slot_counts.asm.

; Left number. High byte at $D0E0, low byte at $D0E1.
DEF wValuePair EQU $D0E0
; Cap. High byte at $D0E2, low byte at $D0E3.
DEF wCapPair EQU $D0E2
; Seven ASCII bytes: three digits, a colon, three digits.
DEF wValueCapText EQU $D023
DEF ASCII_COLON EQU $3A

WriteD023ValueColonCap::
    ld hl, wValuePair
    ld a, [hl+]
    ld e, [hl]
    ld d, a
    call FormatStartDigits
    ld hl, wValueCapText
    ld a, [wStartDigitHundreds]
    add ASCII_ZERO
    ld [hl+], a
    ld a, [wStartDigitTens]
    add ASCII_ZERO
    ld [hl+], a
    ld a, [wStartDigitOnes]
    add ASCII_ZERO
    ld [hl+], a
    ld a, ASCII_COLON
    ld [hl+], a
    ld hl, wCapPair
    ld a, [hl+]
    ld e, [hl]
    ld d, a
    call FormatStartDigits
    ld hl, wValueCapText + 4
    ld a, [wStartDigitHundreds]
    add ASCII_ZERO
    ld [hl+], a
    ld a, [wStartDigitTens]
    add ASCII_ZERO
    ld [hl+], a
    ld a, [wStartDigitOnes]
    add ASCII_ZERO
    ld [hl+], a
    ret
