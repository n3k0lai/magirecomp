; MapPairBankThenCopyTwelveWordPairs. Bank 0 at $35F1.
;
; Saves the current ROM bank. $C9D9 selects the copy. When it is zero,
; the bank at $C9D7 is mapped and CopyTwelveWordPairsThenWriteC9E5
; ($358E) runs with BC loaded from the word at $C9D5. When $C9D9 is
; nonzero, the same bank and pointer feed
; CopyTwelveWordPairsAtIndex0CThenWriteC9E5 ($35AD) instead. The saved
; bank is mapped again before the return.
;
; Both paths contain `ld a, a` ($7F) after the load from $C9D7. A is
; already that bank. $C9D5 is the pointer load_c9_record_picture.asm
; calls wPairSourcePtr. $C9D7 is the bank beside it. $C9D9 is
; wPanelSlot in stage_panel_glyph_dest.asm. Those names are not used
; here. wCurrentROMBank and rROMB0 are the names from reset.asm.

MapPairBankThenCopyTwelveWordPairs::
    ld a, [wCurrentROMBank]
    push af
    ld a, [$C9D9]
    and a
    jr nz, .index0C

    ld a, [$C9D7]
    ld a, a
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [$C9D6]
    ld b, a
    ld a, [$C9D5]
    ld c, a
    call CopyTwelveWordPairsThenWriteC9E5
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret

.index0C
    ld a, [$C9D7]
    ld a, a
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [$C9D6]
    ld b, a
    ld a, [$C9D5]
    ld c, a
    call CopyTwelveWordPairsAtIndex0CThenWriteC9E5
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
