; Bank 1 continuation of script opcode $03. Opcode03 maps this bank and
; jumps here with the adjusted map position in DE (column in D, row in E)
; and HL still pointing at the WRAM address it just wrote.
;
; wLCDC is only tested for zero. The turn-off path clears it, so a dark
; screen returns 0. Otherwise D must sit in [wMapColumn, wMapColumn+15]
; and E in [wMapRow, wMapRow+15]. A delta whose high nibble is set returns
; 0. The subtraction is unsigned, so a cell left of or above the camera
; origin fails that test.
;
; The address and the position are saved for the bank 7 call: HL at
; $C8C5, then E at $C8C7 and D at $C8C8. CallBankedHL maps bank 7 and
; calls $4AA4. That routine is still INCBIN. BC, the two deltas, is
; preserved across the call.
;
; A is 1 when the cell is on an edge that is being reloaded. The view is
; the 11 by 10 window DrawMetatileWindow fills, so the far edges are
; column delta 10 and row delta 9. A left or right edge returns 1 when
; $C892 is set. CopyQueuedColumn stores the column-load countdown there.
; Otherwise a top or bottom edge returns 1 when wRowLoadLatch is set.
; Every other cell returns 0. The column test runs first, so a corner
; with the column latch set does not read the row latch.
;
; wLCDC is the name from turn_off_lcd.asm. wMapColumn is the name from
; draw_metatile_window.asm. wMapRow is the name from queue_sprite_list.asm.
; wRowLoadLatch is the name from load_scrolled_row.asm. CallBankedHL is
; the name from call_hl_in_bank.asm.

; Address Opcode03 just wrote. Low byte first.
DEF wScriptCellAddr EQU $C8C5

; Adjusted row, then column. Low byte first.
DEF wScriptCellPos EQU $C8C7

; Copy of the column-load countdown. Set on the tile pass.
DEF wColumnLoadLatch EQU $C892

; Last column and row of the 11 by 10 view, counting from the camera.
DEF VIEW_LAST_COL EQU $0A
DEF VIEW_LAST_ROW EQU $09

; Bank 7, still INCBIN. Called after the cell address and position are saved.
DEF ScriptCellInView EQU $4AA4

; ROM bank ScriptCellInView lives in.
DEF SCRIPT_CELL_BANK EQU $07

Opcode03ScrollEdge::
    ld a, [wLCDC]
    and a
    ret z
    ld a, [wMapColumn]
    ld b, a
    ld a, d
    sub b
    ld b, a
    and $f0
    ld a, $00
    ret nz
    ld a, [wMapRow]
    ld c, a
    ld a, e
    sub c
    ld c, a
    and $f0
    ld a, $00
    ret nz
    push bc
    ld a, h
    ld [wScriptCellAddr + 1], a
    ld a, l
    ld [wScriptCellAddr], a
    ld a, d
    ld [wScriptCellPos + 1], a
    ld a, e
    ld [wScriptCellPos], a
    ld hl, ScriptCellInView
    ld e, SCRIPT_CELL_BANK
    call CallBankedHL
    pop bc
    ld a, b
    and a
    jr z, .columnEdge
    cp VIEW_LAST_COL
    jr nz, .checkRow
.columnEdge:
    ld a, [wColumnLoadLatch]
    and a
    jr nz, .hit
.checkRow:
    ld a, c
    and a
    jr z, .rowEdge
    cp VIEW_LAST_ROW
    ld a, $00
    ret nz
.rowEdge:
    ld a, [wRowLoadLatch]
    and a
    ret z
.hit:
    ld a, $01
    ret
