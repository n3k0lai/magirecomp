; Second entry of the tag-priming code: save DE, set D = 1 and join the
; shared path at $4F1E (PrimeChannelFromTag starts at $4F1A with a
; different D).

PrimeChannelFromTagD1::
    push de
    ld d, $01
    jr $4F1E
