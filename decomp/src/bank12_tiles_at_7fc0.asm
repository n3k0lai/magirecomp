; Bank 12 at $7FC0 (file $033FC0). Continues the 8x8 GBC 2bpp tiles
; aligned to $4000. A row is stored low plane, then high plane; the
; pixel color is the low bit plus twice the high bit, and bit 7 is the
; leftmost pixel. What these tiles draw is still unknown. Sixty-four
; bytes cover the tiles at $7FC0, $7FD0, $7FE0, and $7FF0. Every plane
; byte is zero, so each tile is blank (pixels 00000000). This is the
; end of bank 12.

Bank12TilesAt7FC0::
    ds 16, $00                     ; tile at $7FC0: eight rows, low $00, high $00, pixels 00000000
    ds 16, $00                     ; tile at $7FD0: eight rows, low $00, high $00, pixels 00000000
    ds 16, $00                     ; tile at $7FE0: eight rows, low $00, high $00, pixels 00000000
    ds 16, $00                     ; tile at $7FF0: eight rows, low $00, high $00, pixels 00000000
