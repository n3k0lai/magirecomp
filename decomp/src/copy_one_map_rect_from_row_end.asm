; Bank 0 at $2D69. CopyPreparedMapBothVRAMFromRowEnd calls this once
; for each VRAM bank, through the EQU CopyOneMapRectFromRowEnd.
;
; BC is the source rectangle. HL is the BG-map destination. E is the
; column count and D is the row count. Each row starts at BC + E, then
; copies E bytes backward so the end of the source row lands at HL and
; the start of the source row lands E columns later. BC is then advanced
; by E again, past that source row. HL adds $20 - E and lands on the
; same column of the next map row. DE is restored between rows. D is
; the remaining row count. E == 0 copies 256 columns, because dec e
; wraps. rVBK is left as the caller set it.

CopyMapRectangleFromRowEnd::
.row:
    push de
    ld a, e
    add c
    ld c, a
    ld a, $00
    adc b
    ld b, a
.column:
    dec bc
    ld a, [bc]
    ld [hl+], a
    dec e
    jr nz, .column
    pop de
    ld a, e
    add c
    ld c, a
    ld a, $00
    adc b
    ld b, a
    ld a, $20
    sub e
    add l
    ld l, a
    ld a, $00
    adc h
    ld h, a
    dec d
    jr nz, .row
    ret
