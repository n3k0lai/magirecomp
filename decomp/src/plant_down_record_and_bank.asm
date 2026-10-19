; Bank 1 at $5BC8. ResumeDownClearHead jumps here when bit 7 of
; $c9a3 is set. Bit 7 is down on the copy of wButtonsHeld. rROMB0 is
; left alone.
;
; hRecordHead ($FF8C) becomes $03. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptBank becomes $20. hScriptPtr
; becomes $5B4C, the 3-byte form (low at $FFA2, high at $FFA3). The
; little-endian word ResumeDownBit7Record ($5BEB) is written at
; hRecordHead + 1. $5B4C is still INCBIN in this bank. What $03 means
; beside marking this down path, what bank $20 selects, and what the
; record uses that word for, is still unknown.
;
; The byte at $5BCF is the $A4 operand of the hScriptHandler store.
; ResumeDownBit7Record plants that address as hScriptPtr when down is
; clear. The byte at $5BDF is the $5B immediate of the hScriptPtr high
; store. ResumeLeftPlantedRecord plants that address as hScriptPtr when
; left is clear. What the script engine does with either address is
; still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptBank, hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER
; are the names from reset.asm. hRecordHead is the name from
; write_record_head.asm. CommitScriptAndRecordHead is the EQU in
; plant_handler_and_head_word.asm. wButtonsHeld is the name from
; read_joypad.asm. ResumeDownBit7Record is the label in
; resume_down_bit7_record.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr5B4C EQU $5B4C

PlantDownRecordAndBank::
    ld a, $03
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, $20
    ldh [hScriptBank], a
    ld a, LOW(ScriptPtr5B4C)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5B4C)
    ldh [hScriptPtr + 1], a
    ld a, LOW(ResumeDownBit7Record)
    ldh [hRecordHead + 1], a
    ld a, HIGH(ResumeDownBit7Record)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
