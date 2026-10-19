; Bank 5 at $66C8. SetXStepFromFineX jumps here when hObjectFineX is
; exactly $08. The X step at wClearedOnRecordLoad is left alone.
; ApplyFineYDelta adds the signed byte at $C6D3 into hObjectFineY.
; This routine does not write rROMB0.

ApplyFineYWhenFineXIsEight::
    call ApplyFineYDelta
    ret
