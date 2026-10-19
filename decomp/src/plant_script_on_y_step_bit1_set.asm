; Bank 1 at $52A6. ResumeYStepBit1ClearRecord jumps here when bit 1 of
; the $c9a3 byte is set, after down is held and left and right are
; clear. What bit 1 means is still unknown. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $03. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $505D. The
; little-endian word $52C5 is written at hRecordHead + 1. $52C5 is the
; next byte after this jump and is still INCBIN. What the record uses
; that word for is still unknown. $505D is a script address still INCBIN
; in this bank.
;
; Control then jumps to CommitScriptAndRecordHead ($5D9B), which copies
; the script bytes and writes the record head.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the name from plant_handler_and_head_word.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr505D EQU $505D

; Next bytes in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord52C5 EQU $52C5

PlantScriptOnYStepBit1Set::
    ld a, $03
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr505D)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr505D)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord52C5)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord52C5)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
