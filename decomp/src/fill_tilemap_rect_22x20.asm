; Paints a 22x20 tile rectangle whose top-left corner is the tilemap address
; at $C863/$C864 (the same word the scroll steps keep). Tile byte $FF and
; attribute $8F are the two staged bytes WriteStagedBytesAtFourPtrs stores,
; once per corner of each 2x2 block.
;
; StageTilemapQuad plants the first block. The calls after it walk adjacent
; blocks: ten right, nine down, ten left, eight up, then a tighter spiral
; (9, 7, 8, 6, 7, 5, 6, 4, 5, 3, 4, 2, 3, 1, 2). That path visits each of
; the 11x10 blocks once. Right and down step from the far corner of the
; last block, so each call advances two tiles. Left and up step two tiles
; back from the top-left. The steppers wrap inside the $9800 map.
; The tail is FinishStartup in bank 0.

FillTilemapRect22x20:
    ld a, $ff
    ld [StagedTileByte], a
    ld a, $8f
    ld [StagedAttrByte], a
    ld hl, $c863
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call StageTilemapQuad
    REPT 10
        call StageTilemapQuadRight
    ENDR
    REPT 9
        call StageTilemapQuadDown
    ENDR
    REPT 10
        call StageTilemapQuadLeft
    ENDR
    REPT 8
        call StageTilemapQuadUp
    ENDR
    REPT 9
        call StageTilemapQuadRight
    ENDR
    REPT 7
        call StageTilemapQuadDown
    ENDR
    REPT 8
        call StageTilemapQuadLeft
    ENDR
    REPT 6
        call StageTilemapQuadUp
    ENDR
    REPT 7
        call StageTilemapQuadRight
    ENDR
    REPT 5
        call StageTilemapQuadDown
    ENDR
    REPT 6
        call StageTilemapQuadLeft
    ENDR
    REPT 4
        call StageTilemapQuadUp
    ENDR
    REPT 5
        call StageTilemapQuadRight
    ENDR
    REPT 3
        call StageTilemapQuadDown
    ENDR
    REPT 4
        call StageTilemapQuadLeft
    ENDR
    REPT 2
        call StageTilemapQuadUp
    ENDR
    REPT 3
        call StageTilemapQuadRight
    ENDR
    call StageTilemapQuadDown
    REPT 2
        call StageTilemapQuadLeft
    ENDR
    jp FinishStartup
