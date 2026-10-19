; Bank 1 at $50D2. DispatchBit6ZeroStepCellRun jumps here when the
; cell-run count is past two and the byte at $C9A6 is at least 5.
; rROMB0 is left alone. Bit 6 is the up direction.
;
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr
; becomes $5BFF, the 3-byte form (low at $FFA2, high at $FFA3). The
; little-endian word $510B is written at hRecordHead + 1. $510B is the
; routine after the $50F0 plant and is still INCBIN. What the record
; uses that word for is still unknown. $5BFF is a script address still
; INCBIN in this bank. $C9A6 has no name.
;
; Control then jumps to CommitScriptAndRecordHead ($5D9B), which copies
; the seven HRAM script bytes and writes the record head.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the name from plant_handler_and_head_word.asm.
; DispatchBit6ZeroStepCellRun is the name from
; dispatch_bit6_zero_step_cell_run.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr5BFF EQU $5BFF

; Routine later in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord510B EQU $510B

PlantBit6PastTwoCellRunScript::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr5BFF)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5BFF)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord510B)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord510B)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
