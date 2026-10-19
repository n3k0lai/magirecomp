; Empty STAT handler. The LCD STAT vector pushes AF and HL, then jumps
; through hSTATHandler. Default-state setup at $082D plants this address,
; and opcode $9A plants it again when the countdown at $FFA6 reaches 0.
; This only pops those registers and returns from the interrupt.
;
; hSTATHandler is the name from lcd_stat.asm. EmptyStatHandler in
; default_state.asm is this address.

EmptyStat::
    pop hl
    pop af
    reti
