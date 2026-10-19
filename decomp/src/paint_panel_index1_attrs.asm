; Bank 4 at $6693. RunIndexedPanelRoutine calls this when [$C9B2] is 1,
; after mapping bank 4 and setting rVBK to 1. It is the index-1 copy of
; PaintPanelIndex0Attrs, $88 bytes later.
;
; Five runs of four BG-attribute bytes, columns 5-8 of map rows 6-10:
; $98C5, $98E5, $9905, $9925, and $9945. MaskBytes keeps the bits in $F8,
; which clears the palette. ClampAddedByte then adds [$C9B1] and stores
; $FF when that sum is not below $FF. LoadEntryGlyphSource writes the low
; three bits of an entry id to $C9B1, so those bits become the palette on
; this block.
;
; MaskBytes and ClampAddedByte are already source. wUnknownC9B1 is the
; name from load_entry_glyph.asm. rVBK is set by the caller.

; Four columns. Each run is one map row.
DEF PANEL1_ATTR_WIDTH EQU $0004

; Clear the three palette bits. The other attribute bits stay.
DEF PANEL1_ATTR_KEEP EQU $F8

; ClampAddedByte replaces a sum that is not below this.
DEF PANEL1_ATTR_CLAMP EQU $FF

PaintPanelIndex1Attrs::
    ld hl, $98C5
    ld bc, PANEL1_ATTR_WIDTH
    ld a, PANEL1_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $98E5
    ld bc, PANEL1_ATTR_WIDTH
    ld a, PANEL1_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9905
    ld bc, PANEL1_ATTR_WIDTH
    ld a, PANEL1_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9925
    ld bc, PANEL1_ATTR_WIDTH
    ld a, PANEL1_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9945
    ld bc, PANEL1_ATTR_WIDTH
    ld a, PANEL1_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $98C5
    ld bc, PANEL1_ATTR_WIDTH
    ld d, PANEL1_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $98E5
    ld bc, PANEL1_ATTR_WIDTH
    ld d, PANEL1_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9905
    ld bc, PANEL1_ATTR_WIDTH
    ld d, PANEL1_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9925
    ld bc, PANEL1_ATTR_WIDTH
    ld d, PANEL1_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9945
    ld bc, PANEL1_ATTR_WIDTH
    ld d, PANEL1_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ret
