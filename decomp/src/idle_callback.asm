; Idle callback. SetupDefaultState and several finished paint paths store
; this address at wCallback. The body writes that same address back and
; returns, so the next call stays here.
;
; IdleCallback and wCallback are the names from default_state.asm. The
; EQU there is this address, so the label below is a second name.

ReinstallIdleCallback::
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
