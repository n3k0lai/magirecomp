; Bank 1 at $4D3C. The four two-cell walks that follow this in the
; hole jump here when the far cell in WRAM bank 5 is $81. Each walk has
; pushed the near-cell pointer, then the one-step column and row in DE.
; On entry DE is the two-step position, HL is the far cell, C is the
; near cell's bank-3 byte, and WRAM bank 5 is selected.
;
; $17 is queued in $C921. That address is wSoundSlotA, defined later in
; select_sound_command.asm. The two-step position and the far address are
; saved in wScriptCellPos and wScriptCellAddr, and again at $C9A9 and
; $C9AB. Those two copies have no name yet. Bank 5 at the far cell
; becomes $09. Bank 3 there becomes the saved near-cell byte. CallBankedHL
; maps bank 7 and runs CopyStampedMapCell.
;
; The one-step position and the near-cell pointer are popped and saved
; the same way. The near address is also stored at $C9A7, still unnamed.
; Bank 5 at the near cell becomes $81 and bank 3 becomes $FD, then
; CopyStampedMapCell runs again. Bit 3 of $FFAA is set. What that bit
; means is still unknown. Control jumps to CommitScriptRecord, whose ret
; returns to the walk's caller. The push bc keeps that return under the
; two pointers until both are popped.
;
; wScriptCellPos and wScriptCellAddr are the names from
; opcode_03_continue.asm. wCurrentWRAMBank and rSVBK are the names from
; timer_overflow.asm. CallBankedHL is the name from call_hl_in_bank.asm.
; CopyStampedMapCell is the name from copy_stamped_map_cell.asm.

; Sound id stored at $C921 before the first stamp.
DEF TWO_STEP_SOUND EQU $17

; Value written to the far cell in WRAM bank 5.
DEF FAR_CELL_BANK5 EQU $09

; Value written to the near cell in WRAM bank 5, then in bank 3.
DEF NEAR_CELL_BANK5 EQU $81
DEF NEAR_CELL_BANK3 EQU $FD

; WRAM bank of the $81 / $09 marks, then the map-byte bank.
DEF CELL_MARK_BANK EQU $05
DEF CELL_MAP_BANK EQU $03

; ROM bank CopyStampedMapCell lives in.
DEF STAMP_ROM_BANK EQU $07

StampTwoStepCells::
    ld a, TWO_STEP_SOUND
    ld [$c921], a
    push bc
    ld a, d
    ld [wScriptCellPos + 1], a
    ld a, e
    ld [wScriptCellPos], a
    ld a, d
    ld [$c9a9], a
    ld a, e
    ld [$c9aa], a
    ld a, h
    ld [wScriptCellAddr + 1], a
    ld a, l
    ld [wScriptCellAddr], a
    ld a, h
    ld [$c9ac], a
    ld a, l
    ld [$c9ab], a
    ld a, FAR_CELL_BANK5
    ld [hl], a
    ld a, CELL_MAP_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld [hl], c
    ld hl, CopyStampedMapCell
    ld e, STAMP_ROM_BANK
    call CallBankedHL
    pop bc
    pop de
    pop hl
    ld a, d
    ld [wScriptCellPos + 1], a
    ld a, e
    ld [wScriptCellPos], a
    ld a, h
    ld [wScriptCellAddr + 1], a
    ld a, l
    ld [wScriptCellAddr], a
    ld a, h
    ld [$c9a8], a
    ld a, l
    ld [$c9a7], a
    ld a, CELL_MARK_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, NEAR_CELL_BANK5
    ld [hl], a
    ld a, CELL_MAP_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, NEAR_CELL_BANK3
    ld [hl], a
    ld hl, CopyStampedMapCell
    ld e, STAMP_ROM_BANK
    call CallBankedHL
    ld hl, $ffaa
    set 3, [hl]
    jp CommitScriptRecord

StampTwoStepCellsEnd:
