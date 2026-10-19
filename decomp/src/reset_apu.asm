; Reset the APU to a silent known state. Master volume, panning and power
; are cleared, then sound is powered on. Channels 1, 2 and 4 get flat or
; zero settings with the trigger/initial bits written as $80 where the
; hardware expects them; channel 3 is disabled while its 16-byte wave RAM
; ($FF30-$FF3F) is zeroed. Master volume ends at $77.

ResetApu::
    xor a
    ld hl, $FF24
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld a, $80
    ld [hl], a
    ld c, $10
    ld a, $08
    ldh [c], a
    ld a, $80
    inc c
    ldh [c], a
    xor a
    inc c
    ldh [c], a
    inc c
    ldh [c], a
    ld a, $80
    inc c
    ldh [c], a
    ld c, $16
    ld a, $80
    ldh [c], a
    xor a
    inc c
    ldh [c], a
    inc c
    ldh [c], a
    ld a, $80
    inc c
    ldh [c], a
    ld c, $1A
    xor a
    ldh [c], a
    inc c
    ldh [c], a
    inc c
    ldh [c], a
    inc c
    ldh [c], a
    ld a, $80
    inc c
    ldh [c], a
    xor a
    ld hl, $FF30
    ld b, $10
.clear_wave:
    ld [hl+], a
    dec b
    jr nz, .clear_wave
    ld c, $20
    ldh [c], a
    inc c
    ldh [c], a
    inc c
    ldh [c], a
    ld a, $80
    inc c
    ldh [c], a
    ld a, $77
    ldh [$FF24], a
    ret
