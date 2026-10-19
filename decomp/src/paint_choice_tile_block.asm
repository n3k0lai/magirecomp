; Bank 5 at $5C81. RunD0B1MapStrips stores this address in wCallback
; with bank 5, then calls FinishFrame once. FinishFrame runs it.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK.
; VRAM bank 0 receives five rows of four consecutive tile ids at $9C00,
; starting at the id in wChoiceTile ($D0B3). Each row is 32 bytes apart
; ($1C is added after the four stores). The last tile is stored without
; another increment. VRAM bank 1 then fills the same 4-by-5 cells with
; attribute $07 (palette 7). wCallback becomes IdleCallback ($29A4) in
; bank 0.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; rVBK is the name from setup_window.asm. wChoiceTile is the name from
; run_d0b1_map_strips.asm. vBGMap is the name from draw_start_screen_map.asm.
; wCallback, wCallbackBank, and IdleCallback are the names from
; default_state.asm.

DEF CHOICE_ROW_SKIP EQU $1C
DEF CHOICE_ATTR EQU $07

; Four tile ids, each one higher than the last. A holds the next id.
MACRO choice_tile_row
    ld [hl+], a
    inc a
    ld [hl+], a
    inc a
    ld [hl+], a
    inc a
    ld [hl+], a
    inc a
    add hl, de
ENDM

MACRO choice_attr_row
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    add hl, de
ENDM

PaintChoiceTileBlock::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    xor a
    ld [rVBK], a
    ld hl, vBGMap
    ld a, [wChoiceTile]
    ld de, CHOICE_ROW_SKIP
    choice_tile_row
    choice_tile_row
    choice_tile_row
    choice_tile_row
    ld [hl+], a
    inc a
    ld [hl+], a
    inc a
    ld [hl+], a
    inc a
    ld [hl+], a
    ld hl, vBGMap
    ld a, $01
    ld [rVBK], a
    ld a, CHOICE_ATTR
    choice_attr_row
    choice_attr_row
    choice_attr_row
    choice_attr_row
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    xor a
    ld [wCallbackBank], a
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
