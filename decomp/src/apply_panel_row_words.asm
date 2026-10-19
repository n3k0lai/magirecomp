; Bank 7 at $489D. DispatchNonzeroD016 calls this once per pass of the
; [$D016] = 3 frame loop, after FillPanelWordsFromC9DA and before $474F.
;
; $C831 is cleared. wEntryRecord ($C9DC) is copied to $C830; this routine
; does not read that copy. PanelRowFromHighNibble returns HL = $C72B plus
; eight times the high nibble of wUnknownC9D8. That pointer is saved in BC,
; and HL is moved $80 bytes past it. PanelQuadFromLowNibble returns the word
; count in A (four times one more than the low nibble). The count is stored
; at $C9D3.
;
; Each pass reads the little-endian word at BC into DE, calls $46E4 with
; BC = $0001, then steps both BC and the saved HL by two. $46E4 may clobber
; HL and BC; both are restored from the stack. The loop stops when the
; decremented count is zero. $C831 is set to $01 before the return.
;
; wEntryRecord is the name from record_ptr_from_id.asm. wUnknownC9D8 is the
; name from indexed_tail_07.asm. $C830, $C831, $C9D3, and $C72B are still
; unnamed. What $46E4 does with HL, DE, and BC = $0001 is still unknown.

ApplyPanelRowWords::
    xor a
    ld [$C831], a
    ld a, [wEntryRecord]
    ld [$C830], a
    call PanelRowFromHighNibble
    push hl
    ld bc, $0080
    add hl, bc
    pop bc
    call PanelQuadFromLowNibble
    ld [$C9D3], a
.word:
    push hl
    push bc
    ld a, [bc]
    inc bc
    ld e, a
    ld a, [bc]
    inc bc
    ld d, a
    ld bc, $0001
    call $46E4
    pop bc
    inc bc
    inc bc
    pop hl
    inc hl
    inc hl
    ld a, [$C9D3]
    dec a
    jr z, .done
    ld [$C9D3], a
    jr .word
.done:
    ld a, $01
    ld [$C831], a
    ret
