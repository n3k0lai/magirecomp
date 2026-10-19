; Bank 1 at $50F0. ResumeHead01Record jumps here when bit 6 of the
; pressed-button copy at $C9A4 is set. Bit 6 is up. rROMB0 is left
; alone. The three bytes at $50ED are a call that falls into this
; entry; they stay INCBIN.
;
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr
; becomes $5C38, the 3-byte form (low at $FFA2, high at $FFA3). The
; little-endian word $510B is written at hRecordHead + 1. $510B is the
; next routine in this bank and is still INCBIN. What the record uses
; that word for is still unknown. $5C38 is a script address still
; INCBIN in this bank.
;
; Control then jumps to CommitScriptAndRecordHead ($5D9B), which copies
; the seven HRAM script bytes and writes the record head.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the name from plant_handler_and_head_word.asm.
; ResumeHead01Record is the name from resume_head01_record.asm. The
; button bit is the name from read_joypad.asm. HeadWord510B is the name
; from plant_bit6_past_two_cell_run_script.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr5C38 EQU $5C38

PlantScriptOnUpPressed::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr5C38)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5C38)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord510B)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord510B)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
