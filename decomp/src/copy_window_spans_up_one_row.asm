; Bank 1 at $487C. ArmStripSlideFollowup plants this as wCallback with
; bank 1. VRAM bank 0 is selected. $46E1 copies fifteen cells from HL to
; BC: columns 5-19 of window-map row 3 land on row 2, then the same
; columns of row 4 land on row 3. wCallback becomes IdleCallback. That
; address is in ROM0, so the bank byte is left alone.
;
; The rVBK store is the 3-byte form. rVBK and vWindowMap are the names
; from setup_window.asm. wCallback and IdleCallback are the names from
; default_state.asm. The span addresses are the names from the blank
; window callbacks. $46E1 is still INCBIN.

CopyWindowSpansUpOneRow::
    xor a
    ld [rVBK], a
    ld hl, vWindowSpanRow3
    ld bc, vWindowSpanRow2
    call CopyFifteenWindowCells
    ld hl, vWindowSpanRow4
    ld bc, vWindowSpanRow3
    call CopyFifteenWindowCells
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret

CopyWindowSpansUpOneRowEnd:
