; Reset all four sound slots. ResetSoundSlots also clears wCountdownFlags;
; ResetSoundSlotsKeepCountdown ($41EC, called from bank $30 $424D) starts at
; the wSoundFlags clear. For slot 0-3: wSlotStreamIndex = slot, the slot's
; wInstalledPriority byte and wSoundStreamPointers word are cleared, then
; ArmChannelAfterCountdown and ContinueClearedChannel run for it.

ResetSoundSlots::
    xor a
    ld [wCountdownFlags], a
ResetSoundSlotsKeepCountdown::
    xor a
    ld [wSoundFlags], a
.slot_loop:
    push af
    ld [wSlotStreamIndex], a
    ld c, a
    ld b, $00
    xor a
    ld hl, wInstalledPriority
    add hl, bc
    ld [hl], a
    sla c
    ld hl, wSoundStreamPointers
    add hl, bc
    ld [hl+], a
    ld [hl], a
    call ArmChannelAfterCountdown
    call ContinueClearedChannel
    pop af
    inc a
    cp $04
    jr nz, .slot_loop
    ret
