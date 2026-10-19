; DropCountdownGate calls this at $57B5 when bit 1 of a $DF09 flag
; is clear. A is that channel index, 0-3. ROM bank $30 stays mapped.
;
; The index is stored at $DF9C. The stream word at $DF7E + 2*A is
; cleared. $48DD then reloads the channel from the word at $DF86,
; and $4710 continues with C holding the index. HL and AF are restored.

ResetChannelStream:
    push af
    push hl
    ld [wSoundStreamIndex], a
    ld c, a
    ld b, $00
    sla c
    ld hl, wSoundStreamPointers
    add hl, bc
    xor a
    ld [hl+], a
    ld [hl], a
    call $48dd
    call $4710
    pop hl
    pop af
    ret
