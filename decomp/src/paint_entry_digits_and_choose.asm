; Bank 5 at $5243. LoadFiveSramEntryDigits jumps here when the seven
; bytes from wEntryFlags sum to something other than zero.
;
; Five map strips are painted with paint_choice_strip. Each points
; wUnknownC93D at wListTailDest, copies one tile pointer into
; wUnknownC6E9 and wStripTileEcho, and calls STRIP_ROUTINE ($2B8F)
; through JumpHL. The pass immediate is 3 and is incremented once, so
; $2B8F runs four times. FinishFrame follows every pass. The text
; pointers are the five three-byte digit fields at wEntryDigits.
;
; wCallback becomes $3931 and FinishFrame runs once. The STAT handler
; at $FF99 becomes $2AC1, both stores in the 3-byte form. When
; [wUnknownCD81] is not 4, wChosenSlot is set to $FF and the menu
; fill is skipped. Otherwise the choice block is filled: $CCB4 is 9,
; wUnknownCCA9 is $F3, $CCB8 is wCurrentWRAMBank, wUnknownCCB6 points
; at wEntryFlags, and wUnknownCCB0 and wUnknownCCB2 both point at
; HoldLcdOff. wUnknownCD81, wUnknownCCB9, and $CCBA are cleared.
; LoadArmedSlotRecord runs in bank 3, then wChosenSlot becomes $FF.
;
; Each pass calls RefreshChoiceCursor in bank 3 and FinishFrame until
; wChosenSlot is no longer $FF. $FE returns. A choice of 5 or more
; restarts LoadFiveSramEntryDigits at the `ld [wEntryIndex], a`: the
; value is [wUnknownD063] + 1, or 0 when that sum is $0A.
;
; A choice below 5 is stored at wEntryIndex, and at $D06F. When
; [wUnknownD063] is 9, five is added to the index first. SRAM bank
; wSRAMBank is enabled and sEntryIds[index] is read. $FF skips the
; record. Any other id times ENTRY_STRIDE selects a byte in the next
; SRAM bank at sEntryBase. SRAM is disabled, that next bank is enabled
; again, $0C is stored at $D103, HL is stored at $D107/$D108, and the
; byte at HL+8 is stored at $D102. DispatchIfD0E0AboveD102 runs. A zero
; [$D0AF] arms the choice block again. Any other value returns.
;
; `add a, $00` keeps the SRAM bank byte. The second `ld b, a` after
; `cp $FF` repeats the copy that already followed the compare. The
; saved B is not read again.
;
; paint_choice_strip and its strip names are from run_d0b1_map_strips.asm.
; wEntryFlags, wEntryDigits, wEntryIndex, wUnknownD063, wChosenSlot, and
; CHOSEN_SLOT_NONE are from load_five_sram_entry_digits.asm. sEntryIds,
; sEntryBase, and ENTRY_STRIDE are from indexed_tail_07.asm. rRAMG is
; from reset.asm. rRAMB, wSRAMBank, SRAM_ENABLE, wUnknownCD81,
; wUnknownCCA9, wUnknownCCB0, wUnknownCCB2, wUnknownCCB6, and
; wUnknownCCB9 are from handle_start_press.asm. wCallback is from
; default_state.asm. STAT_HANDLER_2AC1_LO and STAT_HANDLER_2AC1_HI are
; from drive_d0b1_choice.asm. wCurrentWRAMBank is from timer_overflow.asm.
; JumpHL, FinishFrame, CallBankedHL, MulCByB, HoldLcdOff,
; LoadArmedSlotRecord, RefreshChoiceCursor, and
; DispatchIfD0E0AboveD102 are already source. $2B8F, $3931, and $2AC1
; are still INCBIN.

; [$D063] + 1, or 0, restarts the entry scan at this instruction.
DEF ResumeEntryScan EQU $4F66

; Index after the +5 adjustment when [$D063] is 9. What reads it next
; is still unknown.
DEF wAdjustedEntry EQU $D06F

; Filled from the SRAM record, then passed to DispatchIfD0E0AboveD102.
DEF wLoadedD102 EQU $D102
DEF wLoadedD103 EQU $D103
DEF wLoadedPtrLo EQU $D107
DEF wLoadedPtrHi EQU $D108
DEF LOADED_KIND EQU $0C
DEF LOADED_PTR_SKIP EQU $08

; Zero sends this routine back to arm the choice block.
DEF wUnknownD0AF EQU $D0AF

