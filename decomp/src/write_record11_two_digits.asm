; WriteRecord11TwoDigits. Bank 2 at $5734.
;
; RunFlaggedMeasureScript and RunRankMeasureScript call this fourth when
; bit 1 of $D389 is set, after WriteMeasureWordThreeDigits. HL is the
; record those callers already hold, usually $D110. The byte at record+11
; is the field SampleRecord11Contribution adds into, capped at $63.
;
; FormatStartDigits turns that byte into decimal places. The tens and ones
; plus $30 are stored at $C95B and $C95C. $FC is stored at $C95D, the byte
; after those two digits. Hundreds is left unused. HL is restored.
;
; FormatStartDigits is already source. wStartDigitTens and wStartDigitOnes
; are the names from format_start_digits.asm. ASCII_ZERO is the name from
; fill_ascii_slot_counts.asm. LIST_TAIL_MARK is the name from
; setup_command_4d.asm.

DEF RECORD_PLUS_11_BYTE EQU $000B
DEF RECORD11_TENS_ASCII EQU $C95B
DEF RECORD11_ONES_ASCII EQU $C95C
DEF RECORD11_TAIL_MARK EQU $C95D

WriteRecord11TwoDigits::
    push hl
    ld bc, RECORD_PLUS_11_BYTE
    add hl, bc
    ld e, [hl]
    ld d, $00
    call FormatStartDigits
    ld a, [wStartDigitTens]
    add ASCII_ZERO
    ld [RECORD11_TENS_ASCII], a
    ld a, [wStartDigitOnes]
    add ASCII_ZERO
    ld [RECORD11_ONES_ASCII], a
    ld a, LIST_TAIL_MARK
    ld [RECORD11_TAIL_MARK], a
    pop hl
    ret
