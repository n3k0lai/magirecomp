; Bank 1 at $5888. ResumeUpIdleRecord jumps here when bit 4 of the
; $c9a3 byte is set, and ResumeDownRecordHead jumps here when that same
; bit is set while down is held. Bit 4 is right on the copy of $c931
; written by FinishFrame. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $02. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $53CC, the 3-byte
; form (low at $FFA2, high at $FFA3). The little-endian word $58A7 is
; written at hRecordHead + 1. $58A7 is the next routine in this bank and
; is still INCBIN. What the record uses that word for is still unknown.
; $53CC is a script address still INCBIN in this bank. What $02 means
; beside marking this right path is still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr53CC EQU $53CC

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord58A7 EQU $58A7

PlantRightRecordHead::
    ld a, $02
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr53CC)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr53CC)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord58A7)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord58A7)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
