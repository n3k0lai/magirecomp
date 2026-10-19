; Script opcode $12. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode. This opcode takes no operand, so BC is left
; where it was.
;
; $C188 is set to 3. RestoreScratchRecord treats that value as
; RECORD_STATE_COMMIT and, when it sees it, writes the scratch record back.
; The next two bytes, $C18A and $C18B, are set to $10 and $5E. What those
; bytes are used for is still unknown.
;
; Control then leaves through jp $1402. That tail is still INCBIN, so this
; does not return to the caller of the handler.

Opcode12::
    ld a, $03
    ld [$c188], a
    ld a, $10
    ld [$c18a], a
    ld a, $5e
    ld [$c18b], a
    jp $1402
