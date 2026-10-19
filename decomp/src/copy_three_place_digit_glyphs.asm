; Bank 5 at $4430. FinishD073Slot7058 calls this after the $7058 slot
; record, while ROM bank 5 is mapped.
;
; $C92F, $C92E, and $C92D are the hundreds, tens, and ones places. Those
; addresses are wDigitHigh, wDigitMid, and wDigitLow in
; write_digit_tiles.asm, which is included later. $D0CC starts clear. A zero place while that latch
; is clear selects glyph 0 at $5000. The first nonzero place is stored in
; the latch. After that, every place uses its value plus one, including a
; zero. The index is shifted left four times, so each step is one 16-byte
; glyph, and added to $5000.
;
; The first pass stores that pointer at wGlyphSrc, stores $8FD0 at
; wGlyphDest, and stores 1 at wGlyphVRAMBank. The tens and ones passes
; load $8FD0 into BC and do not write it, so the destination and VRAM bank
; stay as the first pass left them. Each pass plants CopyGlyphInBank6 at
; wCallback and calls FinishFrame. That routine maps ROM bank 6 and copies
; the 16 bytes. wCallbackBank is left alone.
;
; wGlyphSrc, wGlyphDest, and wGlyphVRAMBank are the names from
; draw_cgb_notice.asm. wCallback is the name from default_state.asm.
; CopyGlyphInBank6 and FinishFrame are already source.

DEF wDigitPlaceLatch EQU $D0CC
DEF PLACE_GLYPH_BASE EQU $5000
DEF PLACE_GLYPH_DEST EQU $8FD0
DEF PLACE_GLYPH_VRAM_BANK EQU $01

CopyThreePlaceDigitGlyphs::
    xor a
    ld [wDigitPlaceLatch], a
    ld a, [$C92F]
    and a
    jr z, .hundredsBlank
    ld [wDigitPlaceLatch], a
    add $01
    ld c, a
    ld b, $00
    jr .hundredsShift
.hundredsBlank:
    ld bc, $0000
.hundredsShift:
    ld a, $04
.hundredsMul:
    sla c
    rl b
    dec a
    jr nz, .hundredsMul
    ld hl, PLACE_GLYPH_BASE
    add hl, bc
    ld a, h
    ld [wGlyphSrc + 1], a
    ld a, l
    ld [wGlyphSrc], a
    ld bc, PLACE_GLYPH_DEST
    ld hl, wGlyphDest
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, PLACE_GLYPH_VRAM_BANK
    ld [wGlyphVRAMBank], a
    ld a, LOW(CopyGlyphInBank6)
    ld [wCallback], a
    ld a, HIGH(CopyGlyphInBank6)
    ld [wCallback + 1], a
    call FinishFrame
    ld a, [wDigitPlaceLatch]
    and a
    ld a, [$C92E]
    jr nz, .tensIndex
    and a
    jr z, .tensBlank
    ld [wDigitPlaceLatch], a
.tensIndex:
    add $01
    ld c, a
    ld b, $00
    jr .tensShift
.tensBlank:
    ld bc, $0000
.tensShift:
    ld a, $04
.tensMul:
    sla c
    rl b
    dec a
    jr nz, .tensMul
    ld hl, PLACE_GLYPH_BASE
    add hl, bc
    ld a, h
    ld [wGlyphSrc + 1], a
    ld a, l
    ld [wGlyphSrc], a
; Loaded and not stored. wGlyphDest stays $8FD0.
    ld bc, PLACE_GLYPH_DEST
    ld a, LOW(CopyGlyphInBank6)
    ld [wCallback], a
    ld a, HIGH(CopyGlyphInBank6)
    ld [wCallback + 1], a
    call FinishFrame
    ld a, [wDigitPlaceLatch]
    and a
    ld a, [$C92D]
    jr nz, .onesIndex
    and a
    jr z, .onesBlank
    ld [wDigitPlaceLatch], a
.onesIndex:
    add $01
    ld c, a
    ld b, $00
    jr .onesShift
.onesBlank:
    ld bc, $0000
.onesShift:
    ld a, $04
.onesMul:
    sla c
    rl b
    dec a
    jr nz, .onesMul
    ld hl, PLACE_GLYPH_BASE
    add hl, bc
    ld a, h
    ld [wGlyphSrc + 1], a
    ld a, l
    ld [wGlyphSrc], a
; Loaded and not stored. wGlyphDest stays $8FD0.
    ld bc, PLACE_GLYPH_DEST
    ld a, LOW(CopyGlyphInBank6)
    ld [wCallback], a
    ld a, HIGH(CopyGlyphInBank6)
    ld [wCallback + 1], a
    call FinishFrame
    ret
