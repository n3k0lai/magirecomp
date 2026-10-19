; Bank 4 at $6034. CopiedBlockWindowChoice calls here when $CD81
; differs from $CD3B. This bank stays mapped. The routine does not
; write rROMB0.
;
; $CD81 is copied into $CD3B. Zero and $04 return. Any other value is
; a row in the eight-byte records LoadWRAM6ChoiceRows left at
; wRowBytes. The row is (slot - 1) * ROW_STRIDE. TAIL_SLOT_NOW,
; TAIL_SLOT_SEEN, and those two names are already defined.
;
; Seven bytes at $CD40 are filled with blank tile $80. Byte 1 of the
; row indexes SRAM_SCAN_C. SRAM bank wSRAMBank is selected and enabled,
; then PaintSRAMWordDigits reads that one byte (A is 0) and writes
; three digit tiles at $CD40. SRAM is disabled again. wSRAMBank, rRAMB,
; SRAM_ENABLE, and SRAM_SCAN_C are the names from handle_start_press.asm.
; rRAMG is the name from reset.asm. `add a, $00` keeps the bank byte.
;
; $9C64 + (slot - 1) * $60 is stored little-endian at $CD47. That is
; the window-map row this slot paints from. Byte 3 of the record, when
; it is not $FF, indexes the same SRAM table into three tiles at $CD44
; and stores $91 at $CD43. Byte 7 is saved at $CD50.
;
; wCallback becomes $60DF in this bank, then RefreshFrame runs. $60DF
; is still INCBIN. wCallback and wCallbackBank are the names from
; default_state.asm. MulCByB, PaintSRAMWordDigits, and RefreshFrame are
; already source.

DEF wSlotDigitTiles EQU $CD40
DEF wSlotMapPtr EQU $CD47
DEF wSlotRowByte7 EQU $CD50
DEF SLOT_MAP_BASE EQU $9C64
DEF SLOT_MAP_STRIDE EQU $0060
DEF SLOT_TILE_BLANK EQU $80
DEF SLOT_TILE_COUNT EQU $07
DEF SLOT_SEP_TILE EQU $91
DEF SLOT_ROW_INDEX1 EQU $0001
DEF SLOT_ROW_INDEX3 EQU $0003
DEF SLOT_ROW_INDEX7 EQU $0007
DEF SLOT_SKIP EQU $04
DEF SLOT_EMPTY_INDEX EQU $FF

; Still INCBIN. Copies the digit buffer onto the window map.
DEF SlotDigitCallback EQU $60DF

RefreshChangedSlotDigits::
    ld a, [TAIL_SLOT_NOW]
    ld [TAIL_SLOT_SEEN], a
    cp $00
    ret z

    cp SLOT_SKIP
    ret z

    ld a, SLOT_TILE_BLANK
    ld d, SLOT_TILE_COUNT
    ld hl, wSlotDigitTiles

.fillBlank:
    ld [hl+], a
    dec d
    jr nz, .fillBlank

    ld a, [TAIL_SLOT_NOW]
    dec a
    ld b, a
    ld c, ROW_STRIDE
    call MulCByB
    ld bc, wRowBytes
    add hl, bc
    push hl
    ld bc, SLOT_ROW_INDEX1
    add hl, bc
    ld c, [hl]
    ld b, $00
    ld hl, SRAM_SCAN_C
    add hl, bc
    ld a, [wSRAMBank]
    add $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    xor a
    ld de, wSlotDigitTiles
    call PaintSRAMWordDigits
    xor a
    ld [rRAMG], a
    ld hl, SLOT_MAP_BASE
    ld bc, SLOT_MAP_STRIDE
    ld a, [TAIL_SLOT_NOW]

.stepRows:
    dec a
    jr z, .storeMap

    add hl, bc
    jr .stepRows

.storeMap:
    ld a, h
    ld [wSlotMapPtr + 1], a
    ld a, l
    ld [wSlotMapPtr], a
    pop hl
    push hl
    ld bc, SLOT_ROW_INDEX3
    add hl, bc
    ld c, [hl]
    ld a, SLOT_EMPTY_INDEX
    cp c
    jr z, .rowTail

    ld b, $00
    ld hl, SRAM_SCAN_C
    add hl, bc
    ld a, [wSRAMBank]
    add $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    xor a
    ld de, wSlotDigitTiles + 4
    call PaintSRAMWordDigits
    xor a
    ld [rRAMG], a
    ld a, SLOT_SEP_TILE
    ld [wSlotDigitTiles + 3], a

.rowTail:
    pop hl
    ld bc, SLOT_ROW_INDEX7
    add hl, bc
    ld a, [hl]
    ld [wSlotRowByte7], a
    ld a, $04
    ld [wCallbackBank], a
    ld a, LOW(SlotDigitCallback)
    ld [wCallback], a
    ld a, HIGH(SlotDigitCallback)
    ld [wCallback + 1], a
    call RefreshFrame
    ret
