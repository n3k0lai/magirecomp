; Called when the word at wWaveFloor ($DF78) hits zero.
;
; Clears bit 6 of wSoundFlags so the timer wave feed stops, and writes
; zero to wTagPriorityLimit. rIE and rIF are masked with $1B, which
; drops the timer interrupt and leaves VBlank, STAT, serial, and joypad.
; The wave DAC is turned off and back on, rTAC is cleared so the timer
; stops, and rNR51 is masked with $BB, the channel-3 mute used by
; DropChannelOutput.
;
; wSoundFlags is the name from write_channel_envelope.asm.
; wTagPriorityLimit is the name from open_channel_for_tag.asm.
; rIE and rIF are the names from turn_off_lcd.asm. rTAC is the name
; from reset.asm. rNR30 is the name from load_waveform.asm. rNR51 is
; the name from drop_channel_output.asm.

StopWaveCountdown::
    ld hl, wSoundFlags
    res 6, [hl]
    xor a
    ld [wTagPriorityLimit], a
    ldh a, [rIE]
    and $1b
    ldh [rIE], a
    ldh a, [rIF]
    and $1b
    ldh [rIF], a
    xor a
    ldh [rNR30], a
    ldh [rTAC], a
    ld a, $80
    ldh [rNR30], a
    ldh a, [rNR51]
    and $bb
    ldh [rNR51], a
    ret
