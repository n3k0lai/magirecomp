; Bank 1 at $4CF8. ResumeRightRecordHead calls here when the saved X
; step at $C6D0 is nonzero and the live X step at wClearedOnRecordLoad
; is zero. rROMB0 is left alone. Four other callers are still INCBIN.
;
; B takes hObjectCellX plus one, the column to the right. C takes
; hObjectCellY unchanged. DE is $0001, so adding it to the little-endian
; word at hMapCellPointer moves HL one byte right, the cell in that
; column. Those pointer loads are the 3-byte form.
;
; WRAM bank 5 is stored at wCurrentWRAMBank and selected with ldh to
; rSVBK, then this returns. The caller reads the cell byte at HL.
;
; hObjectCellX and hObjectCellY are the names from queue_sprite_list.asm.
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.

; Map cell plane. Selected after the pointer has moved one column right.
DEF WRAM_CELL_RIGHT EQU $05

PointAtCellOneColumnRight::
    ldh a, [hObjectCellX]
    inc a
    ld b, a
    ldh a, [hObjectCellY]
    ld c, a
    ld de, $0001
    ld a, [hMapCellPointer + 1]
    ld h, a
    ld a, [hMapCellPointer]
    ld l, a
    add hl, de
    ld a, WRAM_CELL_RIGHT
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ret
