; Bank 1 at $51E5. DispatchZeroStepCellRun jumps here when the
; cell-run count from $517C is two. rROMB0 is left alone.
;
; hScriptPtr becomes $585C, stored with the 3-byte form (low at $FFA2,
; high at $FFA3). $585C is still INCBIN in this bank. What that script
; does is still unknown.
;
; Control then jumps to PlantHandlerAndHeadWord at $5DA2, which plants
; the script handler and a record-head word, then jumps to
; CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. PlantHandlerAndHeadWord is the
; name from plant_handler_and_head_word.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr585C EQU $585C

PlantScriptOnTwoCellRun::
    ld a, LOW(ScriptPtr585C)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr585C)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
