; Camera scroll flush. RunDefaultVBlank calls here with ROM bank 7 mapped
; when bit 0 of hVBlankFlags is set, after the LCD is on and OAM DMA has run.
;
; wCameraPixelX and wCameraPixelY are copied to rSCX and rSCY. Both stores
; are ldh. Those names are from queue_sprite_list.asm and lcd_off_setup.asm.
;
; wColumnLoadLatch is the countdown CopyQueuedColumn or
; CopyQueuedColumnAttrs saved at $C892. Zero skips the column. Otherwise
; bit 0 selects rVBK: the tile pass stores 2, so bank 0, and the attribute
; pass stores the shifted countdown 1, so bank 1. The latch is then cleared.
; Nineteen tile bytes at $C116 are written through the word addresses
; CopyQueuedColumn queued at $C89F-$C8C4. Each step is inc c, so the buffer
; stays in page $C1. HL walks two bytes per address and finishes at $C8C5.
;
; wRowLoadLatch is the countdown LoadScrolledRow or ExpandScrolledRowD400 saved
; at $C86A. Zero skips the row. Bit 0 again selects rVBK, and the latch is
; cleared. D is the tilemap high byte StepVerticalScroll stored at
; wScrollMapLow + 1. E is loaded from wScrollMapLow and then replaced by
; each low byte at wScrollMapLows. Those 21 lows are the columns
; LoadScrolledRow wrapped for this row. The tile bytes come from
; wScrollTileBuf. inc c keeps that walk in page $C1.
;
; rVBK is cleared with ldh either way. Bits 0 and 4 of the edge flags at
; $C842 are cleared. A horizontal step rewrites the low three flag bits to
; 1, 3, or 5, all of which set bit 0. A vertical step rewrites bits 4-6 to
; $10, $30, or $50, all of which set bit 4. The clamp bits in 1-3 and 5-7
; stay. rVBK is the name from setup_window.asm. wColumnLoadLatch is the
; name from opcode_03_continue.asm. wRowLoadLatch, wScrollMapLow,
; wScrollMapLows, and wScrollTileBuf are the names from load_scrolled_row.asm.

; Nineteen BG addresses, one word each, queued for the column strip.
DEF wColumnMapAddrs EQU $C89F

; Tile or attribute bytes for that column. Same buffer both passes use.
DEF wColumnTileBuf EQU $C116

; One address per queued column word.
DEF COLUMN_STRIP_BYTES EQU 19

; One low byte per column of the queued row.
DEF ROW_STRIP_BYTES EQU 21

; Edge flags. Bits 0 and 4 mark a horizontal or vertical step since last flush.
DEF wScrollEdgeFlags EQU $C842

; Keep every edge bit except 0 and 4.
DEF SCROLL_STEP_ACK EQU $EE

FlushQueuedScroll::
    ld a, [wCameraPixelX]
    ldh [rSCX], a
    ld a, [wCameraPixelY]
    ldh [rSCY], a
    ld a, [wColumnLoadLatch]
    and a
    jp z, .row

    and $01
    ldh [rVBK], a
    xor a
    ld [wColumnLoadLatch], a
    ld hl, wColumnMapAddrs
    ld bc, wColumnTileBuf
REPT COLUMN_STRIP_BYTES
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [bc]
    inc c
    ld [de], a
ENDR

.row:
    ld a, [wRowLoadLatch]
    and a
    jp z, .ack

    and $01
    ldh [rVBK], a
    xor a
    ld [wRowLoadLatch], a
    ld hl, wScrollMapLows
    ld a, [wScrollMapLow + 1]
    ld d, a
    ld a, [wScrollMapLow]
    ld e, a
    ld bc, wScrollTileBuf
REPT ROW_STRIP_BYTES
    ld a, [hl+]
    ld e, a
    ld a, [bc]
    inc c
    ld [de], a
ENDR

.ack:
    xor a
    ldh [rVBK], a
    ld a, [wScrollEdgeFlags]
    and SCROLL_STEP_ACK
    ld [wScrollEdgeFlags], a
    ret
