; Bank 1 at $623F. PlantLeftWhileUpRecord writes this address as the
; record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs the script already in the record
; and points HL at the map cell. A is the $c9a3 byte, the copy of
; wButtonsHeld FinishFrame writes. Bit 5 is left, bit 6 is up, and
; bit 7 is down, from the high nibble ReadJoypad stores.
;
; Left clear plants hScriptPtr with $7852 (3-byte form, low at $FFA2)
; and jumps to PlantHandlerAndHead6167. $7852 is a script address in
; the bank the planter stored at hScriptBank. What that script does is
; still unknown.
;
; Left held on an even hMainLoopCounter skips the vertical store. On
; an odd count, up stores $FF at the Y step, wClearedOnRecordLoad + 1,
; and down stores $01 there. Neither leaves that byte as it is.
;
; SaveStepThenApplyOrDispatch in bank 5 runs through CallBankedHL, then
; StageThirdScriptFromMarkedCell and NudgeCameraPastFollowEdge. A zero
; X step at wClearedOnRecordLoad calls DispatchCellLeftOnButtonA.
; Control then jumps to CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. hMainLoopCounter is the name
; from main_loop.asm. wButtonsHeld is the name from read_joypad.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; CallBankedHL is the name from call_hl_in_bank.asm.
; PlantLeftWhileUpRecord is the label in plant_left_while_up_record.asm.

; Script planted at hScriptPtr when left is clear.
DEF ScriptPtr7852 EQU $7852

ResumePlantedLeftWhileUpRecord::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 5, a
    jr nz, .leftHeld
    ld a, LOW(ScriptPtr7852)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr7852)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHead6167

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
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [wClearedOnRecordLoad]
    and a
    call z, DispatchCellLeftOnButtonA
    jp CommitScriptRecord

ResumePlantedLeftWhileUpRecordEnd:
