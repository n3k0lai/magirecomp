; Timer-driven wave feed, while bit 6 of wSoundFlags ($DF74) is set.
;
; $DF08 is written to both TIMA and TMA. A nonzero wWaveSampleCopy
; decrements through DecrementWaveSampleCopy, so the waveform waits.
;
; Otherwise the word at wWaveFloor counts down by one. At zero, $3B7C
; (still INCBIN) clears bit 6 and stops the timer, then the word at
; wWavePosition is jumped to when it is nonzero.
;
; Until then the bank in wWaveWidth is mapped and the pointer at
; wWaveStep supplies 16 bytes for wave RAM at $FF30. NR30 is cleared
; first. A header whose high nibble is $7 stores the next byte at
; wWaveSampleCopy, skips $0E bytes, and fills wave RAM with $88.
; NR30 is enabled, and wWaveFreqHigh is written to NR34 with the
; trigger bit set and then clear. The pointer is stored back. A high
; byte at or above $80 is wrapped to $40 and wWaveWidth is incremented.
; The bank saved at $DF00 is not restored.
;
; wSoundFlags is the name from write_channel_envelope.asm. wWaveFloor,
; wWaveStep, wWaveWidth, wWavePosition, wWaveSampleCopy, and
; wWaveFreqHigh are the names from update_wave_duty.asm. rNR30 and
; rNR34 are the names from load_waveform.asm. rTMA is the name from
; reset.asm.

DEF rTIMA EQU $FF05

FeedWaveFromTimer::
    ld a, [wSoundFlags]
    bit 6, a
    ret z

    ld a, [$df08]
    ldh [rTIMA], a
    ldh [rTMA], a
    ld a, [wWaveSampleCopy]
    and a
    jr nz, DecrementWaveSampleCopy

    ld hl, wWaveFloor
    ld a, [hl]
    sub $01
    ld [hl+], a
    ld c, a
    ld a, [hl]
    sbc $00
    ld [hl], a
    or c
    jr z, .countdown_done

    ld a, [wWaveWidth]
    call MapRomBank
    ld hl, wWaveStep
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld c, $30
    xor a
    ldh [rNR30], a
    ld a, [hl+]
    ld b, a
    and $f0
    cp $70
    jr z, .flat

    ld a, b
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a

.retrigger:
    ld a, $80
    ldh [rNR30], a
    ld a, [wWaveFreqHigh]
    or $80
    ldh [rNR34], a
    and $7f
    ldh [rNR34], a
    ld a, l
    ld b, h
    ld hl, wWaveStep
    ld [hl+], a
    ld [hl], b
    bit 7, b
    jr z, .done

    ld [hl], $40
    ld hl, wWaveWidth
    inc [hl]

.done:
    ret

.countdown_done:
    call $3b7c
    ld a, [wWavePosition]
    ld l, a
    ld a, [wWavePosition + 1]
    ld h, a
    or l
    ret z

    jp hl

.flat:
    ld a, [hl+]
    ld [wWaveSampleCopy], a
    ld bc, $000e
    add hl, bc
    ld c, l
    ld b, h
    ld hl, $ff30
    ld a, $88
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld l, c
    ld h, b
    jr .retrigger
