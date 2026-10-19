; Bank 1 at $5DFD. ResumeYStepBit1ClearRecord jumps here when bit 7 of
; the $c9a3 byte is clear. Bit 7 is down on the copy of wButtonsHeld
; FinishFrame writes. That caller has already planted hScriptPtr with
; $50B5. rROMB0 is left alone.
;
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66). The
; little-endian word $5E10 is written at hRecordHead + 1. $5E10 is the
; next routine in this bank and is still INCBIN. What the record uses
; that word for is still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hScriptHandler and INITIAL_SCRIPT_HANDLER are the names from reset.asm.
; hRecordHead is the name from write_record_head.asm. wButtonsHeld is
; the name from read_joypad.asm. CommitScriptAndRecordHead is the EQU
; in plant_handler_and_head_word.asm.

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5E10 EQU $5E10

PlantDownClearRecordHead::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(HeadWord5E10)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5E10)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
