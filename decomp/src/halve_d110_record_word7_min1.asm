; HalveD110RecordWord7Min1. Bank 2 at $5B88.
;
; The big-endian word at $D110+7 is shifted right by one. ApplyRankBandStep
; writes the same two bytes from the measure word at record+9. A zero result
; (original value 0 or 1) is stored as $0001. No call or jump in the ROM
; names this entry.

DEF D110_RECORD EQU $D110
DEF RECORD_WORD7 EQU $0007

HalveD110RecordWord7Min1::
    ld hl, D110_RECORD
    ld de, RECORD_WORD7
    add hl, de
    push hl
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    srl h
    rr l
    ld a, l
    cp h
    jr nz, .store

    cp $00
    jr nz, .store

    ld l, $01

.store:
    ld a, h
    ld c, l
    pop hl
    ld [hl+], a
    ld [hl], c
    ret
