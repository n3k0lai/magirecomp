; Stores the index limit $54 at $C9EC and the record pointer $6C60 at
; $C9F0 (low byte first), then joins ResumeScriptDispatch at $11D9.
;
; $C9EC is the index limit and $C9F0 is the record pointer, from
; step_planted_record.asm. That tail clears $C9EB, $C9EE, and $C9EF,
; copies BC to hScriptPtr, and plants DispatchScriptOpcode as
; hScriptHandler. What this record is, and who calls this, is still
; unknown. This routine does not write rROMB0.

; Little-endian word stored at $C9F0. Still unknown.
DEF LIMIT_54_RECORD EQU $6C60

; Index limit stored at $C9EC.
DEF LIMIT_54 EQU $54

PlantLimit54At6C60::
    ld a, LIMIT_54
    ld [$C9EC], a
    ld a, LOW(LIMIT_54_RECORD)
    ld [$C9F0], a
    ld a, HIGH(LIMIT_54_RECORD)
    ld [$C9F1], a
    jr ResumeScriptDispatch
