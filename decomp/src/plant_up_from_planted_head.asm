; Bank 1 at $608A. ResumePlantedHead60FD jumps here when bit 6 of
; the $c9a3 byte is set. Bit 6 is up on the copy of wButtonsHeld.
; rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $00, the same value PlantUpRecordAndBank
; stores for its up path. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $780A, the 3-byte
; form (low at $FFA2, high at $FFA3). This routine does not store
; hScriptBank, so which bank $780A belongs to is still unknown. The
; little-endian word $60A9 is written at hRecordHead + 1. $60A9 is the
; next code in this hole and is still INCBIN. What the record uses that
; word for is still unknown. What $00 means beside marking this up
; path is still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; wButtonsHeld is the name from read_joypad.asm. ResumePlantedHead60FD
; is the label in resume_planted_head_60fd.asm. PlantUpRecordAndBank is
; the label in plant_up_record_and_bank.asm.

; Script planted at hScriptPtr. Bank is not stored here.
DEF ScriptPtr780A EQU $780A

; Next code in this hole. Still INCBIN. Planted in the record head.
DEF HeadWord60A9 EQU $60A9

PlantUpFromPlantedHead::
    ld a, $00
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr780A)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr780A)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord60A9)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord60A9)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead

PlantUpFromPlantedHeadEnd:
