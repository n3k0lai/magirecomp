; Sound command stored by SelectSoundCommand when $C924 is nonzero, bit 1
; of that byte is clear, and $C92A is zero. Timer overflow calls it with
; ROM bank $30 already mapped.
;
; $5759, still INCBIN in bank $30, returns 1 when the low nibble of $DFA6
; is nonzero or $DFD3 is nonzero, and returns 0 otherwise. A nonzero
; result skips the rest of this command. Zero is written to $C924.
;
; C is $52 and HL is $C8C9, the snapshot SoundCountdown filled from $DFA6.
; Bank $30 is stored to wCurrentROMBank and rROMB0, then $57EE (still
; INCBIN in that bank) copies those $52 bytes back to $DFA6 when C is $52.
; Bank $30 is stored again and LatchCountdownGate runs before the return.

SoundCountdownIdle::
    call $5759
    jr nz, .done
    ld [$C924], a
    ld c, $52
    ld hl, $C8C9
    ld a, $30
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $57EE
    ld a, $30
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call LatchCountdownGate
.done:
    ret
