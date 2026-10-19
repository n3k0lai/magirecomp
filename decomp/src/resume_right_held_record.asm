; Bank 1 at $5A74. PlantRightFromDirectionRecord stores this address
; as the record-head word. rROMB0 is left alone.
;
; ResumeDownRecordHead and the head-03 path plant hScriptPtr with $5A9A
; when a cell is $00. $5A9A is the low byte of `ld [wClearedOnRecordLoad], a`
; below, not its own instruction. Entered there, those bytes are
; `jp nc, $7BC6`.
;
; ReloadRecordRunScriptPointCell runs first. On an even
; hMainLoopCounter (bit 0 clear) the button test is skipped and the
; step bytes stay as they are. On an odd pass, A is the $c9a3 byte, the
; copy of wButtonsHeld written by FinishFrame. Bit 4 is right. Right
; clear jumps to $5B13, still INCBIN.
;
; Right held stores $01 at the X step wClearedOnRecordLoad. Up (bit 6)
; stores $FF at the Y step, down (bit 7) stores $01, and neither stores
; $00.
;
; SaveStepThenApplyOrDispatch in bank 5 runs through CallBankedHL.
; StageThirdScriptFromMarkedCell, NudgeCameraPastFollowEdge, and
; StepCell82EveryFourthFrame follow. DispatchCellRightOnButtonA reads
; the cell one column right. Control then jumps to CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. hMainLoopCounter is the name
; from main_loop.asm. wButtonsHeld is the name from read_joypad.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; CallBankedHL is the name from call_hl_in_bank.asm.
; LeftHeldClearTail is the EQU in resume_left_held_record.asm.

ResumeRightHeldRecord::
    call ReloadRecordRunScriptPointCell
    ldh a, [hMainLoopCounter]
    and $01
    jr z, .apply
    ld a, [$c9a3]
    bit 4, a
    jr nz, .rightHeld
    jp LeftHeldClearTail

.rightHeld:
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
    ld a, $01
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
    call DispatchCellRightOnButtonA
    jp CommitScriptRecord
