; Bank 1 at $5AD6. PlantUpFromDirectionRecord stores this address as
; the record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs first. On an even
; hMainLoopCounter (bit 0 clear) the button test is skipped and the
; step bytes stay as they are. On an odd pass, A is the $c9a3 byte, the
; copy of wButtonsHeld written by FinishFrame. Bit 6 is up. Up clear
; jumps to PlantDirectionDispatchHead.
;
; Up held with left (bit 5) jumps to PlantLeftFromDirectionRecord. Up
; held with right (bit 4) jumps to PlantRightFromDirectionRecord. Up
; alone stores $FF at the Y step wClearedOnRecordLoad + 1 and leaves
; the X step alone.
;
; SaveStepThenApplyOrDispatch in bank 5 runs through CallBankedHL.
; StageThirdScriptFromMarkedCell, NudgeCameraPastFollowEdge, and
; StepCell82EveryFourthFrame follow. DispatchCellAboveOnButtonA reads
; the cell one row up. Control then jumps to CommitScriptRecord.
;
; hMainLoopCounter is the name from main_loop.asm. wButtonsHeld is the
; name from read_joypad.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. CallBankedHL is the name from call_hl_in_bank.asm.

ResumeUpHeldRecord::
    call ReloadRecordRunScriptPointCell
    ldh a, [hMainLoopCounter]
    and $01
    jr z, .apply
    ld a, [$c9a3]
    bit 6, a
    jr nz, .upHeld
    jp PlantDirectionDispatchHead

.upHeld:
    bit 5, a
    jr z, .notLeft
    jp PlantLeftFromDirectionRecord

.notLeft:
    bit 4, a
    jr z, .storeStep
    jp PlantRightFromDirectionRecord

.storeStep:
    ld a, $ff
    ld [wClearedOnRecordLoad + 1], a

.apply:
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    call StepCell82EveryFourthFrame
    call DispatchCellAboveOnButtonA
    jp CommitScriptRecord
