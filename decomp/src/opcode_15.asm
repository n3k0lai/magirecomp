; Script opcode $15. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; HL is the pointer stored at $FF8A (low) and $FF8B (high), both read with
; the 3-byte form. What that pointer addresses is still unknown. HL then
; advances by $11. The next script byte is a record id. Zero ends the list:
; that byte is consumed and control returns through jp DispatchScriptOpcode.
;
; A nonzero id is stored with the auto-increment form. CopyTwoScriptBytesAndHandler
; then writes the next two script bytes, plants DispatchScriptOpcode as the
; following word, and skips the two bytes after that word. The byte after
; those operands is a repeat count. Zero means another record follows at the
; same offset, so the handler loops. A nonzero count is saved at $FFA6 with
; ldh, and BC is saved at hScriptPtr (low at $FFA2, high at $FFA3) with the
; 3-byte form.
;
; hScriptHandler ($FFA4) is set to Opcode15Countdown ($0D50), also with the
; 3-byte form. That entry decrements $FFA6. Until the count reaches zero it
; stores the new count and returns. On the last count it points
; hScriptHandler back at Opcode15 so the next pass reads the following
; record. What calls the planted handler, and what $FFA6 means beside this
; countdown, is still unknown.
;
; hScriptPtr and hScriptHandler are the names from reset.asm.
; CopyTwoScriptBytesAndHandler is the name from
; copy_two_script_bytes_and_handler.asm.

Opcode15::
    ld a, [$ff8b]
    ld h, a
    ld a, [$ff8a]
    ld l, a
    ld de, $0011
    add hl, de
    ld a, [bc]
    inc bc
    and a
    jp z, DispatchScriptOpcode

    ld [hl+], a
    call CopyTwoScriptBytesAndHandler
    ld a, [bc]
    inc bc
    and a
    jr z, Opcode15

    ldh [$ffa6], a
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a

Opcode15PlantCountdown::
    ld a, LOW(Opcode15Countdown)
    ld [hScriptHandler], a
    ld a, HIGH(Opcode15Countdown)
    ld [hScriptHandler + 1], a

Opcode15Countdown::
    ldh a, [$ffa6]
    dec a
    jr z, Opcode15ResetHandler

    ldh [$ffa6], a
    ret

Opcode15ResetHandler::
    ld a, LOW(Opcode15)
    ld [hScriptHandler], a
    ld a, HIGH(Opcode15)
    ld [hScriptHandler + 1], a
    ret
