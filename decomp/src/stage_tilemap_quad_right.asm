; Loads the top-right corner of the last staged 2x2 block (StagedPtrTable+2),
; steps one column to the right, and stages the 2x2 block that starts there.
; The new block sits immediately to the right of the previous one.
; StepTilemapColumn wraps the column inside the 32-tile row. C is left at 1.

StageTilemapQuadRight:
    ld hl, StagedPtrTable + 2
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld c, $01
    call StepTilemapColumn
    call StageTilemapQuad
    ret
