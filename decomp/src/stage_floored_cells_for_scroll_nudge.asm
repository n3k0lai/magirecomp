; Script step at $1D6B. The next script word is a pointer. HL is that
; word plus 5. E is MAP_CELL_BIAS ($FB). Each of the two bytes at HL is
; stored at $FFA6, then $FFA7: a byte below 5 becomes 0, and any other
; byte is added to the bias (the byte minus 5). BC, now past the word,
; is saved as hScriptPtr. hScriptHandler becomes
; NudgeScrollDeltasFromScriptByte ($1D2A).
;
; MAP_CELL_BIAS is the name from store_map_cell_from_de_minus5.asm.
; NudgeScrollDeltasFromScriptByte is the name from
; nudge_scroll_deltas_from_script_byte.asm. hScriptPtr and
; hScriptHandler are the names from reset.asm. $FFA6 and $FFA7 have no
; names yet. Nothing here calls or jumps into an INCBIN.

DEF CELL_UNDER_BIAS EQU $05

StageFlooredCellsForScrollNudge::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld de, CELL_UNDER_BIAS
    add hl, de
    ld e, MAP_CELL_BIAS
    ld a, [hl+]
    ld d, a
    cp CELL_UNDER_BIAS
    ld a, $00
    jr c, .storeColumn
    ld a, d
    add e
.storeColumn:
    ld [$FFA6], a
    ld a, [hl+]
    ld d, a
    cp CELL_UNDER_BIAS
    ld a, $00
    jr c, .storeRow
    ld a, d
    add e
.storeRow:
    ld [$FFA7], a
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(NudgeScrollDeltasFromScriptByte)
    ld [hScriptHandler], a
    ld a, HIGH(NudgeScrollDeltasFromScriptByte)
    ld [hScriptHandler + 1], a
    ret
