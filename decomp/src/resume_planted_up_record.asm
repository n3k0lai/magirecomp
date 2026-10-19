; Bank 1 at $631F. PlantUpRecordAndBank writes this address as the
; record-head word for the up path. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs first. A is the $c9a3 byte, the
; copy of wButtonsHeld FinishFrame writes. Bit 6 is up, bit 5 is left,
; and bit 4 is right.
;
; Up clear plants hScriptPtr with $783A (3-byte form, low at $FFA2) and
; jumps to $6154. $6154 and $783A are still INCBIN. What the script
; engine does with $783A is still unknown. Up with left jumps to $621C.
; Up with right jumps to $628C. Both planters are still INCBIN in this
; bank.
;
; Otherwise bank 5 at SaveStepThenApplyOrDispatch runs through
; CallBankedHL, the third script is staged, and the camera is nudged
; past the follow edge. A zero Y step at wClearedOnRecordLoad + 1 calls
; DispatchCellAboveOnButtonA. Control then jumps to CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. wButtonsHeld is the name from
; read_joypad.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. ReloadRecordRunScriptPointCell,
; SaveStepThenApplyOrDispatch, CallBankedHL,
; StageThirdScriptFromMarkedCell, NudgeCameraPastFollowEdge,
; DispatchCellAboveOnButtonA, and CommitScriptRecord are already source.
; PlantUpRecordAndBank is the label in plant_up_record_and_bank.asm.

; Planted as hScriptPtr when up is clear. Still INCBIN.
DEF ScriptPtr783A EQU $783A

ResumePlantedUpRecord::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 6, a
    jr nz, .upHeld
    ld a, LOW(ScriptPtr783A)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr783A)
    ld [hScriptPtr + 1], a
    jp $6154

.upHeld:
    bit 5, a
    jr z, .notLeft
    jp $621c

.notLeft:
    bit 4, a
    jr z, .noSide
    jp $628c

.noSide:
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [wClearedOnRecordLoad + 1]
    and a
    call z, DispatchCellAboveOnButtonA
    jp CommitScriptRecord

ResumePlantedUpRecordEnd:
