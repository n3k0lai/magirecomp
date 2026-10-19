; Fill BC bytes at HL with the value in E.
;
; Each pass stores E, then decrements BC and repeats while BC is not zero.
; A count of zero wraps and fills 65536 bytes. A is left equal to E.
; HL points one past the last byte written, and BC is zero on return.

FillBytes::
.store:
    ld a, e
    ld [hl+], a
    dec bc
    ld a, c
    or b
    jr nz, .store
    ret
