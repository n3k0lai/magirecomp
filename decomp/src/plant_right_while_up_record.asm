; Bank 1 at $628C. ResumePlantedUpRecord at $631F jumps here when
; bit 6 and bit 4 of the $c9a3 byte are both set. Bit 6 is up and bit 4
; is right on the copy of wButtonsHeld. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $02, the same value PlantRightRecordAndBank
; stores for its right path. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptBank becomes $11. hScriptPtr
; becomes $78D3, the 3-byte form (low at $FFA2, high at $FFA3). The
; little-endian word $62AF is written at hRecordHead + 1. $62AF is the
; next routine in this bank and is still INCBIN. What the record uses
; that word for is still unknown. $78D3 is a script address in the bank
; stored at hScriptBank. What $02 means beside marking this right path,
; and what bank $11 selects, is still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptBank, hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER
; are the names from reset.asm. hRecordHead is the name from
; write_record_head.asm. CommitScriptAndRecordHead is the EQU in
; plant_handler_and_head_word.asm. wButtonsHeld is the name from
; read_joypad.asm. ResumePlantedUpRecord is the label in
; resume_planted_up_record.asm. PlantRightRecordAndBank is the label in
; plant_right_record_and_bank.asm.

; Script planted at hScriptPtr. Bank $11 is stored at hScriptBank.
DEF ScriptPtr78D3 EQU $78D3

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord62AF EQU $62AF

PlantRightWhileUpRecord::
    ld a, $02
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, $11
    ldh [hScriptBank], a
    ld a, LOW(ScriptPtr78D3)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr78D3)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord62AF)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord62AF)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead

PlantRightWhileUpRecordEnd:
