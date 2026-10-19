; Bank 1 at $48BE. Opcode9ACountdown stores this as wCallback with bank 1.
;
; wWindowX is copied to rWX. wWindowY is copied to rWY and to rLYC, so
; the STAT line matches the window's top. wCallback then becomes
; IdleCallback. That address is in ROM0, so the bank byte is left alone.
;
; The rWX, rWY, and rLYC stores are ldh. wCallback is the 3-byte form.
; wWindowX, wWindowY, rWX, and rWY are the names from setup_window.asm.
; wCallback and IdleCallback are the names from default_state.asm.
; rLYC is $FF45.

DEF rLYC EQU $FF45

CopyWindowPosition::
    ld a, [wWindowX]
    ldh [rWX], a
    ld a, [wWindowY]
    ldh [rWY], a
    ldh [rLYC], a
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
