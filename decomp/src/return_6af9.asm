; Bank 4 at $6AF9. One `ret` between StepRowMaskVram and
; SeedRowMaskAndRecord. This routine does not write rROMB0.
; Nothing in the neighboring lifted code calls or stores $6AF9.
; What plants this address is still unknown.

Return6AF9::
    ret
