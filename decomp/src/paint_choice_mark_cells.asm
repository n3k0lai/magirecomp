; Bank 3 at $65AF. MarkWindowChoiceCells plants this as wCallback
; when the $CD69 result is 1, then RefreshFrame runs it.
;
; VRAM bank 0 is selected with the 3-byte store. Tile $96 is written
; through wChoiceOtherCell. When wChoiceResultCell is not zero, tile
; $80 is written through that pointer. wCallback is restored to
; IdleCallback before the return.
;
; This routine does not write rROMB0 and does not call out.
; rVBK and WINDOW_TILE are the names from setup_window.asm.
; WINDOW_MARK_TILE is the name from paint_window_indexed_rows.asm.
; wCallback and IdleCallback are the names from default_state.asm.
; wChoiceOtherCell and wChoiceResultCell are the names from
; mark_window_choice_cells.asm.

PaintChoiceMarkCells::
    xor a
    ld [rVBK], a
    ld hl, wChoiceOtherCell
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld [hl], WINDOW_MARK_TILE
    ld hl, wChoiceResultCell
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    or l
    jr z, .restoreIdle

    ld [hl], WINDOW_TILE

.restoreIdle:
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
