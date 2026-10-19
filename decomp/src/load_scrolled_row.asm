; Scrolled map row. StepVerticalScroll tails here with ROM bank 7 mapped,
; after it arms the row-load countdown at $C869.
;
; Zero returns at once. Any value other than 2 jumps to $52FA, still INCBIN,
; which expands ids already sitting at $C86D with definitions based at $D400.
; Two is this path. The countdown is copied to $C86A and left in place.
;
; $C865 is a little-endian pointer into the map in WRAM bank 3. Eleven
; metatile ids are copied from there to $C86D-$C877. Bit 3 of the vertical
; fine position at $C85E picks a row inside the 2x2 definition: E is 0 or 2,
; and that offset is stored at $C86C. The horizontal fine position at $C85D
; is stored at $C86B.
;
; WRAM bank 2 holds the definitions. Each id addresses $D000 + id * 4, then
; E is added to the low byte only. Two tile bytes from that row are written
; at $C100 and forward. On the first id, bit 3 of $C86B skips the left byte,
; so a half-scrolled column does not copy the tile already off the screen.
; The other ten ids always copy both bytes. The shift sequence on the first
; id differs from the rest and is kept as it is.
;
; $C867 is the tilemap low byte from the scroll step. $C878 receives that
; byte and the next twenty columns, each wrapped inside the 32-tile row
; (low five bits only, row base in E). One further column is wrapped into A
; and not stored.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.

; Bank 7, still INCBIN. Same entry with the countdown not equal to 2.
; Definitions are based at $D400 instead of $D000.

; Eleven metatile ids, one map row.
DEF SCROLL_ROW_IDS EQU $0B

; Tile bytes for the row. First id may omit its left byte.
DEF wScrollTileBuf EQU $C100

; Wrapped tilemap low bytes, one per column copied.
DEF wScrollMapLows EQU $C878

; Row-load countdown. StepVerticalScroll stores 2 here.
DEF wRowLoadCount EQU $C869

; Copy of the countdown taken on this path.
DEF wRowLoadLatch EQU $C86A

; Horizontal fine position, sampled into $C86B. Bit 3 skips the left tile.
DEF wFineX EQU $C85D

DEF wFineXLatch EQU $C86B

; Vertical fine position. Bit 3 selects the bottom row of each metatile.
DEF wFineY EQU $C85E

; 0 or 2, the row selected inside each 4-byte definition.
DEF wMetatileRow EQU $C86C

; Map pointer filled by the scroll step. Low byte first. WRAM bank 3.
DEF wScrollMapPtr EQU $C865

; Tilemap address low byte filled by the scroll step.
DEF wScrollMapLow EQU $C867

; First of the eleven ids. The next ten are the bytes after it.
DEF wScrollMetatile EQU $C86D

; Definitions in WRAM bank 2. Four bytes each, two tiles per row.
DEF METATILE_BASE EQU $D000

; WRAM_MAP is the name from draw_metatile_window.asm.
DEF WRAM_METATILES EQU $02

; Low five bits are the column. Masking with this keeps a step inside the row.
DEF TILEMAP_ROW_MASK EQU $1F

LoadScrolledRow::
    ld a, [wRowLoadCount]
    and a
    ret z

    cp $02
    jp nz, ExpandScrolledRowD400

    ld [wRowLoadLatch], a
    ld a, [wScrollMapPtr + 1]
    ld h, a
    ld a, [wScrollMapPtr]
    ld l, a
    ld a, WRAM_MAP
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [hl+]
    ld [wScrollMetatile], a
    ld a, [hl+]
    ld [wScrollMetatile + 1], a
    ld a, [hl+]
    ld [wScrollMetatile + 2], a
    ld a, [hl+]
    ld [wScrollMetatile + 3], a
    ld a, [hl+]
    ld [wScrollMetatile + 4], a
    ld a, [hl+]
    ld [wScrollMetatile + 5], a
    ld a, [hl+]
    ld [wScrollMetatile + 6], a
    ld a, [hl+]
    ld [wScrollMetatile + 7], a
    ld a, [hl+]
    ld [wScrollMetatile + 8], a
    ld a, [hl+]
    ld [wScrollMetatile + 9], a
    ld a, [hl+]
    ld [wScrollMetatile + 10], a
    ld de, $0000
    ld a, [wFineY]
    bit 3, a
    jr z, .row_offset

    ld e, $02

.row_offset:
    ld a, e
    ld [wMetatileRow], a
    ld a, [wFineX]
    ld [wFineXLatch], a
    ld a, WRAM_METATILES
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld bc, wScrollTileBuf
    ld a, [wScrollMetatile]
    ld l, a
    xor a
    sla l
    adc d
    sla a
    sla l
    adc HIGH(METATILE_BASE)
    ld h, a
    ld a, l
    add e
    ld l, a
    ld a, [wFineXLatch]
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

DEF metatile_src = wScrollMetatile + 1
REPT SCROLL_ROW_IDS - 1
    ld a, [metatile_src]
    ld l, a
    xor a
    sla l
    adc d
    sla l
    rla
    add HIGH(METATILE_BASE)
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
DEF metatile_src += 1
ENDR

    ld hl, wScrollMapLows
    ld d, TILEMAP_ROW_MASK
    ld a, [wScrollMapLow]
    ld c, a
    and LOW(~TILEMAP_ROW_MASK)
    ld e, a
    ld a, c
    ld [hl+], a
REPT 20
    inc a
    and d
    add e
    ld [hl+], a
ENDR
    inc a
    and d
    add e
    ret
