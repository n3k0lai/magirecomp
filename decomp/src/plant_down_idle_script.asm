; Bank 1 at $5779. StageIdleScriptUnlessUpOrDown jumps here when bit 7
; of the $c9a3 byte is set. That bit is the down direction on the copy of
; $c931 written by FinishFrame. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $03. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $526E, the 3-byte
; form (low at $FFA2, high at $FFA3). The little-endian word $5798 is
; written at hRecordHead + 1. $5798 is the next routine in this bank and
; is still INCBIN. What the record uses that word for is still unknown.
; $526E is a script address still INCBIN in this bank.
;
; Control then jumps to $5D9B, still INCBIN. That tail calls $290A and
; WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the name from plant_handler_and_head_word.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr526E EQU $526E

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5798 EQU $5798

PlantDownIdleScript::
    ld a, $03
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr526E)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr526E)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord5798)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5798)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
