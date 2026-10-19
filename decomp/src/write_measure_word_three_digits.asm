; WriteMeasureWordThreeDigits. Bank 2 at $570A.
;
; RunFlaggedMeasureScript and RunRankMeasureScript call this third when
; bit 1 of $D389 is set, after WriteRankByteTwoDigits. HL is the record
; those callers already hold, usually $D110. The big-endian word at
; record+9 is the measure SpendMeasureHundred caps at 250.
;
; FormatStartDigits turns that word into decimal places. The hundreds,
; tens, and ones plus $30 are stored at $C957, $C958, and $C959. $FC is
; stored at $C95A, the byte after those three digits. HL is restored.
;
; FormatStartDigits is already source. wStartDigitHundreds,
; wStartDigitTens, and wStartDigitOnes are the names from
; format_start_digits.asm. ASCII_ZERO is the name from
; fill_ascii_slot_counts.asm. LIST_TAIL_MARK is the name from
; setup_command_4d.asm.

DEF RECORD_MEASURE_WORD EQU $0009
DEF MEASURE_HUNDREDS_ASCII EQU $C957
DEF MEASURE_TENS_ASCII EQU $C958
DEF MEASURE_ONES_ASCII EQU $C959
DEF MEASURE_TAIL_MARK EQU $C95A

WriteMeasureWordThreeDigits::
    push hl
    ld bc, RECORD_MEASURE_WORD
    add hl, bc
    ld a, [hl+]
    ld e, [hl]
    ld d, a
    call FormatStartDigits
    ld a, [wStartDigitHundreds]
    add ASCII_ZERO
    ld [MEASURE_HUNDREDS_ASCII], a
    ld a, [wStartDigitTens]
    add ASCII_ZERO
    ld [MEASURE_TENS_ASCII], a
    ld a, [wStartDigitOnes]
    add ASCII_ZERO
    ld [MEASURE_ONES_ASCII], a
    ld a, LIST_TAIL_MARK
    ld [MEASURE_TAIL_MARK], a
    pop hl
    ret
