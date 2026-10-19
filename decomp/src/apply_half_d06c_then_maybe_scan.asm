; Bank 5 at $42F6. The $D016 = 2 path calls this through CallBankedHL
; after the big-endian word at $D14E is stored at SRAM $A005.
;
; A nonzero [$D0D7] returns immediately. Opcode 25 clears that byte.
; What sets it is still unknown.
;
; [$D06C] is shifted right and then incremented. That byte is stored at
; $C9FE. AddC9FEToMapWord0 adds it to sMapWord0, caps the word at 999,
; and replaces $C9FE with the delta that was actually stored. A zero
; delta skips the text. Otherwise FormatStartDigits splits the delta
; into three digits. Each digit plus $30 is written at $C949, and $FC
; follows. $C93D is pointed at $C949. The fourth script record at $C71B
; becomes bank $4C, pointer $43E2, handler $0A66. WaitUntilC71DClears
; then runs.
;
; AddDividerStep returns a byte. When its low nibble is below 8, $5762
; runs. $FF skips the rest of this roll. Any other return is stored at
; $C9FD, and both $C9FC and $C9FE are set to 1, so DispatchBank7Arg
; takes table index 1 (CopyNameAndAddScanC). That copies the id's name
; over $C949 and adds 1 to the matching SRAM scan byte. $C93D is
; pointed at $C949 again. $C71B becomes bank $4C, pointer $43F9,
; handler $0A66, and WaitUntilC71DClears runs.
;
; A second AddDividerStep uses the high nibble. Below 5, the same
; $5762, index 1, and $43F9 path runs. A high nibble of 5 or more
; returns, as does $FF from $5762.
;
; $5762 is still INCBIN. It returns $FF or one of the eight bytes at
; $D0B8. sMapWord0 is the name from draw_start_screen_map.asm.
; wBank7ArgC9FC is the name from copy_three_c9fc_bank7.asm.
; wStartDigitHundreds, wStartDigitTens, and wStartDigitOnes are the
; names from format_start_digits.asm. wListTailDest, wUnknownC93D, and
; LIST_TAIL_MARK are the names from setup_command_4d.asm. wScriptC71B
; and SCRIPT_BANK_4C are the names from dispatch_nonzero_d016.asm.
; INITIAL_SCRIPT_HANDLER is the name from reset.asm. AddC9FEToMapWord0,
; FormatStartDigits, AddDividerStep, DispatchBank7Arg,
; WaitUntilC71DClears, and CallBankedHL are already source.

; Cleared by opcode $25. A nonzero value skips this whole routine.
DEF wAwardHoldD0D7 EQU $D0D7

; Grown elsewhere, including by $D114 on the high-index refresh path.
; Only half of it, plus one, is offered to sMapWord0 here.
DEF wMapAddAccumD06C EQU $D06C

; Three ASCII digits for a nonzero map-word delta. Bank $4C.
DEF SCRIPT_PTR_MAP_DELTA EQU $43E2

; Name text after CopyNameAndAddScanC. Bank $4C.
DEF SCRIPT_PTR_SCAN_NAME EQU $43F9

; Low nibble of AddDividerStep must be below this to take the first roll.
DEF LOW_NIBBLE_LIMIT EQU $08

; High nibble of the second AddDividerStep must be below this.
DEF HIGH_NIBBLE_LIMIT EQU $05

; $C9FC index that selects CopyNameAndAddScanC, and the $C9FE addend.
DEF SCAN_ARG_ONE EQU $01

; Bank passed to CallBankedHL for AddC9FEToMapWord0 and DispatchBank7Arg.
DEF MAP_WORD_BANK EQU $07

; Bank passed to CallBankedHL for WaitUntilC71DClears.
DEF WAIT_SCRIPT_BANK EQU $05

; Digit glyphs are the digit plus this.
DEF DIGIT_GLYPH_BASE EQU $30

ApplyHalfD06CThenMaybeScan::
    ld a, [wAwardHoldD0D7]
    and a
    ret nz

    ld a, [wMapAddAccumD06C]
    srl a
    inc a
    ld [wBank7ArgC9FC + 2], a
    ld hl, AddC9FEToMapWord0
    ld e, MAP_WORD_BANK
    call CallBankedHL
    ld a, [wBank7ArgC9FC + 2]
    and a
    jr z, .rollLow

    ld e, a
    ld d, $00
    call FormatStartDigits
    ld hl, wListTailDest
    ld a, [wStartDigitHundreds]
    add DIGIT_GLYPH_BASE
    ld [hl+], a
    ld a, [wStartDigitTens]
    add DIGIT_GLYPH_BASE
    ld [hl+], a
    ld a, [wStartDigitOnes]
    add DIGIT_GLYPH_BASE
    ld [hl+], a
    ld [hl], LIST_TAIL_MARK
    ld a, LOW(wListTailDest)
    ld [wUnknownC93D], a
    ld a, HIGH(wListTailDest)
    ld [wUnknownC93D + 1], a
    ld hl, wScriptC71B
    ld a, SCRIPT_BANK_4C
    ld [hl+], a
    ld a, LOW(SCRIPT_PTR_MAP_DELTA)
    ld [hl+], a
    ld a, HIGH(SCRIPT_PTR_MAP_DELTA)
    ld [hl+], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld hl, WaitUntilC71DClears
    ld e, WAIT_SCRIPT_BANK
    call CallBankedHL

.rollLow:
    call AddDividerStep
    and $0f
    cp LOW_NIBBLE_LIMIT
    jr nc, .rollHigh

    call $5762
    cp $ff
    jr z, .rollHigh

    ld [wBank7ArgC9FC + 1], a
    ld a, SCAN_ARG_ONE
    ld [wBank7ArgC9FC], a
    ld a, SCAN_ARG_ONE
    ld [wBank7ArgC9FC + 2], a
    ld hl, DispatchBank7Arg
    ld e, MAP_WORD_BANK
    call CallBankedHL
    ld a, LOW(wListTailDest)
    ld [wUnknownC93D], a
    ld a, HIGH(wListTailDest)
    ld [wUnknownC93D + 1], a
    ld hl, wScriptC71B
    ld a, SCRIPT_BANK_4C
    ld [hl+], a
    ld a, LOW(SCRIPT_PTR_SCAN_NAME)
    ld [hl+], a
    ld a, HIGH(SCRIPT_PTR_SCAN_NAME)
    ld [hl+], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld hl, WaitUntilC71DClears
    ld e, WAIT_SCRIPT_BANK
    call CallBankedHL

.rollHigh:
    call AddDividerStep
    swap a
    and $0f
    cp HIGH_NIBBLE_LIMIT
    ret nc

    call $5762
    cp $ff
    ret z

    ld [wBank7ArgC9FC + 1], a
    ld a, SCAN_ARG_ONE
    ld [wBank7ArgC9FC], a
    ld a, SCAN_ARG_ONE
    ld [wBank7ArgC9FC + 2], a
    ld hl, DispatchBank7Arg
    ld e, MAP_WORD_BANK
    call CallBankedHL
    ld a, LOW(wListTailDest)
    ld [wUnknownC93D], a
    ld a, HIGH(wListTailDest)
    ld [wUnknownC93D + 1], a
    ld hl, wScriptC71B
    ld a, SCRIPT_BANK_4C
    ld [hl+], a
    ld a, LOW(SCRIPT_PTR_SCAN_NAME)
    ld [hl+], a
    ld a, HIGH(SCRIPT_PTR_SCAN_NAME)
    ld [hl+], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld hl, WaitUntilC71DClears
    ld e, WAIT_SCRIPT_BANK
    call CallBankedHL
    ret
