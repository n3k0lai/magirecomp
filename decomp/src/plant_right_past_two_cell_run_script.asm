; Bank 1 at $5028. DispatchZeroXStepCellRun jumps here when the
; cell-run count is past two and the byte at $C9A6 is at least 5.
; rROMB0 is left alone. That caller is the right-held path (X step zero).
;
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr
; becomes $5D70, the 3-byte form (low at $FFA2, high at $FFA3). The
; little-endian word $5061 is written at hRecordHead + 1. $5061 is the
; next routine after the three-byte call at $5043 and is still INCBIN.
; What the record uses that word for is still unknown. $5D70 is a script
; address in this bank. $C9A6 has no name.
;
; Control then jumps to CommitScriptAndRecordHead ($5D9B), which copies
; the seven HRAM script bytes and writes the record head.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; DispatchZeroXStepCellRun is the name from
; dispatch_zero_x_step_cell_run.asm.

; Script planted at hScriptPtr.
DEF ScriptPtr5D70 EQU $5D70

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF RightPastTwoHeadWord EQU $5061

PlantRightPastTwoCellRunScript::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr5D70)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5D70)
    ldh [hScriptPtr + 1], a
    ld a, LOW(RightPastTwoHeadWord)
    ldh [hRecordHead + 1], a
    ld a, HIGH(RightPastTwoHeadWord)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
