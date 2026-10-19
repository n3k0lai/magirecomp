; Bank 5 at $65AE. StepClassOccupancyHandlers uses this word for
; occupancy $00 in step classes 0-3. ApplyFineXDelta adds the signed
; byte at $C6D2 into hObjectFineX. ApplyFineYDelta adds the signed
; byte at $C6D3 into hObjectFineY. This routine does not write rROMB0.

ApplyFineXThenFineY::
    call ApplyFineXDelta
    call ApplyFineYDelta
    ret
