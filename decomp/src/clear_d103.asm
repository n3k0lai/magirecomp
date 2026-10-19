; Bank 2 at $71D9. Index 15 of D0F0JumpWords. JumpHL calls this when
; bit 6 of $D0EE is clear.
;
; Writes zero into the slot selection at $D103.

ClearD103::
    xor a
    ld [$D103], a
    ret
