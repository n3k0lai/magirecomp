; Bank 1 at $62FC. The still-INCBIN entry at $6167 jumps here when bit 6
; of the $c9a3 byte is set. Bit 6 is up on the copy of wButtonsHeld
; written by FinishFrame. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $00, the same value PlantUpFromDirectionRecord
; stores for its up path. hScriptHandler becomes INITIAL_SCRIPT_HANDLER
; ($0A66). hScriptBank becomes $11. hScriptPtr becomes $786A, the 3-byte
; form (low at $FFA2, high at $FFA3). The little-endian word $631F is
; written at hRecordHead + 1. $631F is the next routine in this bank and
; is still INCBIN. What the record uses that word for is still unknown.
; $786A is a script address in the bank stored at hScriptBank. What $00
; means beside marking this up path, and what bank $11 selects, is still
; unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptBank, hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER
; are the names from reset.asm. hRecordHead is the name from
; write_record_head.asm. CommitScriptAndRecordHead is the EQU in
; plant_handler_and_head_word.asm. wButtonsHeld is the name from
; read_joypad.asm. PlantUpFromDirectionRecord is the label in
; plant_up_from_direction_record.asm.

; Script planted at hScriptPtr. Bank $11 is stored at hScriptBank.
DEF ScriptPtr786A EQU $786A

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord631F EQU $631F

PlantUpRecordAndBank::
    ld a, $00
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, $11
    ldh [hScriptBank], a
    ld a, LOW(ScriptPtr786A)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr786A)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord631F)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord631F)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead

PlantUpRecordAndBankEnd:
