; Bank 3 at $6C9E. DispatchPrefixedBlockChoice plants this address at
; wCallback when the latched slot index is outside $03-$0A, runs
; RefreshFrame once, then restores IdleCallback.
;
; Four copies of tile id $80 are stored at BG map cell $9E0E and the
; three cells after it. PlantLatchedSlotDigits uses that same cell
; when the slot is inside the scan range. What tile $80 draws is still
; unknown.
;
; This routine does not write rROMB0 and does not call. vMapCell9E0E
; is the name from plant_latched_slot_digits.asm.

; Tile id written into each of the four map cells.
DEF TILE_ID_80 EQU $80

BlankOutOfRangeSlotMap::
    ld hl, vMapCell9E0E
    ld a, TILE_ID_80
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ret
