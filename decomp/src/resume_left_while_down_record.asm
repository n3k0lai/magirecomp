; Bank 1 at $5534. PlantScriptOnLeftWhileDown stores this address as
; the record-head word. rROMB0 is left alone. HL is the cell the caller
; left; this routine does not set it.
;
; StepCell82EveryFourthFrame runs first, then $5DE1, still INCBIN. A is
; the $c9a3 byte, the copy of wButtonsHeld FinishFrame writes. Bit 5 is
; left, bit 6 is up, and bit 7 is down, from the high nibble ReadJoypad
; stores. What bit 1 means is still unknown.
;
; Left clear plants hScriptPtr with $50FB (3-byte absolute stores, low
; at $FFA2) and jumps to $5DFD. $50FB is still INCBIN in this bank.
;
; Left held on an even hMainLoopCounter skips the vertical store and
; the bit-1 test. On an odd count, up stores $FF at the Y step,
; wClearedOnRecordLoad + 1, and down stores $01 there. Bit 1 set then
; jumps to $5313, still INCBIN.
;
; The cell at HL then biases that Y step by one: $AC increments it and
; $AD decrements it. Any other cell leaves it. What those two cells are
; is still unknown.
;
; SaveStepThenApplyOrDispatch in bank 5 runs through CallBankedHL, then
; StageThirdScriptFromMarkedCell and NudgeCameraPastFollowEdge. A
; nonzero X step at wClearedOnRecordLoad calls
; StepCell82EveryFourthFrame again. A zero X step calls $4BCC, still
; INCBIN. Control then jumps to CommitScriptAndRecordHead.
;
; hScriptPtr is the name from reset.asm. hMainLoopCounter is the name
; from main_loop.asm. wButtonsHeld is the name from read_joypad.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; CallBankedHL is the name from call_hl_in_bank.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.

; Script planted when left is no longer held. Still INCBIN.
DEF ScriptPtr50FB EQU $50FB

ResumeLeftWhileDownRecord::
    call StepCell82EveryFourthFrame
    call $5de1
    ld a, [$c9a3]
    bit 5, a
    jr nz, .leftHeld
    ld a, LOW(ScriptPtr50FB)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr50FB)
    ld [hScriptPtr + 1], a
    jp $5dfd

.leftHeld:
    ldh a, [hMainLoopCounter]
    and $01
    jp z, .cellBias
    ld a, [$c9a3]
    bit 6, a
    jr z, .notUp
    ld a, $ff
    ld [wClearedOnRecordLoad + 1], a
    jr .afterVertical

.notUp:
    bit 7, a
    jr z, .afterVertical
    ld a, $01
    ld [wClearedOnRecordLoad + 1], a

.afterVertical:
    ld a, [$c9a3]
    bit 1, a
    jp nz, $5313

.cellBias:
    ld a, [hl]
    cp $ac
    jr z, .cellAC
    cp $ad
    jr nz, .afterBias
    ld a, [wClearedOnRecordLoad + 1]
    dec a
    ld [wClearedOnRecordLoad + 1], a
    jr .afterBias

.cellAC:
    ld a, [wClearedOnRecordLoad + 1]
    inc a
    ld [wClearedOnRecordLoad + 1], a

.afterBias:
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [wClearedOnRecordLoad]
    and a
    jr z, .xStepZero
    call StepCell82EveryFourthFrame

.xStepZero:
    ld a, [wClearedOnRecordLoad]
    and a
    call z, $4bcc
    jp CommitScriptAndRecordHead
