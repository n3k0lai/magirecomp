; Bank 1 at $5996. ResumeDirectionDispatchHead jumps here when bit 7
; of the $c9a3 byte is set. Bit 7 is down on the copy of $c931 written
; by FinishFrame. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $03, the same value PlantDownRecordAndBank
; stores for its down path. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $4F73, the 3-byte
; form (low at $FFA2, high at $FFA3). $4F73 is the `ld a, LOW(ScriptPtr5CC3)`
; in PlantHead03OtherCellScript. The little-endian word $59B5 is written
; at hRecordHead + 1. $59B5 is the next routine in this bank and is still
; INCBIN. What the record uses that word for is still unknown. What $03
; means beside marking this down path is still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; PlantHead03OtherCellScript is the label in resume_head03_record.asm.

; `ld a, LOW(ScriptPtr5CC3)` inside PlantHead03OtherCellScript.
DEF ScriptPtr4F73 EQU PlantHead03OtherCellScript + 8

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord59B5 EQU $59B5

PlantDownFromDirectionRecord::
    ld a, $03
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr4F73)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr4F73)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord59B5)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord59B5)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
