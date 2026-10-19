; Scale the selected slot at $CD82/$CD83 into the position bytes at $C2D2/$C2D3.
;
; $CD82 is the column. (column + 1) * 8 is stored at $C2D2.
; $CD83 is the row. (row + 2) * 8 is stored at $C2D3.
; SelectSlotFromHighNibble calls this when $CCBA is $02.

ReloadSlotPosition::
    ld a, [$cd82]
    inc a
    add a
    add a
    add a
    ld [$c2d2], a
    ld a, [$cd83]
    inc a
    inc a
    add a
    add a
    add a
    ld [$c2d3], a
    ret
