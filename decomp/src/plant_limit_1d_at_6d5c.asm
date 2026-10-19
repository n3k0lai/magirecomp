; Stores the index limit $1D at $C9EC and the record pointer $6D5C at
; $C9F0 (low byte first), then falls into ResumeScriptDispatch at $11D9.
;
; $C9EC is the index limit and $C9F0 is the record pointer, from
; step_planted_record.asm. That tail clears $C9EB, $C9EE, and $C9EF,
; copies BC to hScriptPtr, and plants DispatchScriptOpcode as
; hScriptHandler. What this record is, and who calls this, is still
; unknown. This routine does not write rROMB0.

; Little-endian word stored at $C9F0. Still unknown.
DEF LIMIT_1D_RECORD EQU $6D5C

; Index limit stored at $C9EC.
DEF LIMIT_1D EQU $1D

PlantLimit1DAt6D5C::
    ld a, LIMIT_1D
    ld [$C9EC], a
    ld a, LOW(LIMIT_1D_RECORD)
    ld [$C9F0], a
    ld a, HIGH(LIMIT_1D_RECORD)
    ld [$C9F1], a
