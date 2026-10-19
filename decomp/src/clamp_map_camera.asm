; Clamp the map camera before DrawMetatileWindow. That caller is in this
; bank and leaves rROMB0 alone. The names below match draw_metatile_window.asm
; and the scroll steps.
;
; $C847 is the map width in cells and the byte stride of one row. $C845 is
; the rightmost camera column. $C846 is the bottom camera row, or $FF when
; the map is shorter than the 10-row window. The window is 11 columns by
; 10 rows, so a width of 10 cannot scroll sideways.
;
; E collects the edge flags stored at $C842. Bit 3 skips horizontal steps
; when the width is 10. Bit 2 blocks a left step at column 0. Bit 1 blocks
; a right step on the limit at $C845. Bit 7 skips vertical steps when $C846
; is $FF. Bit 6 blocks an up step at row 0. Bit 5 blocks a down step on the
; limit at $C846. A column at or past the width, or a row at or past
; $C846 + 10, is pinned back to 0 with a fine position of 0. A column from
; $C845 up to the width, or a row from $C846 up to that row plus 10, is
; pinned to the limit with a fine position of 15.
;
; $C85F/$C85D are the column and its fine X (0-15). $C860/$C85E are the row
; and its fine Y. Scroll is the cell times 16 pixels plus that fine value:
; $C935 and rSCX ($FF43) for X, $C934 and rSCY ($FF42) for Y.
;
; MulCByB then builds the map pointer at $C861 as $D000 plus the column plus
; the row times the stride. The tilemap address at $C863/$C864 is in the
; $9800 window: row times $40, plus the column times 2, wrapped to 32
; columns. Bit 3 of a fine position is the next tile. Fine X bumps the
; column inside its row. Fine Y adds one tile row ($20) and wraps the high
; byte back into $9800-$9BFF. Both adjustments run when both bits are set.

ClampMapCamera::
    ld e, $00
    ld a, [$c847]
    cp $0a
    jr nz, .widthNotTen

    set 3, e
    jr .pinColumnZero

.widthNotTen:
    ld d, a
    ld a, [$c85f]
    and a
    jr z, .pinColumnZero

    cp d
    jr c, .columnInside

.pinColumnZero:
    xor a
    ld [$c85f], a
    ld [$c85d], a
    set 2, e
    ld a, [$c845]
    and a
    jr nz, .columnDone

    set 1, e
    jr .columnDone

.columnInside:
    ld d, a
    ld a, [$c845]
    ld l, a
    cp d
    jr z, .pinColumnRight

    jr nc, .columnDone

.pinColumnRight:
    set 1, e
    ld a, $0f
    ld [$c85d], a
    ld a, l
    ld [$c85f], a
    and a
    jr nz, .columnDone

    set 2, e

.columnDone:
    ld a, [$c846]
    add $0a
    cp $09
    jr nz, .heightPresent

    set 7, e
    jr .pinRowZero

.heightPresent:
    ld d, a
    ld a, [$c860]
    and a
    jr z, .pinRowZero

    cp d
    jr c, .rowInside

.pinRowZero:
    xor a
    ld [$c860], a
    ld [$c85e], a
    set 6, e
    ld a, [$c846]
    and a
    jr nz, .rowDone

    set 5, e
    jr .rowDone

.rowInside:
    ld d, a
    ld a, [$c846]
    ld l, a
    cp d
    jr z, .pinRowBottom

    jr nc, .rowDone

.pinRowBottom:
    set 5, e
    ld a, $0f
    ld [$c85e], a
    ld a, l
    ld [$c860], a
    and a
    jr nz, .rowDone

    set 6, e

.rowDone:
    ld a, e
    ld [$c842], a
    ld a, [$c85f]
    add a
    add a
    add a
    add a
    ld b, a
    ld a, [$c85d]
    add b
    ld [$c935], a
    ldh [$ff43], a
    ld a, [$c860]
    ld c, a
    add a
    add a
    add a
    add a
    ld b, a
    ld a, [$c85e]
    add b
    ld [$c934], a
    ldh [$ff42], a
    ld a, [$c847]
    ld b, a
    call MulCByB
    ld a, [$c85f]
    add l
    ld [$c861], a
    ld a, $d0
    adc h
    ld [$c862], a
    ld a, [$c860]
    ld c, a
    ld b, $40
    call MulCByB
    ld a, h
    and $03
    add $98
    ld [$c864], a
    ld a, [$c85f]
    add a
    and $1f
    add l
    ld [$c863], a
    ld a, [$c864]
    ld d, a
    ld a, [$c863]
    ld e, a
    ld hl, $0020
    ld a, [$c85d]
    bit 3, a
    jr nz, .fineX

    ld a, [$c85e]
    bit 3, a
    jr nz, .fineYOnly

    ret

.fineYOnly:
    add hl, de
    ld a, h
    and $03
    add $98
    ld h, a
    ld a, h
    ld [$c864], a
    ld a, l
    ld [$c863], a
    ret

.fineX:
    ld a, [$c85e]
    bit 3, a
    jr nz, .fineBoth

    ld a, e
    inc a
    and $1f
    ld c, a
    ld a, e
    and $e0
    add c
    ld [$c863], a
    ret

.fineBoth:
    ld a, e
    inc a
    and $1f
    ld c, a
    ld a, e
    and $e0
    add c
    ld e, a
    add hl, de
    ld a, h
    and $03
    add $98
    ld h, a
    ld a, h
    ld [$c864], a
    ld a, l
    ld [$c863], a
    ret
