; Bank 3 at $77C2. StageCopiedBlockArmSlot calls this after $CCE3 is cleared.
;
; wCallbackBank becomes 3 and wCallback becomes $77DF for one RefreshFrame.
; That body, still INCBIN, writes tile $80 into the two map cells at $9C29.
; IdleCallback is stored at wCallback again before the return.
;
; wCallback, wCallbackBank, and IdleCallback are the names from
; default_state.asm. RefreshFrame is already source. This routine does not
; write rROMB0.

; Writes tile $80 at $9C29 and the next cell, then returns. Still INCBIN.
DEF PaintWindowPair EQU $77DF

RefreshFrameWindowPair::
    ld a, $03
    ld [wCallbackBank], a
    ld a, LOW(PaintWindowPair)
    ld [wCallback], a
    ld a, HIGH(PaintWindowPair)
    ld [wCallback + 1], a
    call RefreshFrame
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
