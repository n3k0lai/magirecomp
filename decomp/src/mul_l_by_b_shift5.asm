; A = (L * B) >> 5 when B is at least 2.
;
; L = 0, B = 0, and B = 1 each return A = 0 with Z set.
; H and D are cleared. E becomes L unless the L = 0 return
; is taken. Every other path counts B down to 0.
; The high and low pieces of the shift use different bits,
; so the final add does not carry. Z reflects A.
;
; A caller in bank $57 jumps to .count with carry set. That
; entry skips the setup and the first add: it decrements B,
; adds DE into HL once for each count that remains, then
; finishes with the same shift into A.

MulLByBShift5::
    ld h, $00
    ld d, h
    ld a, l
    and a
    ret z
    ld e, a
    ld a, b
    and a
    ret z
    dec b
    jr nz, .add
    xor a
    ret
.add:
    add hl, de
.count:
    dec b
    jr nz, .add
    sla h
    sla h
    sla h
    srl l
    srl l
    srl l
    srl l
    srl l
    ld a, h
    add l
    ret

MulLByBShift5End:
