; Sound command with a 1-byte operand at BC: a duty or wave selector in E.
; The cursor is saved past it. Slots 2 and 3 restart with E as given. For
; slots 0-1, E = $FF means "keep": the slot's wTagEnvelopeParam >> 2 is used
; instead. Every path tail-calls RestartChannel with C = slot.

SoundCommandRestartWithDuty::
    ld a, [bc]
    ld e, a
    inc bc
    ld hl, wSoundStreamCursor
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [wSlotStreamIndex]
    cp $02
    ld c, a
    ld a, e
    jp nc, RestartChannel
    cp $FF
    jp nz, RestartChannel
    ld b, $00
    ld hl, wTagEnvelopeParam
    add hl, bc
    ld a, [hl]
    srl a
    srl a
    jp RestartChannel
