; Script opcode $19. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode. This handler takes no operand, so BC is
; left where it was.
;
; Bit 7 of the byte at $FF8C is set. What that byte holds is still unknown.
; Opcode $0D, $0E, and $17 also treat $FF8C as the start of the object
; record that holds hObjectFineX. hScriptHandler is then set to
; DispatchScriptOpcode ($0A66) with the 3-byte form, and this returns.
; The next pass through hScriptHandler resumes opcode dispatch.
;
; hScriptHandler is the name from reset.asm. hObjectFineX is the name from
; queue_sprite_list.asm.

Opcode19::
    ldh a, [$FF8C]
    set 7, a
    ldh [$FF8C], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hScriptHandler + 1], a
    ret
