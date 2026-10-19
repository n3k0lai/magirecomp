; Restart channel C (0-3) and route it in rNR51. A is passed in E as a
; per-channel value. Channel 3 only routes. Channel 2 (wave): unless E is
; $FF, $515A maps E to a wave width stored in wWaveWidth and
; CopyMappedWaveform loads it; then the trigger bit is pulsed on its NRx4
; register. Channels 0-1: when E < 4 it becomes the duty (E rotated into bits
; 7-6) in the NRx1 register from the table at $5151; then wChannelFreqHigh
; with bit 7 (trigger) goes to the NRx4 register from the table at $5153.
; Finally bit 7 of the channel's wChannelFlagBase byte is set, and rNR51 keeps
; its bits for this channel (mask table at $5156) merged with
; wChannelOwnMask for the rest.

RestartChannel::
    ld e, a
    ld b, $00
    ld a, c
    cp $03
    jp z, .route
    cp $02
    jr z, .wave
    ld a, e
    cp $04
    jr nc, .trigger
    ld hl, unk_0C1151
    add hl, bc
    ld l, [hl]
    ld h, $FF
    rrc e
    rrc e
    ld [hl], e
.trigger:
    ld hl, wChannelFreqHigh
    add hl, bc
    ld a, [hl]
    ld hl, unk_0C1153
    add hl, bc
    ld l, [hl]
    or $80
    ld h, $FF
    ld [hl], a
    jr .route
.wave:
    ld a, e
    cp $FF
    jr z, .pulse
    push bc
    call $515A
    ld [wWaveWidth], a
    call CopyMappedWaveform
    pop bc
.pulse:
    ld d, c
    ld hl, wChannelFreqHigh
    add hl, bc
    ld a, [hl]
    ld hl, unk_0C1153
    add hl, bc
    ld c, [hl]
    or $80
    ldh [c], a
    and $7F
    ldh [c], a
    ld c, d
.route:
    ld hl, wChannelFlagBase
    add hl, bc
    set 7, [hl]
    ld hl, ChannelNr51ClearMask
    add hl, bc
    ld b, [hl]
    ldh a, [rNR51]
    and b
    ld c, a
    ld a, b
    cpl
    ld b, a
    ld a, [wChannelOwnMask]
    and b
    or c
    ldh [rNR51], a
    ret
