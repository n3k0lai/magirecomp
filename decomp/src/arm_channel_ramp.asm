; ArmChannelRamp ($539C). SoundCommand03 calls this for stream indexes
; below 3, with bank $30 still mapped. A is that index ORed with the
; command's fifth operand. BC is the ramp step and DE is the fold limit.
;
; Bit 7 of A is saved, then cleared. The remaining value indexes the flag
; byte at $DF09. A zero flag takes the primary slide words: bits 0, 2, and
; 3 are cleared. A nonzero flag takes the words three channels later, the
; slot bit 4 of StepChannelSlides reads, and bits 0, 2, and 4 are cleared.
; BC is stored at $DF34 and DE at $DF40, and the accumulator at $DF4C is
; cleared. Saved bit 7 then chooses the enable bit on the original flag:
; clear sets bit 3, set sets bit 4.

ArmChannelRamp:
    bit 7, a
    res 7, a
    push af
    push de
    ld hl, $DF09
    ld d, $00
    ld e, a
    add hl, de
    ld a, [hl]
    jr nz, .secondary_slot

    and $F2
    ld [hl], a
    jr .store_words

.secondary_slot:
    and $EA
    ld [hl], a
    ld a, e
    add a, $03
    ld e, a

.store_words:
    sla e
    ld hl, $DF34
    add hl, de
    ld a, c
    ld [hl+], a
    ld [hl], b
    pop bc
    ld hl, $DF40
    add hl, de
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $DF4C
    add hl, de
    xor a
    ld [hl+], a
    ld [hl], a
    pop af
    ld e, a
    ld hl, $DF09
    add hl, de
    jr nz, .enable_shifted

    set 3, [hl]
    ret

.enable_shifted:
    set 4, [hl]
    ret

ArmChannelRampEnd:
