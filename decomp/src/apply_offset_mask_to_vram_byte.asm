; Bank 4 at $6A4B. ApplyIndexedRowMask calls this twice and does not
; change the bank. This routine does not write rROMB0.
;
; HL points at one offset byte followed by one mask byte. The offset
; is loaded into E. D is left as the caller set it; ApplyIndexedRowMask
; leaves D at 0, so DE is that offset. The word at $C9F6 is a VRAM
; address. DE is added to it, and the mask is ANDed into that byte.
; HL is restored, then advanced past the pair.

ApplyOffsetMaskToVramByte::
    ld e, [hl]
    inc hl
    push hl
    ld hl, $C9F6
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld b, h
    ld c, l
    pop hl
    ld e, [hl]
    ld a, [bc]
    and e
    ld [bc], a
    inc hl
    ret
