; WriteRecord14TwoDigits. Bank 2 at $579A.
;
; RunFlaggedMeasureScript calls this seventh when bit 1 of $D389 is set,
; after WriteRecord13TwoDigits. HL is the record
; those callers already hold, usually $D110. The byte at record+14 is
; formatted the same way as the record+11 through record+13 fields.
;
; FormatStartDigits turns that byte into decimal places. The tens and ones
; plus $30 are stored at $C964 and $C965. $FC is stored at $C966, the byte
; after those two digits. Hundreds is left unused. HL is restored.
;
; FormatStartDigits is already source. wStartDigitTens and wStartDigitOnes
; are the names from format_start_digits.asm. ASCII_ZERO is the name from
; fill_ascii_slot_counts.asm. LIST_TAIL_MARK is the name from
; setup_command_4d.asm.

DEF RECORD_PLUS_14_BYTE EQU $000E
DEF RECORD14_TENS_ASCII EQU $C964
DEF RECORD14_ONES_ASCII EQU $C965
DEF RECORD14_TAIL_MARK EQU $C966

WriteRecord14TwoDigits::
    push hl
    ld bc, RECORD_PLUS_14_BYTE
    add hl, bc
    ld e, [hl]
    ld d, $00
    call FormatStartDigits
    ld a, [wStartDigitTens]
    add ASCII_ZERO
    ld [RECORD14_TENS_ASCII], a
    ld a, [wStartDigitOnes]
    add ASCII_ZERO
    ld [RECORD14_ONES_ASCII], a
    ld a, LIST_TAIL_MARK
    ld [RECORD14_TAIL_MARK], a
    pop hl
    ret
