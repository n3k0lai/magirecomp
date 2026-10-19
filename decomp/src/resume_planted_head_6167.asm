; Bank 1 at $6167. PlantHandlerAndHead6167 writes this address as the
; record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs the script already in the record
; and points HL at the map cell. A then becomes the $c9a3 copy of
; wButtonsHeld that FinishFrame writes. Bit 4 is right, bit 5 is left,
; bit 6 is up, and bit 7 is down.
;
; Right jumps to $628C, still INCBIN. Left jumps to
; PlantLeftWhileUpRecord. Up jumps to PlantUpRecordAndBank. Down jumps
; to $61BB, still INCBIN.
;
; No direction calls bank 5 at SaveStepThenApplyOrDispatch through
; CallBankedHL, stages the third script from the marked cell, and
; nudges the camera past the follow edge. Bit 0 of $c9a4 is A in the
; pressed-button copy FinishFrame writes from wButtonsPressed. A newly
; pressed calls $619A, still INCBIN. That call reads hRecordHead, keeps
; the low two bits, and jumps to one of four bank-1 entries. Control
; then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; wButtonsHeld and the direction bits are the names from
; read_joypad.asm. wButtonsPressed is the name from main_loop.asm.
; $c9a3 and $c9a4 have no names. hRecordHead is the name from
; write_record_head.asm. CallBankedHL is the name from
; call_hl_in_bank.asm. CommitScriptAndRecordHead is the EQU in
; plant_handler_and_head_word.asm. PlantHandlerAndHead6167 is the label
; in plant_handler_and_head_6167.asm. PlantLeftWhileUpRecord is the
; label in plant_left_while_up_record.asm. PlantUpRecordAndBank is the
; label in plant_up_record_and_bank.asm.

ResumePlantedHead6167::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 4, a
    jp nz, $628c
    bit 5, a
    jp nz, PlantLeftWhileUpRecord
    bit 6, a
    jp nz, PlantUpRecordAndBank
    bit 7, a
    jp nz, $61bb
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [$c9a4]
    bit 0, a
    call nz, $619a
    jp CommitScriptAndRecordHead

ResumePlantedHead6167End:
