; Bank 1 at $5798. PlantDownIdleScript stores this address as the
; record-head word. rROMB0 is left alone.
;
; This calls $5DE1, still INCBIN, then SetC12AAndClearC12B. A is the
; copy of wButtonsHeld at $c9a3. Bit 7 is down and bit 5 is left, bit 4
; is right, from the high nibble ReadJoypad stores.
;
; Down clear plants hScriptPtr with $51B3 (low at $FFA2, high at $FFA3,
; the 3-byte form) and jumps to $56C9, still INCBIN. Left while down is
; held jumps to $57F9. Right while down is held jumps to $5888. Both are
; still INCBIN in this bank.
;
; Down alone calls AddCellDirectionStep, calls $682D in bank 5 through
; CallBankedHL, stages the third script from the marked cell, and nudges
; the camera past the follow edge. $C6D1 zero, or a nonzero Y step at
; wClearedOnRecordLoad + 1, jumps to CommitScriptRecord. Otherwise
; PointAtCellOneRowDown selects the cell below. A nonzero cell byte
; takes that same exit. A zero cell calls $56B7, still INCBIN, the
; inverse that clears $C12A and stores $FF at $C12B. hScriptPtr then
; becomes $5A9A and control jumps to PlantHandlerAndHeadWord.
;
; hScriptPtr is the name from reset.asm. wButtonsHeld is the name from
; read_joypad.asm. wClearedOnRecordLoad is the name from
; load_record_head.asm. $c9a3, $C6D1, $51B3, and $5A9A have no names.

; Script planted when down is no longer held. Still uncovered.
DEF ScriptPtr51B3 EQU $51B3

; Script planted when the cell one row down is $00. Still uncovered.
DEF ScriptPtr5A9A EQU $5A9A

ResumeDownRecordHead::
    call $5de1
    call SetC12AAndClearC12B
    ld a, [$c9a3]
    bit 7, a
    jp nz, .down_held
    ld a, LOW(ScriptPtr51B3)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr51B3)
    ld [hScriptPtr + 1], a
    jp $56c9

.down_held:
    bit 5, a
    jr z, .not_left
    jp $57f9

.not_left:
    bit 4, a
    jr z, .down_only
    jp $5888

.down_only:
    call AddCellDirectionStep
    ld hl, $682d
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [$c6d1]
    and a
    jp z, CommitScriptRecord
    ld a, [wClearedOnRecordLoad + 1]
    and a
    jp nz, CommitScriptRecord
    call PointAtCellOneRowDown
    ld a, [hl]
    cp $00
    jp nz, CommitScriptRecord
    call $56b7
    ld a, LOW(ScriptPtr5A9A)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr5A9A)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
