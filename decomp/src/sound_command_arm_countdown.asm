; Sound command with a 1-byte operand: a countdown index. The cursor is
; saved past it. $FF falls through into ArmChannelAfterCountdown; any other
; value joins it at .scale_index.

SoundCommandArmCountdown::
    ld a, [bc]
    inc bc
    ld hl, wSoundStreamCursor
    ld [hl], c
    inc hl
    ld [hl], b
    cp $FF
    jr nz, ArmChannelAfterCountdown.scale_index
