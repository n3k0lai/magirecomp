; Bank 3 at $71AA. StageSramListNames calls this before it stores the
; name-table base. This routine writes the SRAM bank register, not
; rROMB0. The only call is MulCByB in bank 0.
;
; $CCC6 starts as $CCD5 and $CCC7 starts at 0. HL + BC is computed and
; then ignored. SRAM bank wSRAMBank + 1 is selected and enabled.
;
; Each pass looks at one $25-byte SRAM record at $A025, beginning at
; index $CCD5. An id of $FF is skipped. Any other id is stored in the
; eight-byte table at $CCCD. The pass stops after eight ids, or after
; eight indices from $CCD5. Leftover table bytes are $FF. SRAM is
; disabled before either return.
;
; RECORD_INDEX and RECORD_STEP are the names from
; stage_copied_block_arm_slot.asm. CHOICE_BYTES, CHOICE_SLOT_COUNT, and
; CHOICE_PAD are the names from fill_choice_table_from_records.asm.
; wSRAMBank, rRAMB, and SRAM_ENABLE are the names from
; handle_start_press.asm. rRAMG is the name from reset.asm. MulCByB is
; already source.

; Ids accepted into $CCCD. $CCC9 is the fill count in the block copier.
DEF SRAM_ID_COUNT EQU $CCC7

; First byte of each SRAM record is the id. Records begin at $A025.
DEF SRAM_RECORD_STRIDE EQU $25
DEF SRAM_RECORD_BASE EQU $A025

FillSramListIds::
    ld a, [RECORD_INDEX]
    ld [RECORD_STEP], a
    xor a
    ld [SRAM_ID_COUNT], a
    add hl, bc
    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a

.nextIndex:
    ld a, [RECORD_INDEX]
    add CHOICE_SLOT_COUNT
    ld e, a
    ld a, [RECORD_STEP]
    cp e
    jr z, .padRest

    inc a
    ld [RECORD_STEP], a
    dec a
    ld c, a
    ld b, SRAM_RECORD_STRIDE
    call MulCByB
    ld bc, SRAM_RECORD_BASE
    add hl, bc
    ld a, [hl]
    cp CHOICE_PAD
    jr z, .nextIndex

    ld e, a
    ld hl, CHOICE_BYTES
    ld a, [SRAM_ID_COUNT]
    ld c, a
    ld b, $00
    add hl, bc
    ld [hl], e
    inc a
    ld [SRAM_ID_COUNT], a
    cp CHOICE_SLOT_COUNT
    jr nz, .nextIndex

    xor a
    ld [rRAMG], a
    ret

.padRest:
    ld hl, CHOICE_BYTES
    ld a, [SRAM_ID_COUNT]
    ld c, a
    ld b, $00
    add hl, bc

.padByte:
    ld a, CHOICE_PAD
    ld [hl+], a
    inc c
    ld a, c
    cp CHOICE_SLOT_COUNT
    jr nz, .padByte

    xor a
    ld [rRAMG], a
    ret
