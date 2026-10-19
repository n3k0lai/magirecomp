; Sound command stored by SelectSoundCommand when bit 2 of wSoundRequest
; ($C91F) is set. Timer overflow calls it with ROM bank $30 mapped.
; This routine does not write rROMB0.
;
; $57CF, still INCBIN in bank $30, returns at once when bit 4 of $DFA6 is
; clear. Otherwise it clears that bit, sets bit 7, and returns 1 in A.
; The value in A is unused here.

SoundRequestBit2::
    call $57CF
    ret
