; Bank 4 at $60DF. RefreshChangedSlotDigits plants this address at
; wCallback, in this bank, and calls RefreshFrame. This bank stays
; mapped. The routine does not write rROMB0.
;
; rVBK is cleared with the 3-byte form, so the writes land in VRAM
; bank 0. The seven tiles at wSlotDigitTiles land as three cells at
; $9DD0 (window-map row 14, columns 16-18) and four cells at $9DEF
; (row 15, columns 15-18).
;
; wSlotMapPtr is the little-endian window address stored by
; RefreshChangedSlotDigits: $9C64 plus (slot - 1) * $60. Ten cells from
; that address are copied to row 14, columns 4-13 ($9DC4). Ten cells
; from one tilemap row below ($20) are copied to row 15, columns 4-13
; ($9DE4). wCallback then becomes IdleCallback, low byte first.
; wCallbackBank is left alone.
;
; wSlotDigitTiles and wSlotMapPtr are the names from
; refresh_changed_slot_digits.asm. SLOT_MAP_ROW14 and SLOT_MAP_ROW15
; are the names from blank_slot_digit_rows.asm. wCallback and
; IdleCallback are the names from default_state.asm. rVBK is the name
; from setup_window.asm.

DEF SLOT_DIGIT_TOP EQU $9DD0
DEF SLOT_DIGIT_BOTTOM EQU $9DEF
DEF SLOT_DIGIT_TOP_CELLS EQU 3
DEF SLOT_DIGIT_BOTTOM_CELLS EQU 4
DEF SLOT_STRIP_CELLS EQU 10
DEF TILEMAP_NEXT_ROW EQU $0020

CopySlotDigitsToWindow::
    xor a
    ld [rVBK], a
    ld bc, wSlotDigitTiles
    ld hl, SLOT_DIGIT_TOP
    rept SLOT_DIGIT_TOP_CELLS
        ld a, [bc]
        ld [hl+], a
        inc bc
    endr
    ld hl, SLOT_DIGIT_BOTTOM
    rept SLOT_DIGIT_BOTTOM_CELLS
        ld a, [bc]
        ld [hl+], a
        inc bc
    endr
    ld hl, wSlotMapPtr
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, SLOT_MAP_ROW14
    rept SLOT_STRIP_CELLS
        ld a, [bc]
        ld [hl+], a
        inc bc
    endr
    ld hl, wSlotMapPtr
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, TILEMAP_NEXT_ROW
    add hl, bc
    ld b, h
    ld c, l
    ld hl, SLOT_MAP_ROW15
    rept SLOT_STRIP_CELLS
        ld a, [bc]
        ld [hl+], a
        inc bc
    endr
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
