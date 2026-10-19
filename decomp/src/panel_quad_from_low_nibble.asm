; Bank 7 at $47F8. RunPanelIndexThrough2EB6 calls this after it has
; saved the panel-row pointers from PanelRowFromHighNibble.
;
; A returns the low byte, and E the high byte, of four times one more than
; the low nibble of wUnknownC9D8. D is cleared before that shift and is not
; returned.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm.

PanelQuadFromLowNibble::
    ld a, [wUnknownC9D8]
    and $0F
    inc a
    ld d, $00
    ld e, a
    sla e
    rl d
    sla e
    rl d
    ld a, e
    ld e, d
    ret
