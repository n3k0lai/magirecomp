; Adds C to the column of a tilemap address in HL.
; The low five bits of L are the column inside a 32-tile row. They wrap
; with AND $1F, and the row bits of L (AND $E0) are put back. H is left
; alone, so a $9800/$9C00 map pointer stays on the same row.
; Callers in this bank pass C = $01 or C = $FE. The pointer words at
; $C836 are still unnamed.

StepTilemapColumn:
    ld a, l
    add c
    and $1f
    ld e, a
    ld a, l
    and $e0
    add e
    ld l, a
    ret
