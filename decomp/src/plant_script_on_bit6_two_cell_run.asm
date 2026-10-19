; Bank 1 at $5299. DispatchBit6ZeroStepCellRun jumps here when the
; cell-run count from CountCellRun is two. rROMB0 is left alone.
;
; hScriptPtr becomes $5813, stored with the 3-byte form (low at $FFA2,
; high at $FFA3). $5813 is still INCBIN in this bank. What that script
; does is still unknown.
;
; Control then jumps to PlantHandlerAndHeadWord at $5DA2, which plants
; the script handler and a record-head word, then jumps to
; CommitScriptAndRecordHead.
;
; hScriptPtr is the name from reset.asm. PlantHandlerAndHeadWord is the
; name from plant_handler_and_head_word.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr5813 EQU $5813

PlantScriptOnBit6TwoCellRun::
    ld a, LOW(ScriptPtr5813)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr5813)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
