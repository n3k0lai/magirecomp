; Bank 1 at $57F9. ResumeUpIdleRecord jumps here when bit 5 of the
; $c9a3 byte is set, and ResumeDownRecordHead jumps here when that same
; bit is set while down is held. Bit 5 is left on the copy of $c931
; written by FinishFrame. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $01. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $531D, the 3-byte
; form (low at $FFA2, high at $FFA3). The little-endian word $5818 is
; written at hRecordHead + 1. $5818 is the next routine in this bank and
; is still INCBIN. What the record uses that word for is still unknown.
; $531D is a script address still INCBIN in this bank. What $01 means
; beside marking this left path is still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr531D EQU $531D

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5818 EQU $5818

PlantLeftRecordHead::
    ld a, $01
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr531D)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr531D)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord5818)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5818)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
