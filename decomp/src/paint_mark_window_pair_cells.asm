; Bank 3 at $7794. RefreshFrameMarkWindowPair plants this as wCallback
; for one RefreshFrame, with wCallbackBank set to 3.
;
; Both cells of the pair at $9C29 (vGroupDownTiles, column 9 of BG-map
; row 1) become the tile in [$CCEB]. The second cell is the next byte.
; This routine does not write rROMB0 and does not call out.
;
; vGroupDownTiles is the name from scan_group_bytes.asm. wCallback is
; the name from default_state.asm. $CCEB was set to $0B earlier in
; StageCopiedBlockArmSlot. PaintWindowPairCells stamps the same pair
; with the blank tile.

PaintMarkWindowPairCells::
    ld hl, vGroupDownTiles
    ld a, [$CCEB]
    ld [hl+], a
    ld [hl], a
    ret
