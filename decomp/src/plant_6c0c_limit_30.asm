; Bank 4 at $73E7. Plants the same record and index limit as
; PlantLimit30At6C0C, then returns. This copy writes the word at
; $C9F0 first ($6C0C, low byte first), then stores $30 at $C9EC.
; `xor a` clears $C9EB and $C9EE. It does not clear $C9EF and does
; not join ResumeScriptDispatch.
;
; $C9EC is the index limit, $C9EB is the index, $C9EE is the wait
; count, and $C9F0 is the record pointer, from step_planted_record.asm.
; LIMIT_30 and LIMIT_30_RECORD are the names from
; plant_limit_30_at_6c0c.asm. This routine does not write rROMB0
; and does not call out. What the record at $6C0C is, and who calls
; this, is still unknown.

Plant6C0CLimit30::
    ld a, LOW(LIMIT_30_RECORD)
    ld [$C9F0], a
    ld a, HIGH(LIMIT_30_RECORD)
    ld [$C9F1], a
    ld a, LIMIT_30
    ld [$C9EC], a
    xor a
    ld [$C9EB], a
    ld [$C9EE], a
    ret
