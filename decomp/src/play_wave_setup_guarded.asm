; Load and play a wave setup with interrupts off. A goes to wWaveWidth, HL to
; wWaveStep, E to wSavedTagParam; BC is passed through to the routine at
; $3C6B. When $DF04 is $81 and the CPU is in double speed (rKEY1 bit 7), the
; routine at $4288 runs before and after the setup (likely a speed switch).
; The setup resets the sound slots, power-cycles the APU (NR52), sets full
; master volume and panning, primes channels 1 and 2 (duty, envelope, max
; frequency, trigger), calls $3C6B, then power-cycles the APU again.

PlayWaveSetupGuarded::
    di
    push af
    push hl
    ld a, [$DF04]
    cp $81
    jr nz, .single_speed
    ld hl, rKEY1
    bit 7, [hl]
    jr z, .single_speed
    call $4288
    pop hl
    pop af
    call PlayWaveSetup
    call $4288
    ret
.single_speed:
    pop hl
    pop af
PlayWaveSetup::
    di
    ld [wWaveWidth], a
    ld a, l
    ld [wWaveStep], a
    ld a, h
    ld [wWaveStep + 1], a
    ld a, e
    ld [wSavedTagParam], a
    push bc
    call ResetSoundSlotsKeepCountdown
    xor a
    ldh [$FF26], a
    ld a, $80
    ldh [$FF26], a
    ld a, $77
    ldh [$FF24], a
    ld a, $33
    ldh [$FF25], a
    ld a, $C0
    ldh [$FF11], a
    ldh [$FF16], a
    ld a, $F0
    ldh [$FF12], a
    ldh [$FF17], a
    ld a, $FF
    ldh [$FF13], a
    ldh [$FF18], a
    ld a, $87
    ldh [$FF14], a
    ldh [$FF19], a
    pop bc
    call $3C6B
    xor a
    ldh [$FF26], a
    ld a, $80
    ldh [$FF26], a
    ld a, $77
    ldh [$FF24], a
    ei
    ret
