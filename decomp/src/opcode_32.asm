; Script opcode $32. The bank 1 pointer table at $4303 maps opcode $32
; (table index $12, opcodes counted from $20) here. Dispatch leaves BC at
; the operands. This opcode takes five of them.
;
; $C6D8 is set to $01 and $C6D7 is set to $FF. The first three operands
; are copied, in order, to $C6DB through $C6DD. The last two are copied
; to $C6D9 and $C6DA, so those two land between $C6D8 and the three-byte
; run. BC advances past the five operands. Control jumps to
; INITIAL_SCRIPT_HANDLER ($0A66).
;
; What the $C6D7–$C6DD bytes mean is still unknown. $C6D8 is also cleared
; by the startup tail in default_state.asm. INITIAL_SCRIPT_HANDLER is the
; name from reset.asm.

Opcode32::
    ld a, $01
    ld [$C6D8], a
    ld a, $FF
    ld [$C6D7], a
    ld hl, $C6DB
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld hl, $C6D9
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    jp INITIAL_SCRIPT_HANDLER
