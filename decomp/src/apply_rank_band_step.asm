; ApplyRankBandStep. Bank 0 at $3821.
;
; AdjustA000RecordOnce calls this with HL pointing at a record and DE set
; to the rank-band step: $000A below rank $20, $0010 below $3C, and $0001
; from $3C up.
;
; The big-endian word at record+9 is loaded, DE is added with wrap, and the
; sum is clamped to 999 ($03E7). That word is written back at record+9 and
; the same two bytes are stored at record+7. HL returns as the record
; pointer. There is no call.

DEF RANK_BAND_CAP EQU $03E7

ApplyRankBandStep::
    push hl
    ld bc, $0009
    add hl, bc
    push hl
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    add hl, de
    ld de, RANK_BAND_CAP
    ld a, h
    cp d
    jr nz, .compared

    ld a, l
    cp e

.compared:
    jr c, .storeBoth

    ld h, d
    ld l, e

.storeBoth:
    ld a, h
    ld c, l
    pop hl
    ld [hl+], a
    ld [hl], c
    pop hl
    push hl
    ld de, $0007
    add hl, de
    ld [hl+], a
    ld [hl], c
    pop hl
    ret
