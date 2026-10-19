; Sound command at bank $30 $49FA. BC points at the command operands.
; When bit 0 of wSoundFlags is set, four operand bytes load the wave sweep:
; wWaveFloor, wWaveLimit, then the high and low bytes of wWaveStep. The
; stream cursor is saved past them and UpdateWaveDuty runs as a tail call.
; When the bit is clear the four operand bytes are skipped: wSoundStreamCursor
; moves forward by 4 with the carry kept in its high byte.

SoundCommandLoadWaveSweep::
    ld a, [wSoundFlags]
    bit 0, a
    jr z, .skip_operands
    ld l, c
    ld h, b
    ld a, [hl+]
    ld [wWaveFloor], a
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
    jp UpdateWaveDuty

.skip_operands:
    ld hl, wSoundStreamCursor
    ld a, [hl]
    add a, $04
    ld [hl+], a
    ld a, [hl]
    adc a, $00
    ld [hl], a
    ret
