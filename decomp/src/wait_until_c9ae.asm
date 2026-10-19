; Bank 4 at $632E.
;
; $6439 runs first. That routine is still INCBIN. Each pass then maps bank 7
; and calls ArmPanelCallback, then FinishFrame. The loop repeats while $C9AE
; is zero. ClearMapScrollBytes stores zero there. When $C9AE is nonzero the
; loop ends, $629C runs, and this returns. $629C is still INCBIN.
;
; CallBankedHL is the name from call_hl_in_bank.asm. FinishFrame is the name
; from finish_frame.asm. ArmPanelCallback is the name from
; arm_panel_callback.asm.

WaitUntilC9AE::
    call $6439
.loop
    ld hl, ArmPanelCallback
    ld e, $07
    call CallBankedHL
    call FinishFrame
    ld a, [$C9AE]
    and a
    jr z, .loop
    call $629C
    ret
