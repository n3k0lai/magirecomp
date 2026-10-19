; Bank 1 at $51D8. DispatchZeroStepCellRun jumps here when the
; cell-run count from $517C is one. rROMB0 is left alone.
;
; hScriptPtr becomes $5738, stored with the 3-byte form (low at $FFA2,
; high at $FFA3). $5738 is still INCBIN in this bank. What that script
; does is still unknown.
;
; Control then jumps to PlantHandlerAndHeadWord at $5DA2, which plants
; the script handler and a record-head word, then jumps to
; CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. PlantHandlerAndHeadWord is the
; name from plant_handler_and_head_word.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr5738 EQU $5738

PlantScriptOnOneCellRun::
    ld a, LOW(ScriptPtr5738)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr5738)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
