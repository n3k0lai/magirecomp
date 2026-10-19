; Bank 5 at $5575. Callers take this path when bit 7 of $D125 is set,
; then plant $49 $C9 at $C93D so that word points at the text built here.
;
; [$D0DB] is stored at $CD8C and $CD8F is pointed at $C949. CopyIndexedName
; in bank 6 copies that id's ten-byte name there. $FC is stored at $C953.
; [$D112] is copied the same way to $C954, and $FC is stored at $C95E.
;
; HL is left at $C95F. A nonzero [$D076] selects [$D077]; zero selects
; [$D073]. FormatStartDigits turns that byte into three decimal digits at
; $C92F, $C92E, and $C92D. A nonzero hundreds or tens digit is stored as
; that digit plus $30. The ones digit is always stored that way. $FC
; follows the digits, and the routine returns.
;
; CopyIndexedName, CallBankedHL, and FormatStartDigits are already source.
; wUnknownCD8C and wUnknownCD8F are the names from indexed_tail_07.asm.
; wListTailDest and LIST_TAIL_MARK are the names from setup_command_4d.asm.
; wStartDigitHundreds, wStartDigitTens, and wStartDigitOnes are the names
; from format_start_digits.asm.

DEF wSecondNameId EQU $D112
DEF wNameCountFlag EQU $D076
DEF wNameCountAlt EQU $D077
DEF wNameCountDefault EQU $D073
DEF NAME_ID_SRC EQU $D0DB
DEF SECOND_NAME_BUF EQU $C954
DEF FIRST_NAME_MARK EQU $C953
DEF SECOND_NAME_MARK EQU $C95E
DEF COUNT_TEXT EQU $C95F
DEF ASCII_DIGIT_BASE EQU $30
DEF COPY_INDEXED_NAME_BANK EQU $06

WriteIndexedNamesAndCount::
    ld a, [NAME_ID_SRC]
    ld [wUnknownCD8C], a
    ld bc, wListTailDest
    ld hl, wUnknownCD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyIndexedName
    ld e, COPY_INDEXED_NAME_BANK
    call CallBankedHL
    ld a, LIST_TAIL_MARK
    ld [FIRST_NAME_MARK], a
    ld a, [wSecondNameId]
    ld [wUnknownCD8C], a
    ld bc, SECOND_NAME_BUF
    ld hl, wUnknownCD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyIndexedName
    ld e, COPY_INDEXED_NAME_BANK
    call CallBankedHL
    ld a, LIST_TAIL_MARK
    ld [SECOND_NAME_MARK], a
    ld hl, COUNT_TEXT
    ld a, [wNameCountFlag]
    and a
    jr z, .useDefault
    ld a, [wNameCountAlt]
    jr .format
.useDefault:
    ld a, [wNameCountDefault]
.format:
    ld e, a
    ld d, $00
    call FormatStartDigits
    ld a, [wStartDigitHundreds]
    and a
    jr z, .tens
    add ASCII_DIGIT_BASE
    ld [hl+], a
.tens:
    ld a, [wStartDigitTens]
    and a
    jr z, .ones
    add ASCII_DIGIT_BASE
    ld [hl+], a
.ones:
    ld a, [wStartDigitOnes]
    add ASCII_DIGIT_BASE
    ld [hl+], a
    ld a, LIST_TAIL_MARK
    ld [hl+], a
    ret
