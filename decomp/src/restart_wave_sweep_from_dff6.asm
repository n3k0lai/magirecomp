; Restart the wave sweep with the current $DFF6 value: load it into A and
; join SoundCommandResetWaveSweep after its operand read ($4A32).

RestartWaveSweepFromDff6::
    ld a, [$DFF6]
    jr $4A32
