; Sound command stored by SelectSoundCommand when $C924 is nonzero and
; bit 1 of that byte is set. The selector decrements $C924 before storing
; this address. Timer overflow calls it with ROM bank $30 already mapped.
;
; Maps bank $30 again, then calls TestCountdownAndDropGate. C is $52 and
; HL is $C8C9 for the copy at $57E0, still INCBIN in bank $30. That copy
; runs only when C is $52: it moves $52 bytes from $DFA6 to $C8C9. Bank
; $30 is stored to wCurrentROMBank and rROMB0 a second time before the
; call. A from $C925 is then passed to InstallSoundIndex, and this returns.

SoundCountdown::
    ld a, $30
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call TestCountdownAndDropGate
    ld c, $52
    ld hl, $C8C9
    ld a, $30
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $57E0
    ld a, [$C925]
    call InstallSoundIndex
    ret
