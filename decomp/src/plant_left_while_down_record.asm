; Bank 1 at $5FC4. DownHeldFromPlantedRecord jumps here when bit 5 of
; the $c9a3 byte is set. Bit 5 is left and bit 7 is down on the copy of
; wButtonsHeld. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $01, the same value PlantLeftRecordAndBank
; stores for its left path. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $7822, the 3-byte
; form (low at $FFA2, high at $FFA3). This routine does not store
; hScriptBank, so which bank $7822 belongs to is still unknown. The
; little-endian word $5FE3 is written at hRecordHead + 1. $5FE3 is the
; next code in this hole and is still INCBIN. What the record uses that
; word for is still unknown. What $01 means beside marking this left
; path is still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; wButtonsHeld is the name from read_joypad.asm. DownHeldFromPlantedRecord
; is the label in down_held_from_planted_record.asm. PlantLeftRecordAndBank
; is the label in plant_left_record_and_bank.asm.

; Script planted at hScriptPtr. Bank is not stored here.
DEF ScriptPtr7822 EQU $7822

; Next code in this hole. Still INCBIN. Planted in the record head.
DEF HeadWord5FE3 EQU $5FE3

PlantLeftWhileDownRecord::
    ld a, $01
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr7822)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr7822)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord5FE3)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5FE3)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead

PlantLeftWhileDownRecordEnd:
