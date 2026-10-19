; Bank 1 at $5917. StageIdleScriptUnlessUpOrDown jumps here when bit 6
; of the $c9a3 byte is set. That bit is the up direction on the copy of
; $c931 written by FinishFrame. rROMB0 is left alone.
;
; hRecordHead ($FF8C) is cleared. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $51BF, the 3-byte
; form (low at $FFA2, high at $FFA3). The little-endian word $5936 is
; written at hRecordHead + 1. $5936 is the next routine in this bank and
; is still INCBIN. What the record uses that word for is still unknown.
; $51BF is a script address inside the already-lifted path at $51B6.
;
; Control then jumps to $5D9B, still INCBIN. That tail calls $290A and
; WriteRecordHead, then returns.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the name from plant_handler_and_head_word.asm.

; Script planted at hScriptPtr. Already inside lifted source.
DEF ScriptPtr51BF EQU $51BF

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5936 EQU $5936

PlantUpIdleScript::
    ld a, $00
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr51BF)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr51BF)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord5936)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5936)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
