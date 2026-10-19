; Read the byte at HL and write three ASCII digits at $C949.
;
; D is cleared, so FormatStartDigits turns that byte into hundreds, tens,
; and ones at $C92F, $C92E, and $C92D. Those places are copied high first,
; each plus $30, to $C949, $C94A, and $C94B. $FC follows at $C94C. The
; word at $C93D is set to $C949, then this returns.
;
; $2C4B is an entry inside this routine. A caller that lands there already
; holds the mark byte in A and the store address in BC. What calls it is
; still unknown.
;
; FormatStartDigits is already source. wStartDigitHundreds is the name
; from format_start_digits.asm. ASCII_ZERO is the name from
; fill_ascii_slot_counts.asm. wListTailDest, LIST_TAIL_MARK, and
; wUnknownC93D are the names from setup_command_4d.asm.

FormatHLByteThreeDigits::
    ld e, [hl]
    ld d, $00
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

.entry2C4B:
    ld [bc], a
    ld a, LOW(wListTailDest)
    ld [wUnknownC93D], a
    ld a, HIGH(wListTailDest)
    ld [wUnknownC93D + 1], a
    ret
