; Script step at $1D4C. L is $FB, the same bias StoreMapCellFromDEMinus5
; uses for a map cell. The next two script bytes are each added to that
; bias and stored at $FFA6 and $FFA7. NudgeScrollDeltasFromScriptByte
; compares those bytes with the map column and row.
;
; BC, now past those two bytes, is saved as hScriptPtr (high byte first,
; 3-byte form). $1D5C is an entry that stores only the low byte and
; plants the same handler. hScriptHandler becomes
; NudgeScrollDeltasFromScriptByte ($1D2A). That step reads the following
; script byte as the camera delta.
;
; MAP_CELL_BIAS is the name from store_map_cell_from_de_minus5.asm.
; NudgeScrollDeltasFromScriptByte is the name from
; nudge_scroll_deltas_from_script_byte.asm. hScriptPtr and
; hScriptHandler are the names from reset.asm. $FFA6 and $FFA7 have no
; names yet. Nothing here calls or jumps into an INCBIN.

StageBiasedCellsForScrollNudge::
    ld l, MAP_CELL_BIAS
    ld a, [bc]
    inc bc
    add l
    ldh [$FFA6], a
    ld a, [bc]
    inc bc
    add l
    ldh [$FFA7], a
    ld a, b
    ld [hScriptPtr + 1], a

PlantScrollNudgeHandler::
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(NudgeScrollDeltasFromScriptByte)
    ld [hScriptHandler], a
    ld a, HIGH(NudgeScrollDeltasFromScriptByte)
    ld [hScriptHandler + 1], a
    ret
