; Copy three script bytes from BC into the record at HL, then return.
;
; Each byte is stored with the auto-increment form, so HL ends three bytes
; past the first store and BC ends three bytes past the first read. Callers
; use this while filling a script record. What those three fields mean is
; still unknown.

CopyThreeScriptBytes::
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, [bc]
    inc bc
    ld [hl+], a
    ret
