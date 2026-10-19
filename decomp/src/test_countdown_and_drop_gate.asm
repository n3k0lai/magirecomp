; SoundRequestBit1Dead calls this at $5798. The caller at $0739 maps
; ROM bank $30, then calls here. This routine does not write rROMB0.
;
; Tests bit 7 of $DFA6, the same flags DropCountdownGate clears. When
; that bit is clear, return and leave the gate as it was. When it is
; set, set bit 4 and fall into DropCountdownGate.

TestCountdownAndDropGate:
    ld hl, $dfa6
    bit 7, [hl]
    ret z
    set 4, [hl]
