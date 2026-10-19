; Flag slot 2, store $47B4 minus the word at $DF19 as the word at $DF27, and
; start the sound timer: TAC = 7 with $DF08 = $80 in double speed with
; $DF04 = $81, else TAC = 6 with $DF08 = 0. That value also goes to TIMA and
; TMA. A pending timer request is dropped (IF & $1B) and the timer
; interrupt is enabled.

StartSoundTimer::
    ld hl, $DF0B
    set 5, [hl]
    ld hl, $DF19
    ld de, $47B4
    ld a, e
    sub [hl]
    inc hl
    ld e, a
    ld a, d
    sbc a, [hl]
    ld hl, $DF28
    ld [hl-], a
    ld [hl], e
    ld a, [$DF04]
    cp $81
    jr nz, .single_speed
    ldh a, [rKEY1]
    bit 7, a
    jr z, .single_speed
    ld a, $07
    ldh [rTAC], a
    ld a, $80
    jr .set_timer
.single_speed:
    ld a, $06
    ldh [rTAC], a
    ld a, $00
.set_timer:
    ld [wChannelLengthTimerTop + 1], a
    ldh [rTIMA], a
    ldh [rTMA], a
    ldh a, [rIF]
    and $1B
    ldh [rIF], a
    ldh a, [rIE]
    or $04
    ldh [rIE], a
    ret
