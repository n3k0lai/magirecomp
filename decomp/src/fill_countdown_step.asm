; InstallSoundIndex calls this at $577F after the countdown table is stored.
; ROM bank $30 stays mapped. The bytes at $576D also jump here when BC
; is zero.
;
; $3D4A returns a word in HL. That word is copied into BC, multiplied
; by $66 at $4002, then divided by $3C at $40AA. The quotient is the
; 16-bit step at $DFAA. StepSoundCountdowns subtracts it from each
; armed 24-bit count.
;
; $3D4A is still INCBIN in bank 0.

DEF wFilledCountdownStep EQU $DFAA

FillCountdownStep:
    call $3d4a
    ld c, l
    ld b, h
    ld a, $66
    call MultiplyAByBc
    ld bc, $003c
    call DivideHlByBc
    ld a, l
    ld [wFilledCountdownStep], a
    ld a, h
    ld [wFilledCountdownStep + 1], a
    ret
