; Bank 7 at $4774. WritePanelWordThenZero calls this twice with A = 1.
;
; HL is a table base, E is a slot, A is the write count, and BC is a word.
; The first store is at HL + 2*E. Each remaining count writes that same
; word eight bytes later. $C72B is still unnamed.

WriteWordAtTwiceEStride8::
    ld d, $00
    sla e
    add hl, de
    ld de, $0008
.stride:
    push af
    ld a, c
    ld [hl+], a
    ld [hl], b
    dec hl
    add hl, de
    pop af
    dec a
    jr nz, .stride
    ret
