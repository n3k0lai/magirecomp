; Wave-duty sweep. UpdateSoundTick calls this at $43E0 when bit 0 of
; $DF74 is set. The step at $DF76 and the position at $DF7B are signed
; 16-bit words. The position moves by the step, then bounces.
;
; A positive step reflects off the limit in $DF7A, used as that byte
; shifted left by 8. A negative step reflects off the floor in $DF78
; the same way, including when the position itself is still negative.
; Reflection is `position = (limit << 9) - position` and stores the
; negated step back to $DF76. $418D compares the positive limit with
; the new position and returns carry when the limit is below it.
;
; The position's high byte is the pulse width. When it differs from
; $DF75, or the sample at $DF31 differs from the copy in $DF7D, wave
; RAM is rebuilt. NR30 is cleared first. $FF30 receives $DF31 as-is.
; A is then both nibbles of that byte. The width's high half selects
; an entry in the `ld [hl+], a` run, so the pulse is `1 + width / 2`
; bytes, plus one high-nibble byte when the width is odd. The next
; seven stores clear the tail, and the last of them does not advance
; HL. NR30 is set again, NR31 is cleared, NR32 is set to $20, and
; NR34 is written from $DF14 with the trigger bit set and then clear.

DEF wWaveStep EQU $DF76
DEF wWaveFloor EQU $DF78
DEF wWaveLimit EQU $DF7A
DEF wWavePosition EQU $DF7B
DEF wWaveWidth EQU $DF75
DEF wWaveSample EQU $DF31
DEF wWaveSampleCopy EQU $DF7D
DEF wWaveFreqHigh EQU $DF14

UpdateWaveDuty:
    ld hl, wWaveStep
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    ld hl, wWavePosition
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld b, h
    ld c, l
    bit 7, d
    jr nz, .negative_step

    ld a, [wWaveLimit]
    ld h, a
    ld l, $00
    call $418d
    jr nc, .store_position

.reflect:
    ld a, c
    cpl
    add $01
    ld c, a
    ld a, b
    cpl
    adc $00
    ld b, a
    sla h
    add hl, bc
    ld b, h
    ld c, l
    ld a, e
    cpl
    add $01
    ld e, a
    ld a, d
    cpl
    adc $00
    ld d, a
    ld hl, wWaveStep
    ld a, e
    ld [hl+], a
    ld [hl], d

.store_position:
    ld hl, wWavePosition
    ld a, c
    ld [hl+], a
    ld [hl], b
    jr .apply_width

.negative_step:
    ld a, [wWaveFloor]
    ld l, a
    bit 7, b
    jr nz, .below_floor

    ld a, b
    cp l
    jr nc, .store_below

.below_floor:
    ld h, l
    ld l, $00
    jr .reflect

.store_below:
    ld hl, wWavePosition
    ld a, c
    ld [hl+], a
    ld [hl], b

.apply_width:
    ld a, [wWaveWidth]
    cp b
    jr nz, .rewrite

    ld a, [wWaveSampleCopy]
    ld c, a
    ld a, [wWaveSample]
    cp c
    ret z

.rewrite:
    ld a, b
    ld [wWaveWidth], a
    ld c, a
    ld d, $00
    srl a
    ld e, a
    ld a, $07
    sub e
    ld e, a
    ld hl, .pulse
    add hl, de
    push hl
    xor a
    ldh [$ff1a], a
    ld a, [wWaveSample]
    ld [wWaveSampleCopy], a
    ld hl, $ff30
    ld [hl+], a
    ld b, a
    swap a
    or b
    ret

.pulse:
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    bit 0, c
    jr z, .clear_tail

    and $f0
    ld [hl+], a

.clear_tail:
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld a, $80
    ldh [$ff1a], a
    xor a
    ldh [$ff1b], a
    ld a, $20
    ldh [$ff1c], a
    ld a, [wWaveFreqHigh]
    or $80
    ldh [$ff1e], a
    and $7f
    ldh [$ff1e], a
    ret
