; SoundActive calls this at $57A0 before it loads the sound index.
; ROM bank $30 stays mapped.
;
; Clears bit 7 of $DFA6, the gate StepSoundCountdowns tests. Then walks
; the four channel flags at $DF09. When bit 1 of a flag is clear, calls
; $57B5 with A as that channel index. $57B5 is still INCBIN.

DEF wActiveCountdownFlags EQU $DFA6
DEF wActiveChannelFlags EQU $DF09

DropCountdownGate:
    ld hl, wActiveCountdownFlags
    res 7, [hl]
    ld hl, wActiveChannelFlags
    xor a

.channel:
    bit 1, [hl]
    inc hl
    call z, $57b5
    inc a
    cp $04
    jr nz, .channel
    ret
