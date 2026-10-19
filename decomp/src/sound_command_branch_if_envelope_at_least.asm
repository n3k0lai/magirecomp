; Conditional branch on the slot's wTagEnvelopeParam: point HL at it and
; join SoundCommandBranchIfPeriodAtLeast at its compare ($4B10).

SoundCommandBranchIfEnvelopeAtLeast::
    ld a, [wSlotStreamIndex]
    ld e, a
    ld d, $00
    ld hl, wTagEnvelopeParam
    add hl, de
    jr $4B10
