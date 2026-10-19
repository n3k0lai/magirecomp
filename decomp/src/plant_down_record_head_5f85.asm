; Bank 1 at $5F66. The still-INCBIN dispatcher at $60FD jumps here
; when bit 7 of the $c9a3 byte is set. Bit 7 is down on the copy of
; wButtonsHeld. rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $03, the same value PlantDownRecordAndBank
; stores for its down path. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $7816, the 3-byte
; form (low at $FFA2, high at $FFA3). This routine does not store
; hScriptBank, so which bank $7816 belongs to is still unknown. The
; little-endian word $5F85 is written at hRecordHead + 1. $5F85 is the
; next routine in this bank and is still INCBIN. What the record uses
; that word for is still unknown. What $03 means beside marking this
; down path is still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; wButtonsHeld is the name from read_joypad.asm. PlantDownRecordAndBank
; is the label in plant_down_record_and_bank.asm.

; Script planted at hScriptPtr. Bank is not stored here.
DEF ScriptPtr7816 EQU $7816

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5F85 EQU $5F85

PlantDownRecordHead5F85::
    ld a, $03
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr7816)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr7816)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord5F85)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5F85)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead

PlantDownRecordHead5F85End:
