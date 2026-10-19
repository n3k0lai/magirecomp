; Bank 3 at $54F2. StageCopiedBlockArmSlot calls this after TurnOffLCD,
; with the copied block still in WRAM bank 6 and the tile destination
; at $8860. $555E runs next.
;
; $CCC6 starts as $CCD5. $CCC9 starts at 0. WRAM bank 6 is stored at
; wCurrentWRAMBank and selected with rSVBK, so the reads below see the
; block at $D000.
;
; Each pass reads the byte at $D001 plus $CCC6 * $0E and stores it in
; the $CCCD table at index $CCC9. $CCC6 then advances. The pass returns
; once eight steps from the original $CCD5 have been taken. If $CCC6
; meets [$CCCC] first, the remaining table bytes through that eighth
; step are $FF instead of record bytes.
;
; On a record return, A equals $CCD5 + 8 and B holds that same limit.
; On a pad return, A is the same limit and the last store was $FF.
; $CCC6 is the last index visited, not one past it. $CCC9 is one past
; the last store.
;
; RECORD_LEN, RECORD_INDEX, RECORD_STEP, and COPIED_BLOCK_DATA are
; defined in stage_copied_block_arm_slot.asm. wCurrentWRAMBank and
; rSVBK are the names from timer_overflow.asm. MulCByB is the $04CA
; multiply.

DEF CHOICE_BYTES EQU $CCCD
DEF CHOICE_FILL EQU $CCC9
DEF RECORD_STRIDE_0E EQU $0E
DEF CHOICE_SLOT_COUNT EQU $08
DEF CHOICE_PAD EQU $FF

FillChoiceTableFromRecords::
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
    ld b, RECORD_STRIDE_0E
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
    ld a, [RECORD_INDEX]
    add CHOICE_SLOT_COUNT
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
    ld a, [RECORD_INDEX]
    add CHOICE_SLOT_COUNT
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
