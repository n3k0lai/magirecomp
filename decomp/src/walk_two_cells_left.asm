; Bank 1 at $4DFA. The two-cell walk one column left. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs first. Bank 5 at $682D
; (SaveStepThenApplyOrDispatch) runs through CallBankedHL, then
; NudgeCameraPastFollowEdge. The little-endian word $5D81 is written
; at hRecordHead + 1. $5D81 is still INCBIN in this bank.
;
; WRAM bank 3 is stored at wCurrentWRAMBank and selected with rSVBK.
; HL is the little-endian word at hMapCellPointer. Decrementing it once
; lands on the near cell, one column left. C takes that byte and the
; pointer is pushed. HL then steps one more column left, the far cell.
; Bank 5 is selected and that byte is compared to $81. Any other value
; jumps to RejectFarCellQueueSound.
;
; A match builds the one-step position in DE: hObjectCellX minus one,
; and hObjectCellY. That pair is pushed, D is decremented to the
; two-step column, and control jumps to StampTwoStepCells. On entry
; there, DE is the two-step position, HL is the far cell, C is the near
; cell's bank-3 byte, and the near pointer is under the one-step
; position.
;
; Names match walk_two_cells_down.asm.

WalkTwoCellsLeft::
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
    dec hl
    ld c, [hl]
    push hl
    dec hl
    ld a, CELL_MARK_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [hl]
    cp ACCEPTED_FAR_CELL
    jp nz, RejectFarCellQueueSound
    ldh a, [hObjectCellX]
    dec a
    ld d, a
    ldh a, [hObjectCellY]
    ld e, a
    push de
    dec d
    jp StampTwoStepCells

WalkTwoCellsLeftEnd:
