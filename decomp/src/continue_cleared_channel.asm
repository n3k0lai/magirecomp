; ResetChannelStream calls this at $4710 after the stream word is cleared.
; ROM bank $30 stays mapped. $DF9C holds the channel index. This copies
; that index into C and jumps to $505C, which clears bit 7 of $DF09+C
; and masks that channel out of rNR51.

ContinueClearedChannel:
    ld a, [$DF9C]
    ld c, a
    jp $505C
