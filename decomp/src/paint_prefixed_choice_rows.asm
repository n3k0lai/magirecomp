; Bank 3 at $6801. RepaintPrefixedBlockWindow calls here after
; StageIndexedChoiceTiles, with this bank still mapped.
;
; rVBK is cleared with the 3-byte store, and the row step at $CCC6
; starts at 0. Each of the eight bytes at $CCCD is one row. $FF skips
; that row. Any other byte is a choice id.
;
; The window cell is $9C6F plus the step times $20, one map row down.
; A zero mode at $CCCB reads a little-endian word from WRAM at
; $D002 plus (step + $CCD5) times 3 and writes tile $FE in the side
; cell. Any other mode calls $6D72 with the choice id. That routine
; returns a word in BC, and the side cell is blank tile $80.
;
; FormatStartDigits turns that word into the three places at $C92F,
; $C92E, and $C92D. $CCEC then holds one list entry: count $01 and the
; cell just after the side tile, high byte then low byte. AppendEeDigitPlaces
; writes the three $EE-based glyphs after that pointer, then $80.
; WalkPlantedMapList copies the entry onto the window. The step
; advances and the loop returns once it reaches 8.
;
; $6D72 is still INCBIN. RECORD_STEP and RECORD_INDEX are the names from
; stage_copied_block_arm_slot.asm. CHOICE_BYTES, CHOICE_PAD, and
; CHOICE_SLOT_COUNT are the names from fill_choice_table_from_records.asm.
; CHOICE_MODE is the name from setup_prefixed_block_choice.asm.
; CHOICE_00 is the name from dispatch_armed_choice.asm. rVBK is the
; name from setup_window.asm. $9C6F is WINDOW_MARK_SIDE_A in
; stamp_window_choice_marks.asm, which is included later, so this file
; uses the address. $CCEC is wOneEntryList in plant_one_map_list_entry.asm,
; also included later. MulCByB, FormatStartDigits, AppendEeDigitPlaces,
; and WalkPlantedMapList are already source.

; One window-map row, and the side cell of row 0.
DEF WINDOW_ROW_STRIDE EQU $20
DEF WINDOW_ROW_SIDE EQU $9C6F

; Mode-zero records: base $D001, then one more byte, stride 3.
DEF WRAM_RECORD_BASE EQU $D001
DEF WRAM_RECORD_STRIDE EQU $03

DEF SIDE_TILE_BLANK EQU $80
DEF SIDE_TILE_FE EQU $FE
DEF LIST_ONE_ENTRY EQU $01

PaintPrefixedChoiceRows::
    xor a
    ld [rVBK], a
    ld [RECORD_STEP], a

.nextRow:
    ld hl, CHOICE_BYTES
    ld a, [RECORD_STEP]
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl]
    cp CHOICE_PAD
    jp z, .advance

    ld b, WINDOW_ROW_STRIDE
    call MulCByB
    ld e, l
    ld d, h
    ld hl, WINDOW_ROW_SIDE
    add hl, de
    push hl
    ld a, [CHOICE_MODE]
    cp CHOICE_00
    jr z, .fromWram

    ld a, [RECORD_STEP]
    ld c, a
    ld b, $00
    ld hl, CHOICE_BYTES
    add hl, bc
    ld a, [hl]
    call CopyChoiceRecordWord
    pop hl
    ld [hl], SIDE_TILE_BLANK
    inc hl
    ld d, b
    ld e, c
    jr .format

.fromWram:
    ld a, [RECORD_STEP]
    ld c, a
    ld a, [RECORD_INDEX]
    add c
    ld c, a
    ld b, WRAM_RECORD_STRIDE
    call MulCByB
    ld bc, WRAM_RECORD_BASE
    add hl, bc
    inc hl
    ld a, [hl+]
    ld e, a
    ld d, [hl]
    pop hl
    ld [hl], SIDE_TILE_FE
    inc hl

.format:
    call FormatStartDigits
    ld b, h
    ld c, l
    ld hl, $CCEC
    ld [hl], LIST_ONE_ENTRY
    inc hl
    ld [hl], b
    inc hl
    ld [hl], c
    inc hl
    call AppendEeDigitPlaces
    ld [hl], SIDE_TILE_BLANK
    inc hl
    call WalkPlantedMapList

.advance:
    ld a, [RECORD_STEP]
    inc a
    cp CHOICE_SLOT_COUNT
    ret z

    ld [RECORD_STEP], a
    jp .nextRow

PaintPrefixedChoiceRowsEnd:
