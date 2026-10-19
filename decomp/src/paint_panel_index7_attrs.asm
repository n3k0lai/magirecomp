; Bank 4 at $69C3. RunIndexedPanelRoutine calls this when [$C9B2] is
; not 0 through 6, after mapping bank 4 and setting rVBK to 1. It is the
; index-7 copy of PaintPanelIndex0Attrs, $3B8 bytes later. Every other
; index uses this same block.
;
; Five runs of four BG-attribute bytes, columns $10-$13 of map rows 0-4:
; $9810, $9830, $9850, $9870, and $9890. MaskBytes keeps the bits in $F8,
; which clears the palette. ClampAddedByte then adds [$C9B1] and stores
; $FF when that sum is not below $FF. LoadEntryGlyphSource writes the low
; three bits of an entry id to $C9B1, so those bits become the palette on
; this block.
;
; MaskBytes and ClampAddedByte are already source. wUnknownC9B1 is the
; name from load_entry_glyph.asm. rVBK is set by the caller.

; Four columns. Each run is one map row.
DEF PANEL7_ATTR_WIDTH EQU $0004

; Clear the three palette bits. The other attribute bits stay.
DEF PANEL7_ATTR_KEEP EQU $F8

; ClampAddedByte replaces a sum that is not below this.
DEF PANEL7_ATTR_CLAMP EQU $FF

PaintPanelIndex7Attrs::
    ld hl, $9810
    ld bc, PANEL7_ATTR_WIDTH
    ld a, PANEL7_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9830
    ld bc, PANEL7_ATTR_WIDTH
    ld a, PANEL7_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9850
    ld bc, PANEL7_ATTR_WIDTH
    ld a, PANEL7_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9870
    ld bc, PANEL7_ATTR_WIDTH
    ld a, PANEL7_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9890
    ld bc, PANEL7_ATTR_WIDTH
    ld a, PANEL7_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9810
    ld bc, PANEL7_ATTR_WIDTH
    ld d, PANEL7_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9830
    ld bc, PANEL7_ATTR_WIDTH
    ld d, PANEL7_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9850
    ld bc, PANEL7_ATTR_WIDTH
    ld d, PANEL7_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9870
    ld bc, PANEL7_ATTR_WIDTH
    ld d, PANEL7_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9890
    ld bc, PANEL7_ATTR_WIDTH
    ld d, PANEL7_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ret

PaintPanelIndex7AttrsEnd:
