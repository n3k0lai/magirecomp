; Sound command stored by SelectSoundCommand when $C922 is not $FF.
; Timer overflow calls it with ROM bank $30 mapped. This routine does not
; write rROMB0.
;
; A is the value from $C922. B is $0F and C is $01 for the call to $4F44,
; the same opener SoundSlotA uses. $C922 is then set to $FF so this command
; is not chosen again, and the routine returns.

SoundSlotB::
    ld a, [$C922]
    ld b, $0F
    ld c, $01
    call $4F44
    ld a, $FF
    ld [$C922], a
    ret
