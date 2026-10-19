; Bank 3 at $503E. DispatchArmedChoice jumps here when $CCA7 is $0C.
;
; The byte at $CCCD+$07 is incremented and stored at $CCD5. $7550 runs,
; then TurnOffLCD, $7596, and TurnOnLCDIfOff. $CCA7 is copied to $CD81
; and $7777 runs. $CCE1 becomes 1, leaving HL at $CCE2. $CCC8 grows by
; $08. While that sum stays below [$CCCC], $7751 runs. Once it reaches
; [$CCCC], $CCE2 is cleared, $CD81 becomes $0B, and $779D runs.
;
; The arm stores $08 in $CCB4 and $F3 in $CCA9, copies wCurrentWRAMBank
; to $CCB8, points $CCB6 at $CCD6, stores $6B77 at $CCB0 and $42E3 at
; $CCB2, writes $CD81 back to itself, sets $CCB9 to 1 and $CCBA to 0,
; and CallBankedHL runs LoadArmedSlotRecord in this bank. $CCA7 is then
; $FF and control returns to DispatchArmedChoice.
;
; $7550 is still INCBIN. $7596, $7751, $7777, and $779D are the names
; from the $4FBE and $5400 steps. wCurrentWRAMBank is the name from
; timer_overflow.asm. CHOICE_BYTES is the name from
; fill_choice_table_from_records.asm. SLOT_TABLE_INDEX, SLOT_MARK_F3,
; SLOT_PTR_CCD6, SLOT_WORD_6B77, SLOT_WORD_42E3, SLOT_FLAG_ONE,
; CHOICE_WAIT, and BANK3_ARMED are the names from
; stage_tiles_arm_slot.asm. LIMIT_08 and LONG_MARK are the names from
; stage_copied_block_arm_slot.asm. CHOICE_0B is the name from
; dispatch_armed_choice.asm. CallBankedHL, TurnOffLCD, TurnOnLCDIfOff,
; LoadArmedSlotRecord, and DispatchArmedChoice are already source.

DEF CHOICE_ROW_INDEX EQU $07
DEF CHOICE_ROW_PLUS EQU $CCD5
DEF CHOICE_CEILING EQU $CCCC
DEF CHOICE_STEP EQU $CCE1

StepChoice0CByCcc8::
    ld hl, CHOICE_BYTES
    ld e, CHOICE_ROW_INDEX
    ld d, $00
    add hl, de
    ld a, [hl]
    inc a
    ld [CHOICE_ROW_PLUS], a
    call CollectChoiceIndicesForward
    call TurnOffLCD
    call Bank3_7596
    call TurnOnLCDIfOff
    ld a, [$CCA7]
    ld [$CD81], a
    call Bank3_7777
    ld a, LONG_MARK
    ld hl, CHOICE_STEP
    ld [hl+], a
    ld a, [CHOICE_CEILING]
    ld c, a
    ld a, [$CCC8]
    add LIMIT_08
    ld [$CCC8], a
    cp c
    jr c, .underCeiling

    ld a, $00
    ld [hl], a
    ld a, CHOICE_0B
    ld [$CD81], a
    call Bank3_779D
    jr .armSlot

.underCeiling:
    call Bank3_7751

.armSlot:
    ld a, SLOT_TABLE_INDEX
    ld [$CCB4], a
    ld a, SLOT_MARK_F3
    ld [$CCA9], a
    ld a, [wCurrentWRAMBank]
    ld [$CCB8], a
    ld bc, SLOT_PTR_CCD6
    ld hl, $CCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, SLOT_WORD_6B77
    ld hl, $CCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, SLOT_WORD_42E3
    ld hl, $CCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [$CD81]
    ld [$CD81], a
    ld a, SLOT_FLAG_ONE
    ld [$CCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, BANK3_ARMED
    call CallBankedHL
    ld a, CHOICE_WAIT
    ld [$CCA7], a
    jp DispatchArmedChoice
