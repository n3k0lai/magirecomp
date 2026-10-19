; Bank 5 at $65C3. StepClassOccupancyHandlers uses this word for
; occupancy $05 and $07 in step classes 0, 1, and 3.
; AddXStepOrSnapFineXToEight adds the signed byte at $C6D2 into
; hObjectFineX and snaps that sum to $08 when it crosses eight.
; ApplyYStepIntoFineY adds the signed byte at $C6D3 into hObjectFineY
; and stores $08 when that sum crosses eight. This routine does not
; write rROMB0.

ApplyXSnapThenYStep::
    call AddXStepOrSnapFineXToEight
    call ApplyYStepIntoFineY
    ret
