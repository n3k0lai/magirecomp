; Copy five rows of four bytes from BC onto the BG map.
;
; Called with this bank still mapped. DrawIndex9Map passes $6F92 while
; VRAM bank 0 is selected, so the cells are tiles. StampSetupAttributes
; passes $700C while VRAM bank 1 is selected, so the same cells are
; attributes. Neither caller reads BC afterward.
;
; Rows start at $9C28 and step by the $20 map stride. Each row writes
; four bytes with `ld [hl+], a` and advances BC. The four-byte run stays
; on its map row.

DEF vMapStrip EQU $9C28
DEF MAP_STRIP_STRIDE EQU $20

CopyFiveMapRows::
    ld hl, vMapStrip
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld hl, vMapStrip + 1 * MAP_STRIP_STRIDE
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld hl, vMapStrip + 2 * MAP_STRIP_STRIDE
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld hl, vMapStrip + 3 * MAP_STRIP_STRIDE
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld hl, vMapStrip + 4 * MAP_STRIP_STRIDE
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ret
