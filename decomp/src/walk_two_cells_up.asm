; Bank 1 at $4E7A. The two-cell walk one row up. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs first. Bank 5 at $682D
; (SaveStepThenApplyOrDispatch) runs through CallBankedHL, then
; NudgeCameraPastFollowEdge. The little-endian word $5D81 is written
; at hRecordHead + 1. $5D81 is CopySRAMMarkThenHead5E10 in this bank.
;
; WRAM bank 3 is stored at wCurrentWRAMBank and selected with rSVBK.
; HL is the little-endian word at hMapCellPointer. The byte at $C847
; (wMapRowStride from draw_metatile_window.asm) is negated and
; sign-extended, then added so HL lands on the near cell, one row up.
; C takes that byte and the pointer is pushed. HL then steps one more
; row up, the far cell. Bank 5 is selected and that byte is compared
; to $81. Any other value jumps to RejectFarCellQueueSound.
;
; A match builds the one-step position in DE: hObjectCellX, and
; hObjectCellY minus one. That pair is pushed, E is decremented to the
; two-step row, and control jumps to StampTwoStepCells. On entry there,
; DE is the two-step position, HL is the far cell, C is the near cell's
; bank-3 byte, and the near pointer is under the one-step position.
;
; Names match walk_two_cells_down.asm. HeadWord5D81 and
; ACCEPTED_FAR_CELL are defined in walk_two_cells_down.asm.

WalkTwoCellsUp::
    call ReloadRecordRunScriptPointCell
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call NudgeCameraPastFollowEdge
    ld a, LOW(HeadWord5D81)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5D81)
    ldh [hRecordHead + 2], a
    ld a, CELL_MAP_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld hl, hMapCellPointer
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [$c847]
    cpl
    inc a
    ld e, a
    ld d, $ff
    add hl, de
    ld c, [hl]
    push hl
    add hl, de
    ld a, CELL_MARK_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [hl]
    cp ACCEPTED_FAR_CELL
    jp nz, RejectFarCellQueueSound
    ldh a, [hObjectCellX]
    ld d, a
    ldh a, [hObjectCellY]
    dec a
    ld e, a
    push de
    dec e
    jp StampTwoStepCells

WalkTwoCellsUpEnd:
