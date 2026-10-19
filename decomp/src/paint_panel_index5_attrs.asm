; Bank 4 at $68B3. RunIndexedPanelRoutine calls this when [$C9B2] is 5,
; after mapping bank 4 and setting rVBK to 1. It is the index-5 copy of
; PaintPanelIndex0Attrs, $2A8 bytes later.
;
; Five runs of four BG-attribute bytes, columns 5-8 of map rows 0-4:
; $9805, $9825, $9845, $9865, and $9885. MaskBytes keeps the bits in $F8,
; which clears the palette. ClampAddedByte then adds [$C9B1] and stores
; $FF when that sum is not below $FF. LoadEntryGlyphSource writes the low
; three bits of an entry id to $C9B1, so those bits become the palette on
; this block.
;
; MaskBytes and ClampAddedByte are already source. wUnknownC9B1 is the
; name from load_entry_glyph.asm. rVBK is set by the caller.

; Four columns. Each run is one map row.
DEF PANEL5_ATTR_WIDTH EQU $0004

; Clear the three palette bits. The other attribute bits stay.
DEF PANEL5_ATTR_KEEP EQU $F8

; ClampAddedByte replaces a sum that is not below this.
DEF PANEL5_ATTR_CLAMP EQU $FF

PaintPanelIndex5Attrs::
    ld hl, $9805
    ld bc, PANEL5_ATTR_WIDTH
    ld a, PANEL5_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9825
    ld bc, PANEL5_ATTR_WIDTH
    ld a, PANEL5_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9845
    ld bc, PANEL5_ATTR_WIDTH
    ld a, PANEL5_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9865
    ld bc, PANEL5_ATTR_WIDTH
    ld a, PANEL5_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9885
    ld bc, PANEL5_ATTR_WIDTH
    ld a, PANEL5_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9805
    ld bc, PANEL5_ATTR_WIDTH
    ld d, PANEL5_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9825
    ld bc, PANEL5_ATTR_WIDTH
    ld d, PANEL5_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9845
    ld bc, PANEL5_ATTR_WIDTH
    ld d, PANEL5_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9865
    ld bc, PANEL5_ATTR_WIDTH
    ld d, PANEL5_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9885
    ld bc, PANEL5_ATTR_WIDTH
    ld d, PANEL5_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ret

PaintPanelIndex5AttrsEnd:
