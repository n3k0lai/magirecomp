; Copy two script bytes from BC into the record at HL, plant
; DispatchScriptOpcode as the next word, skip two bytes, and return.
;
; Each script byte is stored with the auto-increment form, so HL then points
; at the handler word. That word is written little-endian as the address of
; DispatchScriptOpcode ($0A66). The low byte uses ld a / ld [hl+]; the high
; byte is an immediate store, then one inc hl. The two bytes after the word
; are left unchanged. What those two fields mean is still unknown. BC ends
; two bytes past the first read. Callers use this while filling a script
; record.

CopyTwoScriptBytesAndHandler::
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hl+], a
    ld [hl], HIGH(DispatchScriptOpcode)
    inc hl
    inc hl
    inc hl
    ret
