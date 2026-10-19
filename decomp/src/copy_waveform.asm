; Copy 16 waveform bytes from HL into wave RAM.
;
; Channel 3's DAC at rNR30 is cleared first. Wave RAM ($FF30-$FF3F) is
; writable only while that DAC is off. C walks the low byte of each wave
; address. The last store leaves C at $3F, so it does not increment. The
; DAC is then set again with $80. What the caller does with HL afterward
; is outside this routine. rNR30 is defined in load_waveform.asm.

CopyWaveform::
    ld c, LOW($ff30)
    xor a
    ldh [rNR30], a
FOR N, 15
    ld a, [hl+]
    ldh [c], a
    inc c
ENDR
    ld a, [hl+]
    ldh [c], a
    ld a, $80
    ldh [rNR30], a
    ret
