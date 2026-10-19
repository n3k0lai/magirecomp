; Bank 1 at $5250. DispatchZeroXStepCellRun jumps here when the
; cell-run count from CountCellRun is one. rROMB0 is left alone.
;
; hScriptPtr becomes $56BA, stored with the 3-byte form (low at $FFA2,
; high at $FFA3). $56BA is still INCBIN in this bank. What that script
; does is still unknown.
;
; Control then jumps to PlantHandlerAndHeadWord at $5DA2, which plants
; the script handler and a record-head word, then jumps to
; CommitScriptAndRecordHead.
;
; hScriptPtr is the name from reset.asm. PlantHandlerAndHeadWord is the
; name from plant_handler_and_head_word.asm.
; DispatchZeroXStepCellRun is the name from
; dispatch_zero_x_step_cell_run.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr56BA EQU $56BA

PlantScriptOnXStepOneCellRun::
    ld a, LOW(ScriptPtr56BA)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr56BA)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
