; Bank 7 at $4850. DispatchNonzeroD016 calls this once on the
; [$D016] = 3 path, after storing $0F at wUnknownC9D8 and $7FFF at
; wUnknownC9DA.
;
; $C831 is cleared. PanelRowFromHighNibble returns HL = $C72B plus eight
; times the high nibble of wUnknownC9D8. PanelQuadFromLowNibble returns the
; low byte of four times one more than the low nibble in A; that byte is the
; word count. BC is the little-endian word at wUnknownC9DA. Each pass writes
; that word at HL and steps HL by two. $C831 is set to $01 before the return.
;
; The still-included routine at $4837 jumps to .storeWord after pointing HL
; $80 bytes past the same row and loading the same count and word.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. wUnknownC9DA and
; wUnknownC9DB are the names from dispatch_nonzero_d016.asm. $C831 and
; $C72B are still unnamed.

FillPanelWordsFromC9DA::
    xor a
    ld [$C831], a
    call PanelRowFromHighNibble
    call PanelQuadFromLowNibble
    ld e, a
    ld a, [wUnknownC9DB]
    ld b, a
    ld a, [wUnknownC9DA]
    ld c, a
.storeWord:
    ld a, c
    ld [hl+], a
    ld [hl], b
    inc hl
    dec e
    jr nz, .storeWord
    ld a, $01
    ld [$C831], a
    ret
