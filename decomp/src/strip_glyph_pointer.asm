; Bank 0 at $2BC8. StepMapStripGlyph calls this with the strip character
; in E. Callers know the address as StripGlyphPointer.
;
; After SWAP, the low nibble of E is a 16-byte slot and the high nibble
; is a $100-byte row. Those select a glyph in the bank-6 table at $4000.
; The pointer is stored at wGlyphSrc and wCallbackBank is set to 6.
; $2BCD continues from the shifted slot in A. $2BDA stores the low byte
; of that pointer and the bank. Who enters at those two addresses is
; still unknown.
;
; wGlyphSrc is the name from draw_cgb_notice.asm. wCallbackBank is the
; name from default_state.asm.

LoadStripGlyphPointer::
    swap e
    ld a, e
    and $f0

.rowAndSlot:
    ld c, a
    ld a, e
    and $0f
    ld b, a
    ld hl, $4000
    add hl, bc
    ld a, h
    ld [wGlyphSrc + 1], a

.storeLowAndBank:
    ld a, l
    ld [wGlyphSrc], a
    ld a, $06
    ld [wCallbackBank], a
    ret
