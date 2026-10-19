; Copy the waveform at HL, then restore the saved ROM bank.
;
; BC is preserved. The bank at $DF75 (wWaveWidth, named in
; update_wave_duty.asm) is mapped through MapRomBank. CopyWaveform then
; writes the 16 bytes at HL into wave RAM and turns the channel-3 DAC
; back on. The bank saved at $DF00 is mapped on the way out, the same
; restore LoadWaveform uses.
;
; MapRomBank and CopyWaveform are already source.

CopyMappedWaveform::
    push bc
    ld a, [$df75]
    call MapRomBank
    call CopyWaveform
    ld a, [$df00]
    call MapRomBank
    pop bc
    ret
