; Wave slot command with a 1-byte operand at BC. Only slot 2 acts: wSoundFlags
; is cleared and the operand goes to $515A, which returns a flag in E bit 0.
; Clear: $4B7E and $4BA9 run and wSoundFlags bit 7 is set. Set: $4B7E runs,
; wWavePosition and $DF7C are cleared, $4BD2 runs and wSoundFlags bit 6 is
; set. The stream cursor always advances by 1.

SoundCommandSelectWave::
    ld a, [wSlotStreamIndex]
    cp $02
    jr nz, .advance
    xor a
    ld [wSoundFlags], a
    ld a, [bc]
    call $515A
    bit 0, e
    jr nz, .bit_set
    call $4B7E
    call $4BA9
    ld hl, wSoundFlags
    set 7, [hl]
.advance:
    ld hl, wSoundStreamCursor
    ld a, [hl]
    add a, $01
    ld [hl+], a
    ld a, [hl]
    adc a, $00
    ld [hl], a
    ret
.bit_set:
    call $4B7E
    xor a
    ld [wWavePosition], a
    ld [$DF7C], a
    call $4BD2
    ld hl, wSoundFlags
    set 6, [hl]
    jr .advance
