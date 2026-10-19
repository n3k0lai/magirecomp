; Read the little-endian word at HL and write three ASCII digits at $C949.
;
; FormatStartDigits turns that word into hundreds, tens, and ones at
; $C92F, $C92E, and $C92D. Those places are copied high first, each plus
; $30, to $C949, $C94A, and $C94B. $FC follows at $C94C. The word at
; $C93D is set to $C949, then this returns.
;
; FormatStartDigits is already source. wStartDigitHundreds is the name
; from format_start_digits.asm. ASCII_ZERO is the name from
; fill_ascii_slot_counts.asm. wListTailDest, LIST_TAIL_MARK, and
; wUnknownC93D are the names from setup_command_4d.asm.

FormatHLWordThreeDigits::
    ld e, [hl]
    inc hl
    ld d, [hl]
    call FormatStartDigits
    ld hl, wStartDigitHundreds
    ld bc, wListTailDest
    ld d, $03

.digit:
    ld a, [hl-]
    add ASCII_ZERO
    ld [bc], a
    inc bc
    dec d
    jr nz, .digit

    ld a, LIST_TAIL_MARK
    ld [bc], a
    ld a, LOW(wListTailDest)
    ld [wUnknownC93D], a
    ld a, HIGH(wListTailDest)
    ld [wUnknownC93D + 1], a
    ret
