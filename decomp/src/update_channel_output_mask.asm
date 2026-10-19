; ApplyCallerChannelByte calls this at $469A. BC points at one operand
; byte, and ROM bank $30 stays mapped. $DF9C is the channel index.
;
; $46DA, indexed by that channel, holds $EE, $DD, $BB, or $77. ANDing
; $DF11 with that byte clears both output terminals of the channel.
; The operand is added to three times the channel and indexes $46DE;
; that byte is ORed back into $DF11.
;
; When bit 7 of $DF09+channel is set, NR51 ($FF25) receives the same
; AND and OR. B still holds the clear mask and C the enable byte.
; The word at $DF9A is then incremented.

UpdateChannelOutputMask:
    ld a, [$df9c]
    ld e, a
    ld d, $00
    ld hl, unk_0C06DA
    add hl, de
    ld a, [hl]
    ld d, a
    ld hl, $df11
    ld a, [hl]
    and d
    ld [hl], a
    push hl
    ld a, [bc]
    ld c, a
    ld b, d
    ld a, e
    add a
    add e
    add c
    ld e, a
    ld d, $00
    ld hl, unk_0C06DE
    add hl, de
    ld a, [hl]
    ld c, a
    pop hl
    or [hl]
    ld [hl], a
    ld a, [$df9c]
    ld e, a
    ld hl, $df09
    add hl, de
    bit 7, [hl]
    jr z, .bump_cursor

    ldh a, [$ff25]
    and b
    or c
    ldh [$ff25], a

.bump_cursor:
    ld hl, $df9a
    inc [hl]
    ret nz

    inc hl
    inc [hl]
    ret
