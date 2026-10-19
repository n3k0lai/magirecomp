; Bank 5 at $6653. StepClassOccupancyHandlers uses this word for
; class 2 occupancy $06, and class 5 occupancy $06 uses the same word.
;
; $C6D6 is a countdown. A nonzero count is decremented, then
; ApplyFineYDelta adds the Y step at wClearedOnRecordLoad + 1 ($C6D3)
; into hObjectFineY.
;
; A zero count calls AddXStepOrSnapFineXToEight. If the Y step is still
; zero, $01 is stored there. ApplyFineYDelta then runs.
;
; The copy at $6636 stores $FF instead of $01.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineY is the name from queue_sprite_list.asm.
; AddXStepOrSnapFineXToEight is the routine at $6717. ApplyFineYDelta
; is the routine at $67E7. This routine does not write rROMB0.

CountdownOrSnapXThenSeedPlusY::
    ld hl, $c6d6
    ld a, [hl]
    and a
    jr z, .countDone

    dec [hl]
    jr .applyY

.countDone:
    call AddXStepOrSnapFineXToEight
    ld a, [wClearedOnRecordLoad + 1]
    cp $00
    jr nz, .applyY

    ld a, $01
    ld [wClearedOnRecordLoad + 1], a

.applyY:
    call ApplyFineYDelta
    ret
