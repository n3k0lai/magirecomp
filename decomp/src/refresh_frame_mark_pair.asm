; Bank 3 at $7751. StageCopiedBlockArmSlot calls this when the length
; saved from [$D000] is above $08.
;
; wCallbackBank becomes 3 and wCallback becomes $776E for one RefreshFrame.
; That body, still INCBIN, writes [$CCEB] into the two map cells at $9D89.
; IdleCallback is stored at wCallback again before the return.
;
; wCallback, wCallbackBank, and IdleCallback are the names from
; default_state.asm. RefreshFrame is already source. This routine does not
; write rROMB0. $CCEB was set to $0B earlier in StageCopiedBlockArmSlot.

; Writes [$CCEB] at $9D89 and the next cell, then returns. Still INCBIN.
DEF PaintMarkPair EQU $776E

RefreshFrameMarkPair::
    ld a, $03
    ld [wCallbackBank], a
    ld a, LOW(PaintMarkPair)
    ld [wCallback], a
    ld a, HIGH(PaintMarkPair)
    ld [wCallback + 1], a
    call RefreshFrame
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
