; Bank 1 at $6154. ResumePlantedUpRecord at $631F jumps here when
; bit 6 of $c9a3 is clear. Bit 6 is up on the copy of wButtonsHeld.
; That caller already stored $783A at hScriptPtr (3-byte form, low at
; $FFA2). rROMB0 is left alone.
;
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66). The
; little-endian word $6167 is written at hRecordHead + 1. $6167 is the
; next routine in this bank and is still INCBIN. What the record uses
; that word for is still unknown. This routine does not store
; hRecordHead or hScriptBank.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; wButtonsHeld is the name from read_joypad.asm. ResumePlantedUpRecord
; is the label in resume_planted_up_record.asm.

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord6167 EQU $6167

PlantHandlerAndHead6167::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(HeadWord6167)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord6167)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead

PlantHandlerAndHead6167End:
