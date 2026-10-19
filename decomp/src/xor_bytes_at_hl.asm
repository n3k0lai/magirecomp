; XOR BC bytes at HL with the value in E.
;
; Each pass loads [HL], XORs it with E, stores the result, and advances HL.
; BC is decremented before the zero test, so a count of zero wraps and
; touches 65536 bytes. On return A is the last byte stored, HL points one
; past that byte, and BC is zero.

XorHLWithE::
.store:
    ld a, [hl]
    xor e
    ld [hl+], a
    dec bc
    ld a, c
    or b
    jr nz, .store
    ret
