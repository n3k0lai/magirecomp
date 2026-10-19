; Bank 5 at $65E4. StepClassOccupancyHandlers uses this word for
; class 2 occupancy $02, and class 5 occupancy $02 uses the same word.
;
; A nonzero Y step at wClearedOnRecordLoad + 1 ($C6D3) is applied with
; ApplyFineYDelta. A zero step with hObjectFineY of $08 or higher skips
; the Y apply and adds the X step with ApplyFineXDelta. Fine Y below
; $08 stores Y step $01, then calls ApplyFineYDelta. This routine does
; not write rROMB0.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineY is the name from queue_sprite_list.asm.

MaybeStorePlusYThenApply::
    ld a, [wClearedOnRecordLoad + 1]
    cp $00
    jr nz, .applyY

    ld a, [hObjectFineY]
    cp $08
    jr nc, .applyXOnly

    ld a, $01
    ld [wClearedOnRecordLoad + 1], a

.applyY:
    call ApplyFineYDelta
    ret

.applyXOnly:
    call ApplyFineXDelta
    ret
