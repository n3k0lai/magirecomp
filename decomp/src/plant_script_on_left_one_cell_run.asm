; Bank 1 at $5214. DispatchLeftZeroXStepCellRun jumps here when the
; cell-run count from CountCellRun is one. rROMB0 is left alone.
;
; hScriptPtr becomes $567B, stored with the 3-byte form (low at $FFA2,
; high at $FFA3). $567B is still INCBIN in this bank. What that script
; does is still unknown.
;
; Control then jumps to PlantHandlerAndHeadWord at $5DA2, which plants
; the script handler and a record-head word, then jumps to
; CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. PlantHandlerAndHeadWord is the
; name from plant_handler_and_head_word.asm. DispatchLeftZeroXStepCellRun
; is the name from dispatch_left_zero_x_step_cell_run.asm.
; CountCellRun is the name from count_cell_run.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr567B EQU $567B

PlantScriptOnLeftOneCellRun::
    ld a, LOW(ScriptPtr567B)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr567B)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
