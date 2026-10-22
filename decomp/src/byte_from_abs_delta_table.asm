; ByteFromAbsDeltaTable. Bank 2 at $54B3.
;
; A is increased by 2, then C is subtracted. A borrow means that difference
; was negative, and `cpl` / `inc a` makes it the absolute value. DE is
; incremented once and becomes the column inside each 4-byte row.
; FormatFixedWord0172 enters with A = 0, C = $63, and DE = 0, so the
; distance is $61 and the column is 1. That caller discards the byte.
;
; The first row whose threshold is above the distance supplies [row+DE].
; A distance at least as large as every threshold reads one byte past the
; table, at $54B3 + DE.

ByteFromAbsDeltaRows:
    INCBIN "roms/magination.gbc", $94A3, $10

ByteFromAbsDeltaTable::
    add $02
    sub c
    jr nc, .nonneg
    cpl
    inc a
.nonneg:
    ld hl, ByteFromAbsDeltaRows
    ld bc, $0004
    inc de
    cp [hl]
    jr nc, .second
    add hl, de
    ld a, [hl]
    ret

.second:
    add hl, bc
    cp [hl]
    jr nc, .third
    add hl, de
    ld a, [hl]
    ret

.third:
    add hl, bc
    cp [hl]
    jr nc, .pastTable
    add hl, de
    ld a, [hl]
    ret

.pastTable:
    add hl, bc
    add hl, de
    ld a, [hl]
    ret
