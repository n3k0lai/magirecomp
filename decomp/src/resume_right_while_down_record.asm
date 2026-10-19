; Bank 1 at $55CD. PlantScriptOnRightWhileDown stores this address as
; the record-head word. rROMB0 is left alone. HL is the cell the caller
; left; this routine does not set it.
;
; StepCell82EveryFourthFrame runs first, then $5DE1, still INCBIN. A is
; the $c9a3 byte, the copy of wButtonsHeld FinishFrame writes. Bit 4 is
; right, bit 6 is up, and bit 7 is down, from the high nibble ReadJoypad
; stores. What bit 1 means is still unknown.
;
; Right clear plants hScriptPtr with ScriptPtr5131 (3-byte absolute
; stores, low at $FFA2) and jumps to $5DFD. $5131 is still INCBIN in
; this bank.
;
; Right held on an even hMainLoopCounter skips the vertical store and
; the bit-1 test. On an odd count, up stores $FF at the Y step,
; wClearedOnRecordLoad + 1, and down stores $01 there. Bit 1 set then
; jumps to $53A5, still INCBIN.
;
; The cell at HL then changes that Y step by one: $AC decrements it and
; $AD increments it. Any other cell leaves it. What those two cells are
; is still unknown.
;
; SaveStepThenApplyOrDispatch in bank 5 runs through CallBankedHL, then
; StageThirdScriptFromMarkedCell and NudgeCameraPastFollowEdge. A
; nonzero X step at wClearedOnRecordLoad calls
; StepCell82EveryFourthFrame again. A zero X step calls $4C1D, still
; INCBIN. Control then jumps to CommitScriptAndRecordHead.
;
; hScriptPtr is the name from reset.asm. hMainLoopCounter is the name
; from main_loop.asm. wButtonsHeld is the name from read_joypad.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; CallBankedHL is the name from call_hl_in_bank.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; ScriptPtr5131 is the EQU in right_held_from_bit4.asm.

ResumeRightWhileDownRecord::
    call StepCell82EveryFourthFrame
    call $5de1
    ld a, [$c9a3]
    bit 4, a
    jr nz, .rightHeld
    ld a, LOW(ScriptPtr5131)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr5131)
    ld [hScriptPtr + 1], a
    jp $5dfd

.rightHeld:
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
    jp nz, $53a5

.cellBias:
    ld a, [hl]
    cp $ac
    jr z, .cellAC
    cp $ad
    jr nz, .afterBias
    ld a, [wClearedOnRecordLoad + 1]
    inc a
    ld [wClearedOnRecordLoad + 1], a
    jr .afterBias

.cellAC:
    ld a, [wClearedOnRecordLoad + 1]
    dec a
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
    call z, $4c1d
    jp CommitScriptAndRecordHead
