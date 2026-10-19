; Bank 1. A caller still in INCBIN reaches this only when $C188 is 0.
;
; $FF8A (low) and $FF8B (high) hold a record pointer, both read with `ldh`.
; That pointer is saved at $C174, the same word RestoreScratchRecord writes
; back from. $1B bytes, the record length InitPointerList steps by, are
; copied to the scratch at $C1A4. $C188 is set to 1 so a later commit (state
; 3) can put the scratch back. HL is restored to the source pointer. What
; state 1 means besides "scratch holds this record" is still unknown.

; wRecordState, wSavedRecord, wRecordScratch, and SCRATCH_RECORD_LEN are
; defined in restore_scratch_record.asm, which this bank includes first.
DEF hRecordPointer EQU $FF8A
DEF RECORD_STATE_STAGED EQU $01

CopyRecordToScratch::
    ld a, RECORD_STATE_STAGED
    ld [wRecordState], a
    ldh a, [hRecordPointer]
    ld l, a
    ld [wSavedRecord], a
    ldh a, [hRecordPointer + 1]
    ld h, a
    ld [wSavedRecord + 1], a
    push hl
    ld bc, wRecordScratch
    ld e, SCRATCH_RECORD_LEN
.copy:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec e
    jr nz, .copy
    pop hl
    ret
