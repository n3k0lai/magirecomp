; Sound command stored by SelectSoundCommand when $C921 is not $FF.
; Timer overflow calls it with ROM bank $30 mapped. This routine does not
; write rROMB0.
;
; A is the value from $C921. B is $0F and C is $01 for the call to $4F44,
; still INCBIN in bank $30. $C921 is then set to $FF so this command is not
; chosen again, and the routine returns.

SoundSlotA::
    ld a, [$C921]
    ld b, $0F
    ld c, $01
    call $4F44
    ld a, $FF
    ld [$C921], a
    ret
