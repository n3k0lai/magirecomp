; Sound command at bank $30 $4652. BC points at the command operand in the
; channel stream. The operand byte is read into E and the stream cursor
; (wSoundStreamCursor) is left just past it. For the current slot
; (wSlotStreamIndex) bit 1 of its wChannelFlagBase byte picks the high or
; low nibble of wSlotMix. LookupChannelNibble turns that nibble into a value
; stored in the slot's wTagEnvelopeParam byte, and bit 5 of the slot's
; wTagChannelFlags byte is set. What E means to LookupChannelNibble is still
; unknown.

SoundCommandSetEnvelopeFromMix::
    ld a, [bc]
    ld e, a
    inc bc
    ld hl, wSoundStreamCursor
    ld a, c
    ld [hl+], a
    ld [hl], b
SoundCommandSetEnvelopeFromSlot:: ; $465B, entered only by the unused tail at bank $30 $4FFF
    ld a, [wSlotStreamIndex]
    ld c, a
    ld b, $00
    ld hl, wChannelFlagBase
    add hl, bc
    bit 1, [hl]
    ld a, [wSlotMix]
    jr z, .low_nibble
    swap a
.low_nibble:
    and $0F
    call LookupChannelNibble
    ld hl, wTagEnvelopeParam
    add hl, bc
    ld [hl], a
    ld hl, wTagChannelFlags
    add hl, bc
    set 5, [hl]
    ret