; Choice-block bytes this path writes. $CCB4 indexes the table in
; LoadArmedSlotRecord. $CCB8 is the WRAM bank it selects. $CCBA picks
; the cursor refresh.
DEF wChoiceKind EQU $CCB4
DEF wChoiceWRAMBank EQU $CCB8
DEF wChoiceCursor EQU $CCBA
DEF CHOICE_KIND_ENTRIES EQU $09
DEF CHOICE_MARK EQU $F3
DEF CHOICE_WAITING EQU $FF
DEF ENTRY_SLOT_LIMIT EQU $05
DEF ENTRY_INDEX_WRAP EQU $0A
DEF ENTRY_ALT_ADD EQU $05

; wCallback value stored before the choice wait. Still INCBIN.
DEF ENTRY_CALLBACK_LO EQU $31
DEF ENTRY_CALLBACK_HI EQU $39

PaintEntryDigitsAndChoose::
    paint_choice_strip $80, $8B, $0F, $B8, $BB, LOW(wEntryDigits), HIGH(wEntryDigits), $03
    paint_choice_strip $B0, $8B, $2F, $BB, $BE, LOW(wEntryDigits + 3), HIGH(wEntryDigits + 3), $03
    paint_choice_strip $E0, $8B, $4F, $BE, $C1, LOW(wEntryDigits + 6), HIGH(wEntryDigits + 6), $03
    paint_choice_strip $10, $8C, $6F, $C1, $C4, LOW(wEntryDigits + 9), HIGH(wEntryDigits + 9), $03
    paint_choice_strip $40, $8C, $8F, $C4, $C7, LOW(wEntryDigits + 12), HIGH(wEntryDigits + 12), $03
    ld a, ENTRY_CALLBACK_LO
    ld [wCallback], a
    ld a, ENTRY_CALLBACK_HI
    ld [wCallback + 1], a
    call FinishFrame
    ld a, STAT_HANDLER_2AC1_LO
    ld [$ff99], a
    ld a, STAT_HANDLER_2AC1_HI
    ld [$ff9a], a
    ld a, [wUnknownCD81]
    cp $04
    jr z, .armChoice
    ld a, CHOICE_WAITING
    ld [wChosenSlot], a
    jr .waitChoice

.armChoice:
    ld a, CHOICE_KIND_ENTRIES
    ld [wChoiceKind], a
    ld a, CHOICE_MARK
    ld [wUnknownCCA9], a
    ld a, [wCurrentWRAMBank]
    ld [wChoiceWRAMBank], a
    ld bc, wEntryFlags
    ld hl, wUnknownCCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, HoldLcdOff
    ld hl, wUnknownCCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, HoldLcdOff
    ld hl, wUnknownCCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, $00
    ld [wUnknownCD81], a
    ld a, $00
    ld [wUnknownCCB9], a
    ld a, $00
    ld [wChoiceCursor], a
    ld hl, LoadArmedSlotRecord
    ld e, $03
    call CallBankedHL
    ld a, CHOICE_WAITING
    ld [wChosenSlot], a

.waitChoice:
    ld hl, RefreshChoiceCursor
    ld e, $03
    call CallBankedHL
    call FinishFrame
    ld a, [wChosenSlot]
    cp CHOICE_WAITING
    jr z, .waitChoice
    cp CHOSEN_SLOT_NONE
    ret z
    cp ENTRY_SLOT_LIMIT
    jr c, .loadChosen
    ld a, [wUnknownD063]
    inc a
    cp ENTRY_INDEX_WRAP
    jp nz, ResumeEntryScan
    xor a
    jp ResumeEntryScan

.loadChosen:
    ld a, [wChosenSlot]
    ld [wEntryIndex], a
    ld b, a
    ld a, [wUnknownD063]
    cp $09
    jr nz, .keepIndex
    ld a, b
    add ENTRY_ALT_ADD
    ld [wEntryIndex], a
.keepIndex:
    ld a, [wEntryIndex]
    ld [wAdjustedEntry], a
    ld a, [wSRAMBank]
    add $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wEntryIndex]
    ld c, a
    ld b, $00
    ld hl, sEntryIds
    add hl, bc
    ld a, [hl]
    cp $ff
    ld b, a
    jr z, .enableNextBank
    ld b, a
    ld c, ENTRY_STRIDE
    call MulCByB
    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld bc, sEntryBase
    add hl, bc
    ld b, [hl]
.enableNextBank:
    xor a
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, LOADED_KIND
    ld [wLoadedD103], a
    ld a, h
    ld [wLoadedPtrHi], a
    ld a, l
    ld [wLoadedPtrLo], a
    ld bc, LOADED_PTR_SKIP
    add hl, bc
    ld a, [hl]
    ld [wLoadedD102], a
    call DispatchIfD0E0AboveD102
    ld a, [wUnknownD0AF]
    and a
    jp z, .armChoice
    ret
