; Bank 1 at $528C. DispatchBit6ZeroStepCellRun jumps here when the
; cell-run count from CountCellRun is one. rROMB0 is left alone.
;
; hScriptPtr becomes $56F9, stored with the 3-byte form (low at $FFA2,
; high at $FFA3). $56F9 is still INCBIN in this bank. What that script
; does is still unknown.
;
; Control then jumps to PlantHandlerAndHeadWord at $5DA2, which plants
; the script handler and a record-head word, then jumps to
; CommitScriptAndRecordHead.
;
; hScriptPtr is the name from reset.asm. PlantHandlerAndHeadWord is the
; name from plant_handler_and_head_word.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr56F9 EQU $56F9

PlantScriptOnBit6OneCellRun::
    ld a, LOW(ScriptPtr56F9)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr56F9)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
