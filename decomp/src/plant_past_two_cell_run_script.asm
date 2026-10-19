; Bank 1 at $4ED4. DispatchZeroStepCellRun jumps here when the
; cell-run count from $517C is past two and the byte at $C9A6 is at
; least 5. rROMB0 is left alone.
;
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr
; becomes $5C7A, the 3-byte form (low at $FFA2, high at $FFA3). The
; little-endian word $4F0D is written at hRecordHead + 1. $4F0D is the
; next routine after the short tail at $4EF2 and is still INCBIN. What
; the record uses that word for is still unknown. $5C7A is a script
; address still INCBIN in this bank. $C9A6 has no name.
;
; Control then jumps to $5D9B, still INCBIN. That tail calls $290A and
; WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the name from plant_handler_and_head_word.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr5C7A EQU $5C7A

; Routine later in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord4F0D EQU $4F0D

PlantPastTwoCellRunScript::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr5C7A)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5C7A)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord4F0D)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord4F0D)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
