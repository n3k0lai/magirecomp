; ArmChannelVibrato ($536D). SoundCommand01 jumps here when the stream
; index in C is below 3 and bank $30 is still mapped.
;
; DE is the step word from the command and B is its half-period byte.
; C is the channel, 0 through 2, and is doubled to index the slide words.
; The step is stored at $DF34. B is stored as the low byte of the reload
; at $DF40. B / 2, or 1 when that half is zero, is stored as the low byte
; of the remaining count at $DF3A. The latch word at $DF46 is cleared.
; The flag at $DF09 keeps bits 7, 6, 5, and 1, clears the glide and ramp
; bits 2-4, and sets bit 0 so StepChannelSlides takes the vibrato path.

ArmChannelVibrato:
    ld a, b
    ld b, $00
    sla c
    ld hl, $DF40
    add hl, bc
    ld [hl], a
    ld hl, $DF3A
    add hl, bc
    srl a
    jr nz, .store_half

    inc a

.store_half:
    ld [hl], a
    ld hl, $DF34
    add hl, bc
    ld a, e
    ld [hl+], a
    ld [hl], d
    ld hl, $DF46
    add hl, bc
    xor a
    ld [hl+], a
    ld [hl], a
    srl c
    ld hl, $DF09
    add hl, bc
    ld a, [hl]
    and $E2
    or $01
    ld [hl], a
    ret
