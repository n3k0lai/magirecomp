; Bank 4 at $671B. RunIndexedPanelRoutine calls this when [$C9B2] is 2,
; after mapping bank 4 and setting rVBK to 1. It is the index-2 copy of
; PaintPanelIndex0Attrs, $110 bytes later.
;
; Five runs of four BG-attribute bytes, columns 11-14 of map rows 6-10:
; $98CB, $98EB, $990B, $992B, and $994B. MaskBytes keeps the bits in $F8,
; which clears the palette. ClampAddedByte then adds [$C9B1] and stores
; $FF when that sum is not below $FF. LoadEntryGlyphSource writes the low
; three bits of an entry id to $C9B1, so those bits become the palette on
; this block.
;
; MaskBytes and ClampAddedByte are already source. wUnknownC9B1 is the
; name from load_entry_glyph.asm. rVBK is set by the caller.

; Four columns. Each run is one map row.
DEF PANEL2_ATTR_WIDTH EQU $0004

; Clear the three palette bits. The other attribute bits stay.
DEF PANEL2_ATTR_KEEP EQU $F8

; ClampAddedByte replaces a sum that is not below this.
DEF PANEL2_ATTR_CLAMP EQU $FF

PaintPanelIndex2Attrs::
    ld hl, $98CB
    ld bc, PANEL2_ATTR_WIDTH
    ld a, PANEL2_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $98EB
    ld bc, PANEL2_ATTR_WIDTH
    ld a, PANEL2_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $990B
    ld bc, PANEL2_ATTR_WIDTH
    ld a, PANEL2_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $992B
    ld bc, PANEL2_ATTR_WIDTH
    ld a, PANEL2_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $994B
    ld bc, PANEL2_ATTR_WIDTH
    ld a, PANEL2_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $98CB
    ld bc, PANEL2_ATTR_WIDTH
    ld d, PANEL2_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $98EB
    ld bc, PANEL2_ATTR_WIDTH
    ld d, PANEL2_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $990B
    ld bc, PANEL2_ATTR_WIDTH
    ld d, PANEL2_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $992B
    ld bc, PANEL2_ATTR_WIDTH
    ld d, PANEL2_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $994B
    ld bc, PANEL2_ATTR_WIDTH
    ld d, PANEL2_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ret

PaintPanelIndex2AttrsEnd:
