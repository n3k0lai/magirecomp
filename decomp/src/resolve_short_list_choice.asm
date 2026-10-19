; Bank 3 at $5EE1. ResolveArmedListChoice jumps here when the record byte
; is not $0A and the choice in A is not $FF or $FE. This bank stays mapped.
; The routine does not write rROMB0.
;
; $09 leaves through $6213. Any other choice calls $565B, enables the SRAM
; bank in [$C727], and reads the count at $A122.
;
; Below $0A, three strip blocks are planted and RefreshFrame runs until
; A or B is pressed ($C932 bits 0 and 1). One more RefreshFrame runs, then
; $CD69 becomes 3.
;
; At $0A or above, three other strip blocks are planted and slot id $0C
; is armed the same way as the list slots: index 7, mark $F3, $CCB6 at
; $CC4D, and $CCB0/$CCB2 holding $42E3. $CCB9 and $CCBA are the immediate
; zero, so LoadArmedSlotRecord returns before ReloadSlotPosition. $CCA7
; is $FF. Each wait pass calls bank 3 at $415D, then RefreshFrame.
;
; A choice other than $0B stores 3 at $CD69 and returns. $0B clears $CD7A
; and $CD7B, maps SRAM bank [$C727] plus one, and calls $56BD. It then
; fills $25 bytes at $BE10 with $FF, maps the original SRAM bank, and
; decrements $A122. Each of the ten bytes at $A118 that is not $FF and is
; at least the key in $CD68 is decremented. A nonzero $CD7A or $CD7B,
; which only $56BD can store, indexes $A019 and increments that byte.
; SRAM is disabled and $CD69 becomes 2.
;
; wCurrentWRAMBank is the name from timer_overflow.asm. wButtonsPressed is
; the name from main_loop.asm. rRAMG is the name from reset.asm. rRAMB,
; wSRAMBank, and SRAM_ENABLE are defined in handle_start_press.asm, which
; is included later, so those addresses are written out here. The window
; names, arm_window_slot, and plant_window_strip are the names from
; service_window_choice.asm. LIST_KEY, LIST_SRAM, and LIST_LEN are the
; names from resolve_armed_list_choice.asm. RefreshFrameBlankSavedChoiceRows,
; LoadArmedSlotRecord, CallBankedHL, and RefreshFrame are already source.
; $6213, $56BD, $415D, and $4260 are still INCBIN.

DEF LIST_CHOICE_NINE EQU $09
DEF LIST_CHOICE_ADJUST EQU $0B
DEF LIST_RESULT_TWO EQU $02
DEF LIST_SRAM_COUNT EQU $A122
DEF LIST_FILL EQU $BE10
DEF LIST_FILL_LEN EQU $25
DEF LIST_COUNT_CELL EQU $A019
DEF LIST_SIDE_A EQU $CD7A
DEF LIST_SIDE_B EQU $CD7B
DEF LIST_SLOT_FULL EQU $0C
DEF ShortListChoiceNine EQU $6213

; Buttons A and B in wButtonsPressed.
DEF LIST_PRESS_AB EQU $03

; Next SRAM bank while $BE10 is filled. `add $00` keeps the saved bank.
DEF LIST_SRAM_BANK_NEXT EQU $01

ResolveShortListChoice::
    cp LIST_CHOICE_NINE
    jp z, ShortListChoiceNine
    call RefreshFrameBlankSavedChoiceRows
    ld a, [LIST_SRAM_BANK]
    add $00
    ld [LIST_SRAM_BANK_REG], a
    ld a, LIST_SRAM_ENABLE
    ld [rRAMG], a
    ld a, [LIST_SRAM_COUNT]
    ld b, a
    xor a
    ld [rRAMG], a
    ld a, b
    cp LIST_LEN
    jp nc, .countAtLeastTen
    plant_window_strip $8EE0, $9DA1, $EE, $FE, $48E5, $10
    plant_window_strip $8FE0, $9DC1, $FE, $0F, $48F5, $11
    plant_window_strip $90F0, $9DE1, $0F, $19, $4906, $0A
.waitPress:
    call RefreshFrame
    ld a, [wButtonsPressed]
    and LIST_PRESS_AB
    jr z, .waitPress
    call RefreshFrame
    jp .storeThree
.countAtLeastTen:
    plant_window_strip $8EE0, $9DA1, $EE, $FF, $4873, $11
    plant_window_strip $8FF0, $9DC1, $FF, $10, $4884, $11
    plant_window_strip $9100, $9E02, $10, $1F, $4895, $0F
    arm_list_slot LIST_SLOT_FULL
.waitChoice:
    ld hl, Bank3_415D
    ld e, WIN_BANK
    call CallBankedHL
    call RefreshFrame
    ld a, [WIN_CHOICE]
    cp WIN_CHOICE_WAIT
    jr z, .waitChoice
    ld a, [WIN_CHOICE]
    cp LIST_CHOICE_ADJUST
    jr z, .adjustList
.storeThree:
    ld a, WIN_RESULT_THREE
    ld [WIN_RESULT], a
    ret
.adjustList:
    call RefreshFrame
    xor a
    ld hl, LIST_SIDE_A
    ld [hl+], a
    ld [hl+], a
    ld a, [LIST_SRAM_BANK]
    add LIST_SRAM_BANK_NEXT
    ld [LIST_SRAM_BANK_REG], a
    ld a, LIST_SRAM_ENABLE
    ld [rRAMG], a
    call SlideOutKeyedSRAMRecord
    ld a, $FF
    ld d, LIST_FILL_LEN
    ld hl, LIST_FILL
.fillGap:
    ld [hl+], a
    dec d
    jr nz, .fillGap
    ld a, [LIST_SRAM_BANK]
    add $00
    ld [LIST_SRAM_BANK_REG], a
    ld hl, LIST_SRAM_COUNT
    dec [hl]
    ld a, [LIST_KEY]
    ld b, a
    ld d, LIST_LEN
    ld hl, LIST_SRAM
.renumber:
    ld a, [hl]
    cp $FF
    jr z, .nextKey
    cp b
    jr c, .nextKey
    dec a
    ld [hl], a
.nextKey:
    inc hl
    dec d
    jr nz, .renumber
    ld b, $00
    ld a, [LIST_SIDE_A]
    and a
    jr z, .sideB
    ld c, a
    ld hl, LIST_COUNT_CELL
    add hl, bc
    inc [hl]
.sideB:
    ld a, [LIST_SIDE_B]
    and a
    jr z, .done
    ld c, a
    ld hl, LIST_COUNT_CELL
    add hl, bc
    inc [hl]
.done:
    xor a
    ld [rRAMG], a
    ld a, LIST_RESULT_TWO
    ld [WIN_RESULT], a
    ret
