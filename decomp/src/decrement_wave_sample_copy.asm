; Decrement A and store it at wWaveSampleCopy ($DF7D).
;
; The bytes that follow, still INCBIN, load that copy and jump here when it
; is nonzero, so the waveform stream does not advance on this tick.
; wWaveSampleCopy is the name from update_wave_duty.asm.

DecrementWaveSampleCopy::
    dec a
    ld [wWaveSampleCopy], a
    ret
