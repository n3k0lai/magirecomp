; WriteRecord13TwoDigits. Bank 2 at $5778.
;
; RunFlaggedMeasureScript calls this sixth when bit 1 of $D389 is set,
; after WriteRecord12TwoDigits. HL is the record
; those callers already hold, usually $D110. The byte at record+13 is the
; field SampleRecord13Contribution adds into, capped at $63.
;
; FormatStartDigits turns that byte into decimal places. The tens and ones
; plus $30 are stored at $C961 and $C962. $FC is stored at $C963, the byte
; after those two digits. Hundreds is left unused. HL is restored.
;
; FormatStartDigits is already source. wStartDigitTens and wStartDigitOnes
; are the names from format_start_digits.asm. ASCII_ZERO is the name from
; fill_ascii_slot_counts.asm. LIST_TAIL_MARK is the name from
; setup_command_4d.asm.

DEF RECORD_PLUS_13_BYTE EQU $000D
DEF RECORD13_TENS_ASCII EQU $C961
DEF RECORD13_ONES_ASCII EQU $C962
DEF RECORD13_TAIL_MARK EQU $C963

WriteRecord13TwoDigits::
    push hl
    ld bc, RECORD_PLUS_13_BYTE
    add hl, bc
    ld e, [hl]
    ld d, $00
    call FormatStartDigits
    ld a, [wStartDigitTens]
    add ASCII_ZERO
    ld [RECORD13_TENS_ASCII], a
    ld a, [wStartDigitOnes]
    add ASCII_ZERO
    ld [RECORD13_ONES_ASCII], a
    ld a, LIST_TAIL_MARK
    ld [RECORD13_TAIL_MARK], a
    pop hl
    ret
