; Sound command with a 1-byte operand at BC, the new wave sample start. The
; cursor is saved past it; the operand goes to $DF7C. The wave sweep is reset
; (position, floor and step 0, limit $0F, width and sample copy $FF), then
; the routine at $49E8 runs, wSoundFlags becomes 1, UpdateWaveDuty runs, and
; $50E6 is tail-called with A = $FF and C = 2.

SoundCommandResetWaveSweep::
    ld a, [bc]
    inc bc
    ld hl, wSoundStreamCursor
    ld [hl], c
    inc hl
    ld [hl], b
    ld [$DF7C], a
    xor a
    ld [wWavePosition], a
    ld [wWaveFloor], a
    ld [wWaveStep + 1], a
    ld [wWaveStep], a
    ld a, $0F
    ld [wWaveLimit], a
    ld a, $FF
    ld [wWaveWidth], a
    ld [wWaveSampleCopy], a
    call $49E8
    ld a, $01
    ld [wSoundFlags], a
    call UpdateWaveDuty
    ld a, $FF
    ld c, $02
    jp $50E6
