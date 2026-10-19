; WriteRankByteTwoDigits. Bank 2 at $56E8.
;
; RunFlaggedMeasureScript and RunRankMeasureScript call this second when
; bit 1 of $D389 is set, after CopyRecordNameToListTail. HL is the record
; those callers already hold, usually $D110. The byte at record+4 is the
; rank AdjustA000RecordOnce stores at $D38A.
;
; FormatStartDigits turns that byte into decimal places. The tens and ones
; plus $30 are stored at $C954 and $C955. $FC is stored at $C956, the byte
; after those two digits. Hundreds is left unused. HL is restored.
;
; FormatStartDigits is already source. wStartDigitTens and wStartDigitOnes
; are the names from format_start_digits.asm. ASCII_ZERO is the name from
; fill_ascii_slot_counts.asm. LIST_TAIL_MARK is the name from
; setup_command_4d.asm.

DEF RECORD_RANK_BYTE EQU $0004
DEF RANK_TENS_ASCII EQU $C954
DEF RANK_ONES_ASCII EQU $C955
DEF RANK_TAIL_MARK EQU $C956

WriteRankByteTwoDigits::
    push hl
    ld bc, RECORD_RANK_BYTE
    add hl, bc
    ld e, [hl]
    ld d, $00
    call FormatStartDigits
    ld a, [wStartDigitTens]
    add ASCII_ZERO
    ld [RANK_TENS_ASCII], a
    ld a, [wStartDigitOnes]
    add ASCII_ZERO
    ld [RANK_ONES_ASCII], a
    ld a, LIST_TAIL_MARK
    ld [RANK_TAIL_MARK], a
    pop hl
    ret
