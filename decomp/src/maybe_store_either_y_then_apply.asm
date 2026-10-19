; Bank 5 at $65FF. StepClassOccupancyHandlers uses this word for
; class 2 occupancy $03, and class 5 occupancy $03 uses the same word.
;
; A nonzero Y step at wClearedOnRecordLoad + 1 ($C6D3) is applied with
; ApplyFineYDelta. A zero step reads hObjectFineY. Exactly $08 skips the
; Y apply and adds the X step with ApplyFineXDelta. Fine Y below $08
; stores Y step $01, then calls ApplyFineYDelta. Fine Y of $09 or higher
; stores Y step $FF, then calls ApplyFineYDelta. This routine does not
; write rROMB0.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineY is the name from queue_sprite_list.asm.

MaybeStoreEitherYThenApply::
    ld a, [wClearedOnRecordLoad + 1]
    cp $00
    jr nz, .applyY

    ld a, [hObjectFineY]
    cp $08
    jr z, .applyXOnly
    jr nc, .storeMinusY

    ld a, $01
    ld [wClearedOnRecordLoad + 1], a

.applyY:
    call ApplyFineYDelta
    ret

.storeMinusY:
    ld a, $ff
    ld [wClearedOnRecordLoad + 1], a
    call ApplyFineYDelta
    ret

.applyXOnly:
    call ApplyFineXDelta
    ret
