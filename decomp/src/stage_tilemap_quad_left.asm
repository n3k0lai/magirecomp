; Loads the top-left corner of the last staged 2x2 block (StagedPtrTable),
; steps two columns to the left, and stages the 2x2 block that starts there.
; Two columns is the width of the block, so the new block sits immediately
; to the left of the previous one. StepTilemapColumn wraps the column inside
; the 32-tile row. StageTilemapQuad then leaves C at 1.

StageTilemapQuadLeft:
    ld hl, StagedPtrTable
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld c, $fe
    call StepTilemapColumn
    call StageTilemapQuad
    ret
