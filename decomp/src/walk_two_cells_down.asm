; Bank 1 at $4DB4. The first of the four two-cell walks in this hole.
; rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs first. Bank 5 at $682D
; (SaveStepThenApplyOrDispatch) runs through CallBankedHL, then
; NudgeCameraPastFollowEdge. The little-endian word $5D81 is written
; at hRecordHead + 1. $5D81 is still INCBIN in this bank.
;
; WRAM bank 3 is stored at wCurrentWRAMBank and selected with rSVBK.
; HL is the little-endian word at hMapCellPointer plus one map row
; ($C847, wMapRowStride from draw_metatile_window.asm). C takes that
; near-cell byte and the pointer is pushed. HL then advances one more
; row, the far cell. Bank 5 is selected and that byte is compared to
; $81. Any other value jumps to RejectFarCellQueueSound.
;
; A match builds the one-step position in DE: hObjectCellX, and
; hObjectCellY plus one. That pair is pushed, E is incremented to the
; two-step row, and control jumps to StampTwoStepCells. On entry there,
; DE is the two-step position, HL is the far cell, C is the near cell's
; bank-3 byte, and the near pointer is under the one-step position.
;
; hRecordHead is the name from write_record_head.asm. hMapCellPointer
; is the name from pick_map_cell_from_div.asm. hObjectCellX and
; hObjectCellY are the names from queue_sprite_list.asm.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; CELL_MAP_BANK and CELL_MARK_BANK are the names from
; stamp_two_step_cells.asm.

; Planted at hRecordHead + 1. Still INCBIN in this bank.
DEF HeadWord5D81 EQU $5D81

; Far cell in WRAM bank 5 that this walk accepts.
DEF ACCEPTED_FAR_CELL EQU $81

WalkTwoCellsDown::
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
    ld e, a
    ld d, $00
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
    inc a
    ld e, a
    push de
    inc e
    jp StampTwoStepCells

WalkTwoCellsDownEnd:
