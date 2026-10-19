; AND E into each of BC bytes at HL.
;
; Each pass loads [HL], keeps the bits set in E, and stores that result.
; HL advances one byte. BC counts down, and a count of zero wraps and
; walks 65536 bytes. On return A and BC are zero, and HL points one past
; the last byte.

MaskBytes::
.byte:
    ld a, [hl]
    and e
    ld [hl+], a
    dec bc
    ld a, c
    or b
    jr nz, .byte
    ret
