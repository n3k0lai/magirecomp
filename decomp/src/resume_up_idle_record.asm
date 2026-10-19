; Bank 1 at $5936. PlantUpIdleScript writes this address as the
; record-head word. rROMB0 is left alone.
;
; $5DE1, still INCBIN, runs first. SetC12AAndClearC12B then stores $FF
; at $C12A and $00 at $C12B. A is the $c9a3 byte, the copy of $c931
; written by FinishFrame. Bit 6 is up.
;
; Up clear plants hScriptPtr with $51A7 (3-byte form, low at $FFA2) and
; jumps to $56C9. $51A7 sits inside CountCellRun. What the script engine
; does with that address is still unknown. Bit 5 set jumps to $57F9.
; Bit 4 set jumps to $5888. Those three targets are still INCBIN. What
; bits 4 and 5 mean is still unknown.
;
; Otherwise this adds the cell direction step, calls bank 5 at $682D
; through CallBankedHL, stages the third script, and nudges the camera.
; A zero byte at $C6D1, or a nonzero live Y step at $C6D3, jumps to
; CommitScriptAndRecordHead. $C6D1 is the Y step copied by
; SaveStepThenApplyOrDispatch. $C6D3 is wClearedOnRecordLoad + 1.
;
; $4D13, still INCBIN, leaves a cell in HL. A nonzero cell takes the
; same commit exit. A zero cell calls $56B7 (the inverse of
; SetC12AAndClearC12B, still INCBIN), plants hScriptPtr with $5A5B,
; and jumps to PlantHandlerAndHeadWord. $5A5B is still INCBIN.
;
; hScriptPtr is the name from reset.asm. CallBankedHL is the name from
; call_hl_in_bank.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. CommitScriptAndRecordHead is the EQU in
; plant_handler_and_head_word.asm.

; Planted as hScriptPtr when up is clear. Inside CountCellRun.
DEF ScriptPtr51A7 EQU $51A7

; Planted as hScriptPtr when the cell at HL is zero. Still INCBIN.
DEF ScriptPtr5A5B EQU $5A5B

ResumeUpIdleRecord::
    call $5de1
    call SetC12AAndClearC12B
    ld a, [$c9a3]
    bit 6, a
    jr nz, .upHeld
    ld a, LOW(ScriptPtr51A7)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr51A7)
    ld [hScriptPtr + 1], a
    jp $56c9

.upHeld:
    bit 5, a
    jr z, .notBit5
    jp $57f9

.notBit5:
    bit 4, a
    jr z, .noSideBit
    jp $5888

.noSideBit:
    call AddCellDirectionStep
    ld hl, $682d
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [$c6d1]
    and a
    jp z, CommitScriptAndRecordHead
    ld a, [wClearedOnRecordLoad + 1]
    and a
    jp nz, CommitScriptAndRecordHead
    call $4d13
    ld a, [hl]
    cp $00
    jp nz, CommitScriptAndRecordHead
    call $56b7
    ld a, LOW(ScriptPtr5A5B)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr5A5B)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
