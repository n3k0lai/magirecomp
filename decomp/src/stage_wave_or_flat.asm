; Map the wave bank, then stage a flat wave or a copied waveform.
;
; BC is preserved. The bank at $DF75 (wWaveWidth, named in
; update_wave_duty.asm) is mapped through MapRomBank. A record whose high
; nibble is $7 is a flat wave: the next byte is stored at $DF7D
; (wWaveSampleCopy), wave RAM is filled with sample pair $88, and the last
; $0E bytes of the 16-byte record are skipped. Any other record clears
; $DF7D and falls through to CopyWaveform, which copies all 16 bytes.
; The bank saved at $DF00 is mapped on the way out.
;
; FillWaveRam88 is an entry inside this routine. A is stored to rNR30
; first, so the path above arrives with the channel-3 DAC off. What jumps
; here from outside is still unknown. rNR30 is the channel-3 DAC register
; defined in load_waveform.asm, which is assembled after this file, so the
; stores below use the address $FF1A. $FF30 is wave RAM.
; MapRomBank and CopyWaveform are already source.

StageWaveOrFlat::
    push bc
    ld a, [$df75]
    call MapRomBank
    ld a, [hl]
    and $f0
    cp $70
    jr nz, StageWaveCopy
    inc hl
    ld a, [hl+]
    ld [$df7d], a
    xor a
; Entry with the value for rNR30 already in A.
FillWaveRam88::
    ldh [$ff1a], a
    ld a, $88
    ld c, $10
    push hl
    ld hl, $ff30
.flatByte
    ld [hl+], a
    dec c
    jr nz, .flatByte
    ld a, $80
    ldh [$ff1a], a
    ld bc, $000e
    pop hl
    add hl, bc
    jr StageWaveRestore

StageWaveCopy:
    xor a
    ld [$df7d], a
    call CopyWaveform

StageWaveRestore:
    ld a, [$df00]
    call MapRomBank
    pop bc
    ret
