; Bank 1 at $54A4. OnNonzeroYStepAfterNudge jumps here when bit 1 of
; the $c9a3 byte is clear. That byte is the $c931 copy FinishFrame writes.
; What bit 1 means is still unknown. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $03. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $4FCD. The
; little-endian word $54C3 is written at hRecordHead + 1. $54C3 is the
; next routine in this bank and is still INCBIN. What the record uses
; that word for is still unknown. $4FCD is a script address still INCBIN
; in this bank.
;
; Control then jumps to CommitScriptAndRecordHead ($5D9B), which copies
; the script bytes and writes the record head.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the name from plant_handler_and_head_word.asm.
; YStepBit1Clear in on_nonzero_y_step_after_nudge.asm is this address.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr4FCD EQU $4FCD

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord54C3 EQU $54C3

PlantScriptOnYStepBit1Clear::
    ld a, $03
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr4FCD)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr4FCD)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord54C3)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord54C3)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
