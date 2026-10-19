; SoundCountdown calls this at $57E0 with C = $52 and HL = $C8C9.
; ROM bank $30 is already mapped. This routine does not write rROMB0.
;
; Returns at once unless C is $52. Otherwise copies $52 bytes from
; $DFA6 (the countdown flags through the byte before $DFF9) to HL.
; C counts down to zero and is left at 0.

CopyCountdownBlock:
    ld a, $52
    cp c
    ret nz
    ld de, $dfa6

.copyByte:
    ld a, [de]
    inc de
    ld [hli], a
    dec c
    jr nz, .copyByte
    ret
