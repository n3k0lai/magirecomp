; Set bit 5 of $DF0B (slot 2 flags) and store a period delta for slot 2:
; $2A7B in double speed with $DF04 = $81, else $2A88, minus the word at
; $DF19, stored as the word at $DF27.

SetWavePeriodDelta::
    ld hl, $DF0B
    set 5, [hl]
    ld hl, $DF19
    ld a, [$DF04]
    cp $81
    jr nz, .single_speed
    ldh a, [rKEY1]
    bit 7, a
    jr z, .single_speed
    ld de, $2A7B
    jr .store
.single_speed:
    ld de, $2A88
.store:
    ld a, e
    sub [hl]
    inc hl
    ld e, a
    ld a, d
    sbc a, [hl]
    ld hl, $DF28
    ld [hl-], a
    ld [hl], e
    ret
