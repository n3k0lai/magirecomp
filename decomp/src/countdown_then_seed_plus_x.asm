; Bank 5 at $66FA. $C6D6 is a countdown. A nonzero count is
; decremented, then ApplyFineXDelta adds the X step at
; wClearedOnRecordLoad ($C6D2) into hObjectFineX.
;
; A zero count calls ApplyYStepIntoFineY, which adds the Y step at
; wClearedOnRecordLoad + 1 into hObjectFineY. If the X step is still
; zero, $01 is stored there. ApplyFineXDelta then runs.
;
; This is the plus-one twin of CountdownThenSeedMinusX at $66DD, which
; stores $FF in the same slot. This routine does not write rROMB0.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineX is the name from queue_sprite_list.asm.
; ApplyYStepIntoFineY is the routine at $675A. ApplyFineXDelta is the
; routine at $67B1.

CountdownThenSeedPlusX::
    ld hl, $c6d6
    ld a, [hl]
    and a
    jr z, .countDone

    dec [hl]
    jr .applyX

.countDone:
    call ApplyYStepIntoFineY
    ld a, [wClearedOnRecordLoad]
    cp $00
    jr nz, .applyX

    ld a, $01
    ld [wClearedOnRecordLoad], a

.applyX:
    call ApplyFineXDelta
    ret
