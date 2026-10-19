; Bank 3 at $7777. Called when $CCC8 minus $08 is not $08, and from
; the copied-block choice steps after $CD81 is set from $CCA7.
;
; wCallbackBank becomes 3 and wCallback becomes $7794 for one RefreshFrame.
; That body, still INCBIN, writes [$CCEB] into the two map cells at $9C29
; (vGroupDownTiles, column 9 of BG-map row 1). IdleCallback is stored at
; wCallback again before the return.
;
; wCallback, wCallbackBank, and IdleCallback are the names from
; default_state.asm. vGroupDownTiles is the name from scan_group_bytes.asm.
; RefreshFrame is already source. This routine does not write rROMB0.

; Writes [$CCEB] at $9C29 and the next cell, then returns. Still INCBIN.
DEF PaintMarkWindowPair EQU $7794

RefreshFrameMarkWindowPair::
    ld a, $03
    ld [wCallbackBank], a
    ld a, LOW(PaintMarkWindowPair)
    ld [wCallback], a
    ld a, HIGH(PaintMarkWindowPair)
    ld [wCallback + 1], a
    call RefreshFrame
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
