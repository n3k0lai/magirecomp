; Bank 3 at $731C. SpendSramListChoice calls here after the word at
; $A3A5 and the stock byte at $A4A6 have both been reduced. This
; routine writes the SRAM bank register, not rROMB0. The far call
; passes bank 2 in E.
;
; SRAM bank wSRAMBank + 1 is enabled. The record index is $CCD5 plus
; $CCA7 minus 3, the same choice offset later stored at $CCC6. That
; index times $25, plus $A025, is the SRAM record. Its address is
; stored at $CD52 (low, high at $CD53) and $02 is stored at $CD50.
; SpendNewEntryMeasures then runs once: it treats [$CD50] minus 1 as
; the pass count. The caller's WRAM bank is saved in wCurrentWRAMBank
; and written back with the 3-byte `ld [rSVBK], a`. SRAM is disabled
; after that call returns.
;
; $CCA7 minus 3 is stored at $CCC6. The byte at $CD17 plus that offset
; is incremented, and the new value is stored at $CCEC. wCallback is
; set to $73E3 in bank 3 and RefreshFrame runs, which is what paints
; that byte. wCallback is then set back to $29A4. The callback bank
; byte is left at 3.
;
; RECORD_INDEX, RECORD_STEP, and the $CD17 table are the names from
; stage_copied_block_arm_slot.asm and paint_sram_list_record_bytes.asm.
; SRAM_RECORD_STRIDE and SRAM_RECORD_BASE are the names from
; fill_sram_list_ids.asm. CHOICE_INDEX_BASE is the name from
; commit_copied_block_choice.asm. wSRAMBank, rRAMB, and SRAM_ENABLE
; are the names from handle_start_press.asm. rRAMG is the name from
; reset.asm. wCurrentWRAMBank and rSVBK are the names from
; timer_overflow.asm. wOneEntryList is the name from
; plant_one_map_list_entry.asm. wCallback, wCallbackBank, and
; IdleCallback are the names from default_state.asm. MulCByB,
; CallBankedHL, SpendNewEntryMeasures, and RefreshFrame are already
; source. $73E3 is still INCBIN.

; Pass count handed to SpendNewEntryMeasures. It loops [$CD50] minus 1.
DEF BOUGHT_RECORD_PASSES EQU $02

; Bank mapped for SpendNewEntryMeasures.
DEF BOUGHT_RECORD_BANK EQU $02

CommitBoughtSramRecord::
    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [RECORD_INDEX]
    ld c, a
    ld a, [$CCA7]
    sub CHOICE_INDEX_BASE
    add c
    ld c, a
    ld b, SRAM_RECORD_STRIDE
    call MulCByB
    ld de, SRAM_RECORD_BASE
    add hl, de
    ld a, h
    ld [$CD53], a
    ld a, l
    ld [$CD52], a
    ld a, BOUGHT_RECORD_PASSES
    ld [$CD50], a
    ld a, [wCurrentWRAMBank]
    push af
    ld hl, SpendNewEntryMeasures
    ld e, BOUGHT_RECORD_BANK
    call CallBankedHL
    pop af
    ld [wCurrentWRAMBank], a
    ld [$FF70], a
    xor a
    ld [rRAMG], a
    ld a, [$CCA7]
    sub CHOICE_INDEX_BASE
    ld [RECORD_STEP], a
    ld hl, wRecordByte2Table
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl]
    inc a
    ld [hl], a
    ld [wOneEntryList], a
    ld a, $03
    ld [wCallbackBank], a
    ld a, LOW(Bank3_73E3)
    ld [wCallback], a
    ld a, HIGH(Bank3_73E3)
    ld [wCallback + 1], a
    call RefreshFrame
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
