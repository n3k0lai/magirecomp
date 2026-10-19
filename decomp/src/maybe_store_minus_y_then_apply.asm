; Bank 5 at $65CA. StepClassOccupancyHandlers uses this word for
; class 2 occupancy $01.
;
; A nonzero Y step at wClearedOnRecordLoad + 1 ($C6D3) is left alone.
; A zero step is rewritten to $FF when hObjectFineY is $09 or higher.
; Fine Y below $09 skips the Y apply. Every path then adds the X step
; with ApplyFineXDelta. This routine does not write rROMB0.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineY is the name from queue_sprite_list.asm.

MaybeStoreMinusYThenApply::
    ld a, [wClearedOnRecordLoad + 1]
    cp $00
    jr nz, .applyYThenX

    ld a, [hObjectFineY]
    cp $09
    jr c, .applyXOnly

    ld a, $ff
    ld [wClearedOnRecordLoad + 1], a

.applyYThenX:
    call ApplyFineYDelta

.applyXOnly:
    call ApplyFineXDelta
    ret
