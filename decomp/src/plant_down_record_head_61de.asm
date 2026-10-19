; Bank 1 at $61BB. ResumePlantedHead6167 jumps here when bit 7 of
; $c9a3 is set. Bit 7 is down on the copy of wButtonsHeld. rROMB0 is
; left alone.
;
; hRecordHead ($FF8C) becomes $03, the same value PlantDownRecordAndBank
; stores for its down path. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptBank becomes $11. hScriptPtr
; becomes $788D, the 3-byte form (low at $FFA2, high at $FFA3). The
; little-endian word $61DE is written at hRecordHead + 1. $61DE is the
; next routine in this bank and is still INCBIN. What the record uses
; that word for is still unknown. $788D is a script address in the bank
; stored at hScriptBank. What $03 means beside marking this down path,
; and what bank $11 selects, is still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptBank, hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER
; are the names from reset.asm. hRecordHead is the name from
; write_record_head.asm. CommitScriptAndRecordHead is the EQU in
; plant_handler_and_head_word.asm. wButtonsHeld is the name from
; read_joypad.asm. ResumePlantedHead6167 is the label in
; resume_planted_head_6167.asm. PlantDownRecordAndBank is the label in
; plant_down_record_and_bank.asm.

; Script planted at hScriptPtr. Bank $11 is stored at hScriptBank.
DEF ScriptPtr788D EQU $788D

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord61DE EQU $61DE

PlantDownRecordHead61DE::
    ld a, $03
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, $11
    ldh [hScriptBank], a
    ld a, LOW(ScriptPtr788D)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr788D)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord61DE)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord61DE)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead

PlantDownRecordHead61DEEnd:
