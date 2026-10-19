; SoundCountdownIdle calls this at $57EE with C = $52 and HL = $C8C9.
; ROM bank $30 is already mapped. This routine does not write rROMB0.
;
; Returns at once unless C is $52. Otherwise copies $52 bytes from HL
; (the snapshot SoundCountdown saved at $C8C9) back to $DFA6. C counts
; down to zero and is left at 0. DE is left at $DFF8.

RestoreCountdownBlock:
    ld a, $52
    cp c
    ret nz
    ld de, $DFA6

.copyByte:
    ld a, [hli]
    ld [de], a
    inc de
    dec c
    jr nz, .copyByte
    ret
