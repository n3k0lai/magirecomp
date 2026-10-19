; AddDeClampRecordWord9. Bank 0 at $3847.
;
; HL is a record. DE is an addend. The big-endian word at record+9 is
; loaded, DE is added with wrap, and the sum is clamped to 250 ($00FA).
; That word is written back at record+9. HL returns on the low byte of
; the stored word. A is the high byte and C is the low byte. There is no
; call. What the 250 cap is for is still unknown.

DEF RECORD_WORD9_CAP_250 EQU $00FA

AddDeClampRecordWord9::
    ld bc, $0009
    add hl, bc
    push hl
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    add hl, de
    ld de, RECORD_WORD9_CAP_250
    ld a, h
    cp d
    jr nz, .compared

    ld a, l
    cp e

.compared:
    jr c, .store

    ld h, d
    ld l, e

.store:
    ld a, h
    ld c, l
    pop hl
    ld [hl+], a
    ld [hl], c
    ret
