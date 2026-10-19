; Bank 5 at $668B. StepClassOccupancyHandlers uses this word for
; class 6 occupancy $02, and class 7 occupancy $02 uses the same word.
;
; A nonzero X step at wClearedOnRecordLoad ($C6D2) calls ApplyFineXDelta.
; A zero step reads hObjectFineX ($FF8F). Fine X of at least $08 calls
; ApplyFineYDelta. Fine X below $08 stores $01 as the X step, then
; calls ApplyFineXDelta.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineX is the name from queue_sprite_list.asm.
; ApplyFineXDelta is the routine at $67B1. ApplyFineYDelta is the
; routine at $67E7. This routine does not write rROMB0.

SnapPlusXOrApplyFineY::
    ld a, [wClearedOnRecordLoad]
    cp $00
    jr nz, .applyX

    ld a, [hObjectFineX]
    cp $08
    jr nc, .applyY

    ld a, $01
    ld [wClearedOnRecordLoad], a

.applyX:
    call ApplyFineXDelta
    ret

.applyY:
    call ApplyFineYDelta
    ret
