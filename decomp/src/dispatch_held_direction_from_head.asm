; Bank 1 at $5E10. CopySRAMMarkThenHead5E10 jumps here after the
; SRAM mark at $A3A3 is copied to $C9A6. PlantDownClearRecordHead also
; plants this address as the record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs, then A is the copy of
; wButtonsHeld at $c9a3. Bit 4 is right, bit 5 is left, bit 6 is up,
; and bit 7 is down.
;
; Right jumps to PlantScriptOnRightWhileDown. Left jumps to
; PlantScriptOnLeftWhileDown. Up jumps to PlantHandlerScriptB3. Down
; jumps to PlantScriptOnYStepBit1Clear.
;
; No direction calls bank 5 at $682D (SaveStepThenApplyOrDispatch)
; through CallBankedHL, stages the third script from the marked cell,
; and nudges the camera past the follow edge. DispatchRecordHeadIfAPressed
; returns unless bit 0 of $C9A4 is set. Bit 0 is A in the pressed-button
; copy FinishFrame writes from wButtonsPressed. When A is pressed it
; keeps the low two bits of hRecordHead and jumps to one of four bank-1
; cell entries. Control then jumps to CommitScriptRecord at $5D9B.
; That tail calls CopyScriptBytes and WriteRecordHead, then returns.
;
; wButtonsHeld and the direction bits are the names from
; read_joypad.asm. wButtonsPressed is the name from main_loop.asm.
; hRecordHead is the name from write_record_head.asm.

DispatchHeldDirectionFromHead::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 4, a
    jp nz, PlantScriptOnRightWhileDown
    bit 5, a
    jp nz, PlantScriptOnLeftWhileDown
    bit 6, a
    jp nz, PlantHandlerScriptB3
    bit 7, a
    jp nz, PlantScriptOnYStepBit1Clear
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    call DispatchRecordHeadIfAPressed
    jp CommitScriptRecord
