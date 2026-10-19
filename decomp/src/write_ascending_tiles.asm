; Bank 3 at $65D2. Writes C ascending tile indexes at HL, stepping by DE.
; A is the first index. Each pass stores A, adds DE to HL, and increments
; A. C is the run length and reaches 0. On return HL and A sit one past
; the last cell. Callers in this bank use stride $0001 and leave DE set
; across a second call. PaintWindowTilemap still reaches this address
; through WriteAscendingStride.

WriteAscendingTiles::
    ld [hl], a
    add hl, de
    inc a
    dec c
    jr nz, WriteAscendingTiles
    ret
