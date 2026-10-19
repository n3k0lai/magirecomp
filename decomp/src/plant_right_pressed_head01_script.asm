; Bank 1 at $5046. ResumeHead01Record jumps here when bit 4 of $C9A4
; is set. That byte is the pressed-button copy FinishFrame writes, and
; bit 4 is right. rROMB0 is left alone. The three bytes at $5043, still
; INCBIN, call $5DE1 and fall into this routine.
;
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr
; becomes $5DA9, the 3-byte form (low at $FFA2, high at $FFA3). The
; little-endian word $5061 is written at hRecordHead + 1. $5061 is the
; next routine in this bank and is still INCBIN. What the record uses
; that word for is still unknown. $5DA9 is a script address still INCBIN
; in this bank. hRecordHead itself stays $01, stored by the caller.
;
; Control then jumps to CommitScriptAndRecordHead ($5D9B), which copies
; the script bytes and writes the record head.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr5DA9 EQU $5DA9

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5061 EQU $5061

PlantRightPressedHead01Script::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr5DA9)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5DA9)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord5061)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5061)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
