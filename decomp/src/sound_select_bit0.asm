; Tick the bit-0 sound select. SelectSoundCommand stores this address in
; wSoundCommand when bit 0 of $C92A is set, after writing $FF to $C920.
; Timer overflow calls it with ROM bank $30 mapped.
;
; $C928 counts calls. Until it matches $C929, the byte at $C92C is passed
; to ApplyC92C and this returns. On a match, $C928 is cleared. If $C92C is
; 0 or 1 the fade ends: $C920 becomes $FF, $C92C and $C92A are cleared,
; $C929 is set to 1, ApplyC92C runs, then $57A0. Any larger $C92C is
; decremented and ApplyC92C runs. $57A0 is still INCBIN in bank $30. This
; routine does not write rROMB0, so that call uses the bank the caller mapped.

SoundSelectBit0::
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
    and a
    jp z, .finish

    dec a
    jp z, .finish

    ld [$C92C], a

.apply:
    call ApplyC92C
    ret

.finish:
    ld a, $FF
    ld [$C920], a
    xor a
    ld [$C92C], a
    ld [$C92A], a
    ld a, $01
    ld [$C929], a
    call ApplyC92C
    call $57A0
    ret
