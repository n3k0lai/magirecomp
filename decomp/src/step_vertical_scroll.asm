; Vertical scroll step. FinishFrame calls here with ROM bank 7 mapped,
; before it clears $C843 and $C844.
;
; $C869 is a row-load countdown. Each visit shifts it one bit right.
; $C842 holds edge flags. Bit 7 skips the step. $C844 is a signed pixel
; delta, clamped to -4..+4. It is added into the scroll accumulator at
; $C934 and into the fine position at $C85E (one tile, 0-15).
;
; Bit 6 of $C842, on an up step, refuses to move $C85E below 0. Bit 5, on a
; down step, refuses to move it past 15. Crossing a tile boundary (bit 3 of
; the fine position) updates the map row at $C860 and the word at $C861.
; Bits 4-6 of $C842 become $50 when an up step lands on row 0, $10 on any
; other up step, $30 when a down step lands on the limit at $C846, and $10
; on any other down step. Bits 0-3 and bit 7 are left as they were.
;
; $C863/$C864 is a tilemap address in the $9800 window. An up step rewrites
; it one row back ($20 bytes) and copies that address to $C867. The map word
; moves by the negation of $C847 and is copied to $C865. A down step rewrites
; the tilemap one row forward, stores $C849 plus the map word at $C865, and
; stores the address $240 bytes ahead (18 rows) at $C867. $C869 is then set
; to 2.
;
; Every exit is `jp $5415`. That tail is still INCBIN.

StepVerticalScroll::
    ld hl, $c869
    sra [hl]
    ld a, [$c842]
    bit 7, a
    jp nz, $5415

    ld a, [$c844]
    and a
    jp z, $5415

    ld e, a
    bit 7, e
    jp z, .down

    ld a, e
    cp $fc
    jr nc, .up_clamped

    ld e, $fc

.up_clamped:
    ld a, [$c842]
    bit 6, a
    jr z, .apply_up

    ld a, [$c85e]
    ld b, a
    add e
    bit 7, a
    jr z, .apply_up

    ld a, b
    and a
    jp z, $5415

    cpl
    inc a
    ld e, a

.apply_up:
    ld a, e
    ld hl, $c934
    add [hl]
    ld [hl], a
    ld a, [$c85e]
    ld d, a
    add e
    ld e, a
    bit 7, a
    jr z, .store_up

    add $10

.store_up:
    ld [$c85e], a
    xor d
    bit 3, a
    jp z, $5415

    bit 7, e
    ld hl, $c861
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $c863
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    jr z, .queue_up

    push de
    ld hl, $c860
    dec [hl]
    ld l, [hl]
    ld a, l
    and a
    ld d, $50
    jr z, .flag_up

    ld d, $10

.flag_up:
    ld hl, $c842
    ld a, [hl]
    and $8f
    add d
    ld [hl], a
    ld a, [$c847]
    cpl
    inc a
    ld l, a
    ld h, $ff
    add hl, bc
    ld a, l
    ld [$c861], a
    ld a, h
    ld [$c862], a
    ld c, l
    ld b, h
    pop de

.queue_up:
    ld hl, $c865
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $ffe0
    add hl, de
    ld a, l
    ld [$c863], a
    ld [$c867], a
    ld a, h
    and $03
    add $98
    ld [$c864], a
    ld [$c868], a
    ld a, $02
    ld [$c869], a
    jp $5415

.down:
    ld a, e
    cp $04
    jr c, .down_clamped

    ld e, $04

.down_clamped:
    ld a, [$c842]
    bit 5, a
    jr z, .apply_down

    ld a, [$c85e]
    ld b, a
    add e
    bit 4, a
    jr z, .apply_down

    ld a, b
    cpl
    and $0f
    and a
    jp z, $5415

    ld e, a

.apply_down:
    ld a, e
    ld hl, $c934
    add [hl]
    ld [hl], a
    ld a, [$c85e]
    ld d, a
    add e
    ld e, a
    and $0f
    ld [$c85e], a
    xor d
    bit 3, a
    jp z, $5415

    bit 4, e
    ld hl, $c861
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $c863
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    jr z, .queue_down

    push de
    ld hl, $c860
    inc [hl]
    ld l, [hl]
    ld a, [$c846]
    cp l
    ld d, $30
    jr z, .flag_down

    ld d, $10

.flag_down:
    ld hl, $c842
    ld a, [hl]
    and $8f
    add d
    ld [hl], a
    ld a, [$c847]
    ld l, a
    ld h, $00
    add hl, bc
    ld a, h
    ld [$c862], a
    ld a, l
    ld [$c861], a
    ld c, l
    ld b, h
    pop de

.queue_down:
    ld hl, $0020
    add hl, de
    ld a, h
    and $03
    add $98
    ld h, a
    ld a, h
    ld [$c864], a
    ld a, l
    ld [$c863], a
    ld e, l
    ld d, h
    ld a, [$c84a]
    ld h, a
    ld a, [$c849]
    ld l, a
    add hl, bc
    ld a, h
    ld [$c866], a
    ld a, l
    ld [$c865], a
    ld hl, $0240
    add hl, de
    ld a, h
    and $03
    add $98
    ld h, a
    ld a, h
    ld [$c868], a
    ld a, l
    ld [$c867], a
    ld a, $02
    ld [$c869], a
    jp $5415
