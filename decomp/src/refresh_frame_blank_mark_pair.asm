; Bank 3 at $779D. StageCopiedBlockArmSlot calls this when the length
; saved from [$D000] is at most $08.
;
; wCallbackBank becomes 3 and wCallback becomes $77BA for one RefreshFrame.
; That body, still INCBIN, writes tile $80 into the two map cells at $9D89.
; IdleCallback is stored at wCallback again before the return.
;
; wCallback, wCallbackBank, and IdleCallback are the names from
; default_state.asm. RefreshFrame is already source. This routine does not
; write rROMB0.

; Writes tile $80 at $9D89 and the next cell, then returns. Still INCBIN.
DEF PaintBlankMarkPair EQU $77BA

RefreshFrameBlankMarkPair::
    ld a, $03
    ld [wCallbackBank], a
    ld a, LOW(PaintBlankMarkPair)
    ld [wCallback], a
    ld a, HIGH(PaintBlankMarkPair)
    ld [wCallback + 1], a
    call RefreshFrame
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
