; Bank 3 at $7213. StageSramListNames calls this after TurnOnLCDIfOff,
; and SpendSramListChoice calls it after $731C. This routine does not
; write rROMB0. The bank change goes through CallBankedHL.
;
; $CCC6 starts at 0 and HL walks the eight ids at $CCCD. Each pass
; selects WRAM bank 6 and scans the counted bytes at $D001 for that id.
; [$D000] is the scan limit. A hit, or a step whose byte at $CD17 is
; not $63, multiplies that $CD17 byte by 3 and adds $5AD7. The sum is
; stored at $CD8D, $CD8F points at $CD91, and CallBankedHL maps bank 7
; and runs $5AC1, which copies the three-byte price into $CD91.
;
; A miss, or a $CD17 byte of $63, writes $FF three times at $CD91
; instead. Either way the three bytes are copied into the record at
; $CCFE indexed by the step. Eight steps return. The id's place in the
; $D001 list is not stored.
;
; RECORD_STEP, COPIED_BLOCK_BANK, COPIED_BLOCK_BASE, and
; COPIED_BLOCK_DATA are the names from stage_copied_block_arm_slot.asm.
; CHOICE_BYTES, CHOICE_SLOT_COUNT, and CHOICE_PAD are the names from
; fill_choice_table_from_records.asm. wSlotRecords and SLOT_RECORD_BYTES
; are the names from sync_sram_list_slot_digits.asm. SRAM_NAME_PTR_LO,
; SRAM_NAME_PTR_HI, SRAM_NAME_DEST, and SRAM_NAME_LIST are the names
; from stage_sram_name_tiles.asm. wCurrentWRAMBank and rSVBK are the
; names from timer_overflow.asm. MulCByB and CallBankedHL are already
; source. $5AC1 is still INCBIN. $5AD7 is the three-byte table inside
; that same range.

; Still INCBIN in bank 7. Copies three bytes from [$CD8D] to [$CD8F].
DEF Bank7_5AC1 EQU $5AC1

; Three-byte prices. Index * 3 is added to this word. Bank 7.
DEF PRICE_TABLE_5AD7 EQU $5AD7

; One byte per step. $63 means the price record is three $FF bytes.
DEF wPriceIndexCD17 EQU $CD17
DEF PRICE_INDEX_NONE EQU $63

; Bank mapped for $5AC1.
DEF PRICE_COPY_BANK EQU $07

FillSramListPrices::
    xor a
    ld [RECORD_STEP], a
    ld hl, CHOICE_BYTES

.nextId:
    ld a, [RECORD_STEP]
    cp CHOICE_SLOT_COUNT
    ret z

    inc a
    ld [RECORD_STEP], a
    ld a, [hl+]
    ld d, a
    ld e, $00
    push hl
    ld hl, COPIED_BLOCK_DATA
    ld a, COPIED_BLOCK_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a

.scan:
    ld a, [hl+]
    cp d
    jr z, .priced

    inc e
    ld a, [COPIED_BLOCK_BASE]
    cp e
    jr nz, .scan

.blank:
    ld a, CHOICE_PAD
    ld bc, SRAM_NAME_LIST
    ld [bc], a
    inc bc
    ld [bc], a
    inc bc
    ld [bc], a
    jr .storeRecord

.priced:
    ld a, [RECORD_STEP]
    dec a
    ld c, a
    ld b, $00
    ld hl, wPriceIndexCD17
    add hl, bc
    ld a, [hl]
    cp PRICE_INDEX_NONE
    jr z, .blank

    ld c, a
    ld b, SLOT_RECORD_BYTES
    call MulCByB
    ld de, PRICE_TABLE_5AD7
    add hl, de
    ld a, h
    ld [SRAM_NAME_PTR_HI], a
    ld a, l
    ld [SRAM_NAME_PTR_LO], a
    ld bc, SRAM_NAME_LIST
    ld hl, SRAM_NAME_DEST
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, Bank7_5AC1
    ld e, PRICE_COPY_BANK
    call CallBankedHL

.storeRecord:
    ld a, [RECORD_STEP]
    dec a
    ld c, a
    ld b, SLOT_RECORD_BYTES
    call MulCByB
    ld bc, wSlotRecords
    add hl, bc
    ld bc, SRAM_NAME_LIST
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl], a
    pop hl
    jp .nextId
