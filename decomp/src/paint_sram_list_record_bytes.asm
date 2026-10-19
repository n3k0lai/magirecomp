; Bank 3 at $7393. StageSramListNames calls this after $77F3 copies
; the tiles at $5320. This routine writes the SRAM bank register, not
; rROMB0. The call below stays in this bank.
;
; rVBK is cleared with the 3-byte form, so the painter's map stores hit
; VRAM bank 0. $CCC6 starts at 0. Each pass selects SRAM bank
; wSRAMBank + 1 and enables it. The index is $CCD5 plus $CCC6. That
; index times $25, plus $02, is a byte in the record at $A025. The byte
; is stored in the eight-byte table at $CD17 and at $CCEC. SRAM is
; disabled, then $73E3 paints the byte just stored. $CCC6 advances.
; The pass returns when the next index would be 8. Otherwise `jp`
; returns to the pass head.
;
; RECORD_INDEX and RECORD_STEP are the names from
; stage_copied_block_arm_slot.asm. CHOICE_SLOT_COUNT is the name from
; fill_choice_table_from_records.asm. SRAM_RECORD_STRIDE and
; SRAM_RECORD_BASE are the names from fill_sram_list_ids.asm.
; wSRAMBank, rRAMB, and SRAM_ENABLE are the names from
; handle_start_press.asm. rRAMG is the name from reset.asm. rVBK is
; the name from setup_window.asm. $CCEC is wOneEntryList in
; plant_one_map_list_entry.asm; this path stores one record byte there.
; MulCByB is already source. $73E3 is still INCBIN. What byte 2 of the
; record means is still unknown.

; Eight record bytes, one per pass. Indexed by RECORD_STEP.
DEF wRecordByte2Table EQU $CD17

; Byte 2 of the $25-byte SRAM record.
DEF RECORD_BYTE2 EQU $02

; Still INCBIN. Paints the byte left at $CCEC.
DEF Bank3_73E3 EQU $73E3

PaintSramListRecordBytes::
    xor a
    ld [rVBK], a
    ld [RECORD_STEP], a

.nextRecord:
    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [RECORD_INDEX]
    ld c, a
    ld a, [RECORD_STEP]
    add c
    ld c, a
    ld b, SRAM_RECORD_STRIDE
    call MulCByB
    ld bc, SRAM_RECORD_BASE
    add hl, bc
    ld c, RECORD_BYTE2
    ld b, $00
    add hl, bc
    ld a, [hl]
    ld e, a
    ld hl, wRecordByte2Table
    ld a, [RECORD_STEP]
    ld c, a
    ld b, $00
    add hl, bc
    ld [hl], e
    ld a, e
    ld [wOneEntryList], a
    xor a
    ld [rRAMG], a
    call Bank3_73E3
    ld a, [RECORD_STEP]
    inc a
    cp CHOICE_SLOT_COUNT
    ret z

    ld [RECORD_STEP], a
    jp .nextRecord
