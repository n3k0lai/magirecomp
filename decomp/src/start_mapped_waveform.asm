; Start a mapped waveform. Inputs: A wave width, HL waveform argument, BC and
; DE passed on. Clears wTagPriorityLimit, opens channel 2 for tag 1 through
; OpenChannelForTag.have_channel (B = $FF), stores DE in wWavePosition, then
; maps the waveform with CopyMappedWaveformEnd ($3BB3). A result with bit 7
; of H set is clamped to H = $40 and bumps wWaveWidth. The routine at $4BD2
; then yields BC (floor/limit) and the saved HL becomes wWaveStep; wSoundFlags
; becomes $50, $50E6 runs for channel 2, $DFF6 = $0F, and bit 5 of $DF0F is set.

StartMappedWaveform::
    push hl
    push af
    push bc
    push de
    xor a
    ld [wTagPriorityLimit], a
    ld b, $FF
    ld c, $02
    ld hl, $0000
    inc a
    ld [wSavedTagParam], a
    call OpenChannelForTag.have_channel
    pop de
    ld hl, wWavePosition
    ld a, e
    ld [hl+], a
    ld [hl], d
    pop bc
    pop af
    pop hl
    ld [wWaveWidth], a
    call $3BB3
    bit 7, h
    jr z, .in_range
    ld h, $40
    ld a, [wWaveWidth]
    inc a
    ld [wWaveWidth], a
.in_range:
    push hl
    call $4BD2
    ld a, $50
    ld [wSoundFlags], a
    ld hl, wWaveFloor
    ld a, c
    ld [hl+], a
    ld a, b
    ld [hl+], a
    ld [hl], $00
    ld hl, wWaveStep
    pop bc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, $FF
    ld c, $02
    call $50E6
    ld a, $0F
    ld [$DFF6], a
    ld hl, $DF0F
    set 5, [hl]
    ret
