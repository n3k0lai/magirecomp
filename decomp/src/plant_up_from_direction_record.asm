; Bank 1 at $5AB7. ResumeDirectionDispatchHead jumps here when bit 6
; of $c9a3 is set. That bit is up on the copy of wButtonsHeld written
; by FinishFrame. rROMB0 is left alone.
;
; $4F63 is the operand of `ldh [hScriptPtr], a` in ResumeHead03Record,
; on the path that plants the zero-cell script. What the script engine
; does with an address in the middle of that planter is still unknown.
;
; hRecordHead ($FF8C) is cleared. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $4F63, the 3-byte
; form (low at $FFA2, high at $FFA3). The little-endian word $5AD6 is
; written at hRecordHead + 1. $5AD6 is the next routine in this bank
; and is still INCBIN. What the record uses that word for is still
; unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; ResumeHead03Record is the label in resume_head03_record.asm.

; Operand of `ldh [hScriptPtr], a` on the head-03 zero-cell path.
; ResumeHead03Record is at $4F0D; that operand is at $4F63.
DEF ScriptPtr4F63 EQU ResumeHead03Record + ($4F63 - $4F0D)

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5AD6 EQU $5AD6

PlantUpFromDirectionRecord::
    ld a, $00
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr4F63)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr4F63)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord5AD6)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5AD6)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
