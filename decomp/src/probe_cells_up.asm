; Bank 5 at $6B31. Word 6 of the table at $651E. SaveStepThenApplyOrDispatch
; calls it through JumpHL when the step class is 6: the Y step at $C6D3
; crosses a cell and is negative (up), and the X step at $C6D2 does
; not cross a cell.
;
; C comes back as occupancy bits around hMapCellPointer. Bit 2 is the
; cell one row before the pointer (up). The row step is the map stride
; at $C6CF, which ApplyFineYDelta treats as bytes per row. hObjectFineX
; ($FF8F) then picks the other two bits, and those two are always set
; together. Fine X of exactly $08 sets bit 1 and bit 0 without another
; read. Fine X below $08 steps one byte back and tests that cell, the
; up-left neighbor. Fine X above $08 steps one byte back and then two
; bytes forward, and tests that cell, the up-right neighbor. A cell
; byte of $80 or more leaves the bits clear. A byte of $08 through $7F
; sets them. A byte under $08 sets them only when $C12A plus that byte
; is nonzero. $C12A is the eight-byte pattern WriteC12APatternBank5
; stores. C is 0 on entry, so unset bits stay clear.
;
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; hObjectFineX is the name from queue_sprite_list.asm.
; This routine does not write rROMB0 and does not call out.

ProbeCellsUp::
    ld a, [hMapCellPointer + 1]
    ld h, a
    ld a, [hMapCellPointer]
    ld l, a
    ld c, $00
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
    jr nc, .afterUp
    cp $08
    jr nc, .setUp
    ld de, $c12a
    add a, e
    ld e, a
    ld a, [de]
    cp $00
    jr z, .afterUp

.setUp:
    set 2, c

.afterUp:
    ld a, [hObjectFineX]
    cp $08
    jr nz, .fineXNotMid
    set 1, c
    set 0, c
    ret

.fineXNotMid:
    jr c, .probeUpLeft
    dec hl
    jr .probeUpRight

.probeUpLeft:
    dec hl
    ld a, [hl]
    cp $80
    ret nc

    cp $08
    jr nc, .setUpLeftPair
    ld de, $c12a
    add a, e
    ld e, a
    ld a, [de]
    cp $00
    ret z

.setUpLeftPair:
    set 1, c
    set 0, c
    ret

.probeUpRight:
    inc hl
    inc hl
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
