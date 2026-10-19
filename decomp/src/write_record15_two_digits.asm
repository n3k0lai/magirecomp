; WriteRecord15TwoDigits. Bank 2 at $57BC.
;
; RunFlaggedMeasureScript calls this eighth when bit 1 of $D389 is set,
; after WriteRecord14TwoDigits. HL is the record those callers already
; hold, usually $D110. The byte at record+15 is formatted the same way
; as the record+11 through record+14 fields.
;
; FormatStartDigits turns that byte into decimal places. The tens and ones
; plus $30 are stored at $C967 and $C968. $FC is stored at $C969, the byte
; after those two digits. Hundreds is left unused. HL is restored.
;
; FormatStartDigits is already source. wStartDigitTens and wStartDigitOnes
; are the names from format_start_digits.asm. ASCII_ZERO is the name from
; fill_ascii_slot_counts.asm. LIST_TAIL_MARK is the name from
; setup_command_4d.asm.

DEF RECORD_PLUS_15_BYTE EQU $000F
DEF RECORD15_TENS_ASCII EQU $C967
DEF RECORD15_ONES_ASCII EQU $C968
DEF RECORD15_TAIL_MARK EQU $C969

WriteRecord15TwoDigits::
    push hl
    ld bc, RECORD_PLUS_15_BYTE
    add hl, bc
    ld e, [hl]
    ld d, $00
    call FormatStartDigits
    ld a, [wStartDigitTens]
    add ASCII_ZERO
    ld [RECORD15_TENS_ASCII], a
    ld a, [wStartDigitOnes]
    add ASCII_ZERO
    ld [RECORD15_ONES_ASCII], a
    ld a, LIST_TAIL_MARK
    ld [RECORD15_TAIL_MARK], a
    pop hl
    ret
