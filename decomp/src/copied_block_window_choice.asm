; Bank 4 at $582C. StageCopiedBlockWindow jumps here after the copied
; block window is armed and the LCD is on. This bank stays mapped. The
; routine does not write rROMB0.
;
; Each pass calls PrepWindowChoiceFrame in bank 3, then RefreshFrame.
; When $CD81 differs from $CD3B, $6034 runs. $CD3B is wUnknownCD3B from
; stage_copied_block_window.asm, which is included later, so this file
; uses the address. $CCA7 equal to $FF returns to the top.
;
; Any other choice is saved at $CD55. Zero and $04 turn the LCD off,
; call $5F1A, and stamp the window marks. The slot is armed again with
; table index 5, mark $F3, and id 1. $CCB8 is wCurrentWRAMBank. $CCB6
; points at $CC4D. $CCB0 and $CCB2 both hold $42E3. $CCB9 and $CCBA are
; 0, written with the immediate form, so LoadArmedSlotRecord returns
; before ReloadSlotPosition. $CCA7 is set back to $FF, TurnOnLCDIfOff
; runs, and control returns to the top.
;
; $FE leaves through $54D8. Any other value calls $5A5B and reads
; $CD49. A nonzero byte also leaves through $54D8. wUnknownCD49 is the
; name from call_bank4_5494_then_enter_script.asm. Zero plants $6160
; and then $618B, both in bank 4, at $C6E4 and runs RefreshFrame after
; each store. The slot is armed the same way, except the id is the
; saved choice. LoadArmedSlotRecord runs, $CCA7 becomes $FF, and
; control returns to the top. The LCD stays on on this path.
;
; wCurrentWRAMBank is the name from timer_overflow.asm. CallBankedHL,
; RefreshFrame, TurnOffLCD, PrepWindowChoiceFrame, StampWindowChoiceMarks,
; LoadArmedSlotRecord, and TurnOnLCDIfOff are already source. $54D8,
; $5A5B, $5F1A, $6034, $6160, and $618B are still INCBIN. $CCB4 is the
; table index LoadArmedSlotRecord reads.

DEF TAIL_CHOICE EQU $CCA7
DEF TAIL_CHOICE_WAIT EQU $FF
DEF TAIL_CHOICE_SAVED EQU $CD55
DEF TAIL_CHOICE_FOUR EQU $04
DEF TAIL_CHOICE_CANCEL EQU $FE
DEF TAIL_SLOT_NOW EQU $CD81
DEF TAIL_SLOT_SEEN EQU $CD3B

DEF TAIL_FRAME_BANK EQU $04
DEF TAIL_FRAME_A_LO EQU $60
DEF TAIL_FRAME_A_HI EQU $61
DEF TAIL_FRAME_B_LO EQU $8B
DEF TAIL_FRAME_PTR EQU $C6E4
DEF TAIL_FRAME_BANK_ADDR EQU $C6E6

DEF TAIL_SLOT_INDEX EQU $05
DEF TAIL_SLOT_MARK EQU $F3
DEF TAIL_SLOT_PTR EQU $CC4D
DEF TAIL_SLOT_WORD EQU $42E3
DEF TAIL_SLOT_ID EQU $01
DEF TAIL_RECORD_BANK EQU $03

CopiedBlockWindowChoice::
    ld hl, PrepWindowChoiceFrame
    ld e, TAIL_RECORD_BANK
    call CallBankedHL
    call RefreshFrame
    ld a, [TAIL_SLOT_NOW]
    ld b, a
    ld a, [TAIL_SLOT_SEEN]
    cp b
    jr z, .readChoice

    call RefreshChangedSlotDigits

.readChoice
    ld a, [TAIL_CHOICE]
    cp TAIL_CHOICE_WAIT
    jr z, CopiedBlockWindowChoice

    ld [TAIL_CHOICE_SAVED], a
    and a
    jr nz, .notZero

.zeroOrFour
    call TurnOffLCD
    call LoadWRAM6ChoiceRows
    call StampWindowChoiceMarks
    ld a, TAIL_SLOT_INDEX
    ld [$CCB4], a
    ld a, TAIL_SLOT_MARK
    ld [$CCA9], a
    ld a, [wCurrentWRAMBank]
    ld [$CCB8], a
    ld bc, TAIL_SLOT_PTR
    ld hl, $CCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, TAIL_SLOT_WORD
    ld hl, $CCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, TAIL_SLOT_WORD
    ld hl, $CCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, TAIL_SLOT_ID
    ld [TAIL_SLOT_NOW], a
    ld a, $00
    ld [$CCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, TAIL_RECORD_BANK
    call CallBankedHL
    ld a, TAIL_CHOICE_WAIT
    ld [TAIL_CHOICE], a
    call TurnOnLCDIfOff
    jp CopiedBlockWindowChoice

.notZero
    cp TAIL_CHOICE_FOUR
    jr z, .zeroOrFour

    cp TAIL_CHOICE_CANCEL
    jr nz, .otherChoice

    jp ReloadWindowTiles

.otherChoice
    call TryAffordOtherChoice
    ld a, [wUnknownCD49]
    and a
    jp nz, ReloadWindowTiles

    ld a, TAIL_FRAME_BANK
    ld [TAIL_FRAME_BANK_ADDR], a
    ld a, TAIL_FRAME_A_LO
    ld [TAIL_FRAME_PTR], a
    ld a, TAIL_FRAME_A_HI
    ld [TAIL_FRAME_PTR + 1], a
    call RefreshFrame
    ld a, TAIL_FRAME_B_LO
    ld [TAIL_FRAME_PTR], a
    ld a, TAIL_FRAME_A_HI
    ld [TAIL_FRAME_PTR + 1], a
    call RefreshFrame
    ld a, TAIL_SLOT_INDEX
    ld [$CCB4], a
    ld a, TAIL_SLOT_MARK
    ld [$CCA9], a
    ld a, [wCurrentWRAMBank]
    ld [$CCB8], a
    ld bc, TAIL_SLOT_PTR
    ld hl, $CCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, TAIL_SLOT_WORD
    ld hl, $CCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, TAIL_SLOT_WORD
    ld hl, $CCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [TAIL_CHOICE_SAVED]
    ld [TAIL_SLOT_NOW], a
    ld a, $00
    ld [$CCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, TAIL_RECORD_BANK
    call CallBankedHL
    ld a, TAIL_CHOICE_WAIT
    ld [TAIL_CHOICE], a
    jp CopiedBlockWindowChoice
