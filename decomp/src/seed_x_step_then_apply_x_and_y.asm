; Bank 5 at $66CC. A zero X step at wClearedOnRecordLoad ($C6D2)
; calls $673E, which writes that step from the ends of hObjectFineX:
; $00 stores $FF, $0F stores $01, and any other fine X stores $00.
; A nonzero step skips that call.
;
; ApplyFineXDelta then adds the X step into hObjectFineX. $675A adds
; the Y step at wClearedOnRecordLoad + 1 into hObjectFineY and rewrites
; that Y step. What $675A does past the first compare is still unknown.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineX is the name from queue_sprite_list.asm.
; This routine does not write rROMB0.

SeedXStepThenApplyXAndY::
    ld a, [wClearedOnRecordLoad]
    cp $00
    jr nz, .applyBoth

    call $673e

.applyBoth:
    call ApplyFineXDelta
    call $675a
    ret
