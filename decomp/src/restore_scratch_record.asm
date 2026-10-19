; Bank 1. WalkPointerSlots calls this after it finishes the slot walk.
;
; $C188 is a one-byte state just before the record flags at $C189. This
; returns unless that byte is 3, then clears it. $C174 holds a pointer that
; $401E, still INCBIN, saved when it copied $1B bytes into the scratch at
; $C1A4. Those $1B bytes are written back to that pointer. What the other
; values of $C188 mean is still unknown.

DEF wRecordState EQU $C188
DEF wSavedRecord EQU $C174
DEF wRecordScratch EQU $C1A4
DEF SCRATCH_RECORD_LEN EQU $1B
DEF RECORD_STATE_COMMIT EQU $03

RestoreScratchRecord::
    ld a, [wRecordState]
    cp RECORD_STATE_COMMIT
    ret nz
    xor a
    ld [wRecordState], a
    ld a, [wSavedRecord + 1]
    ld h, a
    ld a, [wSavedRecord]
    ld l, a
    ld bc, wRecordScratch
    ld e, SCRATCH_RECORD_LEN
.copy:
    ld a, [bc]
    inc bc
    ld [hl+], a
    dec e
    jr nz, .copy
    ret

RestoreScratchRecordEnd:
