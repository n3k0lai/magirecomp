; Bank 1 at $5647. ResumeUpOnlyBit1Record jumps here when bit 1 of
; $c9a3 is clear. rROMB0 is left alone.
;
; The first record-head byte is cleared. The script handler becomes
; $0A66, the same word Reset stores as INITIAL_SCRIPT_HANDLER.
; A is then $B3 and execution falls into PlantScriptLowFromA, which
; pairs that low byte with $4F (script $4FB3), plants head word $5666,
; and leaves through CommitScriptRecord.
;
; hRecordHead is the name from write_record_head.asm. hScriptHandler
; and INITIAL_SCRIPT_HANDLER are the names from reset.asm.

; Low byte PlantScriptLowFromA stores at hScriptPtr.
DEF SCRIPT_LOW_B3 EQU $B3

PlantHandlerScriptB3::
    ld a, $00
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, SCRIPT_LOW_B3
