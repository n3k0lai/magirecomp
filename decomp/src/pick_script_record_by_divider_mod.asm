; Script path at $1484. The caller is still INCBIN.
;
; BC addresses a count byte, then a table of 3-byte records. The count is
; loaded into L and BC moves to the first record. AddDividerStep updates
; hDividerAccum and returns it. The low nibble of that byte is reduced by
; L until it is smaller than L, which is the remainder of the nibble modulo
; the count. A count of zero never finishes that loop.
;
; The remainder is multiplied by three and added to BC, so BC lands on the
; chosen record. Control leaves through EnterScriptFromLookup, which reads
; a bank and a little-endian pointer from that record.
;
; AddDividerStep and hDividerAccum are the names from add_divider_step.asm.
; EnterScriptFromLookup is the name from enter_script_from_lookup.asm.

PickScriptRecordByDividerMod::
    ld a, [bc]
    inc bc
    ld l, a
    call AddDividerStep
    and $0f

.modLoop:
    cp l
    jr c, .indexed

    sub l
    jr .modLoop

.indexed:
    ld l, a
    add a
    add l
    ld l, a
    ld h, $00
    add hl, bc
    ld c, l
    ld b, h
    jp EnterScriptFromLookup
