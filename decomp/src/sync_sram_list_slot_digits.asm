; Bank 3 at $6F39. DispatchSramListChoice jumps here while $CCA7 is
; still $FF and the latched index in $CCC9 differs from $CD81.
;
; $CD81 is copied into $CCC9. A value of $0B or more, or a record whose
; second byte is $FF, leaves through $6EF0. Otherwise the index minus
; $03 selects a 3-byte record at $CCFE. MulCByB builds that offset.
;
; FormatStartDigits turns the record's little-endian word into the
; places at $C92F, $C92E, and $C92D. $CCEC then receives $F2 and $6ED7
; appends those three places with E=$DE. The record's third byte, with
; a zero high byte, is formatted the same way and stored after $F1.
;
; The id at $CCCD plus that index selects one SRAM byte at $A4A6. The
; SRAM bank at $C727 is written to $4000 with `add a, $00` in between,
; which keeps the bank byte and sets flags nobody reads. SRAM is
; enabled for the read and disabled before FormatStartDigits. That byte
; is stored after another $F1. The SRAM word at $A3A5 is formatted the
; same way, and $6ED7 appends those three places with no marker in front.
;
; The callback bank is 3 and the callback is $6FE8 for RefreshFrame.
; IdleCallback ($29A4) replaces that pointer, and the bank byte is left
; at 3. Control returns to DispatchSramListChoice.
;
; This routine writes the SRAM bank register, not rROMB0. The calls
; below stay in this bank or in bank 0. rRAMG is the name from reset.asm.
; wCallback and wCallbackBank are the names from default_state.asm.
; CHOICE_BYTES is the name from fill_choice_table_from_records.asm.
; wOneEntryList and sDigitWordA3A5 are the names from
; plant_one_map_list_entry.asm. CHOICE_0B is the name from
; dispatch_armed_choice.asm. $C727, $4000, and the enable value $0A are
; named wSRAMBank, rRAMB, and SRAM_ENABLE in handle_start_press.asm,
; which is included later, so this file uses those addresses. $CD81 is
; named wUnknownCD81 there. MulCByB, FormatStartDigits, RefreshFrame,
; IdleCallback, and DispatchSramListChoice are already source. $6ED7
; and $6EF0 are still INCBIN. $6FE8 is still INCBIN.

; Still INCBIN. Planted at wCallback for the RefreshFrame below.
DEF Bank3_6FE8 EQU $6FE8

; First slot that has a 3-byte record at $CCFE. $0B has none.
DEF SLOT_RECORD_BASE EQU $03

; Three bytes: a word, then one more byte.
DEF SLOT_RECORD_BYTES EQU $03
DEF wSlotRecords EQU $CCFE

DEF LIST_MARK_F2 EQU $F2
DEF LIST_MARK_F1 EQU $F1

DEF WORD_ABSENT EQU $FF

; Callback bank stored at wCallbackBank. This section's bank.
DEF LIST_CALLBACK_BANK EQU $03

SyncSramListSlotDigits::
    ld a, [$CD81]
    ld [$CCC9], a
    cp CHOICE_0B
    jp nc, BlankAbsentSramListSlot

    sub SLOT_RECORD_BASE
    ld c, a
    ld b, SLOT_RECORD_BYTES
    call MulCByB
    ld de, wSlotRecords
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    cp WORD_ABSENT
    jp z, BlankAbsentSramListSlot

    push hl
    call FormatStartDigits
    ld hl, wOneEntryList
    ld a, LIST_MARK_F2
    ld [hl+], a
    call AppendThreeDigitPlaces
    ld b, h
    ld c, l
    pop hl
    push bc
    ld a, [hl+]
    ld e, a
    ld d, $00
    call FormatStartDigits
    pop hl
    ld a, LIST_MARK_F1
    ld [hl+], a
    call AppendThreeDigitPlaces
    push hl
    ld a, [$C727]
    add a, $00
    ld [$4000], a
    ld a, $0A
    ld [rRAMG], a
    ld a, [$CD81]
    sub SLOT_RECORD_BASE
    ld hl, CHOICE_BYTES
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl]
    ld hl, $A4A6
    ld c, a
    add hl, bc
    ld a, [hl]
    ld e, a
    ld d, $00
    xor a
    ld [rRAMG], a
    call FormatStartDigits
    pop hl
    ld a, LIST_MARK_F1
    ld [hl+], a
    call AppendThreeDigitPlaces
    push hl
    ld a, [$C727]
    add a, $00
    ld [$4000], a
    ld a, $0A
    ld [rRAMG], a
    ld hl, sDigitWordA3A5
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    xor a
    ld [rRAMG], a
    call FormatStartDigits
    pop hl
    call AppendThreeDigitPlaces
    ld a, LIST_CALLBACK_BANK
    ld [wCallbackBank], a
    ld a, LOW(Bank3_6FE8)
    ld [wCallback], a
    ld a, HIGH(Bank3_6FE8)
    ld [wCallback + 1], a
    call RefreshFrame
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    jp DispatchSramListChoice
