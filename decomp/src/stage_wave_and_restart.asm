; Stage the wave in A through StageWaveOrFlat and arm channel 2. A goes to
; wWaveWidth; a result with H bit 7 set is clamped to H = $40 and bumps the
; width. BC from StageWaveOrFlat becomes wWaveFloor/wWaveLimit (third byte 0)
; and the returned HL becomes wWaveStep. RestartChannel is tail-called with
; A = $FF (keep wave) and C = 2.

StageWaveAndRestart::
    ld [wWaveWidth], a
    call StageWaveOrFlat
    bit 7, h
    jr z, .in_range
    ld h, $40
    ld a, [wWaveWidth]
    inc a
    ld [wWaveWidth], a
.in_range:
    push hl
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
    jp RestartChannel
