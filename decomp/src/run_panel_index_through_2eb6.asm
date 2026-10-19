; Bank 7 at $481E. StageMapPanelSources and FillMapPanelTiles map this bank,
; store an index in wUnknownC9D8, and call here.
;
; $C831 is cleared. $47DD, still INCBIN, returns HL = $C72B plus eight times
; the high nibble of that index. That pointer is saved in BC, and HL is moved
; $80 bytes past it. $47F8, still INCBIN, leaves A as the low byte and E as
; the high byte of four times (the low nibble plus one). $2EB6, still INCBIN,
; is called with those four values. $C831 is set to $01 before the return.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. Call_2EB6 is the name
; from stage_map_panel_sources.asm. $C831, $C72B, and what $2EB6 does with
; BC, HL, E, and A are still unknown.

RunPanelIndexThrough2EB6::
    xor a
    ld [$C831], a
    call PanelRowFromHighNibble
    push hl
    ld bc, $0080
    add hl, bc
    pop bc
    call PanelQuadFromLowNibble
    call Call_2EB6
    ld a, $01
    ld [$C831], a
    ret
