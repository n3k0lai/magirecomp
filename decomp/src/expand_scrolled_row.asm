; Alternate scrolled-row expand. LoadScrolledRow jumps here, with ROM bank 7
; mapped, when the row-load countdown at $C869 is neither 0 nor 2. A is that
; countdown. It is latched at $C86A and then unused.
;
; $C86C already holds 0 or 2, the row inside each 4-byte definition. Bit 3 of
; $C86B, the latched horizontal fine position, skips the left tile of the
; first id so a half-scrolled column does not copy the tile already off the
; screen. The other ten ids at $C86E-$C877 always copy both bytes.
;
; WRAM bank 2 holds the definitions. Each id addresses $D400 + id * 4, then
; the row offset is added to the low byte only. Tile bytes land at $C100.
; The shift sequence on the first id differs from the rest and is kept as it
; is. D stays 0, so the adc through D does not change the high byte.
;
; $C86A, $C86B, $C86C, $C86D, and $C100 are the same bytes LoadScrolledRow
; names wRowLoadLatch, wFineXLatch, wMetatileRow, wScrollMetatile, and
; wScrollTileBuf. Those names are defined later in this bank. wCurrentWRAMBank
; and rSVBK are the names from timer_overflow.asm.

; WRAM bank that holds metatile definitions.
DEF WRAM_METATILE_DEFS EQU $02

; Eleven metatile ids, one map row. First id may omit its left byte.
DEF SCROLLED_ROW_IDS EQU $0B

; Tile bytes for the row.
DEF wRowTileBuf EQU $C100

; Copy of the countdown taken on entry.
DEF wRowCountLatch EQU $C86A

; Horizontal fine position. Bit 3 skips the left tile of the first id.
DEF wRowFineX EQU $C86B

; 0 or 2, the row selected inside each 4-byte definition.
DEF wRowInMetatile EQU $C86C

; First of the eleven ids. The next ten are the bytes after it.
DEF wRowMetatile EQU $C86D

; Definitions in WRAM bank 2. Four bytes each, two tiles per row.
; LoadScrolledRow uses the table at $D000. This path uses $D400.
DEF ROW_METATILE_BASE EQU $D400

ExpandScrolledRowD400::
    ld [wRowCountLatch], a
    ld de, $0000
    ld a, [wRowInMetatile]
    ld e, a
    ld a, WRAM_METATILE_DEFS
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld bc, wRowTileBuf
    ld a, [wRowMetatile]
    ld l, a
    xor a
    sla l
    adc d
    sla a
    sla l
    adc HIGH(ROW_METATILE_BASE)
    ld h, a
    ld a, l
    add e
    ld l, a
    ld a, [wRowFineX]
    bit 3, a
    jr nz, .skip_left

    ld a, [hl]
    ld [bc], a
    inc bc

.skip_left:
    inc hl
    ld a, [hl]
    ld [bc], a
    inc bc

DEF row_metatile = wRowMetatile + 1
REPT SCROLLED_ROW_IDS - 1
    ld a, [row_metatile]
    ld l, a
    xor a
    sla l
    adc d
    sla l
    rla
    add HIGH(ROW_METATILE_BASE)
    ld h, a
    ld a, l
    add e
    ld l, a
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl]
    ld [bc], a
    inc bc
DEF row_metatile += 1
ENDR
    ret
