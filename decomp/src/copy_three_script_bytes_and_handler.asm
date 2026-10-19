; Copy three script bytes from BC into the record at HL, plant
; DispatchScriptOpcode as the next word, skip two bytes, and return.
;
; Each of the three script bytes is stored with the auto-increment form, so
; HL then points at the handler word. That word is written little-endian as
; the address of DispatchScriptOpcode ($0A66). The two bytes after it are
; left unchanged. What those two fields mean is still unknown. BC ends three
; bytes past the first read. Callers use this while filling a script record.

CopyThreeScriptBytesAndHandler::
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hl+], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hl+], a
    inc hl
    inc hl
    ret
