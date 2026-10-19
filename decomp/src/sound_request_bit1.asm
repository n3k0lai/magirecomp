; Sound command stored by SelectSoundCommand when bit 1 of $C91F is set.
; Timer overflow calls it with ROM bank $30 mapped. Other banks also jump
; here, and they enter at $0701 or $0704.
;
; The entry at $06FC writes $FF to $C920 (wSoundIndex), then falls through.
; $0701 calls DropCountdownGate at $57A0 and returns. $0704 returns at once.
; This routine does not write rROMB0.

SoundRequestBit1::
    ld a, $FF
    ld [$C920], a

SoundRequestDropGate::
    call DropCountdownGate

SoundRequestReturn::
    ret
