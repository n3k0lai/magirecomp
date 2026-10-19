; Bank 1 at $61DE. PlantDownRecordHead61DE writes this address as the
; record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs the script already in the record
; and points HL at the map cell. A is the $c9a3 byte, the copy of
; wButtonsHeld FinishFrame writes. Bit 7 is down, bit 5 is left, and
; bit 4 is right, from the high nibble ReadJoypad stores.
;
; Down clear plants hScriptPtr with $7846 (3-byte form, low at $FFA2)
; and jumps to PlantHandlerAndHead6167. $7846 is a script address in
; the bank the planter stored at hScriptBank. What that script does is
; still unknown.
;
; Down still held with left jumps to PlantLeftWhileUpRecord. Down still
; held with right jumps to PlantRightWhileUpRecord.
;
; Down alone runs SaveStepThenApplyOrDispatch in bank 5 through
; CallBankedHL, then StageThirdScriptFromMarkedCell and
; NudgeCameraPastFollowEdge. A zero Y step at wClearedOnRecordLoad + 1
; calls DispatchCellBelowOnButtonA. Control then jumps to
; CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. wButtonsHeld is the name from
; read_joypad.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. CallBankedHL is the name from
; call_hl_in_bank.asm. PlantDownRecordHead61DE is the label in
; plant_down_record_head_61de.asm.

; Script planted at hScriptPtr when down is clear.
DEF ScriptPtr7846 EQU $7846

ResumePlantedHead61DE::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 7, a
    jp nz, .downHeld
    ld a, LOW(ScriptPtr7846)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr7846)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHead6167

.downHeld:
    bit 5, a
    jr z, .notLeft
    jp PlantLeftWhileUpRecord

.notLeft:
    bit 4, a
    jr z, .downOnly
    jp PlantRightWhileUpRecord

.downOnly:
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [wClearedOnRecordLoad + 1]
    and a
    call z, DispatchCellBelowOnButtonA
    jp CommitScriptRecord

ResumePlantedHead61DEEnd:
