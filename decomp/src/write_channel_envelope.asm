; WriteChannelEnvelope ($5070). UpdateSound reaches this with bank $30
; still mapped. Callers pass the channel in C and the level in A.
; B bit 0 is used only for channels other than the wave channel.
;
; Channel 2 is wave. Bits 3-2 of A select the output level. The whole
; value is saved at $DF31. If those two bits already match the saved
; value, or if bit 0 of $DF74 is set, this returns without writing NR32.
; Otherwise bits 6-5 of NR32 ($FF1C) are replaced from the four-byte
; table at $50E2, indexed by A >> 2, and the channel is retriggered.
;
; Channels 0, 1, and 3 store A at $DF2F + C. The envelope port is the
; byte at $50DA + C ($FF12, $FF17, $FF1C, $FF21). When B bit 0 is clear,
; that port keeps its low nibble and takes the low nibble of A as its
; high nibble. When B bit 0 is set, the port is replaced with A swapped.
; The trigger port is the byte at $50DE + C ($FF14, $FF19, $FF1E, $FF23).
; Channels 0 and 1 write $80 combined with the byte at $DF12 + C.
; Channel 3 writes $80 by itself.

DEF wChannelLevels EQU $DF2F
DEF wChannelFreqHigh EQU $DF12
DEF wSoundFlags EQU $DF74

WriteChannelEnvelope:
    ld e, a
    ld a, c
    cp $02
    ld a, e
    jr z, .wave

    ld d, $00
    ld e, c
    ld hl, wChannelLevels
    add hl, de
    ld [hl], a
    ld c, a
    ld hl, unk_0C10DA
    add hl, de
    bit 0, b
    ld b, c
    ld c, [hl]
    jr nz, .replace_envelope

    ldh a, [c]
    and $0F
    swap b
    or b
    ldh [c], a
    jr .trigger

.replace_envelope:
    ld a, b
    swap a
    ldh [c], a

.trigger:
    ld hl, unk_0C10DE
    add hl, de
    ld c, [hl]
    ld hl, wChannelFreqHigh
    add hl, de
    ld a, e
    cp $03
    jr z, .trigger_noise

    ld a, $80
    or [hl]
    ldh [c], a
    ret

.trigger_noise:
    ld a, $80
    ldh [c], a
    ret

.wave:
    and $0C
    ld d, a
    ld a, [wChannelLevels + 2]
    and $0C
    cp d
    ld a, e
    ld [wChannelLevels + 2], a
    ret z

    ld e, c
    ld c, a
    ld d, $00
    ld a, [wSoundFlags]
    bit 0, a
    ret nz

    ld b, $00
    srl c
    srl c
    ld hl, unk_0C10E2
    add hl, bc
    ld b, [hl]
    ldh a, [$FF1C]
    and $9F
    or b
    ldh [$FF1C], a
    jr .trigger
