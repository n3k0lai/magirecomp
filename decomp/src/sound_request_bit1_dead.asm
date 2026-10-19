; Unreachable sound command. SelectSoundCommand stores $0705 only from a
; second test of bit 1 of wSoundRequest, and that test is already false.
; Timer overflow would call it with ROM bank $30 mapped. This routine does
; not write rROMB0.
;
; $5798, still INCBIN in bank $30, tests bit 7 of $DFA6. When that bit is
; set it sets bit 4 and falls into DropCountdownGate. When it is clear,
; $5798 returns and the gate stays as it was.

SoundRequestBit1Dead::
    call $5798
    ret
