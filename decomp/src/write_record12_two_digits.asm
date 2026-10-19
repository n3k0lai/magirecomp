; WriteRecord12TwoDigits. Bank 2 at $5756.
;
; RunFlaggedMeasureScript calls this fifth when bit 1 of $D389 is set,
; after WriteRecord11TwoDigits. HL is the record
; those callers already hold, usually $D110. The byte at record+12 is the
; field SampleRecord12Contribution adds into, capped at $63.
;
; FormatStartDigits turns that byte into decimal places. The tens and ones
; plus $30 are stored at $C95E and $C95F. $FC is stored at $C960, the byte
; after those two digits. Hundreds is left unused. HL is restored.
;
; FormatStartDigits is already source. wStartDigitTens and wStartDigitOnes
; are the names from format_start_digits.asm. ASCII_ZERO is the name from
; fill_ascii_slot_counts.asm. LIST_TAIL_MARK is the name from
; setup_command_4d.asm.

DEF RECORD_PLUS_12_BYTE EQU $000C
DEF RECORD12_TENS_ASCII EQU $C95E
DEF RECORD12_ONES_ASCII EQU $C95F
DEF RECORD12_TAIL_MARK EQU $C960

WriteRecord12TwoDigits::
    push hl
    ld bc, RECORD_PLUS_12_BYTE
    add hl, bc
    ld e, [hl]
    ld d, $00
    call FormatStartDigits
    ld a, [wStartDigitTens]
    add ASCII_ZERO
    ld [RECORD12_TENS_ASCII], a
    ld a, [wStartDigitOnes]
    add ASCII_ZERO
    ld [RECORD12_ONES_ASCII], a
    ld a, LIST_TAIL_MARK
    ld [RECORD12_TAIL_MARK], a
    pop hl
    ret
