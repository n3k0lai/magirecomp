; Wave slot step (slot 2 only). Clears wSoundFlags, then decides whether to
; load the next wave from the bank tables at $5A79-$5A84. With a nonzero
; count at $5A84, $DF1A must be below it and the table byte at
; [$5A82] + $5A79 + $DF1A must be below the limit at $5A80. With a zero
; count only $DF1A < [$5A80] is needed. The load is the same as
; SoundCommandSelectWave ($515A then $4B7E with $4BA9 or $4BD2, setting bit 7
; or 6 of wSoundFlags), then $50E6 restarts channel 2.

StepWaveSlot::
    ld a, [wSlotStreamIndex]
    cp $02
    ret nz
    xor a
    ld [wSoundFlags], a
    ld a, [$5A84]
    and a
    jr z, .no_count
    ld b, a
    ld a, [$DF1A]
    cp b
    ret nc
    ld c, a
    ld hl, $5A82
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld de, $5A79
    add hl, de
    ld b, $00
    add hl, bc
    ld a, [$5A80]
    and a
    ret z
    ld b, a
    ld a, [hl]
    cp b
    jr c, .load
    ret
.no_count:
    ld a, [$5A80]
    and a
    ret z
    ld b, a
    ld a, [$DF1A]
    cp b
    ret nc
.load:
    call $515A
    bit 0, e
    jr nz, .bit_set
    call $4B7E
    ld hl, wSoundFlags
    set 7, [hl]
    call $4BA9
    jr .restart
.bit_set:
    call $4B7E
    xor a
    ld [wWavePosition], a
    ld [$DF7C], a
    call $4BD2
    ld hl, wSoundFlags
    set 6, [hl]
.restart:
    ld a, $FF
    ld c, $02
    jp $50E6
