; Bank 5 at $6A60. Word 4 of the table at $651E. SaveStepThenApplyOrDispatch
; calls it through JumpHL when the step class is 4: both the X step at
; $C6D2 and the Y step at $C6D3 cross a cell, and both are positive
; (down and right).
;
; C comes back as three occupancy bits around hMapCellPointer. Bit 2 is
; the next byte (right). The pointer then steps forward by the map stride
; at $C6CF, which ApplyFineYDelta treats as bytes per row. Bit 1 is that
; cell (down-right) and bit 0 is the previous byte (down). A cell byte of
; $80 or more leaves its bit clear. A byte of $08 through $7F sets the
; bit. A byte under $08 sets the bit only when $C12A plus that byte is
; nonzero. $C12A is the eight-byte pattern WriteC12APatternBank5 stores.
; C is 0 on entry, so unset bits stay clear.
;
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; This routine does not write rROMB0 and does not call out.

ProbeCellsDownRight::
    ld a, [hMapCellPointer + 1]
    ld h, a
    ld a, [hMapCellPointer]
    ld l, a
    ld c, $00
    inc hl
    ld a, [hl]
    cp $80
    jr nc, .afterRight
    cp $08
    jr nc, .setRight
    ld de, $c12a
    add a, e
    ld e, a
    ld a, [de]
    cp $00
    jr z, .afterRight

.setRight:
    set 2, c

.afterRight:
    ld a, [$C6CF]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    cp $80
    jr nc, .afterDownRight
    cp $08
    jr nc, .setDownRight
    ld de, $c12a
    add a, e
    ld e, a
    ld a, [de]
    cp $00
    jr z, .afterDownRight

.setDownRight:
    set 1, c

.afterDownRight:
    dec hl
    ld a, [hl]
    cp $80
    ret nc

    cp $08
    jr nc, .setDown
    ld de, $c12a
    add a, e
    ld e, a
    ld a, [de]
    cp $00
    ret z

.setDown:
    set 0, c
    ret
