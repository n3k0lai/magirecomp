; Bank 3 at $6EF0. SyncSramListSlotDigits jumps here when the latched
; index is $0B or more, or when the record word's high byte is $FF.
;
; Twelve bytes at $CCEC are filled with $80. The SRAM word at $A3A5 is
; then formatted and appended there with no marker in front. The SRAM
; bank at $C727 is written to $4000 with `add a, $00` in between, which
; keeps the bank byte and sets flags nobody reads. SRAM is enabled for
; the read and disabled before FormatStartDigits. AppendThreeDigitPlaces
; stores the three places with E=$DE.
;
; The callback bank is 3 and the callback is $6FE8 for RefreshFrame.
; IdleCallback ($29A4) replaces that pointer, and the bank byte is left
; at 3. Control returns to DispatchSramListChoice.
;
; This routine writes the SRAM bank register, not rROMB0. The calls
; below stay in this bank or in bank 0. rRAMG is the name from reset.asm.
; wCallback and wCallbackBank are the names from default_state.asm.
; wOneEntryList and sDigitWordA3A5 are the names from
; plant_one_map_list_entry.asm. $C727, $4000, and the enable value $0A
; are named wSRAMBank, rRAMB, and SRAM_ENABLE in handle_start_press.asm,
; which is included later, so this file uses those addresses. $6FE8 is
; still INCBIN. FormatStartDigits, AppendThreeDigitPlaces, RefreshFrame,
; IdleCallback, and DispatchSramListChoice are already source.

; Still INCBIN. Planted at wCallback for the RefreshFrame below.
DEF AbsentSlotCallback EQU $6FE8

; Tile written across the one-entry list when the slot has no record.
DEF ABSENT_SLOT_TILE EQU $80

; Bytes cleared at wOneEntryList before the three digit glyphs.
DEF ABSENT_SLOT_BYTES EQU $0C

; Callback bank stored at wCallbackBank. This section's bank.
DEF ABSENT_SLOT_CALLBACK_BANK EQU $03

BlankAbsentSramListSlot::
    ld hl, wOneEntryList
    ld a, ABSENT_SLOT_TILE
    ld b, ABSENT_SLOT_BYTES
.blank:
    ld [hl+], a
    dec b
    jr nz, .blank

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
    ld a, ABSENT_SLOT_CALLBACK_BANK
    ld [wCallbackBank], a
    ld a, LOW(AbsentSlotCallback)
    ld [wCallback], a
    ld a, HIGH(AbsentSlotCallback)
    ld [wCallback + 1], a
    call RefreshFrame
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    jp DispatchSramListChoice
