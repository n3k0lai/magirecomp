; Bank 1 at $58A7. PlantRightRecordHead writes this address as the
; record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs first. SetC12AAndClearC12B then
; stores $FF at $C12A and $00 at $C12B. A is the $c9a3 byte, the copy of
; wButtonsHeld written by FinishFrame. Bit 4 is right.
;
; Right clear plants hScriptPtr with $519B (3-byte form, low at $FFA2)
; and jumps to PlantHandlerWhenUpClear. $519B sits inside CountCellRun.
; What the script engine does with that address is still unknown.
;
; Right held reads hMainLoopCounter. An even pass (bit 0 clear) skips
; the vertical store. On an odd pass, up (bit 6) stores $FF at the Y
; step wClearedOnRecordLoad + 1, and down (bit 7) stores $01 there.
;
; The body adds the cell direction step, calls bank 5 at
; SaveStepThenApplyOrDispatch through CallBankedHL, stages the third
; script, and nudges the camera. A zero copy of the X step at $C6D0, or
; a still-nonzero live X step at wClearedOnRecordLoad, jumps to
; CommitScriptRecord.
;
; $4CF8, still INCBIN, points HL at the map cell one column right and
; selects WRAM bank 5. A nonzero cell takes the same commit exit. A
; zero cell calls ClearC12AAndSetC12B, plants hScriptPtr with $5A21,
; and jumps to PlantHandlerAndHeadWord. $5A21 is still INCBIN.
;
; hScriptPtr is the name from reset.asm. hMainLoopCounter is the name
; from main_loop.asm. wButtonsHeld is the name from read_joypad.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; CallBankedHL is the name from call_hl_in_bank.asm.

; Planted as hScriptPtr when right is clear. Inside CountCellRun.
DEF RightClearScript EQU $519B

; Planted as hScriptPtr when the cell one column right is zero.
; Still INCBIN.
DEF RightCellScript EQU $5A21

ResumeRightRecordHead::
    call ReloadRecordRunScriptPointCell
    call SetC12AAndClearC12B
    ld a, [$c9a3]
    bit 4, a
    jr nz, .rightHeld
    ld a, LOW(RightClearScript)
    ld [hScriptPtr], a
    ld a, HIGH(RightClearScript)
    ld [hScriptPtr + 1], a
    jp PlantHandlerWhenUpClear

.rightHeld:
    ldh a, [hMainLoopCounter]
    and $01
    jp z, .stepRight
    ld a, [$c9a3]
    bit 6, a
    jr z, .notUp
    ld a, $ff
    ld [wClearedOnRecordLoad + 1], a
    jr .stepRight

.notUp:
    bit 7, a
    jr z, .stepRight
    ld a, $01
    ld [wClearedOnRecordLoad + 1], a

.stepRight:
    call AddCellDirectionStep
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [$c6d0]
    and a
    jp z, CommitScriptRecord
    ld a, [wClearedOnRecordLoad]
    and a
    jp nz, CommitScriptRecord
    call $4cf8
    ld a, [hl]
    cp $00
    jp nz, CommitScriptRecord
    call ClearC12AAndSetC12B
    ld a, LOW(RightCellScript)
    ld [hScriptPtr], a
    ld a, HIGH(RightCellScript)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
