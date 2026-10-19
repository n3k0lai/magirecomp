; Bank 3 at $7415. StageSramListNames calls this after $7393 and
; before TurnOnLCDIfOff. This routine writes the SRAM bank register,
; not rROMB0. The multiply below is in bank 0.
;
; RECORD_STEP starts at 0. Each pass forms D as RECORD_INDEX plus
; RECORD_STEP. SRAM bank wSRAMBank is selected with `add a, $00`, which
; keeps that bank byte, and SRAM is enabled. Ten bytes at LIST_SRAM are
; read. A byte whose value minus one equals D keeps tile $F7 in E. If
; none of the ten match, E becomes the blank tile $80. C only counts
; the scan. SRAM is disabled.
;
; The map cell is RECORD_STEP * $20 + $9C71. E is written there. The
; step advances. The pass returns when the next step would be 8.
; Otherwise `jr` returns to the pass head.
;
; RECORD_INDEX and RECORD_STEP are the names from
; stage_copied_block_arm_slot.asm. CHOICE_SLOT_COUNT is the name from
; fill_choice_table_from_records.asm. LIST_SRAM and LIST_LEN are the
; names from resolve_armed_list_choice.asm. WINDOW_MARK_BASE,
; WINDOW_MAP_STRIDE, and WINDOW_BLANK_TILE are the names from
; paint_window_indexed_rows.asm. wSRAMBank, rRAMB, and SRAM_ENABLE are
; the names from handle_start_press.asm. rRAMG is the name from
; reset.asm. MulCByB is already source. What tile $F7 draws is still
; unknown.

; Written when a LIST_SRAM byte, minus one, matches the slot index.
DEF LIST_MARK_TILE EQU $F7

PaintSramListMarks::
    xor a
    ld [RECORD_STEP], a

.nextRow:
    ld e, LIST_MARK_TILE
    ld a, [RECORD_STEP]
    ld d, a
    ld a, [RECORD_INDEX]
    add a, d
    ld d, a
    ld c, $00
    ld hl, LIST_SRAM
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a

.scan:
    ld a, [hl+]
    dec a
    cp a, d
    jr z, .paint

    inc c
    ld a, c
    cp a, LIST_LEN
    jr nz, .scan

    ld e, WINDOW_BLANK_TILE

.paint:
    xor a
    ld [rRAMG], a
    ld a, [RECORD_STEP]
    ld c, a
    ld b, WINDOW_MAP_STRIDE
    push de
    call MulCByB
    ld bc, WINDOW_MARK_BASE
    add hl, bc
    pop de
    ld [hl], e
    ld a, [RECORD_STEP]
    inc a
    cp a, CHOICE_SLOT_COUNT
    ret z

    ld [RECORD_STEP], a
    jr .nextRow
