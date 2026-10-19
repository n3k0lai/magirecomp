; Bank 5 at $6625. StepClassOccupancyHandlers uses this word for
; class 2 occupancy $04, and class 5 occupancy $04 uses the same word.
;
; Adds the X step with AddXStepOrSnapFineXToEight. A zero Y step at
; wClearedOnRecordLoad + 1 ($C6D3) is seeded from the fine Y ends with
; SeedYStepFromFineYEnds. Every path then calls ApplyFineYDelta.
; This routine does not write rROMB0.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.

SnapXThenMaybeSeedY::
    call AddXStepOrSnapFineXToEight
    ld a, [wClearedOnRecordLoad + 1]
    cp $00
    jr nz, .applyY

    call SeedYStepFromFineYEnds

.applyY:
    call ApplyFineYDelta
    ret
