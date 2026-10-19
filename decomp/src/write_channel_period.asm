; WriteChannelPeriod ($5184). UpdateSound calls this with bank $30
; still mapped, the channel in C, and HL equal to the sum of the words
; at $DF15, $DF1D, and $DF23 for that channel.
;
; H is wrapped into 0..$53 by adding or subtracting $54. That index
; selects a period word at $51D8. When L is not zero, L is multiplied
; by the byte at $5282 + index ($4000, B cleared there) and the high
; byte of that product is added to the period.
;
; The high byte is stored at $DF12 + C. The low byte is written to the
; port at $51D3 + C ($FF13, $FF18, $FF1D for channels 0-2) and the high
; byte to the next port. BC is restored.

DEF NOTE_INDEX_MODULO EQU $54

WriteChannelPeriod:
    push bc
    ld a, h

.wrap_negative:
    bit 7, a
    jr z, .wrap_high

    add NOTE_INDEX_MODULO
    jr .wrap_negative

.wrap_high:
    cp NOTE_INDEX_MODULO
    jr c, .index_ready

    sub NOTE_INDEX_MODULO
    jr .wrap_high

.index_ready:
    ld d, $00
    ld e, a
    ld a, l
    and a
    jr nz, .add_fraction

    sla e
    ld hl, PeriodTable
    add hl, de
    ld e, c
    ld a, [hl+]
    ld b, [hl]

.write_period:
    ld hl, wChannelFreqHigh
    add hl, de
    ld [hl], b
    ld hl, PeriodLowPort
    add hl, de
    ld c, [hl]
    ldh [c], a
    inc c
    ld a, b
    ldh [c], a
    pop bc
    ret

.add_fraction:
    ld hl, PeriodScale
    add hl, de
    ld d, c
    ld c, [hl]
    call $4000
    ld c, h
    ld a, d
    ld b, $00
    ld d, b
    sla e
    ld hl, PeriodTable
    add hl, de
    ld e, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld b, h
    jr .write_period
