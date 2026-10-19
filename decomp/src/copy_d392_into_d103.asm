; Bank 2 at $718A. Index 9 of D0F0JumpWords. JumpHL calls this from
; $6BBA when bit 6 of $D0EE is clear.
;
; Copies the byte at $D392 into the slot selection at $D103.

CopyD392IntoD103::
    ld a, [$D392]
    ld [$D103], a
    ret
