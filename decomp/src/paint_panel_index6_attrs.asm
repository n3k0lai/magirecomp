; Bank 4 at $693B. RunIndexedPanelRoutine calls this when [$C9B2] is 6,
; after mapping bank 4 and setting rVBK to 1. It is the index-6 copy of
; PaintPanelIndex0Attrs, $330 bytes later.
;
; Five runs of four BG-attribute bytes, columns $0B-$0E of map rows 0-4:
; $980B, $982B, $984B, $986B, and $988B. MaskBytes keeps the bits in $F8,
; which clears the palette. ClampAddedByte then adds [$C9B1] and stores
; $FF when that sum is not below $FF. LoadEntryGlyphSource writes the low
; three bits of an entry id to $C9B1, so those bits become the palette on
; this block.
;
; MaskBytes and ClampAddedByte are already source. wUnknownC9B1 is the
; name from load_entry_glyph.asm. rVBK is set by the caller.

; Four columns. Each run is one map row.
DEF PANEL6_ATTR_WIDTH EQU $0004

; Clear the three palette bits. The other attribute bits stay.
DEF PANEL6_ATTR_KEEP EQU $F8

; ClampAddedByte replaces a sum that is not below this.
DEF PANEL6_ATTR_CLAMP EQU $FF

PaintPanelIndex6Attrs::
    ld hl, $980B
    ld bc, PANEL6_ATTR_WIDTH
    ld a, PANEL6_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $982B
    ld bc, PANEL6_ATTR_WIDTH
    ld a, PANEL6_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $984B
    ld bc, PANEL6_ATTR_WIDTH
    ld a, PANEL6_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $986B
    ld bc, PANEL6_ATTR_WIDTH
    ld a, PANEL6_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $988B
    ld bc, PANEL6_ATTR_WIDTH
    ld a, PANEL6_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $980B
    ld bc, PANEL6_ATTR_WIDTH
    ld d, PANEL6_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $982B
    ld bc, PANEL6_ATTR_WIDTH
    ld d, PANEL6_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $984B
    ld bc, PANEL6_ATTR_WIDTH
    ld d, PANEL6_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $986B
    ld bc, PANEL6_ATTR_WIDTH
    ld d, PANEL6_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $988B
    ld bc, PANEL6_ATTR_WIDTH
    ld d, PANEL6_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ret

PaintPanelIndex6AttrsEnd:
