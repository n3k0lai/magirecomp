; Bank 1 at $50BF. ResumeHead02Record jumps here when the cell one
; column right is neither $00 nor $02. rROMB0 is left alone. The caller
; already stored $02 at hRecordHead. This plant does not write the
; record-head word.
;
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr
; becomes $5DB9, the 3-byte form (low at $FFA2, high at $FFA3). $5DB9
; is a script address still INCBIN in this bank.
;
; Control then jumps to CommitScriptAndRecordHead ($5D9B), which copies
; the seven HRAM script bytes and writes the record head.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; ResumeHead02Record is the name from resume_head02_record.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr5DB9 EQU $5DB9

PlantOtherRightCellScript::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr5DB9)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5DB9)
    ldh [hScriptPtr + 1], a
    jp CommitScriptAndRecordHead
