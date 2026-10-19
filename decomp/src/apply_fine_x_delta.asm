; Bank 5 at $67B1. Adds the signed byte at $C6D2 into hObjectFineX
; ($FF8F). $C6D2 is the word LoadRecordHead clears; here only its low
; byte is the X step. A zero step returns.
;
; Fine X lives in the low nibble. Bit 4 of the sum means the step crossed
; a 16-pixel cell. The sum is masked to $0F and stored. A negative step
; (bit 7 of the original delta) decrements hObjectCellX and the
; little-endian word at hMapCellPointer. A non-negative step increments
; both. The pointer high byte is $FF94. A sum that does not set bit 4 is
; stored and the cell is left alone.
;
; hObjectFineX and hObjectCellX are the names from queue_sprite_list.asm.
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; This routine does not write rROMB0 and does not call out.

ApplyFineXDelta::
    ld a, [wClearedOnRecordLoad]
    ld b, a
    and a
    ret z

    ld hl, hObjectFineX
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
    ld a, [hObjectCellX]
    bit 7, b
    jp z, .stepRight

    dec hl
    dec a
    jr .storeStepped

.stepRight:
    inc hl
    inc a

.storeStepped:
    ld [hObjectCellX], a
    ld a, h
    ld [hMapCellPointer + 1], a
    ld a, l
    ld [hMapCellPointer], a
    ret

.storeSum:
    ld [hl], a
    ret
