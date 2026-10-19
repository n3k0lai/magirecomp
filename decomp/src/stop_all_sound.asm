; Stop all sound: clear wSoundSignature, reset the four slots, and power the
; APU off (rNR52 = 0).

StopAllSound::
    xor a
    ld [wSoundSignature], a
    call ResetSoundSlots
    xor a
    ldh [$FF26], a
    ret
