; Bank 3 at $77BA. RefreshFrameBlankMarkPair plants this as wCallback
; for one RefreshFrame, with wCallbackBank set to 3.
;
; Both cells of the pair at $9D89 become tile $80, the blank tile.
; The second cell is the next byte. This routine does not write
; rROMB0 and does not call out.
;
; GROUP_BLANK_TILE is the name from scan_group_bytes.asm. wCallback
; is the name from default_state.asm. $9D89 is column 9 of the row
; twelve tiles below the $9C00 map, the same pair PaintMarkPairCells
; stamps from [$CCEB].

PaintBlankMarkPairCells::
    ld hl, $9D89
    ld a, GROUP_BLANK_TILE
    ld [hl+], a
    ld [hl], a
    ret
