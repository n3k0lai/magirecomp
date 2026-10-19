; Bank 3 at $6880. RefreshPrefixedBlockList calls this when the
; mode at $CCCB is zero, then jumps to RepaintPrefixedBlockWindow.
;
; RECORD_STEP starts as RECORD_INDEX. CHOICE_FILL starts at 0. WRAM
; bank 6 is stored at wCurrentWRAMBank and selected with rSVBK, so the
; reads below see the block at $D000.
;
; Each pass reads the byte at $D001 plus RECORD_STEP * 3 and stores it
; in the $CCCD table at CHOICE_FILL. That stride is the three-byte
; prefixed-block record: a flag byte, then a cost word. RECORD_STEP
; and CHOICE_FILL then advance together. The pass returns when the
; next RECORD_STEP equals CHOICE_ROW. If RECORD_STEP meets RECORD_LEN
; first, the remaining table bytes through that same limit are $FF
; instead of record bytes.
;
; On either return, A is the RECORD_STEP that matched CHOICE_ROW and
; B holds CHOICE_ROW. CHOICE_FILL is one past the last store.
;
; RECORD_LEN, RECORD_INDEX, RECORD_STEP, COPIED_BLOCK_BANK, and
; COPIED_BLOCK_DATA are the names from stage_copied_block_arm_slot.asm.
; CHOICE_BYTES, CHOICE_FILL, and CHOICE_PAD are the names from
; fill_choice_table_from_records.asm. CHOICE_ROW is the name from
; setup_prefixed_block_choice.asm. wCurrentWRAMBank and rSVBK are the
; names from timer_overflow.asm. MulCByB is the $04CA multiply. The
; only call is already source.

; Three bytes per record at $D001.
DEF LIST_RECORD_STRIDE EQU $03

FillChoiceBytesForward::
    ld a, [RECORD_INDEX]
    ld [RECORD_STEP], a
    xor a
    ld [CHOICE_FILL], a
    ld a, COPIED_BLOCK_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a

.readRecord:
    ld a, [RECORD_STEP]
    ld c, a
    ld b, LIST_RECORD_STRIDE
    call MulCByB
    ld de, COPIED_BLOCK_DATA
    add hl, de
    ld a, [hl]
    ld b, a
    ld a, [CHOICE_FILL]
    ld hl, CHOICE_BYTES
    ld e, a
    ld d, $00
    add hl, de
    ld [hl], b
    ld a, [CHOICE_ROW]
    ld b, a
    ld a, [RECORD_STEP]
    inc a
    cp b
    ret z

    ld [RECORD_STEP], a
    ld b, a
    ld a, [CHOICE_FILL]
    inc a
    ld [CHOICE_FILL], a
    ld a, [RECORD_LEN]
    cp b
    jr nz, .readRecord

.padSlot:
    ld a, [CHOICE_FILL]
    ld hl, CHOICE_BYTES
    ld e, a
    ld d, $00
    add hl, de
    ld [hl], CHOICE_PAD
    ld a, [CHOICE_ROW]
    ld b, a
    ld a, [RECORD_STEP]
    inc a
    cp b
    ret z

    ld [RECORD_STEP], a
    ld a, [CHOICE_FILL]
    inc a
    ld [CHOICE_FILL], a
    jr .padSlot
