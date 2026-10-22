; Refresh sound-channel lengths. UpdateSoundTick calls this at $4524
; when bit 0 of $DF04 is set. That tick has just set bit 6 of each
; channel flag at $DF09, $DF0A, and $DF0B.
;
; Countdown bytes sit at $DF07, $DF06, and $DF05, walked with E = 2, 1, 0.
; A nonzero byte is decremented. A zero byte whose flag bit 6 is clear
; stays zero. When that bit is set it is cleared, the channel's length
; register is masked, and the countdown reloads to 60. The mask for
; E = 2 is $00, which clears NR31 ($FF1B) and loads the longest wave
; length. Otherwise the mask is $C0, so NR11 ($FF11) and NR21 ($FF16)
; keep their duty bits and the length field is cleared.

DEF wChannelLengthTimerTop EQU $DF07
DEF wChannelFlagBase EQU $DF09
DEF LENGTH_RELOAD EQU $3C
DEF WAVE_CHANNEL EQU $02

ReloadChannelLengths:
    ld de, $0002
    ld hl, wChannelLengthTimerTop

.each:
    ld a, [hl]
    and a
    jr z, .expired

    dec [hl]

.advance:
    dec hl
    dec e
    bit 7, e
    jr z, .each

    ret

.expired:
    push hl
    ld hl, wChannelFlagBase
    add hl, de
    bit 6, [hl]
    jr nz, .armed

    pop hl
    jr .advance

.armed:
    res 6, [hl]
    ld hl, .length_registers
    add hl, de
    ld c, [hl]
    ld b, $c0
    ld a, e
    cp WAVE_CHANNEL
    jr nz, .mask

    ld b, $00

.mask:
    ldh a, [c]
    and b
    ldh [c], a
    pop hl
    ld [hl], LENGTH_RELOAD
    jr .advance

.length_registers:
    INCBIN "roms/magination.gbc", $C055A, $3
