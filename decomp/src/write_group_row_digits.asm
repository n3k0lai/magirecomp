; Write five group values onto the start-screen map.
;
; IndexedSetup calls this after the group-word store, while this bank
; stays mapped. SRAM is enabled and the bank at $C727 is selected.
; `add a, $00` keeps that bank byte and its flags. Nothing reads them.
; VRAM bank 0 is selected with the 3-byte store.
;
; C runs from 0 through 4. The word at $CC78 + C * 2 is a pointer. A zero
; byte there stores $DF three times at $C92D and clears the byte at
; $CC4D + C + [$CC87]. $DF plus tile base $A1 wraps to $80, the blank map
; tile. A nonzero byte sets that flag to 1 and is passed to $041A as a
; word with a zero high byte. The saved pointer is unused on the zero path.
;
; $04CA then multiplies C by $20. Adding $9C61 lands on column 1 of map
; rows 3 through 7. $61E1 writes the three digit tiles from there.
; SRAM is disabled on the way out.
;
; rRAMG is the name from reset.asm. rVBK is the name from setup_window.asm.
; rRAMB, wSRAMBank, SRAM_ENABLE, and wFillCC4D are the names from
; handle_start_press.asm. wDigitLow and TILE_DIGIT_BASE are the names from
; write_digit_tiles.asm and draw_start_screen_map.asm. FormatStartDigits,
; MulCByB, and WriteDigitTiles are already source.

; Five pointers. What they address, besides one byte each, is still unknown.
DEF wGroupPointers EQU $CC78

; Added to the row index and to $CC4D. IndexedSetup stores it first.
DEF wGroupFlagOffset EQU $CC87

; Becomes tile $80 after WriteDigitTiles adds $A1.
DEF DIGIT_BLANK EQU $DF

DEF GROUP_DIGIT_ROWS EQU $05
DEF GROUP_ROW_BYTES EQU $20

; Column 1 of BG-map row 3. Each next row is $20 bytes later.
DEF vGroupDigitRow EQU $9C61

WriteGroupRowDigits::
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    xor a
    ld [rVBK], a
    ld bc, $0000
.row:
    ld hl, wGroupPointers
    ld b, $00
    add hl, bc
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    xor a
    cp [hl]
    jr nz, .present

    ld a, DIGIT_BLANK
    ld hl, wDigitLow
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, [wGroupFlagOffset]
    ld e, a
    ld d, $00
    push hl
    ld hl, wFillCC4D
    add hl, bc
    add hl, de
    xor a
    ld [hl], a
    pop hl
    jr .place

.present:
    ld a, [wGroupFlagOffset]
    ld e, a
    ld d, $00
    push hl
    ld hl, wFillCC4D
    add hl, bc
    add hl, de
    ld a, $01
    ld [hl], a
    pop hl
    ld e, [hl]
    ld d, $00
    push bc
    call FormatStartDigits
    pop bc

.place:
    ld b, GROUP_ROW_BYTES
    call MulCByB
    ld de, vGroupDigitRow
    add hl, de
    ld d, TILE_DIGIT_BASE
    call WriteDigitTiles
    inc c
    ld a, GROUP_DIGIT_ROWS
    cp c
    jr nz, .row

    xor a
    ld [rRAMG], a
    ret
