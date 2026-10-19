; Script opcode $31. The bank 1 pointer table at $4303 maps opcode $31
; (table index $11, opcodes counted from $20) here. Dispatch leaves BC at
; the operands. This opcode takes six of them.
;
; WRAM bank 7 is stored at $C937 and selected with rSVBK ($FF70). The six
; operand bytes are copied, in order, to $D3CD through $D3D2. BC advances
; past those operands. Control jumps to INITIAL_SCRIPT_HANDLER ($0A66).
;
; What the six bytes at $D3CD mean is still unknown. $C937 and rSVBK are
; the names from timer_overflow.asm. INITIAL_SCRIPT_HANDLER is the name
; from reset.asm. The stores use the literal addresses because those
; EQUs are defined later in the link.

Opcode31::
    ld a, $07
    ld [$C937], a
    ldh [$FF70], a
    ld hl, $D3CD
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    jp INITIAL_SCRIPT_HANDLER
