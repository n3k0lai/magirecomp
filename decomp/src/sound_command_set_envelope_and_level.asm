; Sound command: run SoundCommandSetEnvelopeFromMix, then convert the slot's
; wPhaseLevel through LookupChannelNibble into its wChannelLevels byte (BC is
; the slot index left by that routine).

SoundCommandSetEnvelopeAndLevel::
    call SoundCommandSetEnvelopeFromMix
    ld hl, wPhaseLevel
    add hl, bc
    ld a, [hl]
    call LookupChannelNibble
    ld hl, wChannelLevels
    add hl, bc
    ld [hl], a
    ret
