; Silence the wave channel: disable it (rNR30), clear wave RAM bytes
; $FF39-$FF3F, then enable it again.

ClearWaveTail::
    xor a
    ldh [rNR30], a
    ld hl, $FF39
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld a, $80
    ldh [rNR30], a
    ret
