; Bank 3 at $729A. DispatchSramListChoice jumps here for a $CCA7 value
; other than $FF, $FE, $0B, or $0C, after storing $FF at $CCC9.
; This routine does not write rROMB0. The calls below stay in this bank.
;
; $CCA7 minus 3 indexes the three-byte records at $CCFE. MultiplyCByB
; with B = 3 yields that offset. The first two bytes are a little-endian
; cost. The third byte is a quantity.
;
; SRAM bank wSRAMBank is selected with `add a, $00`, then SRAM is
; enabled. The cost is compared with the word at $A3A5. Carry on the
; high byte, or equal highs with a low byte that is not smaller, means
; the saved word covers the cost. The same index then reads an id from
; $CCCD. That id selects a stock byte at $A4A6. SRAM is enabled again
; before that read. When the stock byte is at least the quantity, the
; quantity is subtracted from it and the cost is subtracted from $A3A5,
; borrowing from the high byte when the low byte wraps.
;
; $731C and $7213 then run, and control returns to DispatchSramListChoice.
; SRAM stays enabled across those calls. If the word or the stock byte
; is short, both pushed values are discarded, SRAM is disabled, 2 is
; stored at wSoundSlotA, and control returns to the same loop.
;
; MultiplyCByB is the name from draw_cgb_notice.asm. CHOICE_BYTES is
; the name from fill_choice_table_from_records.asm. CHOICE_INDEX_BASE
; is the name from commit_copied_block_choice.asm. rRAMB, wSRAMBank,
; and SRAM_ENABLE are the names from handle_start_press.asm. rRAMG is
; the name from reset.asm. wSoundSlotA is the name from
; select_sound_command.asm. $731C is still INCBIN. Bank3_7213 is the
; name from stage_sram_list_names.asm and is still INCBIN.
; DispatchSramListChoice is already source.

; Three-byte records: cost word, then quantity. Index is $CCA7 minus 3.
DEF SRAM_LIST_RECORDS EQU $CCFE
DEF SRAM_LIST_RECORD_STRIDE EQU $03

; Saved currency word and per-id stock bytes.
DEF SRAM_LIST_COST_WORD EQU $A3A5
DEF SRAM_LIST_STOCK EQU $A4A6

; Stored at wSoundSlotA when the word or the stock byte is short.
DEF SRAM_LIST_DENY_SOUND EQU $02

SpendSramListChoice::
    ld a, [$CCA7]
    sub CHOICE_INDEX_BASE
    ld c, a
    ld b, SRAM_LIST_RECORD_STRIDE
    call MultiplyCByB
    ld de, SRAM_LIST_RECORDS
    add hl, de
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc hl
    push bc
    push hl
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld hl, SRAM_LIST_COST_WORD
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, b
    cp h
    jr c, .costFits

    jr nz, .unaffordable

    ld a, l
    cp c
    jp c, .unaffordable

.costFits:
    ld a, [$CCA7]
    sub CHOICE_INDEX_BASE
    ld hl, CHOICE_BYTES
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl]
    ld c, a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld hl, SRAM_LIST_STOCK
    add hl, bc
    pop de
    push de
    ld a, [de]
    ld c, a
    ld a, [hl]
    cp c
    jr c, .unaffordable

    sub c
    ld [hl], a
    ld hl, SRAM_LIST_COST_WORD
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    ld a, e
    pop hl
    pop bc
    sub c
    ld e, a
    jr nc, .noBorrow

    dec d

.noBorrow:
    ld a, d
    sub b
    ld d, a
    ld hl, SRAM_LIST_COST_WORD
    ld a, e
    ld [hl+], a
    ld [hl], d
    call CommitBoughtSramRecord
    call Bank3_7213
    jp DispatchSramListChoice

.unaffordable:
    pop hl
    pop hl
    xor a
    ld [rRAMG], a
    ld a, SRAM_LIST_DENY_SOUND
    ld [wSoundSlotA], a
    jp DispatchSramListChoice
