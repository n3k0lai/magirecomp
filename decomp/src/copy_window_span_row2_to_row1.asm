; Bank 1 at $4864. RunSavedStripText plants this as wCallback with bank 1
; when the strip countdown at $C6ED reaches zero.
;
; VRAM bank 0 is selected. $46E1 copies fifteen cells from HL to BC:
; columns 5-19 of window-map row 2 land on the same columns of row 1.
; wCallback becomes IdleCallback. That address is in ROM0, so the bank
; byte is left alone.
;
; The rVBK store is the 3-byte form. rVBK and vWindowMap are the names
; from setup_window.asm. wCallback and IdleCallback are the names from
; default_state.asm. vWindowSpanRow1 and vWindowSpanRow2 are the spans
; named in the blank-window callbacks. $46E1 is still INCBIN.

; Copies fifteen bytes from [hl+] to [bc], incrementing BC, then returns.
DEF CopyFifteenWindowCells EQU $46E1

CopyWindowSpanRow2ToRow1::
    xor a
    ld [rVBK], a
    ld hl, vWindowSpanRow2
    ld bc, vWindowSpanRow1
    call CopyFifteenWindowCells
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
