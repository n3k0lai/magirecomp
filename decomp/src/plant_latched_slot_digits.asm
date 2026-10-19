; Bank 3 at $6C5C. DispatchPrefixedBlockChoice jumps here when the
; latched slot in C is $03 through $0A. This bank stays mapped.
;
; Three `dec c` turn that slot into an index of $00 through $07. That
; index selects an SRAM record id from the eight bytes at $CCCD.
;
; The SRAM bank at $C727 is stored to $4000 with `add a, $00` in
; between, which keeps that bank byte and sets flags nobody reads.
; SRAM is enabled, the byte at $A3A7 plus that id is loaded into E
; with D clear, and SRAM is disabled. FormatStartDigits turns that
; byte into the three places at $C92F, $C92E, and $C92D.
;
; $CCEC then receives one list entry: count $01, the map cell $9E0E
; stored high byte then low byte, and $03. HL is left on the next
; byte. $6B0C reads those three digits and calls $77E7 with E=$EE.
; $6AE6 runs next. What it writes is still unknown. Control returns
; to the prefixed-block choice loop.
;
; This routine writes the SRAM bank register, not rROMB0. The calls
; below stay in this bank or in bank 0. rRAMG is the name from
; reset.asm. CHOICE_BYTES is the name from
; fill_choice_table_from_records.asm. wOneEntryList and LIST_COUNT_ONE
; are the names from plant_one_map_list_entry.asm. Bank3_6B0C is the
; name from that file. FormatStartDigits and
; DispatchPrefixedBlockChoice are already source. $C727, $4000, and
; the enable value $0A are named wSRAMBank, rRAMB, and SRAM_ENABLE in
; handle_start_press.asm, which is included later, so this file uses
; those addresses. $6AE6 is still INCBIN.

; SRAM byte indexed by the record id at $CCCD.
DEF sRecordByteA3A7 EQU $A3A7

; BG map cell stored in the list, high byte first.
DEF vMapCell9E0E EQU $9E0E

; Byte stored after the map pointer, before $6B0C.
DEF LIST_BYTE_03 EQU $03

; Still INCBIN in this bank. Runs after the digit list is planted.
DEF Bank3_6AE6 EQU $6AE6

PlantLatchedSlotDigits::
    dec c
    dec c
    dec c
    ld hl, CHOICE_BYTES
    ld b, $00
    add hl, bc
    ld a, [$C727]
    add a, $00
    ld [$4000], a
    ld a, $0A
    ld [rRAMG], a
    ld a, [hl]
    ld c, a
    ld b, $00
    ld hl, sRecordByteA3A7
    add hl, bc
    ld a, [hl]
    ld e, a
    xor a
    ld [rRAMG], a
    ld d, $00
    call FormatStartDigits
    ld hl, wOneEntryList
    ld [hl], LIST_COUNT_ONE
    inc hl
    ld bc, vMapCell9E0E
    ld [hl], b
    inc hl
    ld [hl], c
    inc hl
    ld [hl], LIST_BYTE_03
    inc hl
    call Bank3_6B0C
    call Bank3_6AE6
    jp DispatchPrefixedBlockChoice
