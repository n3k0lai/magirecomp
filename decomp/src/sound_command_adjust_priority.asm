; Priority command with a 2-byte operand at BC: mode, value. Mode nonzero
; stores the value as the slot's wInstalledPriority. Mode 0 adds the signed
; value to it, clamped to $00-$FF. The stream cursor advances by 2.

SoundCommandAdjustPriority::
    ld a, [wSlotStreamIndex]
    ld e, a
    ld d, $00
    ld hl, wInstalledPriority
    add hl, de
    ld a, [bc]
    inc bc
    and a
    ld a, [bc]
    jr nz, .store
    ld e, a
    ld a, [hl]
    bit 7, e
    jr nz, .subtract
    add a, e
    jr nc, .store
    ld a, $FF
    jr .store
.subtract:
    sub e
    jr nc, .store
    xor a
.store:
    ld [hl], a
    ld hl, wSoundStreamCursor
    ld a, [hl]
    add a, $02
    ld [hl+], a
    ld a, [hl]
    adc a, $00
    ld [hl], a
    ret
