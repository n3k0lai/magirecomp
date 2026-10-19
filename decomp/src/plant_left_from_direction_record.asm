; Bank 1 at $59F3. ResumeDirectionDispatchHead jumps here when bit 5
; of the $c9a3 byte is set. The down-held path at $59C9, still INCBIN,
; takes the same jump on that bit. Bit 5 is left on the copy of $c931
; written by FinishFrame. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $01, the same value PlantLeftRecordHead
; stores for its left path. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $4F83, the 3-byte
; form (low at $FFA2, high at $FFA3). $4F83 is the operand of
; `ld a, HIGH(INITIAL_SCRIPT_HANDLER)` in PlantScriptForHead01. The
; little-endian word $5A12 is written at hRecordHead + 1. $5A12 is
; ResumeLeftHeldRecord. What the record uses that word for is still
; unknown. What $01 means beside marking this left path is still
; unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; PlantScriptForHead01 is the label in resume_head03_record.asm.
; ResumeLeftHeldRecord is the label in resume_left_held_record.asm.

; Operand of `ld a, HIGH(INITIAL_SCRIPT_HANDLER)` in PlantScriptForHead01.
DEF ScriptPtr4F83 EQU PlantScriptForHead01 + 5

PlantLeftFromDirectionRecord::
    ld a, $01
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr4F83)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr4F83)
    ldh [hScriptPtr + 1], a
    ld a, LOW(ResumeLeftHeldRecord)
    ldh [hRecordHead + 1], a
    ld a, HIGH(ResumeLeftHeldRecord)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
