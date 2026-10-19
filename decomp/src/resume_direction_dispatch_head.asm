; Bank 1 at $5B1E. PlantDirectionDispatchHead writes this address as
; the record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs, then A is the copy of
; wButtonsHeld at $c9a3. Bit 4 is right, bit 5 is left, bit 6 is up,
; and bit 7 is down.
;
; Right jumps to PlantRightFromDirectionRecord. Left jumps to the
; planter at $59F3, still INCBIN. Up jumps to the planter at $5AB7,
; still INCBIN. Down jumps to the record at $5996, still INCBIN.
;
; No direction calls NudgeCameraPastFollowEdge, then calls $5E3E,
; still INCBIN. That call returns unless bit 0 of $C9A4 is set. Bit 0
; is A in the pressed-button copy FinishFrame writes from
; wButtonsPressed. When A is pressed it keeps the low two bits of
; hRecordHead and jumps to one of four bank-1 cell entries. Control
; then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; wButtonsHeld and the direction bits are the names from
; read_joypad.asm. wButtonsPressed is the name from main_loop.asm.
; hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in
; plant_handler_and_head_word.asm.

ResumeDirectionDispatchHead::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 4, a
    jp nz, PlantRightFromDirectionRecord
    bit 5, a
    jp nz, $59f3
    bit 6, a
    jp nz, $5ab7
    bit 7, a
    jp nz, $5996
    call NudgeCameraPastFollowEdge
    call $5e3e
    jp CommitScriptAndRecordHead
