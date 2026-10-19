; Bank 1 at $4CBF. DispatchCellBelowOnButtonA calls here, and so do
; three later sites still in this INCBIN. B takes hObjectCellX. C takes
; hObjectCellY plus one, the row below the object. HL is the little-endian
; word at hMapCellPointer plus the map row stride in $C847, so it lands on
; that same row. Those pointer loads are the 3-byte form. $C847 is
; wMapRowStride, defined later in draw_metatile_window.asm.
;
; WRAM bank 5 is stored at wCurrentWRAMBank and selected with ldh to
; rSVBK, then this returns. The caller reads the cell byte at HL.
;
; hObjectCellX and hObjectCellY are the names from queue_sprite_list.asm.
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.

; Map cell plane. Selected after the pointer has moved one row down.
DEF WRAM_CELL_BELOW EQU $05

PointAtCellOneRowDown::
    ldh a, [hObjectCellX]
    ld b, a
    ldh a, [hObjectCellY]
    inc a
    ld c, a
    ld a, [$c847]
    ld e, a
    ld d, $00
    ld a, [hMapCellPointer + 1]
    ld h, a
    ld a, [hMapCellPointer]
    ld l, a
    add hl, de
    ld a, WRAM_CELL_BELOW
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ret
