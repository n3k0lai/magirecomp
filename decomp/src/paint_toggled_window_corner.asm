; Bank 1 at $4806. Opcode9BCountdownHandler stores this as wCallback
; with bank 1 when the $FFA6 count reaches zero.
;
; VRAM bank 0 is selected. HL is PointedByteWords plus wUnknownC6EC.
; SetupWindow clears that byte, and this routine keeps only bit 0, so
; the index is 0 or 1. Those are the two bytes of the word $BDA4 at
; PointedByteWords: tile $A4, then tile $BD. The chosen byte is the
; first tile id.
;
; Columns 0-4 of window-map rows 0-4 receive 25 consecutive ids. Each
; of the first four rows is five ld [hl+], a stores with A incremented
; after every store. HL then advances by $1B, one row on the 32-wide
; map, so the next row starts in column 0. The last cell is ld [hl], a
; and A is not incremented after it.
;
; wUnknownC6EC is incremented and masked to bit 0, so the next visit
; uses the other byte. wCallback becomes IdleCallback. That address is
; in ROM0, so the bank byte is left alone.
;
; The rVBK store is the 3-byte form. rVBK, vWindowMap, and
; wUnknownC6EC are the names from setup_window.asm. PointedByteWords
; is the name from format_pointed_sram_byte.asm. WINDOW_ROW_AFTER_FIVE
; is the name from blank_window_corner_block.asm. wCallback and
; IdleCallback are the names from default_state.asm.

PaintToggledWindowCorner::
    xor a
    ld [rVBK], a
    ld hl, PointedByteWords
    ld a, [wUnknownC6EC]
    ld c, a
    xor a
    ld b, a
    add hl, bc
    ld a, [hl]
    ld bc, WINDOW_ROW_AFTER_FIVE
    ld hl, vWindowMap
    REPT 4
        ld [hl+], a
        inc a
        ld [hl+], a
        inc a
        ld [hl+], a
        inc a
        ld [hl+], a
        inc a
        ld [hl+], a
        inc a
        add hl, bc
    ENDR
    ld [hl+], a
    inc a
    ld [hl+], a
    inc a
    ld [hl+], a
    inc a
    ld [hl+], a
    inc a
    ld [hl], a
    ld a, [wUnknownC6EC]
    inc a
    and $01
    ld [wUnknownC6EC], a
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
