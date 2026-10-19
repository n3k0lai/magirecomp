; Bank 2 at $5E5E. InitWram7BeforeReset calls here after it stores $51C2
; at $D35D. $D3C2 is set to 1. FinishFrame, at $08BB, then runs until
; something it calls stores zero there. FinishFrame is the name from
; finish_frame.asm.

WaitUntilD3C2Clears::
    ld a, $01
    ld [$D3C2], a
.spin:
    call FinishFrame
    ld a, [$D3C2]
    and a
    jr nz, .spin
    ret
