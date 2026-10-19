; Bank 4's $6FAB. Called from $7016. [$C9E4], opcode $25's first operand,
; selects a little-endian word in the pointer table at $6F2B (still INCBIN).
; That word is returned in HL and stored at wEntryRecordField ($C9DE/$C9DF),
; the name from record_ptr_from_id.asm.

TableWordForC9E4::
    ld hl, RecordTripleSlotPtrs
    ld a, [$C9E4]
    ld d, $00
    ld e, a
    sla e
    rl d
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, l
    ld [$C9DE], a
    ld a, h
    ld [$C9DF], a
    ret
