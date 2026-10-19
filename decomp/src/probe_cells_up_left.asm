; Bank 5 at $68DF. Word 0 of the table at $651E. SaveStepThenApplyOrDispatch
; calls it through JumpHL when the step class is 0: both the X step at
; $C6D2 and the Y step at $C6D3 cross a cell, and both are negative
; (up and left).
;
; C comes back as three occupancy bits around hMapCellPointer. Bit 2 is
; the cell one byte before the pointer (left). The pointer then steps
; back by the map stride at $C6CF, which ApplyFineYDelta treats as bytes
; per row. Bit 1 is that cell (up-left) and bit 0 is the next byte (up).
; A cell byte of $80 or more leaves its bit clear. A byte of $08 through
; $7F sets the bit. A byte under $08 sets the bit only when $C12A plus
; that byte is nonzero. $C12A is the eight-byte pattern WriteC12APatternBank5
; stores. C is 0 on entry, so unset bits stay clear.
;
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; This routine does not write rROMB0 and does not call out.

ProbeCellsUpLeft::
    ld a, [hMapCellPointer + 1]
    ld h, a
    ld a, [hMapCellPointer]
    ld l, a
    ld c, $00
    dec hl
    ld a, [hl]
    cp $80
    jr nc, .afterLeft
    cp $08
    jr nc, .setLeft
    ld de, $c12a
    add a, e
    ld e, a
    ld a, [de]
    cp $00
    jr z, .afterLeft

.setLeft:
    set 2, c

.afterLeft:
    ld a, [$C6CF]
    ld e, a
    ld d, $00
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    add hl, de
    ld a, [hl+]
    cp $80
    jr nc, .afterUpLeft
    cp $08
    jr nc, .setUpLeft
    ld de, $c12a
    add a, e
    ld e, a
    ld a, [de]
    cp $00
    jr z, .afterUpLeft

.setUpLeft:
    set 1, c

.afterUpLeft:
    ld a, [hl]
    cp $80
    ret nc

    cp $08
    jr nc, .setUp
    ld de, $c12a
    add a, e
    ld e, a
    ld a, [de]
    cp $00
    ret z

.setUp:
    set 0, c
    ret
