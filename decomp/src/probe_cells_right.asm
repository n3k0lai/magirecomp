; Bank 5 at $6AB1. Word 5 of the table at $651E. SaveStepThenApplyOrDispatch
; calls it through JumpHL when the step class is 5: the X step at $C6D2
; crosses a cell and is positive (right), and the Y step at $C6D3 does
; not cross a cell.
;
; C comes back as occupancy bits around hMapCellPointer. Bit 2 is the
; cell one byte after the pointer (right). hObjectFineY ($FF90) then
; picks the other two bits, and those two are always set together.
; Fine Y of exactly $08 sets bit 1 and bit 0 without another read.
; Fine Y below $08 steps back by the map stride at $C6CF (bytes per row,
; as ApplyFineYDelta uses it) and tests that cell, the up-right neighbor.
; Fine Y above $08 forms the same up-right address, adds the stride
; twice, and tests that cell, the down-right neighbor. A cell byte of
; $80 or more leaves the bits clear. A byte of $08 through $7F sets
; them. A byte under $08 sets them only when $C12A plus that byte is
; nonzero. $C12A is the eight-byte pattern WriteC12APatternBank5 stores.
; C is 0 on entry, so unset bits stay clear.
;
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; hObjectFineY is the name from queue_sprite_list.asm.
; This routine does not write rROMB0 and does not call out.

ProbeCellsRight::
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
    ld a, [hObjectFineY]
    cp $08
    jr nz, .fineYNotMid
    set 1, c
    set 0, c
    ret

.fineYNotMid:
    jr c, .probeUpRight
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
    jr .probeDownRight

.probeUpRight:
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
    ld a, [hl]
    cp $80
    ret nc

    cp $08
    jr nc, .setUpRightPair
    ld de, $c12a
    add a, e
    ld e, a
    ld a, [de]
    cp $00
    ret z

.setUpRightPair:
    set 1, c
    set 0, c
    ret

.probeDownRight:
    ld a, [$C6CF]
    ld e, a
    ld d, $00
    add hl, de
    add hl, de
    ld a, [hl]
    cp $80
    ret nc

    cp $08
    jr nc, .setDownRightPair
    ld de, $c12a
    add a, e
    ld e, a
    ld a, [de]
    cp $00
    ret z

.setDownRightPair:
    set 1, c
    set 0, c
    ret
