; Bank 3 at $73E3. PaintSramListRecordBytes calls this after it
; stores one SRAM record byte at $CCEC. CommitBoughtSramRecord plants
; the same address at wCallback and runs RefreshFrame.
;
; RECORD_STEP times $20, plus $9C6E, is the window cell. A byte of $FF
; writes the blank tile $80 into that cell and the next one, then
; returns. Any other byte is passed to FormatStartDigits with D cleared.
; Tens and ones are written through $77E7 with E=$DE, the glyph for
; digit 0. Hundreds is left unused. HL advances across the two cells.
;
; This routine does not write rROMB0. The multiply and the formatter
; are in bank 0. $77E7 stays in this bank.
;
; RECORD_STEP is the name from stage_copied_block_arm_slot.asm.
; wOneEntryList is the name from plant_one_map_list_entry.asm.
; WINDOW_MAP_STRIDE, WINDOW_DIGIT_BASE, and WINDOW_BLANK_TILE are the
; names from paint_window_indexed_rows.asm. wStartDigitTens and
; wStartDigitOnes are the names from format_start_digits.asm.
; PLACE_GLYPH_ZERO and Bank3_77E7 are the names from
; append_three_digit_places.asm. MulCByB and FormatStartDigits are
; already source. $77E7 is still INCBIN.

; A record byte of $FF has no digits. Both cells stay blank.
DEF RECORD_BYTE_ABSENT EQU $FF

PaintSramRecordByte::
    ld a, [RECORD_STEP]
    ld c, a
    ld b, WINDOW_MAP_STRIDE
    call MulCByB
    ld de, WINDOW_DIGIT_BASE
    add hl, de
    ld a, [wOneEntryList]
    cp RECORD_BYTE_ABSENT
    jr z, .blankCells

    push hl
    ld e, a
    ld d, $00
    call FormatStartDigits
    pop hl
    ld e, PLACE_GLYPH_ZERO
    ld a, [wStartDigitTens]
    call Bank3_77E7
    ld e, PLACE_GLYPH_ZERO
    ld a, [wStartDigitOnes]
    call Bank3_77E7
    ret

.blankCells:
    ld a, WINDOW_BLANK_TILE
    ld [hl+], a
    ld [hl+], a
    ret
