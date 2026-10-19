; Bank 1 at $489D. ArmStripTextStep plants this as wCallback with bank 1.
; VRAM bank 0 is selected. CopyFifteenCellsHLToBC copies fifteen cells
; from HL to BC: columns 5-19 of window-map row 2 land on row 1, then
; the same columns of row 3 land on row 2. wCallback becomes
; IdleCallback. That address is in ROM0, so the bank byte is left alone.
;
; The rVBK store is the 3-byte form. rVBK and vWindowMap are the names
; from setup_window.asm. wCallback and IdleCallback are the names from
; default_state.asm. The span addresses are the names from the blank
; window callbacks. CopyFifteenCellsHLToBC is bank 1 at $46E1.

CopyWindowSpansUpOntoRow1::
    xor a
    ld [rVBK], a
    ld hl, vWindowSpanRow2
    ld bc, vWindowSpanRow1
    call CopyFifteenCellsHLToBC
    ld hl, vWindowSpanRow3
    ld bc, vWindowSpanRow2
    call CopyFifteenCellsHLToBC
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret

CopyWindowSpansUpOntoRow1End:
