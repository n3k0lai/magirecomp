; Bank 0 at $2FE5. CopyMapRecords calls this with rVBK already selected
; and BC pointing at a 7-byte record:
;
;   dw destination  ; VRAM address. Each row starts $100 bytes later.
;   dw source       ; address in the record's ROM bank
;   db tiles        ; tiles in one row, 16 bytes each. Bit 4 set means the
;                   ; next source row is $100 bytes later. Bit 4 clear means
;                   ; the next source row is swap(tiles) bytes later.
;   db rows
;   db bank         ; stored to wCurrentROMBank and rROMB0 for the copy
;
; The copy writes with inc c, so a row stays inside one $100-byte VRAM page.
; Each tile is copied as two runs of eight bytes. ld a, a after the bank
; byte leaves A unchanged. BC returns advanced by 7, and the saved ROM bank
; is restored. Callers still name this CopyOneVRAMRecord.
;
; wCurrentROMBank and rROMB0 are the names from reset.asm.

PURGE CopyOneVRAMRecord

CopyOneVRAMRecord::
    ld a, [wCurrentROMBank]
    push af
    push bc
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    push hl
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [bc]
    ld e, a
    inc bc
    ld a, [bc]
    ld d, a
    inc bc
    ld a, [bc]
    ld a, a
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    pop bc

.row:
    push de
    push hl
    push bc

.tile:
    ld d, $02

.eight:
    ld a, [hl+]
    ld [bc], a
    inc c
    ld a, [hl+]
    ld [bc], a
    inc c
    ld a, [hl+]
    ld [bc], a
    inc c
    ld a, [hl+]
    ld [bc], a
    inc c
    ld a, [hl+]
    ld [bc], a
    inc c
    ld a, [hl+]
    ld [bc], a
    inc c
    ld a, [hl+]
    ld [bc], a
    inc c
    ld a, [hl+]
    ld [bc], a
    inc c
    dec d
    jr nz, .eight

    dec e
    jr nz, .tile

    pop bc
    pop hl
    pop de
    inc h
    bit 4, e
    jr nz, .next_row

    dec h
    ld a, e
    swap a
    add l
    ld l, a
    ld a, h
    adc $00
    ld h, a

.next_row:
    inc b
    dec d
    jr nz, .row

    pop hl
    ld bc, $0007
    add hl, bc
    ld c, l
    ld b, h
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
