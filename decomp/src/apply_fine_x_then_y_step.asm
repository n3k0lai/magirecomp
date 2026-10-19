; Bank 5 at $65B5. StepClassOccupancyHandlers uses this word for
; occupancy $01, $02, and $03 in step classes 0, 1, and 3.
; ApplyFineXDelta adds the signed byte at $C6D2 into hObjectFineX.
; ApplyYStepIntoFineY adds the signed byte at $C6D3 into hObjectFineY
; and stores $08 when that sum crosses eight. This routine does not
; write rROMB0.

ApplyFineXThenYStep::
    call ApplyFineXDelta
    call ApplyYStepIntoFineY
    ret
