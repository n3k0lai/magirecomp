; Bank 1 at $6027. DownHeldFromPlantedRecord jumps here when bit 4 of
; the $c9a3 byte is set. Bit 4 is right and bit 7 is down on the copy of
; wButtonsHeld. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $02, the same value PlantRightRecordAndBank
; stores for its right path. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $782E, the 3-byte
; form (low at $FFA2, high at $FFA3). This routine does not store
; hScriptBank, so which bank $782E belongs to is still unknown. The
; little-endian word $6046 is written at hRecordHead + 1. $6046 is the
; next code in this hole and is still INCBIN. What the record uses that
; word for is still unknown. What $02 means beside marking this right
; path is still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; wButtonsHeld is the name from read_joypad.asm. DownHeldFromPlantedRecord
; is the label in down_held_from_planted_record.asm. PlantRightRecordAndBank
; is the label in plant_right_record_and_bank.asm.

; Script planted at hScriptPtr. Bank is not stored here.
DEF ScriptPtr782E EQU $782E

; Next code in this hole. Still INCBIN. Planted in the record head.
DEF HeadWord6046 EQU $6046

PlantRightWhileDownRecord::
    ld a, $02
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr782E)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr782E)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord6046)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord6046)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead

PlantRightWhileDownRecordEnd:
