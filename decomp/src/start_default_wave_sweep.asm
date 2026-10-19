; Start the default wave sweep from the 4-byte record at $6069 in this bank:
; floor (also copied to $DF7C), limit, then the high and low bytes of
; wWaveStep. wWavePosition is cleared and wSoundStreamCursor is left just past
; the record. Width and sample copy become $FF, the routine at $49E8 runs,
; wSoundFlags becomes 1, UpdateWaveDuty runs, and $50E6 is tail-called with
; A = $FF and C = 2. Its first byte, $21, doubles as the last entry of
; EnvelopeRegisterBySlot.

StartDefaultWaveSweep::
    ld hl, $6069
    ld a, [hl+]
    ld [wWaveFloor], a
    ld [$DF7C], a
    xor a
    ld [wWavePosition], a
    ld a, [hl+]
    ld [wWaveLimit], a
    ld a, [hl+]
    ld [wWaveStep + 1], a
    ld a, [hl+]
    ld [wWaveStep], a
    ld a, l
    ld [wSoundStreamCursor], a
    ld a, h
    ld [wSoundStreamCursor + 1], a
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
