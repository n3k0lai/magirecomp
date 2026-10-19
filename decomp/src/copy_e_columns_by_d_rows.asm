; Bank 0 at $2D40. CopyMapRectToBothVRAMBanks calls this once for each
; VRAM bank. The name CopyMapRect is already an EQU in that caller.
;
; BC is the source. HL is the BG-map destination. E is the column count
; and D is the row count. Each row copies E bytes, which advances HL by E,
; then adds $20 - E so HL lands on the same column of the next map row.
; DE is restored between rows. D is the remaining row count. BC is left
; just past the copied rectangle. E == 0 copies 256 columns, because
; dec e wraps.

CopyEColumnsByDRows::
.row:
    push de
.column:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec e
    jr nz, .column
    pop de
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
