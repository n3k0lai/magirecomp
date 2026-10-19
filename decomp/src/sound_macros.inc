; Sound stream macros for bank $30. One macro per command in the word
; table at $4DA6; see scripts/own/music-format.md.
;
; Branch and jump targets are labels. Commands $06, $15-$17, and $18
; store them big-endian, as an offset from SoundStreamTable. Command $05
; stores a big-endian offset from the next command.

MACRO snd_be
    db HIGH(\1), LOW(\1)
ENDM
MACRO snd_target
    snd_be (\1) - SoundStreamTable
ENDM

MACRO snd_end
    db $00
ENDM
MACRO snd_cmd01
    db $01, \1, \2, \3
ENDM
MACRO snd_cmd02
    db $02, \1, \2, \3, \4, \5
ENDM
MACRO snd_cmd03
    db $03, \1, \2, \3, \4, \5
ENDM
; wait: until-flag, source, high, low (SoundCommand04 holds the stream here)
MACRO snd_wait
    db $04, \1, \2, \3, \4
ENDM
; loop count, target: repeat back to target until the counter hits count
MACRO snd_loop
    db $05, \1
    DEF SND_REL = (\2) - (@ + 2)
    db HIGH(SND_REL), LOW(SND_REL)
    PURGE SND_REL
ENDM
MACRO snd_jump
    db $06
    snd_target \1
ENDM
MACRO snd_slide_toward
    db $07
    snd_be \1
ENDM
MACRO snd_slide
    db $08, \1
    snd_be \2
ENDM
MACRO snd_env_mix
    db $09, \1
ENDM
MACRO snd_output
    db $0A, \1
ENDM
MACRO snd_random_period
    db $0B, \1, \2, \3, \4
ENDM
MACRO snd_duty
    db $0C, \1
ENDM
MACRO snd_release
    db $0D
ENDM
MACRO snd_skip
    db $0E, \1
ENDM
MACRO snd_phase_script
    db $0F, \1
ENDM
MACRO snd_noise
    db $10, \1
ENDM
MACRO snd_phase_up
    db $11
    dw \1
ENDM
MACRO snd_countdown
    db $12, \1
ENDM
MACRO snd_envelope
    db $13, \1
ENDM
MACRO snd_slide_rel
    db $14
    snd_be \1
ENDM
MACRO snd_if_period
    db $15, \1
    snd_target \2
ENDM
MACRO snd_if_random
    db $16, \1
    snd_target \2
ENDM
MACRO snd_if_envelope
    db $17, \1
    snd_target \2
ENDM
MACRO snd_loop_point
    db $18
    snd_target \1
ENDM
MACRO snd_clear_loop
    db $19
ENDM
MACRO snd_df33_bit
    db $1A, \1
ENDM
MACRO snd_glide
    db $1B, \1, \2, \3, \4
ENDM
MACRO snd_priority
    db $1C, \1, \2
ENDM
MACRO snd_wave_sweep
    db $1D, \1, \2, \3, \4
ENDM
MACRO snd_load_wave_sweep
    db $1E, \1, \2, \3, \4
ENDM
MACRO snd_clear_fx
    db $1F
ENDM
MACRO snd_clear_fx_slide
    db $20
ENDM
MACRO snd_select_wave
    db $21, \1
ENDM
MACRO snd_step_wave
    db $22
ENDM
MACRO snd_end_23
    db $23
ENDM
MACRO snd_reset_wave
    db $24, \1
ENDM
MACRO snd_restart_wave
    db $25
ENDM
MACRO snd_trigger_tag
    db $26, \1, \2
ENDM
MACRO snd_phase_down
    db $27
    dw \1
ENDM
MACRO snd_env_level
    db $28, \1
ENDM
MACRO snd_priority_29
    db $29, \1, \2
ENDM
