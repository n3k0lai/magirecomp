; Bank 3 at $5BC3. ServiceWindowChoice calls here for a choice other than
; 0, 8, or $FE, then reads $CD69. This bank stays mapped. The routine
; does not write rROMB0.
;
; $CD69 starts at 0. Bank 3 at $565B runs, then the slot id at $CD81 is
; added to the byte at $CD57 and stored at $CD68. The byte at $CC4D plus
; that slot id selects the path. $0A plants three strip blocks and arms
; the slot with id $0B. Any other byte plants two strip blocks and arms
; id $09. Both paths write $CCB9 and $CCBA with the immediate zero, call
; LoadArmedSlotRecord, set $CCA7 to $FF, and wait.
;
; Each wait pass calls PrepWindowChoiceFrame, then RefreshFrame, and
; reads $CCA7. $FF repeats the wait.
;
; On the $0A path, $0C enables SRAM, fills the ten bytes at $A118 with
; $FF, disables SRAM, pops the return address, and jumps to $5BBA.
; $FE stores 3 at $CD69 and returns. Any other value stores 1 at $CD69,
; copies $CD68 to $CD75, and removes that key from the ten-byte list at
; $A118. The matched byte becomes $FF, the bytes after it move down one,
; and $A121 is set to $FF. SRAM is disabled and the routine returns.
;
; On the other path, $FE stores 3 at $CD69 and returns. Any other value
; jumps to $5EE1, which is still INCBIN.
;
; rRAMB, wSRAMBank, and SRAM_ENABLE are the names from handle_start_press.asm.
; That file is included later, so those addresses are written out here.
; rRAMG is the name from reset.asm. The window strip names, arm_window_slot,
; and plant_window_strip are the names from service_window_choice.asm.
; PrepWindowChoiceFrame, LoadArmedSlotRecord, RunWindowStripPasses,
; CallBankedHL, and RefreshFrame are already source.

DEF LIST_RECORD EQU $CC4D
DEF LIST_RECORD_TEN EQU $0A
DEF LIST_KEY EQU $CD68
DEF LIST_KEY_BASE EQU $CD57
DEF LIST_SAVED_KEY EQU $CD75
DEF LIST_SRAM EQU $A118
DEF LIST_SRAM_TAIL EQU $A121
DEF LIST_LEN EQU $0A
DEF LIST_CHOICE_CLEAR EQU $0C
DEF LIST_SLOT_TEN EQU $0B
DEF LIST_SLOT_OTHER EQU $09

; rRAMB, wSRAMBank, and SRAM_ENABLE. Included later in this assemble.
DEF LIST_SRAM_BANK_REG EQU $4000
DEF LIST_SRAM_BANK EQU $C727
DEF LIST_SRAM_ENABLE EQU $0A

; \1 slot id stored at $CD81 after the strip blocks.
MACRO arm_list_slot
    arm_window_slot
    ld a, \1
    ld [WIN_SLOT_INDEX_ADDR], a
    ld a, $00
    ld [$ccb9], a
    ld a, $00
    ld [$ccba], a
    ld hl, LoadArmedSlotRecord
    ld e, WIN_BANK
    call CallBankedHL
    ld a, WIN_CHOICE_WAIT
    ld [WIN_CHOICE], a
ENDM

; Map the SRAM bank in [$C727] and enable SRAM. `add $00` keeps that bank.
MACRO open_list_sram
    ld a, [LIST_SRAM_BANK]
    add $00
    ld [LIST_SRAM_BANK_REG], a
    ld a, LIST_SRAM_ENABLE
    ld [rRAMG], a
ENDM

ResolveArmedListChoice::
    xor a
    ld [WIN_RESULT], a
    call Bank3_565B
    ld a, [WIN_SLOT_INDEX_ADDR]
    ld hl, LIST_KEY_BASE
    add [hl]
    ld [LIST_KEY], a
    ld a, [WIN_SLOT_INDEX_ADDR]
    ld c, a
    ld b, $00
    ld hl, LIST_RECORD
    add hl, bc
    ld a, LIST_RECORD_TEN
    cp [hl]
    jp nz, .recordNotTen
    plant_window_strip $8EE0, $9DA1, $EE, $FE, $4910, $10
    plant_window_strip $8FE0, $9DC1, $FE, $0D, $4920, $0F
    plant_window_strip $90D0, $9E02, $0D, $19, $492F, $0C
    arm_list_slot LIST_SLOT_TEN
.waitTen:
    ld hl, PrepWindowChoiceFrame
    ld e, WIN_BANK
    call CallBankedHL
    call RefreshFrame
    ld a, [WIN_CHOICE]
    cp WIN_CHOICE_WAIT
    jr z, .waitTen
    ld a, [WIN_CHOICE]
    cp LIST_CHOICE_CLEAR
    jr z, .clearList
    cp WIN_CHOICE_CANCEL
    jr nz, .removeKey
    ld a, WIN_RESULT_THREE
    ld [WIN_RESULT], a
    ret
.clearList:
    ld hl, LIST_SRAM
    ld d, LIST_LEN
    open_list_sram
    ld a, $ff
.fillList:
    ld [hl+], a
    dec d
    jr nz, .fillList
    xor a
    ld [rRAMG], a
    pop hl
    jp $5bba
.removeKey:
    ld a, WIN_RESULT_ONE
    ld [WIN_RESULT], a
    ld a, [LIST_KEY]
    ld [LIST_SAVED_KEY], a
    open_list_sram
    ld hl, LIST_SRAM
    ld a, [LIST_KEY]
    ld b, a
    ld d, LIST_LEN
.findKey:
    dec d
    ld a, [hl+]
    cp b
    jr nz, .findKey
    ld b, h
    ld c, l
    dec bc
    ld a, $ff
    ld [bc], a
    inc d
.shiftTail:
    dec d
    jr z, .markTail
    ld a, [hl+]
    ld [bc], a
    inc bc
    jr .shiftTail
.markTail:
    ld a, $ff
    ld [LIST_SRAM_TAIL], a
    xor a
    ld [rRAMG], a
    ret
.recordNotTen:
    plant_window_strip $8EE0, $9DA1, $EE, $FC, $4854, $0E
    plant_window_strip $8FC0, $9DC2, $FC, $0D, $4862, $11
    arm_list_slot LIST_SLOT_OTHER
.waitOther:
    ld hl, PrepWindowChoiceFrame
    ld e, WIN_BANK
    call CallBankedHL
    call RefreshFrame
    ld a, [WIN_CHOICE]
    cp WIN_CHOICE_WAIT
    jr z, .waitOther
    cp WIN_CHOICE_CANCEL
    jr nz, $5ee1
    ld a, WIN_RESULT_THREE
    ld [WIN_RESULT], a
    ret
