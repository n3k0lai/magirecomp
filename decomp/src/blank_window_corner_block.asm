; Bank 1 at $475A. Opcode9DBody stores this as wCallback with bank 1.
;
; VRAM bank 0 gets WINDOW_TILE in columns 0-4 of window-map rows 0-4.
; VRAM bank 1 gets attribute $0F on those same cells: palette 7 and tile
; data from VRAM bank 1, with no flip and no BG-to-OAM priority. Each
; row is five ld [hl+], a stores. After the first four rows HL advances
; by $1B, one row on the 32-wide map, so the next row starts in column 0.
; wCallback becomes IdleCallback. That address is in ROM0, so the bank
; byte is left alone.
;
; The rVBK stores are the 3-byte form. rVBK, vWindowMap, and WINDOW_TILE
; are the names from setup_window.asm. wCallback and IdleCallback are
; the names from default_state.asm.

; After five columns, +$1B lands on column 0 of the next row.
DEF WINDOW_ROW_AFTER_FIVE EQU $001B

; Palette 7, tile VRAM bank 1.
DEF WINDOW_CORNER_ATTR EQU $0F

BlankWindowCornerBlock::
    xor a
    ld [rVBK], a
    ld bc, WINDOW_ROW_AFTER_FIVE
    ld hl, vWindowMap
    ld a, WINDOW_TILE
    REPT 4
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        add hl, bc
    ENDR
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, $01
    ld [rVBK], a
    ld bc, WINDOW_ROW_AFTER_FIVE
    ld hl, vWindowMap
    ld a, WINDOW_CORNER_ATTR
    REPT 4
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        add hl, bc
    ENDR
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
