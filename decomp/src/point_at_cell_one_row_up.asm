; Bank 1 at $4D13. ResumeUpIdleRecord calls here when the saved Y
; step at $C6D1 is nonzero and the live Y step at
; wClearedOnRecordLoad + 1 is zero. rROMB0 is left alone.
;
; B takes hObjectCellX. C takes hObjectCellY minus one, the row above
; the object. The map row stride in $C847 is negated (cpl / inc) and
; sign-extended in DE, then added to the little-endian word at
; hMapCellPointer. Those pointer loads are the 3-byte form, so HL lands
; one row up. $C847 is wMapRowStride, defined later in
; draw_metatile_window.asm.
;
; WRAM bank 5 is stored at wCurrentWRAMBank and selected with ldh to
; rSVBK, then this returns. The caller reads the cell byte at HL.
;
; hObjectCellX and hObjectCellY are the names from queue_sprite_list.asm.
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.

; Map cell plane. Selected after the pointer has moved one row up.
DEF WRAM_CELL_ABOVE EQU $05

PointAtCellOneRowUp::
    ldh a, [hObjectCellX]
    ld b, a
    ldh a, [hObjectCellY]
    dec a
    ld c, a
    ld a, [$c847]
    cpl
    inc a
    ld e, a
    ld d, $ff
    ld a, [hMapCellPointer + 1]
    ld h, a
    ld a, [hMapCellPointer]
    ld l, a
    add hl, de
    ld a, WRAM_CELL_ABOVE
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ret
