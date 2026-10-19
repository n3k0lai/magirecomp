; Horizontal scroll step. FinishFrame calls here with ROM bank 7 mapped,
; before it clears $C843 and $C844.
;
; $C891 is a column-load countdown. Each visit shifts it one bit right.
; $C842 holds edge flags in its low bits. Bit 3 skips the step. $C843 is a
; signed pixel delta, clamped to -4..+4. It is added into the scroll
; accumulator at $C935 and into the fine position at $C85D (one tile, 0-15).
;
; Bit 2 of $C842, on a left step, refuses to move $C85D below 0. Bit 1, on a
; right step, refuses to move it past 15. Crossing a tile boundary (bit 3 of
; the fine position) updates the map column at $C85F and the word at $C861.
; The low three bits of $C842 become 5 when a left step lands on column 0,
; 1 on any other left step, 3 when a right step lands on the limit at $C845,
; and 1 on any other right step.
;
; $C863/$C864 is a tilemap address. Bits 0-4 of the low byte are the column
; and bits 5-7 stay with the row. A left step rewrites it one column back and
; copies that address to $C88F. A right step rewrites it one column forward
; and stores the address 20 columns ahead at $C88F. The map word is copied to
; $C88D; a right step adds 10 first. $C891 is then set to 2.
;
; Every exit is `jp $4F38`. That tail, still INCBIN, returns at once when
; $C891 is 0 and otherwise copies the queued column. $4E2B is the other
; column-copy entry and is not part of this step.

StepHorizontalScroll::
    ld hl, $c891
    sra [hl]
    ld a, [$c842]
    bit 3, a
    jp nz, $4f38

    ld a, [$c843]
    and a
    jp z, $4f38

    ld e, a
    bit 7, e
    jp z, .right

    ld a, e
    cp $fc
    jr nc, .left_clamped

    ld e, $fc

.left_clamped:
    ld a, [$c842]
    bit 2, a
    jr z, .apply_left

    ld a, [$c85d]
    ld b, a
    add e
    bit 7, a
    jr z, .apply_left

    ld a, b
    and a
    jp z, $4f38

    cpl
    inc a
    ld e, a

.apply_left:
    ld a, e
    ld hl, $c935
    add [hl]
    ld [hl], a
    ld a, [$c85d]
    ld d, a
    add e
    ld e, a
    bit 7, a
    jr z, .store_left

    add $10

.store_left:
    ld [$c85d], a
    xor d
    bit 3, a
    jp z, $4f38

    bit 7, e
    ld hl, $c861
    jr z, .queue_left

    push hl
    ld hl, $c85f
    dec [hl]
    ld l, [hl]
    ld a, l
    and a
    ld c, $05
    jr z, .flag_left

    ld c, $01

.flag_left:
    ld hl, $c842
    ld a, [hl]
    and $f8
    add c
    ld [hl], a
    pop hl
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    dec de
    ld a, d
    ld [hl-], a
    ld [hl], e

.queue_left:
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $c88d
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [$c863]
    ld e, a
    dec a
    and $1f
    ld d, a
    ld a, e
    and $e0
    add d
    ld [$c88f], a
    ld hl, $c863
    ld [hl+], a
    ld a, [hl]
    ld [$c890], a
    ld a, $02
    ld [$c891], a
    jp $4f38

.right:
    ld a, e
    cp $04
    jr c, .right_clamped

    ld e, $04

.right_clamped:
    ld a, [$c842]
    bit 1, a
    jr z, .apply_right

    ld a, [$c85d]
    ld b, a
    add e
    bit 4, a
    jr z, .apply_right

    ld a, b
    cpl
    and $0f
    and a
    jp z, $4f38

    ld e, a

.apply_right:
    ld a, e
    ld hl, $c935
    add [hl]
    ld [hl], a
    ld a, [$c85d]
    ld d, a
    add e
    ld e, a
    and $0f
    ld [$c85d], a
    xor d
    bit 3, a
    jp z, $4f38

    bit 4, e
    ld hl, $c861
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    jr z, .queue_right

    ld hl, $c85f
    inc [hl]
    ld l, [hl]
    ld a, [$c845]
    cp l
    ld d, $03
    jr z, .flag_right

    ld d, $01

.flag_right:
    ld hl, $c842
    ld a, [hl]
    and $f8
    add d
    ld [hl], a
    inc bc
    ld hl, $c861
    ld a, c
    ld [hl+], a
    ld [hl], b

.queue_right:
    ld hl, $000a
    add hl, bc
    ld a, h
    ld [$c88e], a
    ld a, l
    ld [$c88d], a
    ld a, [$c863]
    ld e, a
    inc a
    and $1f
    ld d, a
    ld a, e
    and $e0
    add d
    ld [$c863], a
    ld e, a
    add $14
    and $1f
    ld d, a
    ld a, e
    and $e0
    add d
    ld [$c88f], a
    ld a, [$c864]
    ld [$c890], a
    ld a, $02
    ld [$c891], a
    jp $4f38
