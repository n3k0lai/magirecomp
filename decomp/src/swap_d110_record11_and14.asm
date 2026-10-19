; SwapD110Record11And14. Bank 2 at $5BA7.
;
; The byte at $D110+$000B (record+11) and the byte at $D110+$000E
; (record+14) are exchanged through B and C. SampleRecord11Contribution
; adds into record+11 and SampleRecord14Contribution adds into record+14,
; each capped at $63. Both pointers are pushed, then popped in reverse
; so the saved record+11 lands at record+14 and the saved record+14
; lands at record+11. No call or jump in the notes names this entry.
;
; D110_RECORD is the name from halve_d110_record_word7_min1.asm.
; RECORD_PLUS_11_BYTE and RECORD_PLUS_14_BYTE are the names from
; write_record11_two_digits.asm and write_record14_two_digits.asm.

SwapD110Record11And14::
    ld hl, D110_RECORD
    ld de, RECORD_PLUS_11_BYTE
    add hl, de
    push hl
    ld a, [hl]
    ld c, a
    ld hl, D110_RECORD
    ld de, RECORD_PLUS_14_BYTE
    add hl, de
    push hl
    ld a, [hl]
    ld b, a
    ld a, c
    pop hl
    ld [hl], a
    ld a, b
    pop hl
    ld [hl], a
    ret
