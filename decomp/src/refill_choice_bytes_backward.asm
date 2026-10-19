; Bank 3 at $68E8. StepPrefixedBlockChoice0B calls this after it
; decrements RECORD_INDEX, when the mode at $CCCB is zero.
;
; RECORD_STEP starts as RECORD_INDEX. CHOICE_FILL starts at 7, formed
; as CHOICE_SLOT_COUNT then DEC A. WRAM bank 6 is stored at
; wCurrentWRAMBank and selected with rSVBK, so the reads below see the
; block at $D000.
;
; Each pass reads the byte at $D001 plus RECORD_STEP * 3 and stores it
; in the $CCCD table at CHOICE_FILL. That stride is the three-byte
; prefixed-block record: a flag byte, then a cost word. The pass walks
; the fill index and the record index down together. When the fill
; index is already 0, the loop stops and that record index is written
; back to RECORD_INDEX. Slot 7 holds the record that was current on
; entry, and slot 0 holds the record seven steps earlier.
;
; RECORD_INDEX, RECORD_STEP, and COPIED_BLOCK_DATA are the names from
; stage_copied_block_arm_slot.asm. CHOICE_BYTES, CHOICE_FILL, and
; CHOICE_SLOT_COUNT are the names from fill_choice_table_from_records.asm.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; MulCByB is the $04CA multiply. The only call is already source.

; Three bytes per record at $D001.
DEF BACK_RECORD_STRIDE EQU $03

RefillChoiceBytesBackward::
    ld a, [RECORD_INDEX]
    ld [RECORD_STEP], a
    ld a, CHOICE_SLOT_COUNT
    dec a
    ld [CHOICE_FILL], a
    ld a, COPIED_BLOCK_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a

.readRecord:
    ld a, [RECORD_STEP]
    ld c, a
    ld b, BACK_RECORD_STRIDE
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
    ld a, [CHOICE_FILL]
    cp $00
    jr z, .keepIndex

    dec a
    ld [CHOICE_FILL], a
    ld a, [RECORD_STEP]
    dec a
    ld [RECORD_STEP], a
    jr .readRecord

.keepIndex:
    ld a, [RECORD_STEP]
    ld [RECORD_INDEX], a
    ret
