; Pack A with E and read one nibble from the table at $564B.
;
; Callers pass a 4-bit channel parameter in A and a level in E (often
; [$DF70 + channel]). swap/or builds one byte, its low bit picks the
; high or low nibble, and the shifted value indexes the table. A returns
; that nibble. The table itself is still INCBIN.

LookupChannelNibble:
    swap a
    or e
    srl a
    ld e, a
    ld d, $00
    ld hl, ChannelNibbleTable
    jr c, .low_nibble

    add hl, de
    ld a, [hl]
    swap a
    and $0f
    ret

.low_nibble:
    add hl, de
    ld a, [hl]
    and $0f
    ret
