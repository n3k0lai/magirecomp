; Bank 4 at $6A5E. StepRowMaskVram calls here while $C9F9 is still
; under the $C9FA limit. This routine does not write rROMB0.
;
; $C9F8 is copied to rVBK with the 3-byte store. The word at $C9F4 is
; a table of pointers. $C9F9 is the index; it is doubled and added to
; that word. HL is then the pointer stored at that slot. $6A4B, still
; INCBIN, is called twice. D is left at 0, so each call reads an offset
; and a mask from HL, adds the offset to the VRAM word at $C9F6, and
; ANDs the mask into that byte.
;
; HL, BC, and DE are saved and restored. rVBK is the name from
; setup_window.asm.

ApplyIndexedRowMask::
    push hl
    push bc
    push de
    ld a, [$C9F8]
    ld [rVBK], a
    ld hl, $C9F4
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [$C9F9]
    add a
    ld d, $00
    ld e, a
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call ApplyOffsetMaskToVramByte
    call ApplyOffsetMaskToVramByte
    pop de
    pop bc
    pop hl
    ret
