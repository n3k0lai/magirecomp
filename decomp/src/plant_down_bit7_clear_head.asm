; Bank 1 at $5B5B. ResumeDownBit7Record jumps here when bit 7 of
; $c9a3 is clear. Bit 7 is down on the copy of wButtonsHeld. That
; caller has already planted hScriptPtr with $5BCF, the $A4 operand
; inside the planter at $5BC8. rROMB0 is left alone.
;
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66). The
; little-endian word $5B6E is written at hRecordHead + 1. $5B6E is the
; next routine in this bank and is still INCBIN. What the record uses
; that word for is still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptHandler and INITIAL_SCRIPT_HANDLER are the names from reset.asm.
; hRecordHead is the name from write_record_head.asm. wButtonsHeld is
; the name from read_joypad.asm. CommitScriptAndRecordHead is the EQU
; in plant_handler_and_head_word.asm.

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5B6E EQU $5B6E

PlantDownBit7ClearHead::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(HeadWord5B6E)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5B6E)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
