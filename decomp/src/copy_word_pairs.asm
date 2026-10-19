; Bank 0 at $2EB6. StageMapPanelSources calls this with BC = $4000,
; HL = $C72B, E = $00, and A = $18. FillMapPanelTiles calls it with
; BC = $4030, HL = $C72B, E = $1C, and A = $04. $2EC3 and $2EE9, still
; INCBIN, call it the same way with A = $20.
;
; E is doubled and added to HL, so the destination skips that many
; existing word pairs. A is then the pair count. $2F0F, still INCBIN,
; copies that many pairs from BC into HL, two bytes at a time.

CopyWordPairs::
    ld d, a
    ld a, e
    add a
    ld e, a
    ld a, d
    ld d, $00
    add hl, de
    ld e, a
    call CopyEWordPairs
    ret
