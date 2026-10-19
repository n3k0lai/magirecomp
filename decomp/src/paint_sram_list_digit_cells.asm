; Bank 3 at $6FE8. BlankAbsentSramListSlot and SyncSramListSlotDigits
; plant this address at wCallback, with the callback bank left at 3,
; and call RefreshFrame. This bank stays mapped. The routine does not
; write rROMB0. It returns to RefreshFrame.
;
; Fifteen bytes at wOneEntryList are written into the $9C00 window map.
; Each store is `ld a, [hl+]`, `ld [bc], a`, `inc bc`, and the last
; `inc bc` of a run is still executed before BC is reloaded or the
; routine returns.
;
; $9DE2 is window row 15, columns 2-5: the $F2 mark and the record-word
; digits, or four blank tiles when the slot is absent. $9E02 is row 16,
; columns 2-5: the $F1 mark and the record's third byte. $9E0E is row
; 16, columns 14-17: the $F1 mark and the SRAM stock byte. $9DEF is row
; 15, columns 15-17: the three digits of the SRAM word at $A3A5, with
; no mark in front. The absent path leaves the first twelve tiles as
; $80 and still writes those three digits at $9DEF.
;
; wOneEntryList is the name from plant_one_map_list_entry.asm.

; Window map row 15, column 2. Four cells: mark and record word.
DEF LIST_MAP_WORD EQU $9DE2

; Window map row 16, column 2. Four cells: mark and record byte.
DEF LIST_MAP_BYTE EQU $9E02

; Window map row 16, column 14. Four cells: mark and SRAM stock.
DEF LIST_MAP_STOCK EQU $9E0E

; Window map row 15, column 15. Three cells: SRAM word digits.
DEF LIST_MAP_HELD EQU $9DEF

DEF LIST_MARKED_CELLS EQU 4
DEF LIST_HELD_CELLS EQU 3

PaintSramListDigitCells::
    ld hl, wOneEntryList
    ld bc, LIST_MAP_WORD
    rept LIST_MARKED_CELLS
        ld a, [hl+]
        ld [bc], a
        inc bc
    endr
    ld bc, LIST_MAP_BYTE
    rept LIST_MARKED_CELLS
        ld a, [hl+]
        ld [bc], a
        inc bc
    endr
    ld bc, LIST_MAP_STOCK
    rept LIST_MARKED_CELLS
        ld a, [hl+]
        ld [bc], a
        inc bc
    endr
    ld bc, LIST_MAP_HELD
    rept LIST_HELD_CELLS
        ld a, [hl+]
        ld [bc], a
        inc bc
    endr
    ret
