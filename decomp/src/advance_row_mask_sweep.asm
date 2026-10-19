; Bank 4 at $6A82. This routine does not write rROMB0.
;
; $C9FB is a pass count. Zero means the sweep is finished, so return.
; Otherwise increment the index at $C9F9. $C9FA is the index limit.
; While the new index is still under that limit, call ApplyIndexedRowMask
; and return. That routine reads $C9F8, the pointer table at $C9F4, and
; the index, and it lives at $6A5E in this bank.
;
; When the index reaches the limit, decrement the pass count, store $FF
; back into the index, and add $10 to the VRAM word at $C9F6. A high byte
; of $98 is stored as $90, so the pointer stays in $9000-$97FF. The mask
; routine is not called on that step.

; Index stored at $C9F9 after one pass reaches $C9FA.
DEF SWEEP_INDEX_RESET EQU $FF

; Bytes added to the word at $C9F6. One 2bpp tile.
DEF SWEEP_VRAM_STRIDE EQU $10

; High byte just past the $9000 tile bank, and the high byte it wraps to.
DEF SWEEP_VRAM_PAST EQU $98
DEF SWEEP_VRAM_BASE EQU $90

AdvanceRowMaskSweep::
    ld a, [$C9FB]
    and a
    ret z
    ld a, [$C9F9]
    inc a
    ld [$C9F9], a
    ld a, [$C9FA]
    ld l, a
    ld a, [$C9F9]
    cp l
    jr nz, .apply
    ld a, [$C9FB]
    dec a
    ld [$C9FB], a
    ld a, SWEEP_INDEX_RESET
    ld [$C9F9], a
    ld a, [$C9F6]
    add a, SWEEP_VRAM_STRIDE
    ld [$C9F6], a
    ld a, [$C9F7]
    adc a, $00
    cp SWEEP_VRAM_PAST
    jr nz, .store_high
    ld a, SWEEP_VRAM_BASE
.store_high:
    ld [$C9F7], a
    ret
.apply:
    call ApplyIndexedRowMask
    ret
