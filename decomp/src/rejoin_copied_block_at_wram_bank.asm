; Bank 4 at $5A52. RefreshFrame runs, then TurnOffLCD, and control joins
; StageCopiedBlockWindow at $59BD, where WRAM bank 6 is stored at
; wCurrentWRAMBank and selected with ldh [rSVBK]. That join is the
; instruction `ld a, COPIED_WRAM_BANK` in stage_copied_block_window.asm.
; It has no label, so the jump uses the address. The bytes before it
; are an unconditional jump, so this path is a separate entry.
;
; This bank stays mapped. The routine does not write rROMB0.
; RefreshFrame and TurnOffLCD are already source.

; WRAM-bank select inside StageCopiedBlockWindow. Still unlabeled there.
DEF StageCopiedBlockWRAMBank EQU $59BD

RejoinCopiedBlockAtWRAMBank::
    call RefreshFrame
    call TurnOffLCD
    jp StageCopiedBlockWRAMBank
