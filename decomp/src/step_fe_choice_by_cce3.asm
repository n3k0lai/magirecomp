; Bank 3 at $5238. DispatchArmedChoice jumps here when $CCA7 is $FE.
;
; $CCE3 selects the step. Zero calls $76E0. A zero result, and any
; $CCE3 other than 0 or 3, stores 3 in $CCE3 and 0 in $CD81, calls
; $76B1, then arms the slot. A nonzero result from $76E0 calls $7679,
; stores 3 in $CD81 and 1 in $CCE3, then arms the slot. When $CCE3 is
; already 3, $CCFC and $CCFD become $FF and control leaves through $7637.
;
; The arm stores $08 in $CCB4 and $F3 in $CCA9, copies wCurrentWRAMBank
; to $CCB8, points $CCB6 at $CCD6, stores $6B77 at $CCB0 and $42E3 at
; $CCB2, writes $CD81 back to itself, sets $CCB9 to 1 and $CCBA to 0,
; and CallBankedHL runs LoadArmedSlotRecord in this bank. $CCA7 is then
; $FF and control returns to DispatchArmedChoice.
;
; $76E0, $7679, $76B1, and $7637 are still INCBIN. wCurrentWRAMBank is
; the name from timer_overflow.asm. SLOT_TABLE_INDEX, SLOT_MARK_F3,
; SLOT_PTR_CCD6, SLOT_WORD_6B77, SLOT_WORD_42E3, SLOT_FLAG_ONE,
; CHOICE_WAIT, BANK3_ARMED, and CCE3_VALUE are the names from
; stage_tiles_arm_slot.asm. CallBankedHL, LoadArmedSlotRecord, and
; DispatchArmedChoice are already source.

DEF Bank3_76E0 EQU $76E0
DEF Bank3_76B1 EQU $76B1
DEF CCE3_ZERO EQU $00
DEF CCE3_STEP EQU $01
DEF CD81_CLEARED EQU $00
DEF CD81_BLOCK EQU $03
DEF CHOICE_PAIR_FF EQU $FF

StepFeChoiceByCce3::
    ld a, [$CCE3]
    cp CCE3_ZERO
    jr z, .fromZero

    cp CCE3_VALUE
    jr nz, .forceThree

    ld a, CHOICE_PAIR_FF
    ld [$CCFC], a
    ld [$CCFD], a
    jp Bank3_7637

.forceThree
    ld a, CCE3_VALUE
    ld [$CCE3], a
    ld a, CD81_CLEARED
    ld [$CD81], a
    call Bank3_76B1
    jr .armSlot

.fromZero
    call Bank3_76E0
    cp CCE3_ZERO
    jr z, .forceThree

    call RefreshFrameChoiceCell
    ld a, CD81_BLOCK
    ld [$CD81], a
    ld a, CCE3_STEP
    ld [$CCE3], a

.armSlot
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

StepFeChoiceByCce3End:
