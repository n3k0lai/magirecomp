; Loads the top-left corner of the last staged 2x2 block (StagedPtrTable),
; steps two rows up, and stages the 2x2 block that starts there.
; Two rows is the height of the block, so the new block sits immediately
; above the previous one. StepTilemapRow wraps inside the $9800 map.
; C = $FE is two rows up. StageTilemapQuad then leaves C at 1.

StageTilemapQuadUp:
    ld hl, StagedPtrTable
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld c, $fe
    call StepTilemapRow
    call StageTilemapQuad
    ret
