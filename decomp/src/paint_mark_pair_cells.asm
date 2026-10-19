; Bank 3 at $776E. RefreshFrameMarkPair plants this as wCallback
; for one RefreshFrame, with wCallbackBank set to 3.
;
; Both cells of the pair at $9D89 become the tile in [$CCEB].
; The second cell is the next byte. This routine does not write
; rROMB0 and does not call out.
;
; wCallback is the name from default_state.asm. $CCEB was set to $0B
; earlier in StageCopiedBlockArmSlot. $9D89 is column 9 of the row
; twelve tiles below the $9C00 map.

PaintMarkPairCells::
    ld hl, $9D89
    ld a, [$CCEB]
    ld [hl+], a
    ld [hl], a
    ret
