; Loads the bottom-left corner of the last staged 2x2 block (StagedPtrTable+4),
; steps one row down, and stages the 2x2 block that starts there.
; The previous block is two rows tall, so the new block sits immediately
; below it. StepTilemapRow wraps inside the $9800 map. C is left at 1.

StageTilemapQuadDown:
    ld hl, StagedPtrTable + 4
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld c, $01
    call StepTilemapRow
    call StageTilemapQuad
    ret
