; Bank 1 at $5D1B. ResumeDownClearHead jumps here when bit 6 of the
; $c9a3 byte is set. Bit 6 is up on the copy of wButtonsHeld. rROMB0
; is left alone. The sibling bit-5 path jumps to PlantLeftRecordAndBank
; and the bit-4 path jumps to PlantRightRecordAndBank.
;
; hRecordHead ($FF8C) becomes $00. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptBank becomes $20. The low byte
; of hScriptPtr becomes $29. $5B29 is `bit 5, a` inside
; ResumeDirectionDispatchHead. What the script engine does with that
; address, what $00 means beside marking this up path, and what bank
; $20 selects, is still unknown.
;
; The last byte here is the opcode of `ldh [hScriptPtr], a`. Its $A2
; operand is the first byte of PlantLeftScriptHighAndHead, so falling
; through consumes that byte and does not execute it. Entering at
; $5D2E instead runs that byte as `and d`, which discards A, then
; joins the same tail. The tail stores $5B at hScriptPtr + 1, so the
; pointer is $5B29, writes ResumeOtherLeftCellScript ($5D3E) at
; hRecordHead + 1, and jumps to CommitScriptRecord.
;
; hScriptBank, hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER
; are the names from reset.asm. hRecordHead is the name from
; write_record_head.asm. wButtonsHeld is the name from read_joypad.asm.
; ResumeDownClearHead is the label in resume_down_clear_head.asm.
; ResumeDirectionDispatchHead is the label in
; resume_direction_dispatch_head.asm. PlantLeftScriptHighAndHead is
; the label in plant_left_script_high_and_head.asm.
; ResumeOtherLeftCellScript is the label in
; resume_other_left_cell_script.asm.

; Low byte planted at hScriptPtr. The address is `bit 5, a` in
; ResumeDirectionDispatchHead. The high byte $5B is stored by the tail.
DEF ScriptPtrLow5B29 EQU $29

PlantUpHeldRecord::
    ld a, $00
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, $20
    ldh [hScriptBank], a
    ld a, ScriptPtrLow5B29
    INCBIN "roms/magination.gbc", $5D2D, $1
