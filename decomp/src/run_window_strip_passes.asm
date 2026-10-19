; Bank 3 at $4260. ServiceWindowChoice plants a window strip block, then
; CallBankedHL enters here. This bank stays mapped. The routine does not
; write rROMB0.
;
; [$C939] is the strip routine for this block. The window planter stores
; StepMapStripGlyph ($2B8F) there. JumpHL calls that pointer, then
; RefreshFrame copies the glyph it staged. [$CCB5] is the pass count, the
; row length plus one. Each pass decrements it. A nonzero count jumps back
; here. Zero returns to the planter.
;
; WIN_STRIP_ROUTINE and WIN_STRIP_PASSES are the names from
; service_window_choice.asm. JumpHL and RefreshFrame are already source.

RunWindowStripPasses::
    ld hl, WIN_STRIP_ROUTINE
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    call RefreshFrame
    ld hl, WIN_STRIP_PASSES
    dec [hl]
    jp nz, RunWindowStripPasses
    ret
