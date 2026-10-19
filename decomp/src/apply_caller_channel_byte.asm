; OpenSlotChannel calls this at $4690 when its incoming C is not $FF.
; A holds that byte. ROM bank $30 stays mapped.
;
; The routine at $469A reads one operand through BC, then masks the
; channel into $DF11 and may update rNR51. This parks A on the stack,
; points BC at it, and restores AF before returning.

ApplyCallerChannelByte:
    push af
    ld hl, sp+1
    ld c, l
    ld b, h
    call $469A
    pop af
    ret
