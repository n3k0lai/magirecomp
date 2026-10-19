; Clear the sound-active flag and countdown, then run the sound index.
;
; SelectSoundCommand stores this address in wSoundCommand when $C91E
; (wSoundActive) is nonzero. Timer overflow calls it with ROM bank $30
; mapped. $57A0 and $5702 are still INCBIN in that bank. $5702 is called
; with A loaded from $C920 (wSoundIndex). ApplyC92C then passes the byte
; at $C92C to $4320.

SoundActive::
    xor a
    ld [$C91E], a
    ld [$C924], a
    call $57A0
    ld a, [$C920]
    call $5702
    call ApplyC92C
    ret
