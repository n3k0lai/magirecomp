; Bank 1 at $4CDD. ResumeHead01Record calls here when the live X step
; has gone to zero. rROMB0 is left alone.
;
; B takes hObjectCellX minus one, the column to the left. C takes
; hObjectCellY unchanged. DE is $FFFF, so adding it to the little-endian
; word at hMapCellPointer moves HL one byte left, the cell in that
; column. Those pointer loads are the 3-byte form.
;
; WRAM bank 5 is stored at wCurrentWRAMBank and selected with ldh to
; rSVBK, then this returns. The caller reads the cell byte at HL.
;
; hObjectCellX and hObjectCellY are the names from queue_sprite_list.asm.
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.

; Map cell plane. Selected after the pointer has moved one column left.
DEF WRAM_CELL_LEFT EQU $05

PointAtCellOneColumnLeft::
    ldh a, [hObjectCellX]
    dec a
    ld b, a
    ldh a, [hObjectCellY]
    ld c, a
    ld de, $ffff
    ld a, [hMapCellPointer + 1]
    ld h, a
    ld a, [hMapCellPointer]
    ld l, a
    add hl, de
    ld a, WRAM_CELL_LEFT
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ret
