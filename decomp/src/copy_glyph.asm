; Copy 16 bytes from the pointer at wGlyphSrc to the pointer at wGlyphDest.
;
; DrawCGBNotice calls this as CopyGlyph, once per glyph. The source and
; destination pointers advance by 16 and are written back. wGlyphVRAMBank
; is stored to rVBK with the 3-byte form before the copy, so the bytes can
; land in either VRAM bank. The notice path passes bank 1. On hardware
; where rVBK is unused, that store does not switch banks.
;
; BC is the destination. Each byte is loaded from HL and stored through BC.
; After the copy, the new source is written high byte first. The new
; destination is written low byte first. A is then IdleCallback's low byte.
;
; $2958 is the point after the bank byte is in A. $2999 stores IdleCallback
; at wCallback and returns. Both are inside this routine.
; wGlyphSrc, wGlyphDest, and wGlyphVRAMBank are the names from
; draw_cgb_notice.asm. rVBK is the name from setup_window.asm. IdleCallback
; and wCallback are the names from default_state.asm.

DEF GLYPH_LEN EQU 16

CopyGlyphBytes::
    ld hl, wGlyphDest
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, wGlyphSrc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [wGlyphVRAMBank]
; $2958. A is the VRAM bank.
.select_bank:
    ld [rVBK], a
    REPT GLYPH_LEN
    ld a, [hl+]
    ld [bc], a
    inc bc
    ENDR
    ld a, h
    ld [wGlyphSrc + 1], a
    ld a, l
    ld [wGlyphSrc], a
    ld hl, wGlyphDest
    ld a, c
    ld [hl+], a
    ld [hl], b
; $2999. Reinstall the idle callback.
.install_idle:
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
