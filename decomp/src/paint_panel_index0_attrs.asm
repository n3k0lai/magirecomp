; Bank 4 at $660B. RunIndexedPanelRoutine calls this when [$C9B2] is 0,
; after mapping bank 4 and setting rVBK to 1. The next six panel indexes
; are the same shape, each $88 bytes later, and stay INCBIN.
;
; Five runs of four BG-attribute bytes, columns 0-3 of map rows 7-11:
; $98E0, $9900, $9920, $9940, and $9960. MaskBytes keeps the bits in $F8,
; which clears the palette. ClampAddedByte then adds [$C9B1] and stores
; $FF when that sum is not below $FF. LoadEntryGlyphSource writes the low
; three bits of an entry id to $C9B1, so those bits become the palette on
; this block.
;
; MaskBytes and ClampAddedByte are already source. wUnknownC9B1 is the
; name from load_entry_glyph.asm. rVBK is set by the caller.

; Four columns. Each run is one map row.
DEF PANEL0_ATTR_WIDTH EQU $0004

; Clear the three palette bits. The other attribute bits stay.
DEF PANEL0_ATTR_KEEP EQU $F8

; ClampAddedByte replaces a sum that is not below this.
DEF PANEL0_ATTR_CLAMP EQU $FF

PaintPanelIndex0Attrs::
    ld hl, $98E0
    ld bc, PANEL0_ATTR_WIDTH
    ld a, PANEL0_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9900
    ld bc, PANEL0_ATTR_WIDTH
    ld a, PANEL0_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9920
    ld bc, PANEL0_ATTR_WIDTH
    ld a, PANEL0_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9940
    ld bc, PANEL0_ATTR_WIDTH
    ld a, PANEL0_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9960
    ld bc, PANEL0_ATTR_WIDTH
    ld a, PANEL0_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $98E0
    ld bc, PANEL0_ATTR_WIDTH
    ld d, PANEL0_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9900
    ld bc, PANEL0_ATTR_WIDTH
    ld d, PANEL0_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9920
    ld bc, PANEL0_ATTR_WIDTH
    ld d, PANEL0_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9940
    ld bc, PANEL0_ATTR_WIDTH
    ld d, PANEL0_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9960
    ld bc, PANEL0_ATTR_WIDTH
    ld d, PANEL0_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ret
