; Script opcode $16. DispatchScriptOpcode jumps here with BC still pointing
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
; those operands is a repeat count.
;
; Zero means the next two script bytes are skipped and another record follows
; at the same offset, so the handler loops. A nonzero count is saved at $FFA6
; with ldh, and BC is saved at hScriptPtr (low at $FFA2, high at $FFA3) with
; the 3-byte form, still pointing at those two bytes.
;
; hScriptHandler ($FFA4) is set to Opcode16AddScroll ($0D97), also with the
; 3-byte form. That entry, which also runs immediately, adds the two bytes
; to $C843 and $C844. refresh_frame.asm names those the horizontal and
; vertical scroll deltas. Until the count reaches zero the handler stores
; the new count and returns, leaving hScriptPtr on the same pair so the next
; call adds it again. On the last count it saves BC past the pair and points
; hScriptHandler back at Opcode16. What calls the planted handler, and what
; $FFA6 means beside this countdown, is still unknown.
;
; hScriptPtr and hScriptHandler are the names from reset.asm.
; CopyTwoScriptBytesAndHandler is the name from
; copy_two_script_bytes_and_handler.asm.

Opcode16::
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
    jp nz, Opcode16ArmScroll

    inc bc
    inc bc
    jr Opcode16

Opcode16ArmScroll::
    ldh [$ffa6], a
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(Opcode16AddScroll)
    ld [hScriptHandler], a
    ld a, HIGH(Opcode16AddScroll)
    ld [hScriptHandler + 1], a

Opcode16AddScroll::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [$c843]
    add l
    ld [$c843], a
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [$c844]
    add l
    ld [$c844], a
    ldh a, [$ffa6]
    dec a
    jr z, Opcode16ResetHandler

    ldh [$ffa6], a
    ret

Opcode16ResetHandler::
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(Opcode16)
    ld [hScriptHandler], a
    ld a, HIGH(Opcode16)
    ld [hScriptHandler + 1], a
    ret
