; Bank 1 at $5015. ResumeHead01Record jumps here when the cell one
; column left is neither $00 nor $02. Cell $02 takes CommitScriptRecord.
; Cell $00 plants script $59E7. rROMB0 is left alone.
;
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr
; becomes $5D3E, the 3-byte form (low at $FFA2, high at $FFA3). Unlike
; the direction planters, this path does not write a word at
; hRecordHead + 1. hRecordHead itself stays $01, stored by the caller.
; $5D3E is a script address still INCBIN in this bank.
;
; Control then jumps to CommitScriptAndRecordHead ($5D9B), which copies
; the script bytes and writes the record head.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the name from plant_handler_and_head_word.asm.
; ResumeHead01Record is the name from resume_head01_record.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr5D3E EQU $5D3E

PlantScriptOnOtherLeftCell::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr5D3E)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5D3E)
    ldh [hScriptPtr + 1], a
    jp CommitScriptAndRecordHead
