; Bank 1 at $5515. ResumeYStepBit1ClearRecord jumps here when bit 5 of
; the $c9a3 byte is set while bit 7 is set. That byte is the copy of
; wButtonsHeld FinishFrame writes. Bit 7 is down and bit 5 is left, from
; the high nibble ReadJoypad stores. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $01. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $4FDD. The
; little-endian word $5534 is written at hRecordHead + 1. $5534 is the
; next routine in this bank and is still INCBIN. What the record uses
; that word for is still unknown. $4FDD is a script address still INCBIN
; in this bank.
;
; Control then jumps to CommitScriptAndRecordHead ($5D9B), which copies
; the script bytes and writes the record head.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the name from plant_handler_and_head_word.asm.
; wButtonsHeld is the name from read_joypad.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr4FDD EQU $4FDD

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5534 EQU $5534

PlantScriptOnLeftWhileDown::
    ld a, $01
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr4FDD)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr4FDD)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord5534)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5534)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
