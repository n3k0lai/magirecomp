; $599D calls this at $4F1A while it arms an upper countdown, and the
; stream reader at $4CED calls it when bit 1 of [$DF09 + channel] is
; clear. ROM bank $30 stays mapped. $4F15 (still INCBIN) joins the call
; below with D = 1 and B left as the caller set it.
;
; A is a tag. This entry forces B = 0 and D = 0, saves the incoming DE,
; and calls $4DFA. That call returns Z to leave the channel alone; this
; routine then returns Z with the saved DE restored.
;
; On NZ, C is the channel $4DFA left. Bit 1 of [$DF09 + C] is cleared
; and bit 5 is set, so the next sound tick rebuilds the period. Bit 5
; of [$DF0D + C] is set, so that tick also reloads the envelope. E is
; stored at [$DFF4 + C] for that reload. The word at [$DF15 + C * 2]
; becomes the saved D in the high byte and zero in the low byte (the
; store starts at the high byte). C is shifted back to the channel
; index. The return flags are rlca of that high byte.

DEF wTagSlideFlags EQU $DF09
DEF wTagChannelFlags EQU $DF0D
DEF wTagEnvelopeParam EQU $DFF4
DEF wTagPeriodBaseHigh EQU $DF16

PrimeChannelFromTag:
    push de
    ld b, $00
    ld d, b
    call $4dfa
    pop de
    ret z

    ld hl, wTagSlideFlags
    add hl, bc
    res 1, [hl]
    set 5, [hl]
    ld hl, wTagChannelFlags
    add hl, bc
    set 5, [hl]
    ld hl, wTagEnvelopeParam
    add hl, bc
    ld [hl], e
    ld hl, wTagPeriodBaseHigh
    sla c
    add hl, bc
    ld a, d
    ld [hl-], a
    ld [hl], $00
    srl c
    rlca
    ret

PrimeChannelFromTagEnd:
