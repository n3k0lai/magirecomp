; Copy BC bytes from HL to DE.
;
; setup_window.asm calls this address as CopyBytes. Each pass loads [HL],
; stores it at [DE], and advances both pointers. BC is decremented before
; the zero test, so a count of zero wraps and copies 65536 bytes. On return
; A and BC are zero, and HL and DE point one past the last byte.

CopyHLToDE::
.copy:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .copy
    ret
