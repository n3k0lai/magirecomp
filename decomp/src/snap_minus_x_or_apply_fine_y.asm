; Bank 5 at $6670. StepClassOccupancyHandlers uses this word for
; class 6 occupancy $01, and class 7 occupancy $01 uses the same word.
;
; A nonzero X step at wClearedOnRecordLoad ($C6D2) calls ApplyFineXDelta.
; A zero step reads hObjectFineX ($FF8F). Fine X below $09 calls
; ApplyFineYDelta. Fine X of at least $09 stores $FF as the X step,
; then calls ApplyFineXDelta.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineX is the name from queue_sprite_list.asm.
; ApplyFineXDelta is the routine at $67B1. ApplyFineYDelta is the
; routine at $67E7. This routine does not write rROMB0.

SnapMinusXOrApplyFineY::
    ld a, [wClearedOnRecordLoad]
    cp $00
    jr nz, .applyX

    ld a, [hObjectFineX]
    cp $09
    jr c, .applyY

    ld a, $ff
    ld [wClearedOnRecordLoad], a

.applyX:
    call ApplyFineXDelta
    ret

.applyY:
    call ApplyFineYDelta
    ret
