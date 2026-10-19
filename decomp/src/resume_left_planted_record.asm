; Bank 1 at $5C52. PlantLeftRecordAndBank stores this address as the
; record-head word. rROMB0 is left alone.
;
; StepCell82EveryFourthFrame runs, then ReloadRecordRunScriptPointCell.
; A is the $c9a3 byte, the copy of wButtonsHeld FinishFrame writes.
; Bit 5 is left. Left clear plants hScriptPtr with $5BDF (low at $FFA2,
; high at $FFA3, the 3-byte form) and jumps to PlantDownBit7ClearHead.
; $5BDF is still INCBIN in this bank.
;
; Left held reads hMainLoopCounter. An even pass (bit 0 clear) leaves
; the step bytes alone. An odd pass tests up (bit 6) and down (bit 7).
; Up stores $FF at the Y step, wClearedOnRecordLoad + 1. Down stores
; $01 there. Neither leaves that byte as it is.
;
; AddCellDirectionStep folds the map cell into the step bytes.
; SaveStepThenApplyOrDispatch in bank 5 runs through CallBankedHL.
; StageThirdScriptFromMarkedCell and NudgeCameraPastFollowEdge follow.
; A zero X step at wClearedOnRecordLoad calls DispatchCellLeftOnButtonA.
; Control then jumps to CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. hMainLoopCounter is the name
; from main_loop.asm. wButtonsHeld is the name from read_joypad.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; CallBankedHL is the name from call_hl_in_bank.asm.

; Script planted when left is clear. Still INCBIN in this bank.
DEF ScriptPtr5BDF EQU $5BDF

ResumeLeftPlantedRecord::
    call StepCell82EveryFourthFrame
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 5, a
    jr nz, .leftHeld
    ld a, LOW(ScriptPtr5BDF)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr5BDF)
    ld [hScriptPtr + 1], a
    jp PlantDownBit7ClearHead

.leftHeld:
    ldh a, [hMainLoopCounter]
    and $01
    jp z, .apply
    ld a, [$c9a3]
    bit 6, a
    jr z, .notUp
    ld a, $ff
    ld [wClearedOnRecordLoad + 1], a
    jr .apply

.notUp:
    bit 7, a
    jr z, .apply
    ld a, $01
    ld [wClearedOnRecordLoad + 1], a

.apply:
    call AddCellDirectionStep
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [wClearedOnRecordLoad]
    and a
    call z, DispatchCellLeftOnButtonA
    jp CommitScriptRecord
