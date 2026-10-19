; Bank 4 at $67A3. RunIndexedPanelRoutine calls this when [$C9B2] is 3,
; after mapping bank 4 and setting rVBK to 1. It is the index-3 copy of
; PaintPanelIndex0Attrs, $198 bytes later.
;
; Five runs of four BG-attribute bytes, columns 16-19 of map rows 7-11:
; $98F0, $9910, $9930, $9950, and $9970. MaskBytes keeps the bits in $F8,
; which clears the palette. ClampAddedByte then adds [$C9B1] and stores
; $FF when that sum is not below $FF. LoadEntryGlyphSource writes the low
; three bits of an entry id to $C9B1, so those bits become the palette on
; this block.
;
; MaskBytes and ClampAddedByte are already source. wUnknownC9B1 is the
; name from load_entry_glyph.asm. rVBK is set by the caller.

; Four columns. Each run is one map row.
DEF PANEL3_ATTR_WIDTH EQU $0004

; Clear the three palette bits. The other attribute bits stay.
DEF PANEL3_ATTR_KEEP EQU $F8

; ClampAddedByte replaces a sum that is not below this.
DEF PANEL3_ATTR_CLAMP EQU $FF

PaintPanelIndex3Attrs::
    ld hl, $98F0
    ld bc, PANEL3_ATTR_WIDTH
    ld a, PANEL3_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9910
    ld bc, PANEL3_ATTR_WIDTH
    ld a, PANEL3_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9930
    ld bc, PANEL3_ATTR_WIDTH
    ld a, PANEL3_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9950
    ld bc, PANEL3_ATTR_WIDTH
    ld a, PANEL3_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9970
    ld bc, PANEL3_ATTR_WIDTH
    ld a, PANEL3_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $98F0
    ld bc, PANEL3_ATTR_WIDTH
    ld d, PANEL3_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9910
    ld bc, PANEL3_ATTR_WIDTH
    ld d, PANEL3_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9930
    ld bc, PANEL3_ATTR_WIDTH
    ld d, PANEL3_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9950
    ld bc, PANEL3_ATTR_WIDTH
    ld d, PANEL3_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9970
    ld bc, PANEL3_ATTR_WIDTH
    ld d, PANEL3_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ret

PaintPanelIndex3AttrsEnd:
