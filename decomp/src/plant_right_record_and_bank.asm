; Bank 1 at $5CA5. Three bit-4 paths jump here: $5B79 (record at $5B6E),
; $5C11 (down still held, from $5C06), and $5D63 (body after $5D3E).
; Bit 4 is right on the copy of wButtonsHeld at $c9a3. rROMB0 is left
; alone. Those three callers are still INCBIN.
;
; hRecordHead ($FF8C) becomes $02. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptBank becomes $20. hScriptPtr
; becomes $5B9C, the 3-byte form (low at $FFA2, high at $FFA3). The
; little-endian word $5CC8 is written at hRecordHead + 1. $5CC8 is the
; next routine in this bank and is still INCBIN. What the record uses
; that word for is still unknown. $5B9C is a script address still
; INCBIN in this bank. What $02 means beside marking this right path,
; and what bank $20 selects, is still unknown.
;
; The byte at $5CB3 is `ldh [hScriptBank], a` below. PlantScriptOnDownPressed
; also stores $5CB3 as hScriptPtr. What the opcode dispatcher does with
; that address is still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptBank, hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER
; are the names from reset.asm. hRecordHead is the name from
; write_record_head.asm. CommitScriptAndRecordHead is the EQU in
; plant_handler_and_head_word.asm. wButtonsHeld is the name from
; read_joypad.asm. PlantScriptOnDownPressed is the name from
; plant_script_on_down_pressed.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr5B9C EQU $5B9C

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5CC8 EQU $5CC8

PlantRightRecordAndBank::
    ld a, $02
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, $20
    ldh [hScriptBank], a
    ld a, LOW(ScriptPtr5B9C)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5B9C)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord5CC8)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5CC8)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
