; Bank 3 at $6930. DispatchPrefixedBlockChoice jumps here when the
; mode at CHOICE_MODE is not zero and the choice at $CCA7 is not $FF,
; $FE, $0B, $0C, $00, $01, or $02. This routine writes the SRAM bank
; register, not rROMB0.
;
; $CCA7 minus CHOICE_INDEX_BASE indexes CHOICE_BYTES. That byte is a
; record id. It is pushed, SRAM is disabled, and CopyChoiceRecordWord
; returns the record's little-endian word in BC. A zero word jumps to
; RejectPrefixedRecordCost, which discards the pushed id.
;
; Otherwise the SRAM bank at $C727 is stored to $4000 with `add a, $00`
; in between, which keeps that bank byte and sets flags nobody reads.
; SRAM is enabled and the word at $A3A5 is loaded. BC is added. A sum
; past $03E7 (999) is clamped to that cap, then stored back. SRAM is
; disabled. PlantOneMapListEntry rebuilds the digit list and
; RefreshFrame runs once with WalkPlantedMapList, then IdleCallback
; replaces that pointer. The callback bank stays 3.
;
; The id is popped. SRAM is enabled again and the byte at $A3A7 plus
; that id is decremented. A nonzero result jumps to $6A41, still
; INCBIN, which disables SRAM, stores $FF at $CCC9, and returns to the
; choice loop.
;
; A zero count builds a two-entry list at $CCEC. The second entry's
; pointer is $9C6F plus ($CCA7 - 3) * $20, and the next list byte is
; tile $80. LIST_MARK becomes 1, so the walker treats that second
; entry as the selected row. The byte at $CCD6 plus $CCA7 is cleared.
; SyncRowEndMarksThenScan runs, the planted list is copied again, and
; the slot is armed the same way as the $00 choice: $CCB4 is $06,
; $CCA9 is $F3, $CCB8 copies wCurrentWRAMBank, $CCB6 points at $CCD6,
; $CCB0 holds $6B77, and $CCB2 holds $42E3. $CD81 is written back to
; itself. $CCB9 is 1 and $CCBA is 0, so LoadArmedSlotRecord returns
; before ReloadSlotPosition. CallBankedHL runs that routine in this
; bank. $CCA7 becomes $FF, C takes $CD81, and control jumps to
; PlantLatchedSlotDigits.
;
; CHOICE_BYTES is the name from fill_choice_table_from_records.asm.
; CHOICE_INDEX_BASE is the name from commit_copied_block_choice.asm.
; wCallback, wCallbackBank, and IdleCallback are the names from
; default_state.asm. LIST_MARK, LIST_A3A7, SLOT_TABLE_06, SLOT_BANK_PTR,
; SLOT_FLAG_CCB9, and SLOT_FLAG_CCBA are the names from
; setup_prefixed_block_choice.asm. SLOT_MARK_F3, SLOT_PTR_CCD6,
; SLOT_WORD_6B77, SLOT_WORD_42E3, SLOT_FLAG_ONE, CHOICE_WAIT, and
; BANK3_ARMED are the names from stage_tiles_arm_slot.asm.
; wCurrentWRAMBank is the name from timer_overflow.asm. rRAMG is the
; name from reset.asm. $C727, $4000, and the enable value $0A are
; wSRAMBankC727, rRAMB4000, and SRAM_ENABLE_0A from opcode_9e.asm.
; CopyChoiceRecordWord, RejectPrefixedRecordCost, PlantOneMapListEntry,
; WalkPlantedMapList, RefreshFrame, SyncRowEndMarksThenScan,
; RefreshFramePlantedMapList, LoadArmedSlotRecord, CallBankedHL, and
; PlantLatchedSlotDigits are already source.

; Sum of the SRAM word and the record word, capped at 999.
DEF SRAM_WORD_CAP EQU $03E7

