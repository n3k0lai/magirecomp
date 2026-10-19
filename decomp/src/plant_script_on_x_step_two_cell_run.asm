; Bank 1 at $525D. DispatchZeroXStepCellRun jumps here when the
; cell-run count from CountCellRun is two. rROMB0 is left alone.
;
; hScriptPtr becomes $57C5, stored with the 3-byte form (low at $FFA2,
; high at $FFA3). $57C5 is still INCBIN in this bank. What that script
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
DEF ScriptPtr57C5 EQU $57C5

PlantScriptOnXStepTwoCellRun::
    ld a, LOW(ScriptPtr57C5)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr57C5)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
