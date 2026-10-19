; SoundCommandTrampoline ($505B). RunSoundStream calls this with the
; looked-up command address in HL.

SoundCommandTrampoline:
    jp hl

; DropChannelOutput ($505C). The channel index is in C.
;
; Bit 7 of the flag at $DF09+C is cleared. NR51 ($FF25) is then ANDed
; with the byte at $5156+C, which is $EE, $DD, $BB, or $77. Those masks
; clear the left and right terminals of channels 0 through 3.
;
; A is 0 and B is 1 as this falls into WriteChannelEnvelope, so the
; envelope is replaced with silence and the channel is retriggered.

DEF rNR51 EQU $FF25

DropChannelOutput:
    ld b, $00
    ld hl, wChannelFlagBase
    add hl, bc
    res 7, [hl]
    ld hl, ChannelNr51ClearMask
    add hl, bc
    ldh a, [rNR51]
    and [hl]
    ldh [rNR51], a
    xor a
    ld b, $01
