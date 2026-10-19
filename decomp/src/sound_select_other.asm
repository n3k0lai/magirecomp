; Tick the leftover sound select. SelectSoundCommand stores this address in
; wSoundCommand when $C92A is nonzero and bits 0 and 1 are both clear.
; Timer overflow calls it with ROM bank $30 mapped.
;
; The byte at $C92C is passed to ApplyC92C, then $C92A is cleared. This
; routine does not write rROMB0.

SoundSelectOther::
    call ApplyC92C
    xor a
    ld [$C92A], a
    ret
