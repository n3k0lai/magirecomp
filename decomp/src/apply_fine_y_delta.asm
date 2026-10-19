; Bank 5 at $67E7. Adds the signed byte at $C6D3 into hObjectFineY
; ($FF90). $C6D3 is the high byte of the word LoadRecordHead clears.
; A zero step returns.
;
; Fine Y lives in the low nibble. Bit 4 of the sum means the step crossed
; a 16-pixel cell. The sum is masked to $0F and stored. A negative step
; (bit 7 of the original delta) decrements hObjectCellY and subtracts the
; byte at $C6CF from the little-endian word at hMapCellPointer. A
; non-negative step increments the cell and adds that byte. $C6CF is the
; map stride in bytes per row. What writes it is still unknown. The
; pointer high byte is $FF94. A sum that does not set bit 4 is stored and
; the cell is left alone.
;
; hObjectFineY and hObjectCellY are the names from queue_sprite_list.asm.
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; This routine does not write rROMB0 and does not call out.

ApplyFineYDelta::
    ld a, [wClearedOnRecordLoad + 1]
    ld b, a
    and a
    ret z

    ld hl, hObjectFineY
    ld a, [hl]
    add b
    bit 4, a
    jr z, .storeSum

    and $0f
    ld [hl], a
    ld a, [hMapCellPointer + 1]
    ld h, a
    ld a, [hMapCellPointer]
    ld l, a
    ld a, [hObjectCellY]
    ld c, a
    bit 7, b
    jp z, .stepDown

    ld a, [$C6CF]
    cpl
    ld e, a
    ld d, $ff
    inc de
    add hl, de
    dec c
    jr .storeStepped

.stepDown:
    ld a, [$C6CF]
    ld e, a
    ld d, $00
    add hl, de
    inc c

.storeStepped:
    ld a, c
    ld [hObjectCellY], a
    ld a, h
    ld [hMapCellPointer + 1], a
    ld a, l
    ld [hMapCellPointer], a
    ret

.storeSum:
    ld [hl], a
    ret
