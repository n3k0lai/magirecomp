; Bank 1 at $4A3E. Returns while the third script pointer's high byte
; ($C716, wThirdScriptRecord + 2) is still nonzero, and again when the
; bank-21 list count at $C999 is zero.
;
; Otherwise A becomes [$C9A0] + $C0, which is [$C9A0] - $40 in 8 bits.
; That index is compared with the count. Carrying out (index >= count)
; returns. A live index is multiplied by four, the size of one list
; entry, and added to the list pointer saved at $C99A/$C99B. HL then
; steps past the entry's leading byte and ReadBank21ScriptHead copies
; the bank and little-endian pointer into wThirdScriptRecord. The
; handler there becomes INITIAL_SCRIPT_HANDLER ($0A66). Both handler
; stores are the 3-byte form. $C999, $C99A, and $C9A0 have no names yet.
;
; wThirdScriptRecord is the name from setup_command_4d.asm.
; ReadBank21ScriptHead is the routine at $0A1D.
; INITIAL_SCRIPT_HANDLER is the name from reset.asm.

StageThirdScriptFromListIndex::
    ld a, [wThirdScriptRecord + 2]
    and a
    ret nz
    ld a, [$c999]
    and a
    ret z
    ld e, a
    ld a, [$c9a0]
    add $C0
    cp e
    ret nc
    add a
    add a
    ld e, a
    ld d, $00
    ld hl, $c99a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    inc hl
    call ReadBank21ScriptHead
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [wThirdScriptRecord + 3], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [wThirdScriptRecord + 4], a
    ret
