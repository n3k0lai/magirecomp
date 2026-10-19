; Bank 5 at $65BC. StepClassOccupancyHandlers uses this word for
; occupancy $04 and $06 in step classes 0, 1, and 3, and for occupancy
; $07 in step class 2. AddXStepOrSnapFineXToEight adds the signed byte
; at $C6D2 into hObjectFineX and snaps that sum to $08 when it crosses
; eight. ApplyFineYDelta adds the signed byte at $C6D3 into
; hObjectFineY. This routine does not write rROMB0.

ApplyXSnapThenFineY::
    call AddXStepOrSnapFineXToEight
    call ApplyFineYDelta
    ret
