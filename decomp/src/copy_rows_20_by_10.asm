; Copy $200 bytes from HL to BC as $20 rows of $10 bytes.
;
; HL is the source and BC is the destination. Both advance through the
; block. D and E are the row and column counters. A holds the last byte.
; CopyVRAMBank1Tiles uses this to move tiles $E0-$FF out of VRAM bank 1.

CopyRows20By10::
    ld d, $20
.row
    ld e, $10
.byte
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec e
    jr nz, .byte
    dec d
    jr nz, .row
    ret
