; Bank 1 at $5C2F. The still-INCBIN entry at $5C06 jumps here when bit 5
; of the $c9a3 byte is set. That entry is taken from $5BF6 when bit 7 of
; $c9a3 is set. Bit 7 is down and bit 5 is left on the copy of
; wButtonsHeld at $c9a3. rROMB0 is left alone. The sibling bit-4 path
; jumps to PlantRightRecordAndBank.
;
; hRecordHead ($FF8C) becomes $01. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptBank becomes $20. hScriptPtr
; becomes $5B6F, the 3-byte form (low at $FFA2, high at $FFA3). The
; little-endian word $5C52 is written at hRecordHead + 1. $5C52 is the
; next routine in this bank and is still INCBIN. What the record uses
; that word for is still unknown. $5B6F is a script address still
; INCBIN in this bank. What $01 means beside marking this left path,
; and what bank $20 selects, is still unknown.
;
; The byte at $5C48 is the immediate of `ld a, LOW(HeadWord5C52)` below.
; ResumeHead00Record plants that address as hScriptPtr when the cell one
; row up is neither $00 nor $02. What the opcode dispatcher does with
; that address is still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptBank, hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER
; are the names from reset.asm. hRecordHead is the name from
; write_record_head.asm. CommitScriptAndRecordHead is the EQU in
; plant_handler_and_head_word.asm. wButtonsHeld is the name from
; read_joypad.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr5B6F EQU $5B6F

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5C52 EQU $5C52

PlantLeftRecordAndBank::
    ld a, $01
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, $20
    ldh [hScriptBank], a
    ld a, LOW(ScriptPtr5B6F)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5B6F)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord5C52)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5C52)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
