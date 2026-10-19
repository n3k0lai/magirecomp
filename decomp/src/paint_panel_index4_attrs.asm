; Bank 4 at $682B. RunIndexedPanelRoutine calls this when [$C9B2] is 4,
; after mapping bank 4 and setting rVBK to 1. It is the index-4 copy of
; PaintPanelIndex0Attrs, $220 bytes later.
;
; Five runs of four BG-attribute bytes, columns 0-3 of map rows 0-4:
; $9800, $9820, $9840, $9860, and $9880. MaskBytes keeps the bits in $F8,
; which clears the palette. ClampAddedByte then adds [$C9B1] and stores
; $FF when that sum is not below $FF. LoadEntryGlyphSource writes the low
; three bits of an entry id to $C9B1, so those bits become the palette on
; this block.
;
; MaskBytes and ClampAddedByte are already source. wUnknownC9B1 is the
; name from load_entry_glyph.asm. rVBK is set by the caller.

; Four columns. Each run is one map row.
DEF PANEL4_ATTR_WIDTH EQU $0004

; Clear the three palette bits. The other attribute bits stay.
DEF PANEL4_ATTR_KEEP EQU $F8

; ClampAddedByte replaces a sum that is not below this.
DEF PANEL4_ATTR_CLAMP EQU $FF

PaintPanelIndex4Attrs::
    ld hl, $9800
    ld bc, PANEL4_ATTR_WIDTH
    ld a, PANEL4_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9820
    ld bc, PANEL4_ATTR_WIDTH
    ld a, PANEL4_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9840
    ld bc, PANEL4_ATTR_WIDTH
    ld a, PANEL4_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9860
    ld bc, PANEL4_ATTR_WIDTH
    ld a, PANEL4_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9880
    ld bc, PANEL4_ATTR_WIDTH
    ld a, PANEL4_ATTR_KEEP
    ld e, a
    call MaskBytes
    ld hl, $9800
    ld bc, PANEL4_ATTR_WIDTH
    ld d, PANEL4_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9820
    ld bc, PANEL4_ATTR_WIDTH
    ld d, PANEL4_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9840
    ld bc, PANEL4_ATTR_WIDTH
    ld d, PANEL4_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9860
    ld bc, PANEL4_ATTR_WIDTH
    ld d, PANEL4_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ld hl, $9880
    ld bc, PANEL4_ATTR_WIDTH
    ld d, PANEL4_ATTR_CLAMP
    ld a, [wUnknownC9B1]
    ld e, a
    call ClampAddedByte
    ret

PaintPanelIndex4AttrsEnd:
