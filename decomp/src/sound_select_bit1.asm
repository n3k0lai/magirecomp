; Tick the bit-1 sound select. SelectSoundCommand stores this address in
; wSoundCommand when bit 1 of $C92A is set. Timer overflow calls it with
; ROM bank $30 mapped.
;
; $C928 counts calls. Until it matches $C929, the byte at $C92C is passed
; to ApplyC92C and this returns. On a match, $C928 is cleared and $C92C is
; incremented. When that increment reaches $0F the rise ends: $C92C stays
; $0F, $C92A is cleared, $C929 is set to 1, and ApplyC92C runs. A smaller
; value is stored and ApplyC92C runs. This routine does not write rROMB0.

SoundSelectBit1::
    ld a, [$C929]
    ld e, a
    ld a, [$C928]
    inc a
    ld [$C928], a
    cp e
    jp nz, .apply

    xor a
    ld [$C928], a
    ld a, [$C92C]
    inc a
    cp $0F
    jp z, .finish

    ld [$C92C], a

.apply:
    call ApplyC92C
    ret

.finish:
    ld [$C92C], a
    xor a
    ld [$C92A], a
    ld a, $01
    ld [$C929], a
    call ApplyC92C
    ret
