; Bank 1 at $55AE. ResumeYStepBit1ClearRecord jumps here when bit 4 of
; the $c9a3 byte is set while bit 7 is set and bit 5 is clear. That byte
; is the copy of wButtonsHeld FinishFrame writes. Bit 7 is down and bit 4
; is right, from the high nibble ReadJoypad stores. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $02. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $4FED. The
; little-endian word $55CD is written at hRecordHead + 1. $55CD is the
; next routine in this bank and is still INCBIN. What the record uses
; that word for is still unknown. $4FED is a script address still INCBIN
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
DEF ScriptPtr4FED EQU $4FED

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord55CD EQU $55CD

PlantScriptOnRightWhileDown::
    ld a, $02
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr4FED)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr4FED)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord55CD)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord55CD)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
