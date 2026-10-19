; Bank 3 at $4511. Same pass shape as RunWindowStripPasses at $4260,
; with FinishFrame in place of RefreshFrame and a short branch back.
; This bank stays mapped. The routine does not write rROMB0.
;
; [$C939] is the strip routine for this block. JumpHL calls that pointer,
; then FinishFrame runs the frame tail. [$CCB5] is the pass count. Each
; pass decrements it. A nonzero count jumps back here. Zero returns.
;
; JumpHL and FinishFrame are already source.

RunStripPassesThenFinish::
    ld hl, $c939
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    call FinishFrame
    ld hl, $ccb5
    dec [hl]
    jr nz, RunStripPassesThenFinish
    ret
