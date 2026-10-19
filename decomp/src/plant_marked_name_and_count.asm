; Bank 5 at $560E. Run560EThenWaitC71D calls this, then points $C93D
; at $C949 so that word reads the text built here.
;
; $FC is stored at $C949, and $CD8F is pointed at the next byte, $C94A.
; [$D0C7] is stored at $CD8C. CopyIndexedName in bank 6 copies that id's
; ten-byte name to $C94A. $FC is stored at $C954, the byte after the name.
;
; FormatStartDigits turns [$D0C8] into three decimal digits at $C92F,
; $C92E, and $C92D. From $C955, a nonzero hundreds or tens digit is stored
; as that digit plus $30. The ones digit is always stored that way. $FC
; follows the digits, and the routine returns.
;
; CopyIndexedName, CallBankedHL, and FormatStartDigits are already source.
; wUnknownCD8C and wUnknownCD8F are the names from indexed_tail_07.asm.
; wListTailDest and LIST_TAIL_MARK are the names from setup_command_4d.asm.
; wStartDigitHundreds, wStartDigitTens, and wStartDigitOnes are the names
; from format_start_digits.asm. COPY_INDEXED_NAME_BANK and ASCII_DIGIT_BASE
; are the names from write_indexed_names_and_count.asm.

DEF wMarkedNameId EQU $D0C7
DEF wMarkedNameCount EQU $D0C8
DEF MARKED_NAME_END EQU $C954
DEF MARKED_COUNT_TEXT EQU $C955

PlantMarkedNameAndCount::
    ld hl, wListTailDest
    ld a, LIST_TAIL_MARK
    ld [hl+], a
    ld a, h
    ld [wUnknownCD8F + 1], a
    ld a, l
    ld [wUnknownCD8F], a
    ld a, [wMarkedNameId]
    ld [wUnknownCD8C], a
    ld hl, CopyIndexedName
    ld e, COPY_INDEXED_NAME_BANK
    call CallBankedHL
    ld a, LIST_TAIL_MARK
    ld [MARKED_NAME_END], a
    ld a, [wMarkedNameCount]
    ld e, a
    ld d, $00
    call FormatStartDigits
    ld hl, MARKED_COUNT_TEXT
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
