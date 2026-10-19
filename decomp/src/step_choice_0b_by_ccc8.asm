; Bank 3 at $4FBE. DispatchArmedChoice jumps here when $CCA7 is $0B.
;
; $7512 runs, then TurnOffLCD, $7596, and TurnOnLCDIfOff. A is [$CCEB]
; for $7751. $CCE2 becomes 1. $CCC8 is reduced by $08. When the new
; value is $08, $CCE1 is cleared and $77C2 runs. Any other value calls
; $7777 instead.
;
; $CCA7 is copied to $CD81. The arm stores $08 in $CCB4 and $F3 in
; $CCA9, copies wCurrentWRAMBank to $CCB8, points $CCB6 at $CCD6,
; stores $6B77 at $CCB0 and $42E3 at $CCB2, writes $CD81 back to
; itself, sets $CCB9 to 1 and $CCBA to 0, and CallBankedHL runs
; LoadArmedSlotRecord in this bank. $CCA7 is then $FF and control
; returns to DispatchArmedChoice.
;
; $7512, $7596, $7751, $7777, and $77C2 are still INCBIN.
; wCurrentWRAMBank is the name from timer_overflow.asm. SLOT_TABLE_INDEX,
; SLOT_MARK_F3, SLOT_PTR_CCD6, SLOT_WORD_6B77, SLOT_WORD_42E3,
; SLOT_FLAG_ONE, CHOICE_WAIT, and BANK3_ARMED are the names from
; stage_tiles_arm_slot.asm. LIMIT_08 and LONG_MARK are the names from
; stage_copied_block_arm_slot.asm. CallBankedHL, TurnOffLCD,
; TurnOnLCDIfOff, LoadArmedSlotRecord, and DispatchArmedChoice are
; already source.

DEF Bank3_7512 EQU $7512
DEF Bank3_7596 EQU $7596
DEF Bank3_7777 EQU $7777

StepChoice0BByCcc8::
    call Bank3_7512
    call TurnOffLCD
    call Bank3_7596
    call TurnOnLCDIfOff
    ld a, [$CCEB]
    call Bank3_7751
    ld hl, $CCE2
    ld a, LONG_MARK
    ld [hl-], a
    ld a, [$CCC8]
    sub LIMIT_08
    ld [$CCC8], a
    cp LIMIT_08
    jr nz, .notFloor

    ld a, $00
    ld [hl], a
    call Bank3_77C2
    jr .armSlot

.notFloor:
    call Bank3_7777

.armSlot:
    ld a, [$CCA7]
    ld [$CD81], a
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
