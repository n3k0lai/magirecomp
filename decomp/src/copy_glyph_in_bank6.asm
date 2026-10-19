; Save the ROM bank, map bank 6, copy one glyph, and restore the bank.
;
; CopyGlyphBytes reads wGlyphSrc, wGlyphDest, and wGlyphVRAMBank, then
; copies 16 bytes. Those glyph bytes live in ROM bank 6. $390E is the
; call after that bank is mapped; the previous bank is already on the
; stack. wCurrentROMBank and rROMB0 are the names from reset.asm.

DEF GLYPH_ROM_BANK EQU $06

CopyGlyphInBank6::
    ld a, [wCurrentROMBank]
    push af
    ld a, GLYPH_ROM_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a

; $390E
.call:
    call CopyGlyphBytes
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
