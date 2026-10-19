; Script opcode $14. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; HL is the pointer stored at $FF8A (low) and $FF8B (high), both read with
; the 3-byte form. What that pointer addresses is still unknown. HL then
; advances by $11, and the next script byte is stored there with the
; auto-increment form.
;
; CopyTwoScriptBytesAndHandler writes the next two script bytes, plants
; DispatchScriptOpcode as the following word, and skips the two bytes after
; that word. Together with the byte stored here, that is a seven-byte script
; record at offset $11. BC is left on the opcode after those three operand
; bytes. Control returns through jp DispatchScriptOpcode.
;
; CopyTwoScriptBytesAndHandler is the name from
; copy_two_script_bytes_and_handler.asm.

Opcode14::
    ld a, [$ff8b]
    ld h, a
    ld a, [$ff8a]
    ld l, a
    ld de, $0011
    add hl, de
    ld a, [bc]
    inc bc
    ld [hl+], a
    call CopyTwoScriptBytesAndHandler
    jp DispatchScriptOpcode
