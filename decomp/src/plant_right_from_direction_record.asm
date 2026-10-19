; Bank 1 at $5A55. Three still-INCBIN bodies jump here when bit 4 of
; the $c9a3 byte is set. That bit is right on the copy of $c931 written
; by FinishFrame. One body follows the down record at $5996, one follows
; the up planter at $5AB7, and one follows the dispatcher at $5B13.
; rROMB0 is left alone.
;
; $5A5B is the `ldh [hScriptHandler], a` below. ResumeHead00Record and
; ResumeUpIdleRecord plant that address as hScriptPtr when a cell is
; $00. What the script engine does with an address in the middle of this
; planter is still unknown.
;
; hRecordHead ($FF8C) becomes $02, the same value PlantRightRecordHead
; stores for its right path. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $4FA3, the 3-byte
; form (low at $FFA2, high at $FFA3). $4FA3 is the operand of
; `ldh [hScriptHandler + 1], a` in PlantLeftIntoHead01. The little-endian
; word $5A74 is written at hRecordHead + 1. $5A74 is the next routine in
; this bank and is still INCBIN. What the record uses that word for is
; still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; PlantLeftIntoHead01 is the label in resume_head03_record.asm.

; Operand inside PlantLeftIntoHead01. Already source.
DEF ScriptPtr4FA3 EQU PlantLeftIntoHead01 + 7

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5A74 EQU $5A74

PlantRightFromDirectionRecord::
    ld a, $02
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr4FA3)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr4FA3)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord5A74)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5A74)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
