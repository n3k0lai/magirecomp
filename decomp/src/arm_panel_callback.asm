; Bank 7 at $474F. DispatchNonzeroD016 calls this once per pass of the
; [$D016] = 3 frame loop, after $489D and before FinishFrame.
;
; $C831 is set by the panel writers, including FillPanelWordsFromC9DA,
; when they store words. If that byte is nonzero, this clears it and
; points wCallback at $4575 in this bank. $4575 is still INCBIN: it calls
; $445F and $44EA, then stores IdleCallback back into wCallback.
;
; If $C831 is already zero, wCallback is set to IdleCallback and
; wCallbackBank is left alone.
;
; wCallback, wCallbackBank, and IdleCallback are the names from
; default_state.asm. $C831 is still unnamed.

; Bank 7, still INCBIN. Runs once after a panel write, then restores the idle callback.
DEF PanelRefreshCallback EQU $4575

ArmPanelCallback::
    ld a, [$C831]
    and a
    jr z, .idle
    xor a
    ld [$C831], a
    ld a, BANK(@)
    ld [wCallbackBank], a
    ld a, LOW(PanelRefreshCallback)
    ld [wCallback], a
    ld a, HIGH(PanelRefreshCallback)
    ld [wCallback + 1], a
    ret

.idle:
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