; BG map cell for choice index 0. Each later choice is one row lower.
DEF vChoiceRow9C6F EQU $9C6F

; Bytes in one walker entry: a pointer, then four payload bytes.
DEF ENTRY_BYTES EQU $06

; Tile byte stored after the selected entry's pointer.
DEF ROW_TILE_80 EQU $80

; Two entries: the count byte, one untouched entry, then this pointer.
DEF LIST_COUNT_TWO EQU $02

; SRAM total the record word is added to.
DEF sTotalWordA3A5 EQU $A3A5

AddPrefixedChoiceWord::
    ld a, [$CCA7]
    sub CHOICE_INDEX_BASE
    ld e, a
    ld d, $00
    ld hl, CHOICE_BYTES
    add hl, de
    ld a, [hl]
    ld d, $00
    ld e, a
    push de
    xor a
    ld [rRAMG], a
    ld a, e
    call CopyChoiceRecordWord
    xor a
    cp c
    jp nz, .addWord

    cp b
    jp z, RejectPrefixedRecordCost

.addWord:
    ld a, [wSRAMBankC727]
    add a, $00
    ld [rRAMB4000], a
    ld a, SRAM_ENABLE_0A
    ld [rRAMG], a
    ld hl, sTotalWordA3A5
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, h
    cp HIGH(SRAM_WORD_CAP)
    jr c, .keepSum

    jr z, .checkLow

    jr nc, .clampSum

.checkLow:
    ld a, l
    cp LOW(SRAM_WORD_CAP)
    jr c, .keepSum

.clampSum:
    ld h, HIGH(SRAM_WORD_CAP)
    ld l, LOW(SRAM_WORD_CAP)

.keepSum:
    ld c, l
    ld b, h
    ld hl, sTotalWordA3A5
    ld a, c
    ld [hl+], a
    ld [hl], b
    xor a
    ld [rRAMG], a
    call PlantOneMapListEntry
    ld a, $03
    ld [wCallbackBank], a
    ld a, LOW(WalkPlantedMapList)
    ld [wCallback], a
    ld a, HIGH(WalkPlantedMapList)
    ld [wCallback + 1], a
    call RefreshFrame
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    pop de
    ld a, [wSRAMBankC727]
    add a, $00
    ld [rRAMB4000], a
    ld a, SRAM_ENABLE_0A
    ld [rRAMG], a
    ld hl, LIST_A3A7
    add hl, de
    dec [hl]
    jp nz, ClearLatchedSlotResumeChoice

    ld a, [$CCA7]
    sub CHOICE_INDEX_BASE
    ld c, a
    ld b, $20
    call MulCByB
    ld e, l
    ld d, h
    ld hl, vChoiceRow9C6F
    add hl, de
    ld b, h
    ld c, l
    ld hl, $CCEC
    ld [hl], LIST_COUNT_TWO
    ld d, $00
    ld e, ENTRY_BYTES + 1
    add hl, de
    ld [hl], b
    inc hl
    ld [hl], c
    inc hl
    ld [hl], ROW_TILE_80
    ld a, $01
    ld [LIST_MARK], a
    ld a, [$CCA7]
    ld hl, SLOT_PTR_CCD6
    ld c, a
    ld b, $00
    add hl, bc
    ld [hl], b
    call SyncRowEndMarksThenScan
    call RefreshFramePlantedMapList
    ld a, SLOT_TABLE_06
    ld [$CCB4], a
    ld a, SLOT_MARK_F3
    ld [$CCA9], a
    ld a, [wCurrentWRAMBank]
    ld [SLOT_BANK_PTR], a
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
    ld [SLOT_FLAG_CCB9], a
    ld a, $00
    ld [SLOT_FLAG_CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, BANK3_ARMED
    call CallBankedHL
    ld a, CHOICE_WAIT
    ld [$CCA7], a
    ld a, [$CD81]
    ld c, a
    jp PlantLatchedSlotDigits
