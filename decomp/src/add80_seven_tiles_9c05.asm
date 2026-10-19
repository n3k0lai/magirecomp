; Bank 0 at $3919. DriveD0B1Choice plants this at wCallback when
; the wait byte at $CD81 is $05. FinishFrame runs it once.
;
; Seven tile ids at $9C05, columns 5 through 11 of row 0 on the $9C00
; window map, each have $80 added. A tile below $80 gains the high bit.
; A tile at or above $80 wraps. wCallback then becomes IdleCallback.
;
; wCallback and IdleCallback are the names from default_state.asm.
; vBGMap is the name from draw_start_screen_map.asm.

; First of the seven cells, and how many to add $80 to.
DEF vEntryRowTiles EQU $9C05
DEF ENTRY_ROW_TILE_COUNT EQU $07

; Added to each tile id. Below $80 this sets the high bit.
DEF ENTRY_ROW_TILE_BIAS EQU $80

Add80ToSevenTiles9C05::
    ld hl, vEntryRowTiles
    ld d, ENTRY_ROW_TILE_COUNT
    ld b, ENTRY_ROW_TILE_BIAS

.tile:
    ld a, b
    add [hl]
    ld [hl+], a
    dec d
    jr nz, .tile

    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
