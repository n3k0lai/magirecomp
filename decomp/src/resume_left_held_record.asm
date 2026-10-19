; Bank 1 at $5A12. The planter at $59F3, still INCBIN, stores this
; address as the record-head word. rROMB0 is left alone.
;
; ResumeRightRecordHead plants hScriptPtr with $5A21 when the cell one
; column right is $00. $5A21 is the displacement of the `jr nz` after
; `bit 5, a` below, not its own instruction. Entered there, that byte is
; `inc bc` and falls into the `jp` to $5B13.
;
; ReloadRecordRunScriptPointCell runs first. On an even
; hMainLoopCounter (bit 0 clear) the button test is skipped and the
; step bytes stay as they are. On an odd pass, A is the $c9a3 byte, the
; copy of wButtonsHeld written by FinishFrame. Bit 5 is left. Left clear
; jumps to $5B13, still INCBIN.
;
; Left held stores $FF at the X step wClearedOnRecordLoad. Up (bit 6)
; stores $FF at the Y step, down (bit 7) stores $01, and neither stores
; $00.
;
; SaveStepThenApplyOrDispatch in bank 5 runs through CallBankedHL.
; StageThirdScriptFromMarkedCell, NudgeCameraPastFollowEdge, and
; StepCell82EveryFourthFrame follow. $4BCC, still INCBIN, is the hole
; just before DispatchCellRightOnButtonA. Control then jumps to
; CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. hMainLoopCounter is the name
; from main_loop.asm. wButtonsHeld is the name from read_joypad.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; CallBankedHL is the name from call_hl_in_bank.asm.

; Taken when left is clear, and also the instruction after the byte at
; $5A21. Still INCBIN.
DEF LeftHeldClearTail EQU $5B13

ResumeLeftHeldRecord::
    call ReloadRecordRunScriptPointCell
    ldh a, [hMainLoopCounter]
    and $01
    jr z, .apply
    ld a, [$c9a3]
    bit 5, a
    jr nz, .leftHeld
    jp LeftHeldClearTail

.leftHeld:
    ld e, $00
    bit 6, a
    jr z, .notUp
    ld e, $ff
    jr .storeStep

.notUp:
    bit 7, a
    jr z, .storeStep
    ld e, $01

.storeStep:
    ld a, $ff
    ld [wClearedOnRecordLoad], a
    ld a, e
    ld [wClearedOnRecordLoad + 1], a

.apply:
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    call StepCell82EveryFourthFrame
    call $4bcc
    jp CommitScriptRecord
