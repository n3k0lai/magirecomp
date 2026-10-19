; Map the ROM bank in E, call HL, and restore the previous bank.
;
; default_state.asm calls this address as CallHLInBank. HL is the routine.
; The call goes through JumpHL, so that routine's ret returns here. A comes
; back as the bank that was mapped on entry, and the flags are the flags
; from entry.
;
; $0778 enters with the new bank already in A and the bank to restore
; already pushed. $0782 maps the bank in A and returns.
; rROMB0 and wCurrentROMBank are the names from reset.asm. JumpHL is the
; name from jump_hl.asm.

CallBankedHL::
    ld a, [wCurrentROMBank]
    push af
    ld a, e
; $0778. A is the ROM bank to map. The previous bank is on the stack.
.in_a:
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call JumpHL
    pop af
; $0782. A is the ROM bank to map.
.set_bank:
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
