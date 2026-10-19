; Scale wCountdownStep by BC. BC = 0 goes to FillCountdownStep. Otherwise
; the 32-bit product from MultiplyHlByBc32 is taken in its middle bytes
; (H of the low word, C of the high word) and stored back as the step.

ScaleCountdownStep::
    ld a, c
    or b
    jr z, FillCountdownStep
    ld hl, wCountdownStep
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call MultiplyHlByBc32
    ld a, h
    ld hl, wCountdownStep
    ld [hl+], a
    ld [hl], c
    ret
